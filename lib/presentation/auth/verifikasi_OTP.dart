import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';


import '../../components/colors.dart';
import '../../services/auth_services.dart';
import '../homescreen.dart';



class VerifikasiOTP extends StatefulWidget{
  final String verificationId;
  final String userName;
  final String phoneNumber;

  const VerifikasiOTP({
    Key? key,
    required this.verificationId,
    required this.userName,
    required this.phoneNumber,
  }) : super(key: key);
  @override
  State<VerifikasiOTP> createState() => _VerifikasiOTPState();
}

class _VerifikasiOTPState extends State<VerifikasiOTP>{
  // Hanya satu controller yang dibutuhkan
  final TextEditingController _otpController = TextEditingController();

  bool _canResendCode = false;
  late Timer timer;
  int _timerSeconds = 60;

  final authService _authService = authService();
  bool isLoading = false;

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 60,
    textStyle: const TextStyle(fontSize: 22, color: Colors.black),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.transparent),
    ),
  );

  Future<void> _handleVerifyOTP() async {
    if (_otpController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan 6 digit kode OTP')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userCredential = await _authService.signInWithPhoneNumber(
        verificationId: widget.verificationId,
        smsCode: _otpController.text.trim(),
      );

      if (userCredential.user != null) {
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

        if (isNewUser) {
          await userCredential.user!.updateDisplayName(widget.userName);
        }

        await _authService.saveUser(userCredential.user!);

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            // Arahkan ke DashboardScreen setelah berhasil
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
                (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kode OTP Salah atau Error: ${e.message}")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _canResendCode = false;
      _timerSeconds = 60;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canResendCode = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      // PERBAIKAN 2: Menambahkan SingleChildScrollView untuk mengatasi overflow
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20), // Memberi sedikit jarak dari status bar
                      IconButton(onPressed: () => Navigator.pop(context), icon: Image.asset('assets/images/arrow_back.png')),
                      const SizedBox(height: 30),
                      Column(
                          children: [
                            const Center(
                              child: Text(
                                'Verifikasi OTP',
                                style: TextStyle(
                                  fontFamily: 'circular',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40,),

                            Center(
                              child: Image.asset('assets/images/OTP.png'),
                            ),

                            const SizedBox(height: 40,),

                            const Center(
                              child: Text(
                                // PERBAIKAN: Mengubah teks dari 4 digit menjadi 6 digit
                                'Masukkan 6 digit kode yang telah dikirim ke \n                 nomor telepon kamu',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'circular',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ),

                            const SizedBox(height: 60,),

                            Pinput(
                              // PERBAIKAN 1: Mengubah panjang OTP menjadi 6
                              length: 6,
                              controller: _otpController, // Menggunakan controller yang benar
                              defaultPinTheme: defaultPinTheme,
                              focusedPinTheme: defaultPinTheme.copyWith(
                                decoration: defaultPinTheme.decoration!.copyWith(
                                  border: Border.all(color: Colors.blueAccent),
                                ),
                              ),
                              onCompleted: (pin) => _handleVerifyOTP(),
                            ),

                            const SizedBox(height: 32),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (!_canResendCode)
                                  Text(
                                    'Kirim ulang dalam 00:${_timerSeconds.toString().padLeft(2, '0')}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                if (_canResendCode)
                                  Row(
                                    children: [
                                      Text(
                                        'Belum menerima kode? ',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                      GestureDetector(
                                        onTap: (){
                                          // Tambahkan logika kirim ulang OTP di sini
                                          _startTimer();
                                        },
                                        child: const Text(
                                          'Kirim ulang',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 48),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                // PERBAIKAN 3: Menghubungkan ke fungsi verifikasi dan disable saat loading
                                onPressed: isLoading ? null : _handleVerifyOTP,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4C66CD),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 0,
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3,)
                                    : const Text(
                                  'Verifikasi', // Mengubah teks tombol
                                  style: TextStyle(
                                    fontFamily: 'circular',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
                          ]
                      )
                    ]
                )
            )
        )
    );
  }
}
