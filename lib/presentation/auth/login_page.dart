import 'package:diabetest/components/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../services/auth_services.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nomorTeleponController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final authService _authService = authService();
  bool _isPasswordObscured = true;
  bool isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userCredential = await _authService.signInWithGoogle();
      await _authService.saveUser(userCredential!.user!);
      {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/homepage', (route) => false);
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/images/vector.png',
                  scale: 0.8,
                ),
                Positioned(
                    top: 0,
                    left: 270,
                    child: Image.asset('assets/images/Ellipse_51.png')),
                Positioned(
                  bottom: 80,
                  left: 10,
                  child: Image.asset('assets/images/Ellipse_53.png'),
                ),
                Positioned(
                    top: 75,
                    left: 50,
                    child: Image.asset(
                      'assets/images/nama_apps.png',
                      scale: 0.8,
                    ))
              ],
            ),
            Center(
              child: Column(children: [
                Text(
                  'Selamat Datang!',
                  style: TextStyle(
                    fontFamily: 'circular',
                    fontWeight: FontWeight.bold,
                    fontSize: 29,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Silakan masuk menggunakan nomor',
                  style: TextStyle(
                    fontFamily: 'circular',
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'telepon yang sudah terdaftar',
                  style: TextStyle(
                    fontFamily: 'circular',
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 30),
              ]),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      hintStyle:
                      TextStyle(color: Colors.grey[400], fontSize: 14),
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

                  // --- PERUBAHAN DIMULAI DI SINI ---

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


                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/forgot_password');
                            },
                            child: Text(
                              'Lupa sandi?',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'circular',
                                  color: Colors.black),
                            ))
                      ]),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/homepage');
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
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
                        onTap: (){
                          _handleGoogleSignIn();
                        },
                        child: Container(
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
                  SizedBox(
                    height: 5,
                  ),
                  Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Belum punya akun?',
                            style: TextStyle(
                              fontFamily: 'circular',
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                              child: Text(
                                'Daftar',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'circular',
                                    color: Color(0xFF4C66CD)),
                              ))
                        ],
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}