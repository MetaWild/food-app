import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../components/meal_review_dialog.dart';

class CapturePage extends StatefulWidget {
  const CapturePage({super.key});

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final rearCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first);

    _controller = CameraController(rearCamera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureAndSend() async {
    if (_controller == null) return;

    setState(() => _loading = true);

    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      final bytes = await File(image.path).readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      final analyzeRes = await http.post(
        Uri.parse('https://food-app-zpft.onrender.com/analyze-image'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      );

      if (analyzeRes.statusCode != 200) {
        throw Exception("Image analysis failed.");
      }

      final mealData = jsonDecode(analyzeRes.body);
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user!.getIdToken();
      final today = DateTime.now().toIso8601String().split("T")[0];
      mealData['date'] = today;
      mealData['image'] = base64Image;

      final updatedMeal = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (_) => MealReviewDialog(
          meal: mealData,
          imageBase64: base64Image,
        ),
      );

      if (updatedMeal != null) {
        final mealToSave = {
          ...mealData,      
          ...updatedMeal, 
        };
        final saveRes = await http.post(
          Uri.parse('https://food-app-zpft.onrender.com/save-meal'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'userId': user.uid,
            'meal': {
              ...mealToSave,
              'image': base64Image,
           },
          }),
        );

        if (saveRes.statusCode != 200) {
          throw Exception("Failed to save meal.");
        }

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/');
      } else {
        debugPrint("User cancelled meal save.");
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Capture failed: ${e.toString()}")));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller!.value.previewSize!.height,
                        height: _controller!.value.previewSize!.width,
                        child: CameraPreview(_controller!),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: _loading ? null : _captureAndSend,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child:
                            Text(_loading ? 'Analyzing...' : 'Capture'),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
