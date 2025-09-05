import 'package:flutter/material.dart';

const Color primaryBlue = Color(0xFF5A67D8);
const Color primaryRed = Color(0xFFE53E3E);
const Color darkTextColor = Color(0xFF1A202C);

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final Color themeColor;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.themeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double navBarHeight = 70.0;
    const double fabDiameter = 65.0;

    return Container(
      height: navBarHeight,
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [

          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, navBarHeight),
            painter: NavBarPainter(themeColor: themeColor),
          ),


          Positioned(
            bottom: navBarHeight - (fabDiameter / 2) - 8,
            child: GestureDetector(
              onTap: () => onItemTapped(1), // Memanggil fungsi dari DashboardScreen
              child: Container(
                width: fabDiameter,
                height: fabDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: themeColor,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Image.asset(
                  'assets/images/scan.png',
                  width: 30,
                  height: 30,
                ),
              ),
            ),
          ),


          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    label: 'Beranda',
                    icon: Icons.home,
                    isSelected: selectedIndex == 0,
                    onTap: () => onItemTapped(0),
                    themeColor: themeColor,
                  ),
                  const SizedBox(width: 70),
                  _buildNavItem(
                    label: 'Artikel',
                    icon: Icons.list_alt,
                    isSelected: selectedIndex == 2,
                    onTap: () => onItemTapped(2),
                    themeColor: themeColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color themeColor,
  }) {
    if (isSelected) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: themeColor,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: darkTextColor, size: 26),
      tooltip: label,
    );
  }
}

class NavBarPainter extends CustomPainter {
  final Color themeColor;
  NavBarPainter({required this.themeColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 20);
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.arcToPoint(
      Offset(size.width * 0.65, 0),
      radius: const Radius.circular(40.0),
      clockwise: false,
    );
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black26, 6, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}