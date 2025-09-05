import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diabetest/components/user/scanOption.dart';
import 'package:diabetest/presentation/scan_product.dart';
import 'package:diabetest/presentation/scan_result.dart';
import 'package:diabetest/services/edamam_services.dart';
import 'package:diabetest/services/gemini_services.dart';
import 'package:diabetest/services/product_ingredients_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../components/user/manual_entry.dart';
import '../components/user/navi.dart';
import '../services/product_save.dart';
import 'Article.dart';
import 'history.dart';

// --- Colors ---
const Color primaryBlue = Color(0xFF5A67D8);
const Color primaryRed = Color(0xFFE53E3E);
const Color successGreen = Color(0xFF4CAF50);
const Color lightGreen = Color(0xFFE6F4EA);
const Color lightRed = Color(0xFFFDECEA);
const Color pageBackground = Color(0xFFF7FAFC);
const Color darkTextColor = Color(0xFF1A202C);
const Color lightTextColor = Color(0xFF718096);

// Helper function
double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is int) return value.toDouble();
  if (value is double) return value;
  return double.tryParse(value.toString()) ?? 0.0;
}

// --------------- Dashboard Screen (Parent Widget) ---------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _diabetesStatus = '';
  bool _isLoading = true;
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadUserStatus().then((_) {
      _initializePages();
    });
  }

  void _initializePages() {
    final bool isHighRisk = _diabetesStatus.toLowerCase() == 'tinggi';
    final Color themeColor = isHighRisk ? primaryRed : primaryBlue;
    _pages = [
      DashboardPage(themeColor: themeColor),
      const ScanProduct(),
      const ArticleScreen(),
    ];
  }

  Future<void> _loadUserStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection('identity').doc(user.uid).get();
        if (userDoc.exists) {
          _diabetesStatus = userDoc.get('status_diabetes') ?? 'tidak';
        }
      } catch (e) {
        debugPrint("Error fetching diabetes status: $e");
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      _showScanOptions();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showScanOptions() {
    final bool isHighRisk = _diabetesStatus.toLowerCase() == 'tinggi';
    final Color themeColor = isHighRisk ? primaryRed : primaryBlue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ScanOptionsDialog(
          remainingScans: 3,
          themeColor: themeColor,
          onTakePhoto: () {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, '/scan');
            debugPrint("Ambil Foto ditekan");
          },
          onManualEntry: () {
            Navigator.of(context).pop();
            _showManualEntryDialog(themeColor);
            debugPrint("Catat Sendiri ditekan");
          },

        );

      },
    );

  }

  void _showManualEntryDialog(Color themeColor) {
    final parentContext = context;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ManualEntryDialog(
          themeColor: themeColor,
          onCancel: () {
            Navigator.of(context).pop();
          },
          onSearch: (foodName) async {
            Navigator.of(context).pop();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mencari data nutrisi...')),
            );
            try {
              final translatedFoodName = await GeminiServices().translateText(
                  foodName, 'English');
              debugPrint("Nama makanan diterjemahkan: $translatedFoodName");

              final result = await EdamamService().getNutrition(translatedFoodName);

              if (!mounted) return;

              if (result != null && mounted) {
                Navigator.push(
                  parentContext,
                  MaterialPageRoute(
                      builder: (context) => ScanR(productData: result,),
                )
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Gagal menemukan data nutrisi.')),
                );
              }
            } catch(e){
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Gagal menemukan data nutrisi.')),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: pageBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bool isHighRisk = _diabetesStatus.toLowerCase() == 'tinggi';
    final Color themeColor = isHighRisk ? primaryRed : primaryBlue;

    return Scaffold(
      backgroundColor: pageBackground,
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        themeColor: themeColor,
      ),
    );
  }
}

// --------------- Dashboard Page (Child Widget) ---------------
class DashboardPage extends StatefulWidget {
  final Color themeColor;
  const DashboardPage({Key? key, required this.themeColor}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  String _userName = 'Pengguna';
  String? _profileImageUrl;
  List<Map<String, dynamic>> products = [];
  late TabController _tabController;

  final List<int> dailyData = [80, 40, 90, 60, 120, 30, 70];
  final List<int> monthlyData = [100, 150, 120, 140, 110, 130, 160, 90, 100];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    final allProducts = await ProductSave().getLatestProducts();
    final today = DateTime.now();
    final todaysProducts = allProducts.where((food) {
      final timestamp = food['timestamp'] as Timestamp?;
      if (timestamp == null) return false;
      final date = timestamp.toDate();
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).toList();

    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection('user').doc(user.uid).get();
        if (userDoc.exists) {
          _userName = userDoc.get('displayName') ?? 'Pengguna';
          _profileImageUrl = userDoc.get('photoURL');
        }
      } catch (e) {
        debugPrint("Error fetching user data: $e");
      }
    }

    setState(() {
      products = todaysProducts;
      isLoading = false;
    });
  }

  Widget _buildHeader(Color themeColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: CircleAvatar(
              radius: 25,
              backgroundImage: _profileImageUrl != null
                  ? NetworkImage(_profileImageUrl!)
                  : const AssetImage('assets/images/monkey_avatar.png')
              as ImageProvider,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat pagi, $_userName',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Jangan lupa minum air putih cukup hari ini. Kesehatan dimulai dari kebiasaan kecil.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: pageBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Hitung GL
    final consumedGL = products.fold<double>(0.0, (sum, food) {
      final other = food['other_nutriments'] as Map<String, dynamic>?;
      return sum + _toDouble(other?['fat_100g']);
    });
    const totalGL = 64.0;
    final glProgress = totalGL > 0 ? consumedGL / totalGL : 0.0;

    final Color themeColor = widget.themeColor;
    final Color progressColor = (glProgress > 0.7) ? primaryRed : successGreen;
    final Color progressBgColor = (glProgress > 0.7) ? lightRed : lightGreen;
    final Color foodCardColor = (glProgress > 0.7) ? const Color(0xFFFDECEA) : lightGreen;

    return Scaffold(
      backgroundColor: pageBackground,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(themeColor),
            _buildGLCard(
                glProgress, consumedGL, totalGL, progressColor, progressBgColor, themeColor),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Glycemic Load (GL) menunjukkan seberapa banyak dan jenis karbohidrat dari makanan yang kamu makan, serta dampaknya pada gula darahmu.',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: darkTextColor),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Gula darah kamu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  TabBar(
                    controller: _tabController,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(width: 5, color: themeColor),
                      insets: const EdgeInsets.symmetric(horizontal: 60.0),
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                    ),
                    dividerColor: Colors.transparent,
                    labelColor: themeColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: themeColor,
                    tabs: const [
                      Tab(text: 'Mingguan'),
                      Tab(text: 'Bulanan'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildBloodSugarSection(
                            themeColor, 120, dailyData, "Rata-rata gula darah"),
                        _buildBloodSugarSection(
                            themeColor, 135, monthlyData, "Rata-rata gula darah"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Asupan Makanan Hari Ini',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkTextColor),
                  ),
                  const SizedBox(height: 16),
                  if (products.isEmpty)
                    const Center(child: Text('Belum ada data makanan'))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final food = products[index];
                        final name = food['product_name'] ?? 'Nama Tidak Ada';
                        final image = food['image_url'] ?? 'assets/images/mie_dummy.png';
                        final carbs = _toDouble(food['total_karbohidrat']);
                        final gl = _toDouble((food['other_nutriments'] as Map<String, dynamic>?)?['fat_100g']);

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => HistoryPage(foodData: food)),
                            );
                          },
                          child: _buildFoodItemCard(
                            name: name,
                            imagePath: image,
                            carbs: carbs,
                            gl: gl,
                            cardColor: foodCardColor,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ------------------- WIDGETS -------------------

Widget _buildGLCard(double progress, double consumed, double total, Color progressColor,
    Color progressBgColor, Color themeColor) {
  int percentage = (progress * 100).toInt();
  return Container(
    margin: const EdgeInsets.fromLTRB(24, 20, 24, 16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 5, blurRadius: 10)],
    ),
    child: Row(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 10,
                backgroundColor: progressBgColor,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
              Center(
                child: Text(
                  '$percentage%',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: themeColor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Terkonsumsi ', style: TextStyle(color: themeColor)),
                    TextSpan(
                        text: '${consumed.toStringAsFixed(1)} GL ',
                        style: TextStyle(fontWeight: FontWeight.bold, color: themeColor)),
                    TextSpan(text: 'dari $total GL', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text('Sisa ${(total - consumed).toStringAsFixed(1)} GL',
                  style: const TextStyle(fontSize: 14, color: darkTextColor)),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildBloodSugarSection(Color themeColor, int avg, List<int> data, String title) {
  final String emoji = avg > 140 ? '😟' : '😍';
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 5, blurRadius: 10)],
        ),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkTextColor)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Text('$avg',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: themeColor)),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text('mg/dL', style: TextStyle(color: themeColor)),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Container(
        height: 220,
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 5, blurRadius: 10)]),
        child: DailyBloodSugarChart(data: data),
      ),
    ],
  );
}

Widget _buildFoodItemCard({
  String? imagePath,
  required String name,
  required double carbs,
  required double gl,
  required Color cardColor,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.08),
          spreadRadius: 2,
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: cardColor,
          ),
          child: Image.network(imagePath!),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkTextColor)),
              const SizedBox(height: 6),
              Text('Karbohidrat: ${carbs.toStringAsFixed(1)} g',
                  style: const TextStyle(fontSize: 12, color: lightTextColor)),
              Text('GL: ${gl.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 12, color: lightTextColor)),
            ],
          ),
        ),
        const Icon(Icons.more_vert, color: Colors.grey),
      ],
    ),
  );
}

class DailyBloodSugarChart extends StatelessWidget {
  final List<int> data;
  const DailyBloodSugarChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: 200,
        minY: 0,
        gridData: FlGridData(show: true, horizontalInterval: 50),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 50,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString(),
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                if (value.toInt() < days.length) {
                  return Text(days[value.toInt()],
                      style: const TextStyle(fontSize: 10, color: Colors.grey));
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value.toDouble(),
                width: 14,
                borderRadius: BorderRadius.circular(4),
                color: value > 140 ? primaryRed : successGreen,
              ),
            ],
          );
        }).toList(),
        extraLinesData: ExtraLinesData(horizontalLines: [
          HorizontalLine(
            y: 150,
            color: Colors.red,
            strokeWidth: 1.5,
            dashArray: [6, 6],
            label: HorizontalLineLabel(
              show: true,
              alignment: Alignment.topLeft,
              style: const TextStyle(color: Colors.red, fontSize: 10),
              labelResolver: (_) => "Batas Atas: 150 mg/dL",
            ),
          ),
        ]),
      ),
    );
  }
}