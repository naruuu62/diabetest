import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/product_save.dart';

const Color pageBackground = Color(0xFFF7FAFC);
const Color darkTextColor = Color(0xFF1A202C);
const Color lightTextColor = Color(0xFF718096);
const Color cardBackgroundColor = Colors.white;
const Color sugarColor = Color(0xFFEBF4FF);
const Color carbsColor = Color(0xFFFFF5F5);
const Color giColor = Color(0xFFF0FFF4);
const Color glColor = Color(0xFFFAF5FF);

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key, required Map<String, dynamic> foodData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/arrow_back.png',
              width: 24,
              height: 24,
            ),
          ),
        ),
        title: const Text(
          'Riwayat Asupan',
          style: TextStyle(
            color: darkTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ProductSave().getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(child: Text('Belum ada riwayat asupan'));
          }

          // ambil tanggal hari ini
          final today = DateTime.now();
          final startOfDay = DateTime(today.year, today.month, today.day);
          final endOfDay = startOfDay.add(const Duration(days: 1));

          // filter hanya produk hari ini
          final todayProducts = products.where((foodData) {
            final ts = foodData['timestamp'];
            if (ts == null) return false;

            DateTime dt;
            if (ts is Timestamp) {
              dt = ts.toDate();
            } else if (ts is DateTime) {
              dt = ts;
            } else {
              return false;
            }

            return dt.isAfter(startOfDay) && dt.isBefore(endOfDay);
          }).toList();

          if (todayProducts.isEmpty) {
            return const Center(
                child: Text('Belum ada riwayat asupan hari ini'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: todayProducts.map((foodData) {
                final String foodName =
                    foodData['product_name'] ?? 'Nama Tidak Ada';
                final String foodDescription =
                    foodData['generic_name'] ?? 'Deskripsi tidak tersedia';
                final String imagePath =
                    foodData['image_url'] ?? 'assets/images/mie_dummy.png';
                final List<String> tags =
                List<String>.from(foodData['categories_tags'] ?? []);
                final String totalGula =
                    '${foodData['total_gula'] ?? 0} g';
                final String totalKarbohidrat =
                    '${foodData['total_karbohidrat'] ?? 0} g';
                final String glycemicIndex =
                    '${(foodData['other_nutriments'] as Map<String, dynamic>?)?['fiber_100g'] ?? 0} GI';
                final String glycemicLoad =
                    '${(foodData['other_nutriments'] as Map<String, dynamic>?)?['fat_100g'] ?? 0} GL';

                return _buildHistoryCard(
                  foodName: foodName,
                  foodDescription: foodDescription,
                  imagePath: imagePath,
                  tags: tags,
                  totalGula: totalGula,
                  totalKarbohidrat: totalKarbohidrat,
                  glycemicIndex: glycemicIndex,
                  glycemicLoad: glycemicLoad,
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard({
    required String foodName,
    required String foodDescription,
    required String imagePath,
    required List<String> tags,
    required String totalGula,
    required String totalKarbohidrat,
    required String glycemicIndex,
    required String glycemicLoad,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(imagePath, tags),
          _buildDetailsSection(
              foodName,
              foodDescription,
              totalGula,
              totalKarbohidrat,
              glycemicIndex,
              glycemicLoad),
        ],
      ),
    );
  }

  Widget _buildImageSection(String imagePath, List<String> tags) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(20.0)),
          child: Image.network(
            imagePath,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported,
                    color: Colors.grey, size: 50),
              );
            },
          ),
        ),
        if (tags.isNotEmpty)
          Positioned(
            top: 16,
            right: 16,
            child: _buildTag(tags[0]),
          ),
        if (tags.length > 1)
          Positioned(
            bottom: 16,
            left: 16,
            child: _buildTag(tags[1]),
          ),
        if (tags.length > 2)
          Positioned(
            bottom: 16,
            right: 16,
            child: _buildTag(tags[2]),
          ),
      ],
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: darkTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDetailsSection(
      String foodName,
      String foodDescription,
      String totalGula,
      String totalKarbohidrat,
      String glycemicIndex,
      String glycemicLoad) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: darkTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      foodDescription,
                      style: const TextStyle(
                        color: lightTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.0,
            children: [
              _buildInfoCard('Total Gula', totalGula, sugarColor),
              _buildInfoCard('Total Karbohidrat', totalKarbohidrat, carbsColor),
              _buildInfoCard('Glycemic Index', glycemicIndex, giColor),
              _buildInfoCard('Glycemic Load', glycemicLoad, glColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: darkTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
