import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserAnalysis {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;

  Future<void> saveQuestionUser1(String gender, DateTime birthDate, String height, String weight) async {
    _user = _auth.currentUser;
    DocumentReference userDoc = FirebaseFirestore.instance.collection('identity').doc(_user?.uid);
    await userDoc.set({
      'gender': gender,
      'birthDate': birthDate,
      'height': height,
      'weight': weight,
    });

  }

  Future<void> saveQuestionUser2(String? diabetes, String tipe) async {
    _user = _auth.currentUser;
    DocumentReference userDoc = FirebaseFirestore.instance.collection('identity').doc(_user?.uid);
    await userDoc.update({
      'diabetes': diabetes,
      'tipe': tipe,
    });

  }

  Future<void> saveQuestionUser3(String Diabethistory, String bloodhistory, String kolestrolHistory) async {
    _user = _auth.currentUser;
    DocumentReference userDoc = FirebaseFirestore.instance.collection('identity').doc(_user?.uid);
    await userDoc.update({
      'diabetes_keluarga': Diabethistory,
      'darah_tinggi': bloodhistory,
      'kolestrol': kolestrolHistory,
    });

  }

  Future<void> saveQuestionUser4(String workout, String alcohol) async {
    _user = _auth.currentUser;
    DocumentReference userDoc = FirebaseFirestore.instance.collection(
        'identity').doc(_user?.uid);
    await userDoc.update({
      'olahraga': workout,
      'alkohol': alcohol,
    });
  }

    Future<void> saveQuestionUser5(String foodType) async {
      _user = _auth.currentUser;
      DocumentReference userDoc = FirebaseFirestore.instance.collection('identity').doc(_user?.uid);
      await userDoc.update({
        'pola_makan': foodType,
      });

    }

  }

