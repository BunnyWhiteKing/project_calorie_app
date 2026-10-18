import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_models.dart';
import '../../providers/app_provider.dart';

class Tab1FoodScreen extends StatefulWidget {
  const Tab1FoodScreen({super.key});

  @override
  State<Tab1FoodScreen> createState() => _Tab1FoodScreenState();
}

class _Tab1FoodScreenState extends State<Tab1FoodScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController(text: '1');
  final TextEditingController _calPerUnitController = TextEditingController(text: '80');

  String _currentUnitLabel = 'หน่วย';
  double _calculatedTotalCal = 80.0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_recalculateCalories);
    _calPerUnitController.addListener(_recalculateCalories);
    _recalculateCalories();
  }

  @override
  void dispose() {
    _amountController.removeListener(_recalculateCalories);
    _calPerUnitController.removeListener(_recalculateCalories);
    _nameController.dispose();
    _amountController.dispose();
    _calPerUnitController.dispose();
    super.dispose();
  }

  void _recalculateCalories() {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    double calUnit = double.tryParse(_calPerUnitController.text) ?? 0.0;
    if (mounted) {
      setState(() {
        _calculatedTotalCal = amount * calUnit;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 1. กล่องป้อนข้อมูลและค้นหาวัตถุดิบ
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Autocomplete<FoodPreset>(
                    displayStringForOption: (FoodPreset option) => option.name,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.trim().isEmpty) {
                        return const Iterable<FoodPreset>.empty();
                      }
                      return defaultFoodDatabase.where((FoodPreset option) {
                        return option.name.contains(textEditingValue.text.trim());
                      });
                    },
                    onSelected: (FoodPreset selection) {
                      _nameController.text = selection.name;
                      _amountController.text = selection.defaultAmount.toStringAsFixed(0);
                      _calPerUnitController.text = selection.calPerUnit.toString();
                      setState(() {
                        _currentUnitLabel = selection.unit;
                      });
                      _recalculateCalories();
                    },
                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: 'ค้นหาวัตถุดิบ (เช่น อกไก่, ข้าวสวย, นมโปรตีน)',
                          prefixIcon: const Icon(Icons.search, color: Colors.teal),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (text) => _nameController.text = text,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'จำนวน ($_currentUnitLabel)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _calPerUnitController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'kcal / 1 $_currentUnitLabel',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.teal.shade200),
                        ),
                        child: Column(
                          children: [
                            const Text('แคลรวม', style: TextStyle(fontSize: 11, color: Colors.teal)),
                            Text(
                              '${_calculatedTotalCal.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('เพิ่มรายการอาหาร', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      String name = _nameController.text.trim();
                      double amount = double.tryParse(_amountController.text) ?? 0.0;

                      if (name.isNotEmpty && amount > 0) {
                        provider.addIngredient(IngredientItem(
                          name: '$name (${amount.toStringAsFixed(0)} $_currentUnitLabel)',
                          amount: 1,
                          caloriesPerUnit: _calculatedTotalCal,
                        ));
                        _amountController.text = '1';
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 2. รายการอาหารที่บันทึกแล้วในมื้อนี้
          Expanded(
            child: provider.currentMealIngredients.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text('ยังไม่มีรายการอาหารในมื้อนี้', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: provider.currentMealIngredients.length,
                    itemBuilder: (context, index) {
                      final item = provider.currentMealIngredients[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Icon(Icons.fastfood_outlined, color: Colors.white, size: 20),
                          ),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${item.totalCalories.toStringAsFixed(0)} kcal',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.teal),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                onPressed: () => provider.removeIngredient(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // 3. สรุปแคลอรีรวมทั้งมื้อ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.teal.shade700,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('แคลอรีรวมมื้อนี้:', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                Text(
                  '${provider.currentMealTotalCalories.toStringAsFixed(0)} kcal',
                  style: const TextStyle(fontSize: 22, color: Colors.amberAccent, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}