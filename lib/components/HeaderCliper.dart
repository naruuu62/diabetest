import 'package:flutter/material.dart';

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // Start from top-left
    path.lineTo(0, size.height * 0.75); // Start the curve a bit higher

    // Define the single, broad curve
    path.quadraticBezierTo(
      size.width / 2, // Control point X: exactly in the middle horizontally
      size.height,    // Control point Y: dips to the very bottom of the header area
      size.width,     // End point X: right edge
      size.height * 0.75, // End point Y: same height as start point
    );


    path.lineTo(size.width, 0);


    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}