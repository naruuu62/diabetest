import 'package:diabetest/components/colors.dart';
import 'package:diabetest/services/user_analysis.dart';
import 'package:flutter/material.dart';

class Question1 extends StatefulWidget {
  const Question1({super.key});

  @override
  State<Question1> createState() => _Question1State();
}

class _Question1State extends State<Question1> {

  UserAnalysis userAnalysis = UserAnalysis();

  String? _selectedGender;
  DateTime? _selectedDate;

  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();


  final double _progress = 0.2;


  final List<String> _genderOptions = ['Pria', 'Wanita'];

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }



  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),

        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: scan,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: scan,
                ),
              ),
            ),
            child: child!,
          );
        });
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    const lightGreyColor = Color(0xFFF0F0F0);
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
                    width: MediaQuery.of(context).size.width * _progress,
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
                      // 2. Teks Judul
                      const Text(
                        '1/5',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: lightTextColor),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Yuk Kenalan Lebih Dulu',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: darkTextColor),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Parameter pribadi kamu penting bagi kami untuk personalisasi yang lebih mendalam.',
                        style: TextStyle(fontSize: 14, color: lightTextColor),
                      ),
                      const SizedBox(height: 32),

                      // 3. Form Input
                      _buildDropdownField(
                        label: 'Apa jenis kelaminmu?',
                        hint: 'Pilih jenis kelaminmu',
                        value: _selectedGender,
                        items: _genderOptions,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildDateField(
                        label: 'Kapan tanggal lahir kamu?',
                        context: context,
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _heightController,
                        label: 'Berapa tinggi badanmu?',
                        hint: 'Masukan tinggimu',
                        suffixText: 'cm',
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _weightController,
                        label: 'Berapa berat badanmu?',
                        hint: 'Masukan beratmu',
                        suffixText: 'kg',
                      ),
                    ],
                  ),
                ),
              ),


              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await userAnalysis.saveQuestionUser1(_selectedGender!, _selectedDate!, _heightController.text, _weightController.text);
                  Navigator.pushNamed(context, '/question2');
                  print('Jenis Kelamin: $_selectedGender');
                  print('Tanggal Lahir: $_selectedDate');
                  print('Tinggi: ${_heightController.text}');
                  print('Berat: ${_weightController.text}');
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


  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }


  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(hint),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }


  Widget _buildDateField({
    required String label,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  _selectedDate == null
                      ? 'Pilih tanggal lahirmu'
                      : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}