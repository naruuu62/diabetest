// File: lib/model/product_data_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductData {
  final String foodName;
  final String foodDescription;
  final String imageUrl;
  final List<String> tags;
  final double totalGula;
  final double totalKarbohidrat;
  final double glycemicIndex;
  final double glycemicLoad;

  ProductData({
    required this.foodName,
    required this.foodDescription,
    required this.imageUrl,
    required this.tags,
    required this.totalGula,
    required this.totalKarbohidrat,
    required this.glycemicIndex,
    required this.glycemicLoad,
  });

  // Factory constructor dari Open Food Facts
  factory ProductData.fromOpenFoodFacts(Map<String, dynamic> data) {
    final nutriments = data['nutriments'] ?? {};
    return ProductData(
      foodName: data['product_name'] ?? 'Nama Tidak Ada',
      foodDescription: data['generic_name'] ?? 'Deskripsi tidak tersedia',
      imageUrl: data['image_url'] ?? 'assets/images/mie_dummy.png',
      tags: (data['categories_tags'] as List<dynamic>?)
          ?.cast<String>()
          .map((tag) => tag.split(':').last.replaceAll('-', ' '))
          .toList() ??
          [],
      totalGula: (nutriments['sugars_100g'] ?? 0.0).toDouble(),
      totalKarbohidrat: (nutriments['carbohydrates_100g'] ?? 0.0).toDouble(),
      glycemicIndex: (nutriments['saturated-fat_100g'] ?? 0.0).toDouble(),
      glycemicLoad: (nutriments['fiber_100g'] ?? 0.0).toDouble(),
    );
  }

  // Factory constructor dari Edamam
  factory ProductData.fromEdamam(Map<String, dynamic> data) {
    final totalNutrients = data['totalNutrients'] ?? {};
    final ingredients = data['ingredients']?[0]?['parsed']?[0] ?? {};
    final double totalFat = (totalNutrients['FAT']?['quantity'] ?? 0.0).toDouble();
    final double totalProtein = (totalNutrients['PROCNT']?['quantity'] ?? 0.0).toDouble();

    return ProductData(
      foodName: ingredients['food'] ?? 'Nama Tidak Ada',
      foodDescription: 'Analisis dari Edamam',
      imageUrl: ingredients['image'] ?? 'assets/images/mie_dummy.png',
      tags: [],
      totalGula: (totalNutrients['SUGAR']?['quantity'] ?? 0.0).toDouble(),
      totalKarbohidrat: (totalNutrients['CHOCDF']?['quantity'] ?? 0.0).toDouble(),
      glycemicIndex: totalFat,
      glycemicLoad: totalProtein,
    );
  }

  // Method toMap() yang hilang
  Map<String, dynamic> toMap() {
    return {
      'foodName': foodName,
      'foodDescription': foodDescription,
      'imageUrl': imageUrl,
      'tags': tags,
      'totalGula': totalGula,
      'totalKarbohidrat': totalKarbohidrat,
      'glycemicIndex': glycemicIndex,
      'glycemicLoad': glycemicLoad,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}