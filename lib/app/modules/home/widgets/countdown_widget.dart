import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/core/constants/app_styles.dart';
import 'package:flutter/material.dart';

class CountdownWidget extends StatelessWidget {
  final String timeLeft;

  const CountdownWidget({super.key, required this.timeLeft});

  @override
  Widget build(BuildContext context) {
    // Parse format "DD : HH : MM : SS"
    final parts = timeLeft.split(' : ');
    final String days = parts.isNotEmpty ? parts[0] : '00';
    final String hours = parts.length > 1 ? parts[1] : '00';
    final String mins = parts.length > 2 ? parts[2] : '00';
    final String secs = parts.length > 3 ? parts[3] : '00';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.appbarbg.withOpacity(
          0.9,
        ), // Slightly darker for contrast
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'EVENT STARTS IN',
            style: AppFont.caption.copyWith(
              color: Colors.white70,
              letterSpacing: 3,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeBlock(days, 'DAYS'),
              _buildSeparator(),
              _buildTimeBlock(hours, 'HRS'),
              _buildSeparator(),
              _buildTimeBlock(mins, 'MINS'),
              _buildSeparator(),
              _buildTimeBlock(secs, 'SECS'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBlock(String value, String label) {
    return Column(
      children: [
        // Number
        Text(
          value,
          style: AppFont.heading.copyWith(
            // Use a monospace-like look or just standard bold
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.0,
            shadows: [
              Shadow(color: AppColors.primary.withOpacity(0.6), blurRadius: 10),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // Label
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primary, // Neon accent
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16), // Align with numbers
      child: Text(
        ':',
        style: TextStyle(
          color: Colors.white.withOpacity(0.3),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
