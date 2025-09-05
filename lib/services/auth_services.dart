import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class authService {
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      return await firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      log("Gagal login dengan nomor telepon: ${e.code} - ${e.message}");
      throw e;
    }
  }

  Future<void> sendPhoneNumberVerification({
    required String phoneNumber,
    required Function(String, int?) onCodeSent,
    required Function(FirebaseAuthException) onVerificationFailed,
  }) async {
    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        log('Verifikasi otomatis berhasil.');
        await firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        log("Verifikasi gagal: ${e.code} - ${e.message}");
        onVerificationFailed(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        log("Kode OTP terkirim ke $phoneNumber");
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        log('Auto retrieval timeout. Verification ID: $verificationId');
      },
    );
  }


  Future<void> signOut() async {

    await googleSignIn.signOut();
    return await FirebaseAuth.instance.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    return await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String phoneNumber,
  }) async {
    AuthCredential credential =
    EmailAuthProvider.credential(email: phoneNumber, password: currentPassword);
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {

        return null;
      }
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential;
    } catch (e) {
      log("Error saat login dengan Google: $e");
      return null;
      // --------------------------------
    }
  }

  Future<void> saveUser(User user) async {
    final userRef = firestore.collection('user').doc(user.uid);
    try {
      return userRef.set({
        'uid': user.uid,
        'email': user.email ?? "",
        'phoneNumber': user.phoneNumber ?? "",
        'displayName': user.displayName ?? "",
        'photoURL': user.photoURL ?? "",
        'lastSignIn': FieldValue.serverTimestamp(), // Menambah info waktu login
      }, SetOptions(merge: true));
    } catch (e) {
      log(e.toString());
    }
  }
}