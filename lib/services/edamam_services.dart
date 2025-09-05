import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class EdamamService {
  final String appId = "df917882"; // Ganti dengan App ID kamu
  final String appKey = "411ff50784b28452b19b639efa214978"; // Ganti dengan App Key kamu

  Future<Map<String, dynamic>?> getNutrition(String foodName) async {
    final encodedFoodName = Uri.encodeComponent(foodName);
    final url = Uri.parse(
        'https://api.edamam.com/api/nutrition-data?app_id=$appId&app_key=$appKey&ingr=$encodedFoodName');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data.isNotEmpty) {
          debugPrint("Edamam API success: ${data['ingredients'][0]['parsed'][0]['food']}");
          return data;
        } else {
          debugPrint("Edamam API: No nutrition data found.");
          return null;
        }
      } else {
        debugPrint("Edamam API error: Status code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Edamam API exception: $e");
      return null;
    }
  }
}