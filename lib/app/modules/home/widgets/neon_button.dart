import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

const Color cyanGlow = Color(0xFF00E5FF);
const Color purpleGlow = Color(0xFF9C5CFF);

class NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color glowColor;

  const NeonButton({
    super.key,
    required this.text,
    required this.onTap,
    this.glowColor = AppColors.primaryLight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: ShapeDecoration(
          shape: BeveledRectangleBorder(
            side: BorderSide(color: glowColor, width: 1.5),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          color: Colors.transparent.withOpacity(0.1),
          shadows: [
            BoxShadow(
              color: glowColor.withOpacity(0.4),
              blurRadius: 2,
              spreadRadius: -2,
              offset: const Offset(0, 0),
            ),
            BoxShadow(
              color: glowColor.withOpacity(0.2),
              blurRadius: 2,
              spreadRadius: 0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 1.2,
            shadows: [Shadow(color: glowColor, blurRadius: 10)],
          ),
        ),
      ),
    );
  }
}
