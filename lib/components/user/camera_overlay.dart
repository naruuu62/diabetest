import 'package:flutter/material.dart';

class ResizableScannerOverlay extends StatefulWidget {
  final double initialSize;
  final bool isScanning;

  const ResizableScannerOverlay({
    super.key,
    this.initialSize = 250,
    required this.isScanning,
  });

  @override
  State<ResizableScannerOverlay> createState() =>
      _ResizableScannerOverlayState();
}

class _ResizableScannerOverlayState extends State<ResizableScannerOverlay>
    with SingleTickerProviderStateMixin {
  late double _boxSize;
  double _scaleFactor = 1.0;
  Offset _position = Offset.zero;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _boxSize = widget.initialSize;

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant ResizableScannerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isScanning && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isScanning && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        _scaleFactor = 1.0;
      },
      onScaleUpdate: (details) {
        setState(() {

          _scaleFactor = details.scale;
          _boxSize = (_boxSize * _scaleFactor).clamp(150.0, 500.0);


          _position += details.focalPointDelta;
        });
      },
      child: Stack(
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Transform.translate(
                    offset: _position,
                    child: Container(
                      width: _boxSize,
                      height: _boxSize,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // sudut kuning
          Center(
            child: Transform.translate(
              offset: _position,
              child: SizedBox(
                width: _boxSize,
                height: _boxSize,
                child: CustomPaint(
                  painter: BorderPainter(),
                ),
              ),
            ),
          ),

          // garis scanner (kalau scanning)
          if (widget.isScanning)
            Center(
              child: Transform.translate(
                offset: _position,
                child: SizedBox(
                  width: _boxSize,
                  height: _boxSize,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _animation.value * (_boxSize - 2)),
                        child: Container(
                          width: _boxSize,
                          height: 2,
                          color: Colors.yellowAccent,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// painter untuk sudut kuning
class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    double corner = 30;

    // kiri atas
    canvas.drawLine(Offset(0, 0), Offset(corner, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, corner), paint);

    // kanan atas
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - corner, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, corner), paint);

    // kiri bawah
    canvas.drawLine(Offset(0, size.height), Offset(corner, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - corner), paint);

    // kanan bawah
    canvas.drawLine(
        Offset(size.width, size.height), Offset(size.width - corner, size.height), paint);
    canvas.drawLine(
        Offset(size.width, size.height), Offset(size.width, size.height - corner), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
