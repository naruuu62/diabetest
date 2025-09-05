import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../components/colors.dart';

class NewPassword extends StatefulWidget{
  const NewPassword({super.key});
  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  bool _isPasswordObscured = true;
  int _currentPage = 2;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Menggunakan AlertDialog untuk struktur dasar
        return AlertDialog(
          // Mengatur bentuk dialog dengan sudut melengkung
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          // Menghilangkan padding default agar konten bisa mepet ke tepi
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Agar tinggi dialog menyesuaikan konten
            children: [
              const Text(
                'Kata sandi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Berhasil diubah',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.green, // Warna hijau untuk pesan sukses
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ketuk dimana saja untuk menutup',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        body:
        Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 35), child:
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(onPressed: (){}, icon: Image.asset('assets/images/arrow_back.png')),
              SizedBox(height: 30),
              Column(
                  children: [
                    Center(
                      child: Text(
                        'Buat kata sandi baru',
                        style: TextStyle(
                          fontFamily: 'circular',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 40,),

                    Center(
                      child:
                      Image.asset('assets/images/newPass.png'),
                    ),

                    SizedBox(height: 40,),

                    Center(
                      child: Text(
                        'Silakan masukkan kata sandi baru kamu, lalu \n                 konfirmasi untuk melanjutkan',
                        style: TextStyle(
                          fontFamily: 'circular',
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    SizedBox(height: 60,),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordObscured
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey[400],
                                ),
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
                            obscureText: _isPasswordObscured,
                            decoration: InputDecoration(
                              hintText: 'Minimal 8 karakter',
                              hintStyle:
                              TextStyle(color: Colors.grey[400], fontSize: 14),
                              filled: true,
                              fillColor: Colors.grey[50],
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordObscured
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey[400],
                                ),
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
                        ]
                    ),

                    SizedBox(height: 40,),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          _showSuccessDialog(context);
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

                    SizedBox(height: 50,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          height: 8.0,
                          width: index == _currentPage ? 24.0 : 8.0,
                          decoration: BoxDecoration(
                            color: index == _currentPage ? scan : scan.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                  ]
              )



            ]
        )
        )
    );
  }
}