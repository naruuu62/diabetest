import 'package:diabetest/components/colors.dart';
import 'package:flutter/material.dart';

class OnBoarding4 extends StatefulWidget {
  const OnBoarding4({super.key});

  @override
  State<OnBoarding4> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnBoarding4> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/on_board4.png'), // Pastikan path ini benar
                fit: BoxFit.cover,
                opacity: 100,
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),


          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(

                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Spacer(),


                  const Text(
                    'Kenali & Cegah Diabetes Sejak Dini',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),


                  const Text(
                    'Diabetes membantumu memantau makanan, gaya hidup, dan risiko diabetes secara personal.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),


                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                            print('Tombol daftar ditekan!');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                          child: const Text(
                            'Daftar',
                            style: TextStyle(fontSize: 18, color: scan),
                          ),
                        ),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                            print('Tombol Lanjut ditekan!');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B72FF), // Warna tombol ungu
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30), // Sudut melengkung
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                          child: const Text(
                            'Masuk',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),



                      ]

                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}