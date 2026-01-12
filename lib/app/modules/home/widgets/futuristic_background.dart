import 'package:flutter/material.dart';

const Color bgDark = Color(0xFF070B14);
const Color cyanGlow = Color(0xFF00E5FF);
const Color purpleGlow = Color(0xFF9C5CFF);
const Color gridLine = Color(0xFF1A2235);

class FuturisticBackground extends StatelessWidget {
  const FuturisticBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base background
        Container(decoration: const BoxDecoration(color: bgDark)),

        // Checkered grid overlay
        CustomPaint(size: Size.infinite, painter: GridPainter()),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridLine.withOpacity(0.25)
      ..strokeWidth = 0.6;

    const double gridSize = 40;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
