import 'dart:math' as math;
import 'package:diabetest/components/colors.dart';
import 'package:diabetest/services/gemini_services.dart';
import 'package:flutter/material.dart';

class QuestionProcess extends StatefulWidget {
  const QuestionProcess({super.key});

  @override
  State<QuestionProcess> createState() => _QuestionProcessState();
}

class _QuestionProcessState extends State<QuestionProcess> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final GeminiServices _geminiServices = GeminiServices();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7), // Durasi awal bisa apa saja, nanti akan terus diulang
    )..repeat(); // Mengulang animasi terus-menerus

    _startAnalysisAndNavigate();
  }

  void _startAnalysisAndNavigate() async {
    try {

      await _geminiServices.getAnalysisFromGemini();


      _animationController.stop();


      if (mounted) {
        Navigator.pushReplacementNamed(context, '/homepage');
      }
    } catch (e) {

      if (mounted) {
        _animationController.stop(); // Hentikan animasi saat error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get analysis: ${e.toString()}')),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scan,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animationController.value * 2.0 * math.pi,
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/images/time.png',
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                textAlign: TextAlign.center,
                'Tunggu sebentar ya, kami sedang menganalisis\n jawaban kamu untuk memberikan hasil yang\n sesuai.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: darkWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}