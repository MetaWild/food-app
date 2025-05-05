import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> meals = [];
  Map<String, dynamic>? dailyTotals;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchMealsAndTotals();
  }

  Future<void> fetchMealsAndTotals() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final idToken = await user.getIdToken();
    final today = DateTime.now().toIso8601String().split("T")[0];

    final uri = Uri.parse(
        'https://food-app-zpft.onrender.com/meals?userId=${user.uid}&date=$today');

    final res = await http.get(uri, headers: {
      'Authorization': 'Bearer $idToken',
    });

    if (res.statusCode == 200) {
      final List decoded = json.decode(res.body);
      final Map<String, dynamic> sum = {
        'calories': 0.0,
        'protein': 0.0,
        'carbs': 0.0,
        'fats': 0.0,
      };

      for (var meal in decoded) {
        final total = meal['total'];
        if (total != null) {
          sum['calories'] += (total['calories'] ?? 0).toDouble();
          sum['protein']  += (total['protein']  ?? 0).toDouble();
          sum['carbs']    += (total['carbs']    ?? 0).toDouble();
          sum['fats']     += (total['fat']      ?? 0).toDouble();
        }
      }

      setState(() {
        meals = decoded.cast<Map<String, dynamic>>();
        dailyTotals = sum;
        loading = false;
      });
    } else {
      debugPrint('Error fetching meals: ${res.statusCode}');
      setState(() => loading = false);
    }
  }

  void handleLogout() async {
    print("logging out");
    await _auth.signOut();
  }

  void handleAlltimeTracker() {
    Navigator.pushNamed(context, '/tracker');
  }

  void handleMealClick(Map<String, dynamic> meal) {
    Navigator.pushNamed(context, '/meal', arguments: {'meal': meal});
  }

  void handleCapture() {
    Navigator.pushNamed(context, '/capture');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 420),
          child: SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Button(text: 'Logout', onPressed: handleLogout),
                    const Text('Daily Tracker',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    _Button(text: 'Alltime', onPressed: handleAlltimeTracker),
                  ],
                ),
                const SizedBox(height: 20),
                if (dailyTotals != null)
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.5,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _Stat(label: 'Calories', value: '${dailyTotals!['calories'].toStringAsFixed(0)} kcal'),
                      _Stat(label: 'Protein', value: '${dailyTotals!['protein'].toStringAsFixed(1)} g'),
                      _Stat(label: 'Carbs', value: '${dailyTotals!['carbs'].toStringAsFixed(1)} g'),
                      _Stat(label: 'Fats', value: '${dailyTotals!['fats'].toStringAsFixed(1)} g'),
                    ],
                  ),
                const SizedBox(height: 20),
                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          itemCount: meals.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final meal = meals[index];
                            if (meal['title'] == null || meal['nutrition'] == null) {
                              return const SizedBox.shrink();
                            }

                            return InkWell(
                              onTap: () => handleMealClick(meal),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.indigo),
                                  color: const Color(0xFFF7F7F7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    if (meal['imageUrl'] != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.network(
                                          meal['imageUrl'],
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        meal['title'],
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 20),
                FloatingActionButton(
                  onPressed: handleCapture,
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.camera_alt, size: 28),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _Button({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo,
        side: const BorderSide(color: Colors.indigo),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade100,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
