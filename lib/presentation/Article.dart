import 'package:flutter/material.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({Key? key}) : super(key: key);

  @override
  _ArticleScreenState createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {

  int _currentPage = 0;
  final PageController _pageController = PageController(viewportFraction: 0.85);

  // State untuk search bar
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  // --- Data Dummy ---
  final List<Map<String, String>> trendingArticles = [
    {
      "image": "assets/images/thumbnail.png",
      "title": "Mengenal Lebih Dalam Apa Itu Diabetes",
      "source": "Hello Sehat",
    },
    {
      "image": "assets/images/thumbnail.png",
      "title": "Tips Pola Makan Sehat untuk Penderita Diabetes",
      "source": "Alodokter",
    },
    {
      "image": "assets/images/thumbnail.png",
      "title": "Pentingnya Olahraga Rutin Setiap Hari",
      "source": "KlikDokter",
    },
  ];

  final List<Map<String, String>> recommendedArticles = [
    {
      "image": "assets/images/artikel.png",
      "title": "Cara Sederhana Mengontrol Diabetes Sehari-hari",
      "description": "Mengelola diabetes bukan hanya bergantung pada obat-obatan...",
      "source": "Hello Sehat",
    },
    {
      "image": "assets/images/artikel.png",
      "title": "Makanan yang Baik dan Buruk untuk Gula Darah",
      "description": "Pilihan makanan sangat krusial dalam menjaga stabilitas gula...",
      "source": "Hello Sehat",
    },
    {
      "image": "assets/images/artikel.png",
      "title": "Mitos dan Fakta Seputar Insulin",
      "description": "Banyak kesalahpahaman tentang penggunaan insulin. Mari kita...",
      "source": "Hello Sehat",
    }
  ];

  final List<String> searchHistory = [
    "Gejala awal diabetes tipe 2",
    "Cara mengontrol gula darah harian",
    "Makanan untuk penderita diabetes",
    "Efek olahraga ringan pada kadar gula"
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,

      body: Stack(
        children: [

          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(), // Unfocus saat tap di luar
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchSection(),
                  const SizedBox(height: 24),
                  _buildTrendingSection(),
                  const SizedBox(height: 30),
                  _buildRecommendationsSection(),
                ],
              ),
            ),
          ),


          if (_isSearchFocused)
            _buildSearchOverlay(),
        ],
      ),
    );
  }


  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Cari',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _isSearchFocused
              ? IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () {
              _searchController.clear();
              FocusScope.of(context).unfocus();
            },
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  // --- Overlay Riwayat Pencarian ---
  Widget _buildSearchOverlay() {
    return Positioned(
      top: 125,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...searchHistory.map((item) => ListTile(
                leading: const Icon(Icons.history, color: Colors.grey),
                title: Text(item, style: const TextStyle(color: darkTextColor)),
                onTap: (){},
              )).toList(),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Lihat lebih banyak", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
                  Icon(Icons.expand_more, color: primaryBlue),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // --- Bagian Trending ---
  Widget _buildTrendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Sedang Trending',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkTextColor),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: trendingArticles.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final article = trendingArticles[index];
              return _buildTrendingCard(
                imagePath: article['image']!,
                title: article['title']!,
                source: article['source']!,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Indikator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(trendingArticles.length, (index) {
            return _buildDotIndicator(isActive: index == _currentPage);
          }),
        ),
      ],
    );
  }

  Widget _buildTrendingCard({required String imagePath, required String title, required String source}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken)
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const CircleAvatar(backgroundColor: Colors.blue, radius: 10), // Placeholder icon
                const SizedBox(width: 8),
                Text(source, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicator({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? primaryBlue : Colors.grey.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }


  // --- Bagian Rekomendasi ---
  Widget _buildRecommendationsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rekomendasi Untukmu',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkTextColor),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            itemCount: recommendedArticles.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final article = recommendedArticles[index];
              return _buildRecommendationCard(
                imagePath: article['image']!,
                title: article['title']!,
                description: article['description']!,
                source: article['source']!,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard({required String imagePath, required String title, required String description, required String source}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(imagePath, width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: darkTextColor)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 12, color: lightTextColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const CircleAvatar(backgroundColor: Colors.blue, radius: 8), // Placeholder
                    const SizedBox(width: 6),
                    Text(source, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}


// --- Palet Warna ---
const Color primaryBlue = Color(0xFF5A67D8);
const Color pageBackground = Color(0xFFF7FAFC);
const Color darkTextColor = Color(0xFF1A202C);
const Color lightTextColor = Color(0xFF718096);
