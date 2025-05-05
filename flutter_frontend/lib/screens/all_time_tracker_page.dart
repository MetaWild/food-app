import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String formatDouble(dynamic value) {
  if (value is int) return value.toString();
  if (value is double) return value.toStringAsFixed(1);
  return value.toString();
}

class AllTimeTrackerPage extends StatefulWidget {
  const AllTimeTrackerPage({super.key});

  @override
  State<AllTimeTrackerPage> createState() => _AllTimeTrackerPageState();
}

class _AllTimeTrackerPageState extends State<AllTimeTrackerPage> {
  Map<String, dynamic>? totals;

  @override
  void initState() {
    super.initState();
    fetchTotals();
  }

  Future<void> fetchTotals() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final idToken = await user.getIdToken();

      final uri = Uri.parse(
          "https://food-app-zpft.onrender.com/meals/alltime?userId=${user.uid}");

      final res = await http.get(uri, headers: {
        'Authorization': 'Bearer $idToken',
      });

      if (res.statusCode != 200) {
        throw Exception("Failed to fetch meals");
      }

      final List meals = json.decode(res.body);

      final Map<String, double> sum = {
        'calories': 0.0,
        'protein': 0.0,
        'carbs': 0.0,
        'fats': 0.0,
      };

      for (var meal in meals) {
        final total = meal['total'];
        if (total != null) {
          sum['calories'] = sum['calories']! + (total['calories'] ?? 0).toDouble();
          sum['protein']  = sum['protein']!  + (total['protein']  ?? 0).toDouble();
          sum['carbs']    = sum['carbs']!    + (total['carbs']    ?? 0).toDouble();
          sum['fats']     = sum['fats']!     + (total['fat']      ?? 0).toDouble();
        }
      }

      setState(() {
        totals = sum;
      });
    } catch (e) {
      debugPrint("Error fetching totals: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.indigo),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'All-Time Tracker',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Stats
                if (totals != null)
                  Column(
                    children: [
                      _Stat(label: "Total Calories", value: "${formatDouble(totals!['calories'])} kcal"),
                      _Stat(label: "Protein", value: "${formatDouble(totals!['protein'])} g"),
                      _Stat(label: "Carbs", value: "${formatDouble(totals!['carbs'])} g"),
                      _Stat(label: "Fats", value: "${formatDouble(totals!['fats'])} g"),
                    ],
                  )
                else
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 18)),
          Text(value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}