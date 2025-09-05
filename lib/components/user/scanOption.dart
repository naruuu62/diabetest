import 'package:flutter/material.dart';

const Color primaryBlue = Color(0xFF5A67D8);
const Color darkTextColor = Color(0xFF1A202C);
const Color backgroundBlue = Color(0xFFEBF4FF);
const Color lightTextColor = Color(0xFF718096);

class ScanOptionsDialog extends StatelessWidget {
  final int remainingScans;
  final VoidCallback onTakePhoto;
  final VoidCallback onManualEntry;
  final Color themeColor;

  const ScanOptionsDialog({
    Key? key,
    required this.remainingScans,
    required this.onTakePhoto,
    required this.onManualEntry,
    required this.themeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionButton(
                  context,
                  icon: Icons.camera_alt,
                  label: 'Ambil foto',
                  onTap: onTakePhoto,
                ),
                _buildOptionButton(
                  context,
                  icon: Icons.text_fields,
                  label: 'Catat sendiri',
                  onTap: onManualEntry,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Scan gratis kamu tinggal $remainingScans kali lagi. Upgrade ke Premium biar nggak terbatas',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: darkTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.3,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: themeColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: themeColor, size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: darkTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}