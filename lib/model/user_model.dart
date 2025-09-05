import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String namaLengkap;
  final String noTelp;
  final String gender;
  final int umur;
  final double tinggi;
  final double berat;
  final String riwayatDiabetes;
  final String jenisDiabetes;
  final String riwayatKeluarga;
  final String olahraga;
  final String alkohol;
  final String polaMakan;
  final String riwayatDarahTinggi;
  final String riwayatKolesterol;
  final String? imageUrl;

  UserModel({
    required this.namaLengkap,
    required this.noTelp,
    required this.gender,
    required this.umur,
    required this.tinggi,
    required this.berat,
    required this.riwayatDiabetes,
    required this.jenisDiabetes,
    required this.riwayatKeluarga,
    required this.olahraga,
    required this.alkohol,
    required this.polaMakan,
    required this.riwayatDarahTinggi,
    required this.riwayatKolesterol,
    this.imageUrl,
  });

  // Metode untuk menggabungkan data dari dua dokumen berbeda
  factory UserModel.fromMap(Map<String, dynamic> userData, Map<String, dynamic> identityData) {
    // Menghitung umur dari birthDate
    final birthDate = identityData['birthDate'] as Timestamp?;
    int umur = 0;
    if (birthDate != null) {
      final dob = birthDate.toDate();
      final now = DateTime.now();
      umur = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        umur--;
      }
    }

    return UserModel(
      namaLengkap: userData['displayName'] ?? 'Tidak ada data',
      noTelp: userData['phoneNumber'] ?? 'Tidak ada data',
      gender: identityData['gender'] ?? 'Tidak ada data',
      umur: umur,
      tinggi: (identityData['height'] is String) ? double.tryParse(identityData['height']) ?? 0.0 : (identityData['height'] ?? 0.0).toDouble(),
      berat: (identityData['weight'] is String) ? double.tryParse(identityData['weight']) ?? 0.0 : (identityData['weight'] ?? 0.0).toDouble(),
      riwayatDiabetes: identityData['diabetes'] ?? 'Tidak ada data',
      jenisDiabetes: identityData['tipe'] ?? 'Tidak ada data',
      riwayatKeluarga: identityData['diabetes_keluarga'] ?? 'Tidak ada data',
      olahraga: identityData['olahraga'] ?? 'Tidak ada data',
      alkohol: identityData['alkohol'] ?? 'Tidak ada data',
      polaMakan: identityData['pola_makan'] ?? 'Tidak ada data',
      riwayatDarahTinggi: identityData['darah_tinggi'] ?? 'Tidak ada data',
      riwayatKolesterol: identityData['kolesterol'] ?? 'Tidak ada data',
      imageUrl: userData['photoURL'] ?? 'Tidak ada data',
    );
  }
}