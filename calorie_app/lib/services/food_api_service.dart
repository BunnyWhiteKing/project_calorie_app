import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/app_models.dart';

class FoodApiService {
  static Future<List<FoodPreset>> searchFood(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final url = Uri.parse(
        'https://world.openfoodfacts.org/cgi/search.pl?search_terms=${Uri.encodeComponent(query)}&search_simple=1&action=process&json=1&page_size=15',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List products = data['products'] ?? [];
        List<FoodPreset> results = [];

        for (var item in products) {
          // ดึงชื่อภาษาไทย หรือ ชื่อหลัก
          String name = item['product_name_th'] ??
              item['product_name'] ??
              item['generic_name_th'] ??
              item['generic_name'] ??
              '';
          if (name.trim().isEmpty) continue;

          var nutriments = item['nutriments'];
          double kcal = 0.0;

          if (nutriments != null) {
            // ดักจับฟิลด์แคลอรีทุกรูปแบบของ Open Food Facts
            if (nutriments['energy-kcal_100g'] != null) {
              kcal = (nutriments['energy-kcal_100g'] as num).toDouble();
            } else if (nutriments['energy-kcal_value'] != null) {
              kcal = (nutriments['energy-kcal_value'] as num).toDouble();
            } else if (nutriments['energy-kcal'] != null) {
              kcal = (nutriments['energy-kcal'] as num).toDouble();
            } else if (nutriments['energy_100g'] != null) {
              // ถ้า API ให้มาเป็น กิโลจูล (kJ) ให้หาร 4.184 แปลงเป็น kcal
              double kj = (nutriments['energy_100g'] as num).toDouble();
              kcal = kj / 4.184;
            }
          }

          if (kcal > 0) {
            results.add(FoodPreset(
              name: name,
              unit: '100 กรัม',
              defaultAmount: 1, // 1 หน่วย = 100 กรัม
              calPerUnit: double.parse(kcal.toStringAsFixed(1)),
            ));
          }
        }
        return results;
      }
    } catch (e) {
      debugPrint('Error searching Open Food Facts API: $e');
    }
    return [];
  }
}