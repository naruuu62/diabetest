import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import 'package:diabetest/model/user_model.dart';
import 'package:diabetest/components/colors.dart';

// Pastikan file colors.dart sudah ada dan berisi definisi warna.
const Color primaryBlue = Color(0xFF5A67D8);
const Color primaryRed = Color(0xFFE53E3E);
const Color backgroundBlue = Color(0xFFEBF4FF);
const Color darkTextColor = Color(0xFF1A202C);
const Color lightTextColor = Color(0xFF718096);
const Color pageBackground = Color(0xFFF7FAFC);
const Color textFieldBorderColor = Color(0xFFCBD5E0);

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Controller untuk text field
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  File? _imageFile;
  String? _profileImageUrl;
  String _diabetesStatus = '';
  bool _isLoading = true;
  bool _isSaving = false;

  DateTime? _selectedBirthDate;
  bool _isCalendarVisible = false;

  String? _selectedGender;
  String? _selectedDiabetesHistory;
  String? _selectedDiabetesType;
  String? _selectedFamilyHistory;
  String? _selectedExerciseFrequency;
  String? _selectedAlcoholConsumption;
  String? _selectedDietPattern;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _loadUserProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfileData() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      DocumentSnapshot userDoc = await _firestore.collection('user').doc(user.uid).get();
      DocumentSnapshot identityDoc = await _firestore.collection('identity').doc(user.uid).get();

      if (userDoc.exists && identityDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final identityData = identityDoc.data() as Map<String, dynamic>;

        _nameController.text = userData['displayName'] ?? '';
        _heightController.text = (identityData['height'] ?? '').toString();
        _weightController.text = (identityData['weight'] ?? '').toString();
        _selectedGender = identityData['gender'];
        _selectedDiabetesHistory = identityData['diabetes'];
        _selectedDiabetesType = identityData['tipe'];
        _selectedFamilyHistory = identityData['diabetes_keluarga'];
        _selectedExerciseFrequency = identityData['olahraga'];
        _selectedAlcoholConsumption = identityData['alkohol'];
        _selectedDietPattern = identityData['pola_makan'];

        if (identityData['birthDate'] is Timestamp) {
          _selectedBirthDate = (identityData['birthDate'] as Timestamp).toDate();
        }

        _profileImageUrl = userData['photoURL'];
        _diabetesStatus = identityData['status_diabetes'] ?? 'tidak';
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (mounted) setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;
    try {
      final userId = _auth.currentUser!.uid;
      final fileExtension = p.extension(_imageFile!.path);
      final ref = FirebaseStorage.instance.ref().child('user_profile_images/$userId$fileExtension');
      await ref.putFile(_imageFile!);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;
    if (mounted) setState(() => _isSaving = true);

    final user = _auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isSaving = false);
      return;
    }

    try {
      String? newImageUrl;
      if (_imageFile != null) {
        newImageUrl = await _uploadImage();
      }

      // Update Firebase Auth user profile
      if (newImageUrl != null || _nameController.text.isNotEmpty) {
        await user.updateProfile(
          displayName: _nameController.text,
          photoURL: newImageUrl ?? _profileImageUrl,
        );
      }

      // Update Firestore user data (collection 'user')
      await _firestore.collection('user').doc(user.uid).update({
        'displayName': _nameController.text,
        'photoURL': newImageUrl ?? _profileImageUrl,
      });

      // Update Firestore identity data (collection 'identity')
      await _firestore.collection('identity').doc(user.uid).update({
        'height': _heightController.text,
        'weight': _weightController.text,
        'gender': _selectedGender,
        'birthDate': _selectedBirthDate != null ? Timestamp.fromDate(_selectedBirthDate!) : null,
        'diabetes': _selectedDiabetesHistory,
        'tipe': _selectedDiabetesType,
        'diabetes_keluarga': _selectedFamilyHistory,
        'olahraga': _selectedExerciseFrequency,
        'alkohol': _selectedAlcoholConsumption,
        'pola_makan': _selectedDietPattern,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui profil. Silakan coba lagi.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = _diabetesStatus.toLowerCase() == 'tinggi' ? primaryRed : primaryBlue;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: pageBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!) as ImageProvider
                        : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty
                        ? NetworkImage(_profileImageUrl!) as ImageProvider
                        : const AssetImage('assets/images/monkey_avatar.png')),
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: themeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              _SectionHeader(title: 'Informasi Pribadi', themeColor: themeColor),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Siapa nama panjangmu?',
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              _buildGenderSelection(
                label: 'Apa jenis kelaminmu?',
                groupValue: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                themeColor: themeColor,
              ),
              const SizedBox(height: 16),
              _buildInlineDateField(
                label: 'Kapan tanggal lahir kamu?',
                selectedDate: _selectedBirthDate,
                isVisible: _isCalendarVisible,
                onTap: () {
                  setState(() {
                    _isCalendarVisible = !_isCalendarVisible;
                  });
                },
                onDateSelected: (date) {
                  setState(() {
                    _selectedBirthDate = date;
                    _isCalendarVisible = false;
                  });
                },
              ),
              const SizedBox(height: 32),

              _SectionHeader(title: 'Fisik dan Kondisi Tubuh', themeColor: themeColor),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Berapa tinggi badanmu?',
                controller: _heightController,
                suffixText: 'cm',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Berapa berat badanmu?',
                controller: _weightController,
                suffixText: 'kg',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),

              _SectionHeader(title: 'Riwayat Kesehatan', themeColor: themeColor),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Punya riwayat diabetes?',
                value: _selectedDiabetesHistory,
                items: ['Ya, sudah', 'Tidak pernah', 'Tidak tahu'],
                onChanged: (value) {
                  setState(() {
                    _selectedDiabetesHistory = value;
                  });
                },
                themeColor: themeColor,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Diabetes jenis apa?',
                value: _selectedDiabetesType,
                items: ['Diabetes Tipe 1', 'Diabetes Tipe 2', 'Diabetes Gestasional', 'Lainnya/Tidak yakin'],
                onChanged: (value) {
                  setState(() {
                    _selectedDiabetesType = value;
                  });
                },
                themeColor: themeColor,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Apakah keluarga punya riwayat diabetes?',
                value: _selectedFamilyHistory,
                items: ['Ya, ada', 'Tidak ada', 'Tidak tahu'],
                onChanged: (value) {
                  setState(() {
                    _selectedFamilyHistory = value;
                  });
                },
                themeColor: themeColor,
              ),
              const SizedBox(height: 32),

              _SectionHeader(title: 'Kebiasaan Hidup', themeColor: themeColor),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Apakah kamu sering olahraga?',
                value: _selectedExerciseFrequency,
                items: ['Tidak pernah', 'Jarang', 'Cukup rutin', 'Rutin'],
                onChanged: (value) {
                  setState(() {
                    _selectedExerciseFrequency = value;
                  });
                },
                themeColor: themeColor,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Apakah kamu sering minum alkohol?',
                value: _selectedAlcoholConsumption,
                items: ['Tidak pernah', 'Kadang-kadang', 'Sering'],
                onChanged: (value) {
                  setState(() {
                    _selectedAlcoholConsumption = value;
                  });
                },
                themeColor: themeColor,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Bagaimana pola makanmu?',
                value: _selectedDietPattern,
                items: ['Banyak karbohidrat', 'Seimbang', 'Banyak gorengan & lemak', 'Tidak teratur'],
                onChanged: (value) {
                  setState(() {
                    _selectedDietPattern = value;
                  });
                },
                themeColor: themeColor,
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Simpan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelection({
    required String label,
    required String? groupValue,
    required ValueChanged<String?> onChanged,
    required Color themeColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: darkTextColor, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _buildRadioOption(
          title: 'Laki-laki',
          value: 'Laki-laki',
          groupValue: groupValue,
          onChanged: onChanged,
          themeColor: themeColor,
        ),
        const SizedBox(height: 8),
        _buildRadioOption(
          title: 'Perempuan',
          value: 'Perempuan',
          groupValue: groupValue,
          onChanged: onChanged,
          themeColor: themeColor,
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required String title,
    required String value,
    required String? groupValue,
    required ValueChanged<String?> onChanged,
    required Color themeColor,
  }) {
    final bool isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
         // color: isSelected ? (themeColor == primaryRed ? primaryRed : backgroundBlue) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? themeColor : textFieldBorderColor,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: themeColor,
            ),
            Text(title, style: const TextStyle(color: darkTextColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? suffixText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final Color themeColor = _diabetesStatus.toLowerCase() == 'tinggi' ? primaryRed : primaryBlue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: darkTextColor, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            suffixText: suffixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: textFieldBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: textFieldBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: themeColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInlineDateField({
    required String label,
    required DateTime? selectedDate,
    required bool isVisible,
    required VoidCallback onTap,
    required ValueChanged<DateTime> onDateSelected,
  }) {
    final String formattedDate = selectedDate != null
        ? DateFormat('d MMMM yyyy').format(selectedDate)
        : 'Pilih tanggal lahirmu';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: darkTextColor, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: textFieldBorderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formattedDate, style: const TextStyle(fontSize: 16, color: darkTextColor)),
                Icon(isVisible ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: lightTextColor),
              ],
            ),
          ),
        ),
        if (isVisible)
          const SizedBox(height: 8),
        if (isVisible)
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            shadowColor: Colors.black.withOpacity(0.2),
            child: CalendarDatePicker(
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(1920),
              lastDate: DateTime.now(),
              onDateChanged: onDateSelected,
            ),
          ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required Color themeColor,
  }) {
    // Pastikan value valid
    final String? dropdownValue = items.contains(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: darkTextColor, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: dropdownValue,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: textFieldBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: textFieldBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: themeColor, width: 2),
            ),
          ),
        ),
      ],
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