import 'package:diabetest/services/user_analysis.dart';
import 'package:flutter/material.dart';

import '../../components/colors.dart';


class Question4 extends StatefulWidget {
  const Question4({super.key});

  @override
  State<Question4> createState() => _Question4State();
}

class _Question4State extends State<Question4> {
  UserAnalysis userAnalysis = UserAnalysis();

  String? _workout;
  String? _alcoholic;

  final double _progress = 0.8;


  final Map<String, String> _options1 = {
    'Tidak Pernah': '',
    'Jarang': '(1x seminggu atau kurang)',
    'Cukup Rutin': '(2-3x seminggu)',
    'Rutin': '(≥4x seminggu)'
  };


  final List<String> _options2 = ['Tidak Pernah', 'Kadang', 'Rutin'];

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
                        child: Text(
                          '4/5',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: darkTextColor),
                        ),
                      ),

                      const SizedBox(height: 8),
                      Center(
                        child:
                        const Text(
                          'Gaya Hidup Kamu',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: darkTextColor),
                        ),
                      ),

                      const SizedBox(height: 32),

                      _buildRadioGroup(
                        label: 'Seberapa sering kamu berolahraga',
                        options: _options1,
                        groupValue: _workout,
                        onChanged: (value) {
                          setState(() {
                            _workout = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildRadioGroup(
                        label: 'Apakah kamu mengonsumsi alkohol',
                        options: _options2,
                        groupValue: _alcoholic,
                        onChanged: (value) {
                          setState(() {
                            _alcoholic = value;
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
                  await userAnalysis.saveQuestionUser4(_workout!, _alcoholic!);
                  Navigator.pushNamed(context, '/question5');
                  print('Intensitas Olahraga: $_workout');
                  print('Konsumsi alkohol: $_alcoholic');
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
    required dynamic options,
    required String? groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    List<Widget> radioButtons = [];


    if (options is Map<String, String>) {

      radioButtons = options.entries.map((entry) {
        final String value = entry.key;
        final String subtitle = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: groupValue == value ? scan : const Color(0xFFE0E0E0),
            ),
          ),
          child: RadioListTile<String>(
            title: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: scan,
            controlAffinity: ListTileControlAffinity.trailing,
          ),
        );
      }).toList();
    } else if (options is List<String>) {
      radioButtons = options.map((option) {
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
            controlAffinity: ListTileControlAffinity.trailing,
          ),
        );
      }).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        ...radioButtons,
      ],
    );
  }
}