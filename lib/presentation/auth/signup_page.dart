import 'package:diabetest/components/HeaderCliper.dart';
import 'package:diabetest/presentation/auth/verifikasi_OTP.dart';
import 'package:diabetest/presentation/homescreen.dart';
import 'package:diabetest/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/user_model.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _isPasswordObscured = true;
  final TextEditingController _nomorTeleponController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String formatPhoneNumber(String input) {
    String phone = input.trim();


    phone = phone.replaceAll(RegExp(r'\s+|-'), '');


    if (phone.startsWith('0')) {
      phone = '+62${phone.substring(1)}';
    }
    else if (!phone.startsWith('+62')) {
      phone = '+62$phone';
    }

    return phone;
  }

  final authService _authService = authService();
  bool isLoading = false;

  Future<void> _handleSignUp() async {
    if (_nameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty||
        _nomorTeleponController.text.isEmpty
    ) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua bidang harus diisi')));
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata Sandi dan Konfirmasi Kata Sandi tidak cocok!'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final String phoneNumber = formatPhoneNumber(_nomorTeleponController.text);
      await _authService.sendPhoneNumberVerification(
        phoneNumber: phoneNumber,

        onCodeSent: (String verificationId, int? resendToken) {

          if (!mounted) return;
          setState(() { isLoading = false; });


          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifikasiOTP(
                verificationId: verificationId,
                userName: _nameController.text.trim(),
                phoneNumber: phoneNumber,
              ),
            ),
          );
        },

        onVerificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() { isLoading = false; });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal mengirim OTP: ${e.message}")),
          );
        },
      );
    } catch (e) {

      if (!mounted) return;
      setState(() { isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi error: ${e.toString()}")),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userCredential = await _authService.signInWithGoogle();
      await _authService.saveUser(userCredential!.user!);
      {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/question1', (route) => false);
        }
      }
    } catch (e) {
    } finally {

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body:
      SingleChildScrollView(
        child: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/images/vector2.png',
                scale: 0.8,
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Image.asset('assets/images/Ellipse_56.png')),
              Positioned(
                top: 20,
                left: 10,
                child: Image.asset('assets/images/Ellipse_53.png'),
              ),
        ]
          ),
                    SizedBox(height: 25),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 20), child:
                    Column(
                      children: [
                    Text(
                      'Buat Akun Baru',
                      style: TextStyle(
                        fontFamily: 'circular',
                        fontWeight: FontWeight.bold,
                        fontSize: 29,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Buat Akun dengan menggunakan',
                      style: TextStyle(
                        fontFamily: 'circular',
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'email dan password',
                      style: TextStyle(
                        fontFamily: 'circular',
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 30),

                    // Form Fields
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama Lengkap Field
                        Text(
                          'Nama Lengkap',
                          style: TextStyle(
                            fontFamily: 'circular',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Contoh: Budi Santoso',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF4C66CD)),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Nomor Telepon Field
                        Text(
                          'Nomor Telepon',
                          style: TextStyle(
                            fontFamily: 'circular',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _nomorTeleponController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Contoh: 0812-3456-7890',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF4C66CD)),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Kata Sandi Field
                        Text(
                          'Kata Sandi',
                          style: TextStyle(
                            fontFamily: 'circular',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: _isPasswordObscured,
                          decoration: InputDecoration(
                            hintText: 'Minimal 8 karakter',
                            hintStyle:
                            TextStyle(color: Colors.grey[400], fontSize: 14),
                            filled: true,
                            fillColor: Colors.grey[50],
                            // 3. Ubah suffixIcon menjadi IconButton agar bisa ditekan
                            suffixIcon: IconButton(
                              // 4. Ganti ikon berdasarkan state
                              icon: Icon(
                                _isPasswordObscured
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey[400],
                              ),
                              // 5. Buat fungsi untuk mengubah state saat ditekan
                              onPressed: () {
                                setState(() {
                                  _isPasswordObscured = !_isPasswordObscured;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF4C66CD)),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),


                        Text(
                          'Konfirmasi Kata Sandi',
                          style: TextStyle(
                            fontFamily: 'circular',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Ulangi kata sandi',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                            filled: true,
                            fillColor: Colors.grey[50],
                            suffixIcon: Icon(Icons.visibility_off, color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF4C66CD)),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                        SizedBox(height: 40),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              _handleSignUp();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4C66CD),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Daftar',
                              style: TextStyle(
                                fontFamily: 'circular',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Atau daftar dengan
                        Center(
                          child: Text(
                            'atau daftar dengan',
                            style: TextStyle(
                              fontFamily: 'circular',
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Social Login Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Apple
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.apple,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),

                            GestureDetector(
                              onTap: _handleGoogleSignIn,
                              child:
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Center(
                                    child: Image.asset(
                                      'assets/images/google.png',
                                      width: 24,
                                      height: 24,
                                    )
                                ),
                              ),
                            ),

                            // Facebook
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xFF1877F2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.facebook,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),

                        Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Sudah punya akun?',
                                  style: TextStyle(
                                    fontFamily: 'circular',
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/login');
                                    },
                                    child: Text(
                                      'Masuk',
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'circular',
                                          color: Color(0xFF4C66CD)),
                                    ))
                              ],
                            )),
                        SizedBox(height: 30),
                      ],
                    ),
                        ]
                    )
    )
                  ],
                ),
              )
    );
  }
}