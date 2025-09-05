import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:diabetest/presentation/Article.dart';
import 'package:diabetest/presentation/auth/forgot_password.dart';
import 'package:diabetest/presentation/auth/login_page.dart';
import 'package:diabetest/presentation/auth/new_password.dart';
import 'package:diabetest/presentation/auth/signup_page.dart';
import 'package:diabetest/presentation/auth/verifikasi_OTP.dart';
import 'package:diabetest/presentation/edit_profil.dart';
import 'package:diabetest/presentation/history.dart';
import 'package:diabetest/presentation/homescreen.dart';
import 'package:diabetest/presentation/on_boarding1.dart';
import 'package:diabetest/presentation/on_boarding2.dart';
import 'package:diabetest/presentation/on_boarding3.dart';
import 'package:diabetest/presentation/on_boarding4.dart';
import 'package:diabetest/presentation/profile_page.dart';
import 'package:diabetest/presentation/question_user/question1.dart';
import 'package:diabetest/presentation/question_user/question2.dart';
import 'package:diabetest/presentation/question_user/question3.dart';
import 'package:diabetest/presentation/question_user/question4.dart';
import 'package:diabetest/presentation/question_user/question5.dart';
import 'package:diabetest/presentation/question_user/question_process.dart';
import 'package:diabetest/presentation/question_user/tes.dart';
import 'package:diabetest/presentation/results.dart';
import 'package:diabetest/presentation/scan_product.dart';
import 'package:diabetest/presentation/scan_result.dart';
import 'package:diabetest/presentation/splash_screen.dart';
import 'package:diabetest/services/yolo_testing.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';



List<CameraDescription>? cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  cameras = await availableCameras();


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
      title: 'Diabetest',
      theme: ThemeData(
        fontFamily: 'circular'
      ),

      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/scan': (context) => const ScanProduct(),
        '/yolo_testing': (context) => const YoloTesting(modelPath: '', labelsPath: '', scanType: ScanType.food,),
        '/onBoarding1' : (context) => const OnBoarding1(),
        '/onBoarding2' : (context) => const OnBoarding2(),
        '/onBoarding3' : (context) => const OnBoarding3(),
        '/onBoarding4' : (context) => const OnBoarding4(),
        '/signup' : (context) => const SignUp(),
        '/login' : (context) => const LoginPage(),
        '/forgot_password' : (context) => const ForgotPassword(),
        '/verifikasi_OTP' : (context) => const VerifikasiOTP(verificationId: '', userName: '', phoneNumber: '',),
        '/new_password' : (context) => const NewPassword(),
        '/question1' : (context) => const Question1(),
        '/question2' : (context) => const Question2(),
        '/question3' : (context) => const Question3(),
        '/question4' : (context) => const Question4(),
        '/question5' : (context) => const Question5(),
        '/questionwait' : (context) => const QuestionProcess(),
        '/profile' : (context) => const ProfilePage(),
        '/edit_profile' : (context) => const EditProfilePage(),
        '/homepage': (context) => const DashboardScreen(),
        '/history': (context) => const HistoryPage(foodData: {},),
        '/results' : (context) => ResultPage(result: ScanResult(imageBytes: Uint8List(0), tags: const [], primaryLabel: '')),
        '/article' : (context) => const ArticleScreen(),
        '/scanR' : (context) => const ScanR(productData: {}),


      }
    );
  }
}

