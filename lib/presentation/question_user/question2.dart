import 'package:diabetest/components/colors.dart'; // Pastikan path ini sesuai
import 'package:diabetest/services/user_analysis.dart';
import 'package:flutter/material.dart';

class Question2 extends StatefulWidget {
  const Question2({super.key});

  @override
  State<Question2> createState() => _Question2State();
}

class _Question2State extends State<Question2> {
  UserAnalysis userAnalysis = UserAnalysis();

  String? _diagnosedValue;
  String? _diabetesTypeValue;

  final double _progress = 0.4;


  final List<String> _diagnosedOptions = ['Ya, sudah', 'Tidak pernah', 'Tidak tahu'];
  final List<String> _diabetesTypeOptions = [
    'Diabetes Tipe 1',
    'Diabetes Tipe 2',
    'Diabetes Gestasional (diabetes saat hamil)',
    'Lainnya / Tidak yakin',
  ];

  @override
  Widget build(BuildContext context) {
    const darkTextColor = Color(0xFF333333);
    const lightTextColor = Color(0xFF888888);


    bool showDiabetesTypeQuestion = _diagnosedValue == 'Ya, sudah';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

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

                      const Text(
                        '2/5',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: lightTextColor),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Cerita Sehat Kamu',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: darkTextColor),
                      ),
                      const SizedBox(height: 32),


                      _buildRadioGroup(
                        label: 'Apakah kamu sudah pernah didiagnosis diabetes?',
                        options: _diagnosedOptions,
                        groupValue: _diagnosedValue,
                        onChanged: (value) {
                          setState(() {
                            _diagnosedValue = value;

                            if (_diagnosedValue != 'Ya, sudah') {
                              _diabetesTypeValue = null;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 24),


                      AnimatedOpacity(
                        opacity: showDiabetesTypeQuestion ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          child: showDiabetesTypeQuestion
                              ? _buildRadioGroup(
                            label: 'Kamu mengalami diabetes jenis apa?',
                            options: _diabetesTypeOptions,
                            groupValue: _diabetesTypeValue,
                            onChanged: (value) {
                              setState(() {
                                _diabetesTypeValue = value;
                              });
                            },
                          )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await userAnalysis.saveQuestionUser2(_diagnosedValue, _diabetesTypeValue??'');
                  Navigator.pushNamed(context, '/question3');
                  print('Diagnosis: $_diagnosedValue');
                  if (_diagnosedValue == 'Ya, sudah') {
                    print('Tipe Diabetes: $_diabetesTypeValue');
                  }
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
            ),
            child: RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: scan,
              controlAffinity: ListTileControlAffinity.trailing, // Pindahkan radio ke kanan
            ),
          );
        }).toList(),
      ],
    );
  }
}