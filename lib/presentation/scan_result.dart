import 'package:diabetest/services/product_save.dart';
import 'package:flutter/material.dart';

import 'package:diabetest/services/gemini_services.dart';


// --- Colors ---
const Color pageBackground = Color(0xFFF7FAFC);
const Color darkTextColor = Color(0xFF1A202C);
const Color lightTextColor = Color(0xFF718096);
const Color cardBackgroundColor = Colors.white;
const Color sugarColor = Color(0xFFEBF4FF);
const Color carbsColor = Color(0xFFFFF5F5);
const Color giColor = Color(0xFFF0FFF4);
const Color glColor = Color(0xFFFAF5FF);

// --- New Colors based on your screenshots ---
const Color highRiskBackground = Color(0xFFFDECEA);
const Color highRiskText = Color(0xFFE53E3E);
const Color primaryBlue = Color(0xFF5A67D8);
const Color highRiskTextRed = Color(0xFFE53E3E);

// --- Helper function to determine API source ---
bool _isEdamamData(Map<String, dynamic> data) {
  return data.containsKey('totalNutrients') && data.containsKey('ingredients');
}

class ScanR extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ScanR({Key? key, required this.productData}) : super(key: key);

  @override
  State<ScanR> createState() => _ScanRState();
}

class _ScanRState extends State<ScanR> {
  bool isLoading = true;
  Map<String, dynamic>? analysisResult;
  final GeminiServices _geminiService = GeminiServices();

  @override
  void initState() {
    super.initState();
    _fetchAnalysis();
  }

  Future<void> _fetchAnalysis() async {
    try {
      final result = await _geminiService.getProductAnalysis(widget.productData);
      if (mounted) {
        setState(() {
          analysisResult = result;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        debugPrint("Error fetching Gemini analysis: $e");
        setState(() {
          isLoading = false;
          analysisResult = {
            "skor_kesehatan": 50,
            "status": "Analisis Gagal",
            "rekomendasi": ["Gagal mendapatkan rekomendasi."],
            "alternatif": ["Coba lagi nanti."],
            "penjelasan": "Terjadi kesalahan saat memproses data produk. Harap coba lagi."
          };
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdamam = _isEdamamData(widget.productData);

    final String foodName;
    final String foodDescription;
    final String imagePath;
    final List<String> tags;
    final String totalGula;
    final String totalKarbohidrat;
    final String glycemicIndex;
    final String glycemicLoad;

    // Edamam
    if (isEdamam) {
      final totalNutrients = widget.productData['totalNutrients'] ?? {};
      foodName = widget.productData['ingredients']?[0]?['parsed']?[0]?['food'] ?? 'Nama Tidak Ada';
      foodDescription = 'Analisis dari Edamam';
      imagePath = widget.productData['ingredients']?[0]?['parsed']?[0]?['image'] ?? 'assets/images/mie_dummy.png';
      tags = [];
      totalGula = (totalNutrients['SUGAR']?['quantity'] ?? 0.0).toStringAsFixed(1);
      totalKarbohidrat = (totalNutrients['CHOCDF']?['quantity'] ?? 0.0).toStringAsFixed(1);
      final totalFat = (totalNutrients['FAT']?['quantity'] ?? 0.0).toStringAsFixed(1);
      final totalProtein = (totalNutrients['PROCNT']?['quantity'] ?? 0.0).toStringAsFixed(1);
      glycemicIndex = '$totalFat g';
      glycemicLoad = '$totalProtein g';
    }
    // Open Food Facts
    else {
      final nutriments = widget.productData['nutriments'] ?? {};
      foodName = widget.productData['product_name'] ?? 'Nama Tidak Ada';
      foodDescription = widget.productData['generic_name'] ?? 'Deskripsi tidak tersedia';
      imagePath = widget.productData['image_url'] ?? 'assets/images/mie_dummy.png';
      tags = (widget.productData['categories_tags'] as List<dynamic>?)
          ?.cast<String>()
          .take(3)
          .map((tag) => tag.split(':').last.replaceAll('-', ' '))
          .toList() ?? [];
      totalGula = nutriments['sugars_100g']?.toStringAsFixed(1) ?? '0';
      totalKarbohidrat = nutriments['carbohydrates_100g']?.toStringAsFixed(1) ?? '0';
      glycemicIndex = nutriments['Saturated_fat_100g']?.toStringAsFixed(1) ?? 'N/A';
      glycemicLoad = nutriments['Fiber_100g']?.toStringAsFixed(1) ?? 'N/A';
    }

    final bool isHighRisk = (analysisResult?['skor_kesehatan'] ?? 100) < 50;
    final Color riskColor = isHighRisk ? highRiskTextRed : darkTextColor;
    final Color riskBackgroundColor = isHighRisk ? highRiskBackground : Colors.white;

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        elevation: 0,
        leading: GestureDetector(
          onTap: () async {
            await ProductSave().saveProduct(widget.productData);
            Navigator.pushNamedAndRemoveUntil(context, '/homepage', (route) => false);
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildHistoryCard(
          foodName: foodName,
          foodDescription: foodDescription,
          imagePath: imagePath,
          tags: tags,
          totalGula: totalGula,
          totalKarbohidrat: totalKarbohidrat,
          glycemicIndex: glycemicIndex,
          glycemicLoad: glycemicLoad,
          riskColor: riskColor,
          riskBackgroundColor: riskBackgroundColor,
          analysisResult: analysisResult,
        ),
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
    required Color riskColor,
    required Color riskBackgroundColor,
    required Map<String, dynamic>? analysisResult,
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
          _buildImageSection(imagePath, tags),
          _buildDetailsSection(
            foodName,
            foodDescription,
            totalGula,
            totalKarbohidrat,
            glycemicIndex,
            glycemicLoad,
          ),
          if (analysisResult != null) ...[
            _buildScoreSection(analysisResult, riskColor, riskBackgroundColor),
            _buildRecommendationSection('Rekomendasi Konsumsi', analysisResult['rekomendasi']),
            _buildRecommendationSection('Alternatif Konsumsi', analysisResult['alternatif']),
            _buildExplanationSection('Penjelasan', analysisResult['penjelasan']),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreSection(Map<String, dynamic> analysisResult, Color riskColor, Color riskBackgroundColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: riskBackgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Text(
            (analysisResult['skor_kesehatan'] ?? 0) < 50 ? '😟' : '😊',
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Skor Kesehatan',
                  style: TextStyle(
                    color: darkTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  analysisResult['status'],
                  style: TextStyle(
                    color: lightTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${analysisResult['skor_kesehatan'] ?? 'N/A'}/100',
            style: TextStyle(
              color: riskColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationSection(String title, List<dynamic>? recommendations) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: darkTextColor,
          ),
        ),
        initiallyExpanded: true,
        children: (recommendations ?? [])
            .map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(color: darkTextColor)),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(color: darkTextColor),
                ),
              ),
            ],
          ),
        ))
            .toList(),
      ),
    );
  }

  Widget _buildExplanationSection(String title, String? explanation) {
    if (explanation == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: darkTextColor,
          ),
        ),
        initiallyExpanded: true,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              explanation,
              style: const TextStyle(color: darkTextColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(String imagePath, List<String> tags) {
    bool isNetworkImage = imagePath.startsWith('http');
    ImageProvider imageProvider;
    if (isNetworkImage) {
      imageProvider = NetworkImage(imagePath);
    } else {
      imageProvider = AssetImage(imagePath);
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
          child: Image(
            image: imageProvider,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
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