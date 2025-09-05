import 'package:diabetest/components/colors.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double opacity = 0.0;
  Timer? _delayTimer;

  final int _seconds = 2;


  @override
  void initState() {
    super.initState();
    _delayTimer = Timer(Duration(seconds: _seconds), () {
      setState(() {
        opacity = 1.0;
      });
    });

    Future.delayed(const Duration(seconds: 7), () {
      Navigator.pushReplacementNamed(context, '/onBoarding1');
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scan,
      body: Stack(
        fit: StackFit.expand,
        children: [

          Positioned(
            top: -50,
            right: -60,
            child: AnimatedOpacity(
              opacity: opacity,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn,
              child: Image.asset(
                'assets/images/Ellipse_54.png',
                width: 200,
              ),
            ),
          ),

          Positioned(
            top: 200,
            left: 40,
            child: AnimatedOpacity(
            opacity: opacity,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
            child: Image.asset(
              'assets/images/Ellipse_53.png',
              width: 200,
            ),
          ),

          ),


          Positioned(
            bottom: -70, // Posisi dari bawah
            left: -40, // Posisi dari kiri
            child: AnimatedOpacity(
              opacity: opacity,
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeIn,
              child: Image.asset(
                'assets/images/Ellipse_55.png',
                width: 300,
              ),
            ),
          ),


          Positioned(
            bottom: 20,
            child: AnimatedOpacity(
              opacity: opacity,
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeIn,
              child: Image.asset(
                'assets/images/Ellipse_53.png',
                width: 520,
              ),
            ),
          ),

          Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 200,
              height: 200,
            ),
          ),

          Positioned(
            bottom: 270,
            left: -75,
            child: AnimatedOpacity(
              opacity: opacity,
              duration: const Duration(milliseconds: 3000),
              curve: Curves.easeInToLinear,
              child: Image.asset(
                'assets/images/nama_apps.png',
                width: 520,
              ),
            ),
          )
        ],
      ),
    );
  }
  }

