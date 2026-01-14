import 'dart:ui';
import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AttendeeGlassNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AttendeeGlassNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50), // Pill shape
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Frosted glass
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.scaffoldbg.withOpacity(0.2), // Dark translucent
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(0, Icons.home_rounded),
                  _buildNavItem(1, Icons.dynamic_feed_rounded),
                  _buildNavItem(2, Icons.forum_rounded), // Community/Chat
                  _buildNavItem(3, Icons.map_rounded),
                  _buildNavItem(4, Icons.calendar_month_rounded),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Colors.transparent, // Lime Green for active
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white70, size: 28),
      ),
    );
  }
}
