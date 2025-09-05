import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../components/colors.dart';

class ForgotPassword extends StatefulWidget{
  const ForgotPassword({super.key});
  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword>{
  int _currentPage = 0;
  final TextEditingController _nomorTeleponController = TextEditingController();
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
              'Masukkan nomor teleponmu',
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
                Image.asset('assets/images/forgot.png'),
              ),

              SizedBox(height: 40,),

              Center(
                child: Text(
                  'Silakan masukkan nomor telepon kamu untuk \n                 menerima kode verifikasi',
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
                        borderRadius: BorderRadius.circular(12),
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
                    Navigator.pushNamed(context, '/signup');
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