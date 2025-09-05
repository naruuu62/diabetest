import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:diabetest/services/edamam_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

import '../presentation/scan_result.dart';
import 'gemini_food_services.dart';
import 'gemini_services.dart';
import 'product_ingredients_service.dart';
enum ScanType { food, product }


List<CameraDescription>? cameras;

class Recognition {
  String id;
  String label;
  double score;
  Rect location;
  bool isProcessingGemini;
  final ScanType? scanType;

  Recognition({
    required this.id,
    required this.label,
    required this.score,
    required this.location,
    this.isProcessingGemini = false,
    this.scanType,

  });
}

// ... (Fungsi _convertCameraImage, _preProcessImage, applyNMS, _calculateIoU tetap sama) ...
img.Image _convertCameraImage(CameraImage image) {
  final int width = image.width;
  final int height = image.height;
  final int uvRowStride = image.planes[1].bytesPerRow;
  final int uvPixelStride = image.planes[1].bytesPerPixel!;

  final yuvBytes = List.generate(3, (i) => image.planes[i].bytes);
  final yPlane = yuvBytes[0];
  final uPlane = yuvBytes[1];
  final vPlane = yuvBytes[2];

  final imageConverted = img.Image(width: width, height: height);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int uvIndex =
          uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
      final int index = y * width + x;
      final yp = yPlane[index];
      final up = uPlane[uvIndex];
      final vp = vPlane[uvIndex];

      int r = (yp + 1.402 * (vp - 128)).round().clamp(0, 255);
      int g = (yp - 0.344136 * (up - 128) - 0.71414 * (vp - 128))
          .round()
          .clamp(0, 255);
      int b = (yp + 1.772 * (up - 128)).round().clamp(0, 255);

      imageConverted.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  return imageConverted;
}

List<List<List<List<double>>>> _preProcessImage(img.Image image) {
  final resizedImage = img.copyResize(image, width: 640, height: 640);
  final imageMatrix = List.generate(
    640,
        (y) => List.generate(
      640,
          (x) {
        final pixel = resizedImage.getPixel(x, y);
        return [
          pixel.r.toDouble() / 255.0,
          pixel.g.toDouble() / 255.0,
          pixel.b.toDouble() / 255.0,
        ];
      },
    ),
  );
  return [imageMatrix];
}

List<Recognition> applyNMS(List<Recognition> recognitions,
    {double iouThreshold = 0.5}) {
  recognitions.sort((a, b) => b.score.compareTo(a.score));
  final picked = <Recognition>[];

  while (recognitions.isNotEmpty) {
    final current = recognitions.removeAt(0);
    picked.add(current);

    recognitions.removeWhere((other) {
      final iou = _calculateIoU(current.location, other.location);
      return iou > iouThreshold;
    });
  }

  return picked;
}

double _calculateIoU(Rect a, Rect b) {
  final double intersectX =
  math.max(0, math.min(a.right, b.right) - math.max(a.left, b.left));
  final double intersectY =
  math.max(0, math.min(a.bottom, b.bottom) - math.max(a.top, b.top));
  final double intersection = intersectX * intersectY;
  final double union =
      a.width * a.height + b.width * b.height - intersection;
  return union > 0 ? (intersection / union) : 0.0;
}


class YoloTesting extends StatefulWidget {
  final String modelPath;
  final String labelsPath;
  final ScanType scanType;

  const YoloTesting({
    Key? key,
    required this.modelPath,
    required this.labelsPath,
    required this.scanType,
  }) : super(key: key);

  @override
  State<YoloTesting> createState() => YoloTestingState();
}

class YoloTestingState extends State<YoloTesting> {
  final geminiProduk = GeminiServices();
  final geminiFood = GeminiFoodServices();
  late CameraController _cameraController;
  late Interpreter _interpreter;
  bool isDetecting = false;
  List<String> labels = [];
  List<Recognition> recognitions = [];
  final int inputSize = 640;
  final double threshold = 0.2;
  bool isCameraInitialized = false;
  bool isScanning = false;

  Map<String, String> geminiCache = {};
  CameraImage? lastCameraImage;

  final GlobalKey<_ResizableScannerOverlayState> _overlayKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    await loadModel();
    await loadLabels();

    cameras = await availableCameras();
    _cameraController = CameraController(
      cameras![0],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _cameraController.initialize();

    if (mounted) {
      setState(() { isCameraInitialized = true; });

      _cameraController.startImageStream((CameraImage image) {
        lastCameraImage = image;

      });
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _interpreter.close();
    super.dispose();
  }

  Future<void> _pushScanResult() async {
    if (recognitions.isEmpty) return;

    // Ambil recognition pertama (atau bisa diganti logika sesuai kebutuhan)
    final rec = recognitions.first;

    // Panggil FoodNinjas untuk nutrisi jika belum dipanggil
    final nutrition = await ninjaS.getNutrition(rec.label);

    final productData = {
      'product_name': rec.label,
      'generic_name': nutrition != null
          ? "Kalori: ${nutrition['calories'] ?? 0} kcal\n"
          "Karbohidrat: ${nutrition['carbohydrates_g'] ?? 0} g\n"
          "Gula: ${nutrition['sugar_g'] ?? 0} g\n"
          "Protein: ${nutrition['protein_g'] ?? 0} g"
          : 'Deskripsi tidak tersedia',
      'image_url': null, // bisa diganti kalau ada gambar
      'categories_tags': [], // bisa isi jika ada kategori
      'nutriments': nutrition ?? {},
    };

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScanR(productData: productData),
      ),
    );
  }

  Future<void> startScan() async {
    if (lastCameraImage == null || isScanning) return;

    setState(() { isScanning = true; });

    try {
      final overlayState = _overlayKey.currentState;
      if (overlayState == null) return;


      final scanRect = overlayState.getScanRect();
      final fullImage = _convertCameraImage(lastCameraImage!);


      final previewSize = _cameraController.value.previewSize!;

      final scaleX = fullImage.width / previewSize.height;
      final scaleY = fullImage.height / previewSize.width;

      final cropX = (scanRect.left * scaleX).toInt();
      final cropY = (scanRect.top * scaleY).toInt();
      final cropWidth = (scanRect.width * scaleX).toInt();
      final cropHeight = (scanRect.height * scaleY).toInt();


      final croppedImage = img.copyCrop(fullImage, x: cropX, y: cropY, width: cropWidth, height: cropHeight);

      // Menjalankan deteksi pada gambar yang sudah dipotong
      await runObjectDetection(croppedImage: croppedImage);

    } catch (e) {
      print("Error during scan: $e");
    } finally {
      if(mounted) {
        setState(() { isScanning = false; });
      }
    }
  }


  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(widget.modelPath);
      print('Model ${widget.modelPath} berhasil dimuat');
    } catch (e) {
      print('Gagal memuat model: $e');
    }
  }

  Future<void> loadLabels() async {
    try {
      final labelsFile = await rootBundle.loadString(widget.labelsPath);
      labels = labelsFile.split('\n').where((label) => label.isNotEmpty).toList();
    } catch (e) {
      print('Gagal memuat label: $e');
    }
  }

  Future<void> runObjectDetection({img.Image? croppedImage}) async {
    final imageToProcess = croppedImage ?? _convertCameraImage(lastCameraImage!);
    final preprocessedImage = await compute(_preProcessImage, imageToProcess);

    final outputShape = _interpreter.getOutputTensor(0).shape;
    final outputBuffer = List.generate(
      outputShape[0], (_) => List.generate(outputShape[1], (_) => List.filled(outputShape[2], 0.0)),
    );

    _interpreter.run(preprocessedImage, outputBuffer);

    var rawRecognitions = _postprocessOutput(outputBuffer[0]);
    var filteredRecognitions = applyNMS(rawRecognitions);

    for (var rec in filteredRecognitions) {
      final cacheKey = '${rec.id}_${rec.location}';
      if(!geminiCache.containsKey(cacheKey)) {
        rec.isProcessingGemini = true;
        classifyWithGemini(lastCameraImage!, rec, cacheKey);
      } else {
        rec.label = geminiCache[cacheKey]!;
      }
    }


    if(mounted) {
      setState(() {
        recognitions = filteredRecognitions;
      });
    }
    await _pushScanResult();
  }

  List<Recognition> _postprocessOutput(List<List<double>> output) {

    final transposedOutput = List.generate(
      output[0].length, (i) => List.generate(output.length, (j) => output[j][i]),
    );

    final List<Recognition> detectedObjects = [];

    for (final detection in transposedOutput) {
      final scores = detection.sublist(4);
      double maxScore = 0;
      int bestClassId = -1;

      for (int i = 0; i < scores.length; i++) {
        if (scores[i] > maxScore) {
          maxScore = scores[i];
          bestClassId = i;
        }
      }

      if (maxScore > threshold) {
        final String label = labels.length > bestClassId ? labels[bestClassId] : 'unknown';

        final double centerX = detection[0] * inputSize;
        final double centerY = detection[1] * inputSize;
        final double width = detection[2] * inputSize;
        final double height = detection[3] * inputSize;

        final double left = (centerX - width / 2).clamp(0, inputSize.toDouble());
        final double top = (centerY - height / 2).clamp(0, inputSize.toDouble());

        final location = Rect.fromLTWH(left, top, width, height);

        detectedObjects.add(
          Recognition(
            id: '$bestClassId',
            label: label,
            score: maxScore,
            location: location, scanType: null,
          ),
        );
      }
    }
    return detectedObjects;
  }

  Future<void> classifyWithGemini(
      CameraImage cameraImage, Recognition rec, String cacheKey) async {
    try {
      final fullImage = _convertCameraImage(cameraImage);

      final left = rec.location.left.toInt().clamp(0, fullImage.width - 1);
      final top = rec.location.top.toInt().clamp(0, fullImage.height - 1);
      final width = rec.location.width.toInt().clamp(1, fullImage.width - left);
      final height = rec.location.height.toInt().clamp(1, fullImage.height - top);

      if (width <= 0 || height <= 0) {
        rec.isProcessingGemini = false;
        return;
      }

      final cropped = img.copyCrop(fullImage, x: left, y: top, width: width, height: height);
      final jpegBytes = Uint8List.fromList(img.encodeJpg(cropped, quality: 85));

      String geminiLabel;
      if (widget.scanType == ScanType.product) {
        geminiLabel = await geminiProduk.identifyObject(jpegBytes);
      } else {
        geminiLabel = await geminiFood.identifyObject(jpegBytes);
      }

      geminiCache[cacheKey] = geminiLabel;
      fetchNutritionForRecognition(rec);

      if (mounted) {
        setState(() {
          final index = recognitions.indexWhere((r) => r.id == rec.id && r.location == rec.location);
          if (index != -1) {
            recognitions[index].label = geminiLabel;
            recognitions[index].isProcessingGemini = false;
          }
        });
      }
    } catch (e) {
      print("Error calling Gemini: $e");
      if(mounted) {
        setState(() {
          rec.isProcessingGemini = false;
        });
      }
    }
  }

  final ninjaS = EdamamService();

  Future<void> fetchNutritionForRecognition(Recognition rec) async {
    final nutrition = await ninjaS.getNutrition(rec.label);
    if (nutrition != null) {
      final double carbs = nutrition['carbohydrates_g'] ?? 0;
      if (mounted) {
        setState(() {
          final index = recognitions.indexWhere((r) => r.id == rec.id && r.location == rec.location);
          if (index != -1) {
            recognitions[index].label = "${rec.label}\n"
                "Kalori: ${nutrition['calories']} kcal\n"
                "Karbohidrat: ${carbs} g\n"
                "Gula: ${nutrition['sugar_g']} g\n"
                "Protein: ${nutrition['protein_g']} g\n";
            recognitions[index].isProcessingGemini = false;
          }
        });
      }
    } else {
      print("Data nutrisi tidak ditemukan untuk ${rec.label}");
    }
  }


  @override
  Widget build(BuildContext context) {
    if (!isCameraInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_cameraController),
        // Bounding box tidak lagi ditampilkan saat scan manual
        // CustomPaint(
        //   painter: BoundingBoxPainter(...)
        // ),
        ResizableScannerOverlay(
          key: _overlayKey, // Memberikan key ke overlay
          isScanning: isScanning, // Memberitahu overlay kapan harus beranimasi
        ),
      ],
    );
  }
}

// ... (class BoundingBoxPainter tetap sama) ...
class BoundingBoxPainter extends CustomPainter {
  final List<Recognition> recognitions;
  final int inputSize;
  final Size screenSize;
  final Size previewSize;

  BoundingBoxPainter({
    required this.recognitions,
    required this.inputSize,
    required this.screenSize,
    required this.previewSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final recognition in recognitions) {
      paint.color = recognition.score > 0.5 ? Colors.green : Colors.red;

      final scaleX = size.width / inputSize;
      final scaleY = size.height / inputSize;

      final rect = Rect.fromLTRB(
        recognition.location.left * scaleX,
        recognition.location.top * scaleY,
        recognition.location.right * scaleX,
        recognition.location.bottom * scaleY,
      );

      canvas.drawRect(rect, paint);

      final labelBg = Paint()
        ..color = recognition.isProcessingGemini ? Colors.blue.withOpacity(0.8) : paint.color.withOpacity(0.8)
        ..style = PaintingStyle.fill;

      final labelText = recognition.isProcessingGemini
          ? '${recognition.label} (verifying...)'
          : '${recognition.label} ${(recognition.score * 100).toStringAsFixed(1)}%';

      textPainter.text = TextSpan(
        text: labelText,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      );

      textPainter.layout();
      final labelRect = Rect.fromLTWH(rect.left, rect.top - 24, textPainter.width + 8, 24);
      canvas.drawRect(labelRect, labelBg);
      textPainter.paint(canvas, Offset(rect.left + 4, rect.top - 20));
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// --- WIDGET BARU: OVERLAY PEMINDAI INTERAKTIF ---
class ResizableScannerOverlay extends StatefulWidget {
  final bool isScanning; // Menerima status pemindaian
  const ResizableScannerOverlay({Key? key, this.isScanning = false}) : super(key: key);

  @override
  _ResizableScannerOverlayState createState() => _ResizableScannerOverlayState();
}

class _ResizableScannerOverlayState extends State<ResizableScannerOverlay> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Offset _initialFocalPoint = Offset.zero;
  double _initialScale = 1.0;

  // DITAMBAHKAN: Animation controller untuk garis pemindai
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );
  }

  @override
  void didUpdateWidget(ResizableScannerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Memulai atau menghentikan animasi berdasarkan state isScanning
    if (widget.isScanning && !oldWidget.isScanning) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isScanning && oldWidget.isScanning) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // DITAMBAHKAN: Fungsi untuk diekspos ke parent
  Rect getScanRect() {
    final size = context.size!;
    final initialSize = size.width * 0.7;
    final boxSize = initialSize * _scale;
    final centerX = size.width / 2 + _offset.dx;
    final centerY = size.height / 2 + _offset.dy;
    return Rect.fromCenter(center: Offset(centerX, centerY), width: boxSize, height: boxSize);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final initialSize = constraints.maxWidth * 0.7;
        final minSize = constraints.maxWidth * 0.3;
        final maxSize = constraints.maxWidth * 1.2;

        return GestureDetector(
          onScaleStart: (details) {
            if(widget.isScanning) return; // Nonaktifkan gesture saat memindai
            _initialFocalPoint = details.focalPoint;
            _initialScale = _scale;
          },
          onScaleUpdate: (details) {
            if(widget.isScanning) return;
            setState(() {
              _scale = (_initialScale * details.scale).clamp(minSize / initialSize, maxSize / initialSize);
              final delta = details.focalPoint - _initialFocalPoint;
              _offset += delta;
              _initialFocalPoint = details.focalPoint;
            });
          },
          child: AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: ScannerBoxPainter(
                  boxSize: initialSize * _scale,
                  offset: _offset,
                  isScanning: widget.isScanning,
                  scanAnimationValue: _scanAnimation.value,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// --- CUSTOM PAINTER BARU UNTUK KOTAK PEMINDAI KUNING ---
class ScannerBoxPainter extends CustomPainter {
  final double boxSize;
  final Offset offset;
  final bool isScanning;
  final double scanAnimationValue;

  ScannerBoxPainter({
    required this.boxSize,
    required this.offset,
    required this.isScanning,
    required this.scanAnimationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2 + offset.dx;
    final centerY = size.height / 2 + offset.dy;

    final rect = Rect.fromCenter(center: Offset(centerX, centerY), width: boxSize, height: boxSize);

    final path = Path();
    final cornerLength = boxSize * 0.1;

    path.moveTo(rect.left, rect.top + cornerLength);
    path.lineTo(rect.left, rect.top);
    path.lineTo(rect.left + cornerLength, rect.top);

    path.moveTo(rect.right - cornerLength, rect.top);
    path.lineTo(rect.right, rect.top);
    path.lineTo(rect.right, rect.top + cornerLength);

    path.moveTo(rect.right, rect.bottom - cornerLength);
    path.lineTo(rect.right, rect.bottom);
    path.lineTo(rect.right - cornerLength, rect.bottom);

    path.moveTo(rect.left + cornerLength, rect.bottom);
    path.lineTo(rect.left, rect.bottom);
    path.lineTo(rect.left, rect.bottom - cornerLength);

    canvas.drawPath(path, paint);

    // Menggambar garis pemindai animasi jika isScanning true
    if (isScanning) {
      final lineY = rect.top + rect.height * scanAnimationValue;
      final linePaint = Paint()
        ..color = Colors.yellow.withOpacity(0.9)
        ..strokeWidth = 3.0
        ..shader = LinearGradient(
          colors: [Colors.yellow.withOpacity(0), Colors.yellow, Colors.yellow.withOpacity(0)],
        ).createShader(Rect.fromLTWH(rect.left, lineY - 2, rect.width, 4));

      canvas.drawLine(
        Offset(rect.left, lineY),
        Offset(rect.right, lineY),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ScannerBoxPainter oldDelegate) {
    // Gambar ulang hanya jika ada perubahan
    return boxSize != oldDelegate.boxSize ||
        offset != oldDelegate.offset ||
        isScanning != oldDelegate.isScanning ||
        scanAnimationValue != oldDelegate.scanAnimationValue;
  }
}

