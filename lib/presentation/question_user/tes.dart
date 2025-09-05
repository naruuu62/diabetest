

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode Nutrition App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _scannedBarcode = '';
  Map<String, dynamic>? _productData;
  bool _isLoading = false;

  Future<void> _fetchProductData(String barcode) async {
    setState(() {
      _isLoading = true;
    });

    final apiUrl = 'https://world.openfoodfacts.org/api/v0/product/$barcode.json';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          setState(() {
            _productData = data['product'];
          });
        } else {
          setState(() {
            _productData = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk tidak ditemukan.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data produk. Status Code: ${response.statusCode}')),
        );
      }
    } catch (e) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Barcode & Gizi'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Mulai Pindai Barcode'),
                onPressed: () async {
                  final String? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BarcodeScannerScreen(),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _scannedBarcode = result;
                    });
                    _fetchProductData(result);
                  }
                },
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_productData != null)
                Expanded(
                  child: SingleChildScrollView(
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _productData!['product_name'] ?? 'Nama tidak diketahui',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            Text('Barcode: $_scannedBarcode', style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 10),
                            const Text(
                              'Informasi Gizi (per 100g):',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            _buildNutritionRow('Kalori', _productData!['nutriments']?['energy-kcal_100g']?.toString()),
                            _buildNutritionRow('Karbohidrat', _productData!['nutriments']?['carbohydrates_100g']?.toString()),
                            _buildNutritionRow('Gula', _productData!['nutriments']?['sugars_100g']?.toString()),
                            _buildNutritionRow('Protein', _productData!['nutriments']?['proteins_100g']?.toString()),
                            _buildNutritionRow('Lemak', _productData!['nutriments']?['fat_100g']?.toString()),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else
                const Text(
                  'Tekan tombol untuk memindai barcode produk dan melihat informasi gizi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value != null ? '$value g' : 'Tidak ada data', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class BarcodeScannerScreen extends StatelessWidget {
  const BarcodeScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pindai Barcode'),
      ),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
        ),
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String barcodeValue = barcodes.first.rawValue ?? 'No value found';
            Navigator.pop(context, barcodeValue);
          } else {
            final String barcodeValue = 'No barcode found';
            //Navigator.pop(context, barcodeValue);
          }
        },
      ),
    );
  }
}