import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:diabetest/model/user_model.dart'; // Impor model yang sudah diperbarui
import 'package:diabetest/components/colors.dart'; // Impor warna
import 'package:diabetest/components/HeaderCliper.dart'; // Impor clipper

// --- Colors & Constants ---
// Pastikan file ini berisi definisi warna Anda
const Color primaryBlue = Color(0xFF5A67D8);
const Color primaryRed = Color(0xFFE53E3E);
const Color backgroundBlue = Color(0xFFEBF4FF);
const Color darkTextColor = Color(0xFF1A202C);
const Color lightTextColor = Color(0xFF718096);
const Color pageBackground = Color(0xFFF7FAFC);
const Color scan = primaryBlue;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);
  @override
  State<ProfilePage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilePage> {
  UserModel? _userProfile;
  bool _isLoading = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _diabetesStatus = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      DocumentSnapshot userDoc = await _firestore.collection('user').doc(user.uid).get();
      DocumentSnapshot identityDoc = await _firestore.collection('identity').doc(user.uid).get();

      if (userDoc.exists && identityDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final identityData = identityDoc.data() as Map<String, dynamic>;

        _diabetesStatus = identityData['status_diabetes'] ?? 'tidak';

        setState(() {
          _userProfile = UserModel.fromMap(userData, identityData);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final Color themeColor = _diabetesStatus.toLowerCase() == 'tinggi' ? primaryRed : primaryBlue;

    return Scaffold(
      backgroundColor: pageBackground,
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: primaryBlue))
          else if (_userProfile == null)
            const Center(child: Text('Gagal memuat data profil atau data tidak ditemukan.', style: TextStyle(color: darkTextColor)))
          else
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 25),
                        _SectionHeader(title: 'Informasi Pribadi', themeColor: themeColor),
                        const SizedBox(height: 30),
                        Text(
                          'Nama Lengkap',
                          style: TextStyle(
                            color: darkTextColor,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildNamaLengkap(_userProfile!.namaLengkap),
                        const SizedBox(height: 12),
                        _ProfileInfoRow(
                          iconAssetPath: 'assets/images/kelamin.png',
                          label: 'Jenis Kelamin',
                          value: _userProfile!.gender,
                        ),
                        const SizedBox(height: 12),
                        _ProfileInfoRow(
                          iconAssetPath: 'assets/images/umur.png',
                          label: 'Umur',
                          value: '${_userProfile!.umur} th',
                        ),
                        const SizedBox(height: 32),
                        _SectionHeader(title: 'Fisik dan Kondisi Tubuh', themeColor: themeColor),
                        const SizedBox(height: 16),
                        _ProfileInfoRow(
                          iconAssetPath: 'assets/images/tinggi.png',
                          label: 'Tinggi Badan',
                          value: '${_userProfile!.tinggi.toInt()} cm',
                        ),
                        const SizedBox(height: 12),
                        _ProfileInfoRow(
                          iconAssetPath: 'assets/images/berat.png',
                          label: 'Berat Badan',
                          value: '${_userProfile!.berat.toInt()} kg',
                        ),
                        const SizedBox(height: 32),
                        _SectionHeader(title: 'Riwayat Kesehatan', themeColor: themeColor),
                        const SizedBox(height: 16),
                        _ProfileInfoRow(
                          iconAssetPath: 'assets/images/darah.png',
                          label: 'Riwayat Diabetes',
                          value: _userProfile!.riwayatDiabetes,
                        ),
                        const SizedBox(height: 12),
                        _ProfileInfoRow(
                          iconAssetPath: 'assets/images/keluarga.png',
                          label: 'Jenis Diabetes',
                          value: _userProfile!.jenisDiabetes,
                        ),
                        const SizedBox(height: 12),
                        _ProfileInfoRow(
                          iconAssetPath: 'assets/images/keluarga.png',
                          label: 'Riwayat Keluarga',
                          value: _userProfile!.riwayatKeluarga,
                        ),
                        const SizedBox(height: 32),
                        _SectionHeader(title: 'Kebiasaan Hidup', themeColor: themeColor),
                        const SizedBox(height: 16),
                        _ProfileInfoRow(
                          iconAssetPath: 'assets/images/olahraga.png',
                          label: 'Frekuensi olahraga',
                          value: _userProfile!.olahraga,
                        ),
                        const SizedBox(height: 12),
                        _ProfileInfoRow(
                          iconAssetPath: 'assets/images/alkohol.png',
                          label: 'Konsumsi alkohol',
                          value: _userProfile!.alkohol,
                        ),
                        const SizedBox(height: 12),
                        _ProfileInfoRow(
                          iconAssetPath: 'assets/images/makanan.png',
                          label: 'Pola makan',
                          value: _userProfile!.polaMakan,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          _buildHeader(context, screenWidth, _userProfile?.imageUrl, themeColor),
        ],
      ),
    );
  }

  Widget _buildNamaLengkap(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300)),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(name,
                  style: const TextStyle(
                      color: darkTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double screenWidth, String? imageUrl, Color themeColor) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          ClipPath(
            clipper: HeaderClipper(), // Menggunakan custom clipper
            child: Container(
              width: screenWidth,
              height: screenWidth * 0.7,
              decoration: BoxDecoration(
                color: themeColor,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        'Profil',
                        style: TextStyle(
                          fontFamily: 'circular',
                          fontWeight: FontWeight.bold,
                          fontSize: 29,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          Navigator.pushNamed(context, '/edit_profile');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl) as ImageProvider
                          : const AssetImage('assets/images/monkey_avatar.png') as ImageProvider,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color themeColor;

  const _SectionHeader({required this.title, required this.themeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: themeColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          textAlign: TextAlign.start,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ));
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final String iconAssetPath;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.iconAssetPath,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        children: [
          Image.asset(
            iconAssetPath,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: darkTextColor,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: darkTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}