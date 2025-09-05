import 'package:diabetest/presentation/results.dart';
import 'package:diabetest/presentation/scan_result.dart';
import 'package:diabetest/services/yolo_testing.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart'; // Import mobile_scanner
import 'package:diabetest/presentation/question_user/tes.dart'; // Tetap impor kode YOLO Anda
import '../components/colors.dart';


class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final MobileScannerController controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pindai Barcode Produk'),
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String barcodeValue = barcodes.first.rawValue ?? '';
            controller.stop();
            Navigator.pop(context, barcodeValue);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class ScanProduct extends StatefulWidget {
  const ScanProduct({super.key});

  @override
  State<ScanProduct> createState() => _ScanProductState();
}

class _ScanProductState extends State<ScanProduct> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===== TAB BAR =====
              Material(
                color: Colors.white,
                child: TabBar(
                  labelColor: scan,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: scan,
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(width: 5, color: scan),
                    insets: EdgeInsets.symmetric(horizontal: 30.0),
                  ),
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: "Pindai Asupan"),
                    Tab(text: "Pindai Produk"),
                  ],
                ),
              ),

              // ===== TAB VIEW =====
              Expanded(
                child: TabBarView(
                  children: [
                    _KeepAlivePage(
                      child: _ScanTabContent(
                        key: const ValueKey('AsupanScanner'),
                        title: "Pindai Asupan",
                        description: "Pindai makanan atau minumanmu untuk cek nutrisi dengan mudah",
                        modelPath: 'assets/models/yolov8n_float16.tflite',
                        labelsPath: 'assets/models/food_labels.txt',
                        scanType: ScanType.food,
                      ),
                    ),
                    _KeepAlivePage(
                      child: _ScanTabContent(
                        key: const ValueKey('ProdukScanner'),
                        title: "Pindai Produk",
                        description: "Pindai barcode produk untuk melihat informasi nutrisinya",
                        modelPath: 'assets/models/product_model.tflite', // Path tidak akan digunakan
                        labelsPath: 'assets/models/product_labels.txt', // Path tidak akan digunakan
                        scanType: ScanType.product,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanTabContent extends StatefulWidget {
  final String title;
  final String description;
  final String modelPath;
  final String labelsPath;
  final ScanType scanType;

  const _ScanTabContent({
    Key? key,
    required this.title,
    required this.description,
    required this.modelPath,
    required this.labelsPath,
    required this.scanType,
  }) : super(key: key);

  @override
  State<_ScanTabContent> createState() => _ScanTabContentState();
}

class _ScanTabContentState extends State<_ScanTabContent> {
  final GlobalKey<YoloTestingState> yoloKey = GlobalKey<YoloTestingState>();
  final MobileScannerController barcodeController = MobileScannerController();
  String _resultText = '';
  bool _isLoading = false;

  Future<void> _fetchProductData(String barcode) async {
    setState(() {
      _isLoading = true;
      _resultText = '';
    });

    final apiUrl = 'https://world.openfoodfacts.org/api/v0/product/$barcode.json';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 1) {
        final product = data['product'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanR(productData: product),
          ),
        );
      } else {
        setState(() {
          _resultText = "Produk dengan barcode $barcode tidak ditemukan.";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk tidak ditemukan.')),
        );
      }
    } catch (e) {
      setState(() {
        _resultText = "Terjadi kesalahan: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isFoodTab = widget.scanType == ScanType.food;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'circular',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.description,
                style: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'circular',
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.zero,
            child: isFoodTab
                ? YoloTesting(
              key: yoloKey,
              modelPath: widget.modelPath,
              labelsPath: widget.labelsPath,
              scanType: widget.scanType,
            )
                : Stack(
              children: [
                MobileScanner(
                  controller: barcodeController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      final String barcodeValue = barcodes.first.rawValue ?? '';
                      barcodeController.stop();
                      _fetchProductData(barcodeValue);
                    }
                  },
                ),

                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.srcOut,
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          backgroundBlendMode: BlendMode.dstOut,
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellow, width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {

                if (isFoodTab) {
                  yoloKey.currentState?.startScan();
                } else {
                  if (_isLoading) return;
                  if (barcodeController.value.isRunning) {
                    barcodeController.stop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pemindaian dihentikan.')),
                    );
                  } else {
                    barcodeController.start();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pemindaian dimulai...')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: isFoodTab
                  ? const Text(
                "Mulai Memindai",
                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
              )
                  : const Text(
                "Pindai Barcode",
                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}



class _KeepAlivePage extends StatefulWidget {
  final Widget child;

  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}