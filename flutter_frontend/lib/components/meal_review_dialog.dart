// Add this import if in a separate file
import 'package:flutter/material.dart';

class MealReviewDialog extends StatefulWidget {
  final Map<String, dynamic> meal;
  final String imageBase64;

  const MealReviewDialog({
    required this.meal,
    required this.imageBase64,
    super.key,
  });

  @override
  State<MealReviewDialog> createState() => _MealReviewDialogState();
}

class _MealReviewDialogState extends State<MealReviewDialog> {
  late TextEditingController _titleController;
  late List<Map<String, dynamic>> nutrition;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.meal['title'] ?? '');
    // Add 'quantity' = 1 to each ingredient
    nutrition = List<Map<String, dynamic>>.from(widget.meal['nutrition']).map((item) {
      return {
        ...item,
        'quantity': 1,
      };
    }).toList();
  }

  void _increment(int index) {
    setState(() {
      nutrition[index]['quantity'] += 1;
    });
  }

  void _decrement(int index) {
    setState(() {
      if (nutrition[index]['quantity'] > 1) {
        nutrition[index]['quantity'] -= 1;
      }
    });
  }

  double _scaled(dynamic value, int quantity) => (value as num).toDouble() * quantity;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Review & Edit Meal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.imageBase64.isNotEmpty)
              Image.memory(
                Uri.parse(widget.imageBase64).data!.contentAsBytes(),
                height: 150,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Meal Title'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ingredients',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...nutrition.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final quantity = item['quantity'];
              return Card(
                child: ListTile(
                  title: Text('${quantity}x ${item['name']}'),
                  subtitle: Text(
                    'Calories: ${_scaled(item['calories'], quantity).toStringAsFixed(0)} kcal\n'
                    'Protein: ${_scaled(item['protein'], quantity).toStringAsFixed(1)}g | '
                    'Fat: ${_scaled(item['fat'], quantity).toStringAsFixed(1)}g | '
                    'Carbs: ${_scaled(item['carbs'], quantity).toStringAsFixed(1)}g',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => _decrement(index),
                      ),
                      Text('$quantity'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _increment(index),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final adjustedNutrition = nutrition.map((item) {
            final qty = item['quantity'];
            return {
              'name': '${qty}x ${item['name']}',
              'calories': _scaled(item['calories'], qty).round(),
              'protein': _scaled(item['protein'], qty),
              'fat': _scaled(item['fat'], qty),
              'carbs': _scaled(item['carbs'], qty),
            };
            }).toList();

            final total = adjustedNutrition.fold<Map<String, dynamic>>({
              'calories': 0,
              'protein': 0.0,
              'fat': 0.0,
              'carbs': 0.0,
            }, (sum, item) {
              sum['calories'] += item['calories'] as int;
              sum['protein'] += item['protein'] as double;
              sum['fat']     += item['fat']     as double;
              sum['carbs']   += item['carbs']   as double;
              return sum;
            });

            final updatedMeal = {
              'title': _titleController.text.trim(),
              'nutrition': adjustedNutrition,
              'total': total,
            };

            Navigator.of(context).pop(updatedMeal);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}