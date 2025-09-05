import 'dart:typed_data';
import 'package:flutter/material.dart';

// --- Palet Warna untuk Halaman Hasil ---
const Color pageBackground = Color(0xFFF7FAFC);
const Color darkTextColor = Color(0xFF1A202C);
const Color lightTextColor = Color(0xFF718096);
const Color cardBackgroundColor = Colors.white;
const Color sugarColor = Color(0xFFEBF4FF);
const Color carbsColor = Color(0xFFFFF5F5);
const Color giColor = Color(0xFFF0FFF4);
const Color glColor = Color(0xFFFAF5FF);

// --- Class Model untuk Membawa Data Hasil Scan ---
class ScanResult {
  final Uint8List imageBytes;
  final List<String> tags;
  final String primaryLabel;

  ScanResult({
    required this.imageBytes,
    required this.tags,
    required this.primaryLabel,
  });
}


class ResultPage extends StatelessWidget {
  // Menerima objek ScanResult
  final ScanResult result;

  const ResultPage({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Data sekarang diambil dari objek 'result' ---
    final String foodName = result.primaryLabel;
    final String foodDescription = 'Hasil pindai';
    final Uint8List imageBytes = result.imageBytes;
    final List<String> tags = result.tags;

    // Data nutrisi masih dummy, nantinya bisa diambil dari Firebase berdasarkan foodName
    final String totalGula = '12 g';
    final String totalKarbohidrat = '26.3 g';
    final String glycemicIndex = 'Tinggi';
    final String glycemicLoad = 'Sedang';

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Hasil Analisis',
          style: TextStyle(
            color: darkTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildResultCard(
          foodName: foodName,
          foodDescription: foodDescription,
          imageBytes: imageBytes,
          tags: tags,
          totalGula: totalGula,
          totalKarbohidrat: totalKarbohidrat,
          glycemicIndex: glycemicIndex,
          glycemicLoad: glycemicLoad,
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required String foodName,
    required String foodDescription,
    required Uint8List imageBytes,
    required List<String> tags,
    required String totalGula,
    required String totalKarbohidrat,
    required String glycemicIndex,
    required String glycemicLoad,
  }) {
    return Container(
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
          _buildImageSection(imageBytes, tags),
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

  Widget _buildImageSection(Uint8List imageBytes, List<String> tags) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
          // Menggunakan Image.memory untuk menampilkan gambar dari bytes
          child: Image.memory(
            imageBytes,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        // Menampilkan hingga 3 tag teratas
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
