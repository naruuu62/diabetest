import 'package:diabetest/components/colors.dart'; // Pastikan path ini sesuai
import 'package:diabetest/services/user_analysis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Question5 extends StatefulWidget {
  const Question5({super.key});

  @override
  State<Question5> createState() => _Question5State();
}

class _Question5State extends State<Question5> {

  UserAnalysis userAnalysis = UserAnalysis();

  String? _foodHabit;


  final double _progress = 1.0;


  final List<String> _options = ['Banyak karbohidrat & gula', 'seimbang', 'Banyak gorengan & lemak', 'Tidak Teratur'];

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
                          '5/5',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkTextColor),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child:
                        const Text(
                          'Pola Makan',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: darkTextColor),
                        ),
                      ),

                      const SizedBox(height: 32),


                      _buildRadioGroup(
                        label: 'Bagaimana pola makan kamu sehari-hari?',
                        options: _options,
                        groupValue: _foodHabit,
                        onChanged: (value) {
                          setState(() {
                            _foodHabit = value;
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
                  await userAnalysis.saveQuestionUser5(_foodHabit!);
                  Navigator.pushNamed(context, '/questionwait');
                  print('Pola makan: $_foodHabit');
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