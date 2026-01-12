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
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    // Responsive square size (12 squares per width)
    final double squareSize = size.width / 12;

    // Calculate centering offsets
    final double offsetX = (size.width % squareSize) / 2;
    final double offsetY = (size.height % squareSize) / 2;

    for (double x = offsetX; x < size.width; x += squareSize) {
      for (double y = offsetY; y < size.height; y += squareSize) {
        // Draw actual square rectangle
        canvas.drawRect(Rect.fromLTWH(x, y, squareSize, squareSize), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
