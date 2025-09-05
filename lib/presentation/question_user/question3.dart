import 'package:diabetest/components/colors.dart'; // Pastikan path ini sesuai
import 'package:diabetest/services/user_analysis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Question3 extends StatefulWidget {
  const Question3({super.key});

  @override
  State<Question3> createState() => _Question3State();
}

class _Question3State extends State<Question3> {

  UserAnalysis userAnalysis = UserAnalysis();

  String? _familyDiabetes;
  String? _highBloodPressure;
  String? _highCholesterol;


  final double _progress = 0.6;


  final List<String> _options = ['Ya, ada', 'Tidak ada', 'Tidak tahu'];

  @override
  Widget build(BuildContext context) {
    const darkTextColor = Color(0xFF333333);
    const lightTextColor = Color(0xFF888888);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Progress Bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: scan.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: (MediaQuery.of(context).size.width - 48) * _progress,
                    decoration: BoxDecoration(
                      color: scan,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child:Text(
                          '3/5',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkTextColor),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Riwayat Kesehatan & Keluarga',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: darkTextColor),
                      ),
                      const SizedBox(height: 32),


                      _buildRadioGroup(
                        label: 'Apakah ada riwayat keluarga dengan diabetes?',
                        options: _options,
                        groupValue: _familyDiabetes,
                        onChanged: (value) {
                          setState(() {
                            _familyDiabetes = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildRadioGroup(
                        label: 'Apakah kamu memiliki riwayat tekanan darah tinggi?',
                        options: _options,
                        groupValue: _highBloodPressure,
                        onChanged: (value) {
                          setState(() {
                            _highBloodPressure = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildRadioGroup(
                        label: 'Apakah kamu memiliki riwayat kolesterol tinggi?',
                        options: _options,
                        groupValue: _highCholesterol,
                        onChanged: (value) {
                          setState(() {
                            _highCholesterol = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await userAnalysis.saveQuestionUser3(_familyDiabetes!, _highBloodPressure!, _highCholesterol!);
                  Navigator.pushNamed(context, '/question4');
                  print('Riwayat Diabetes Keluarga: $_familyDiabetes');
                  print('Riwayat Darah Tinggi: $_highBloodPressure');
                  print('Riwayat Kolesterol Tinggi: $_highCholesterol');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: scan,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Selanjutnya',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildRadioGroup({
    required String label,
    required List<String> options,
    required String? groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        ...options.map((option) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: groupValue == option ? scan : const Color(0xFFE0E0E0),
              ),
              color: groupValue == option ? scan.withOpacity(0.05) : Colors.transparent,
            ),
            child: RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: scan,
              controlAffinity: ListTileControlAffinity.trailing,
            ),
          );
        }).toList(),
      ],
    );
  }
}