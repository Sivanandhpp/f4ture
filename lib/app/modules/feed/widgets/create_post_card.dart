import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/data/services/auth_service.dart';
import '../controllers/feed_controller.dart';
import '../views/create_post_view.dart';

class CreatePostCard extends GetView<FeedController> {
  const CreatePostCard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.to.currentUser.value;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark surface
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row: Avatar + Input Hint
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: user?.profilePhoto != null
                    ? NetworkImage(user!.profilePhoto!)
                    : null,
                backgroundColor: Colors.grey[800],
                child: user?.profilePhoto == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.to(() => const CreatePostView()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'What do you want to share?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Post Button (Small Icon style or Text?)
              // Request says "bottom 3 options", but design usually has text input + button.
              // I'll put a small "+" or rely on the bottom buttons.
            ],
          ),
          const SizedBox(height: 16),
          // Bottom Row: Camera, Gallery, Post
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(
                icon: Icons.camera_alt_rounded,
                label: 'Camera',
                onTap: controller.captureAndCreatePost,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                onTap: () => Get.to(() => const CreatePostView()),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.send_rounded,
                label: 'Post',
                color: AppColors.primary,
                textColor: Colors.black,
                onTap: () => Get.to(() => const CreatePostView()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    Color? textColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: textColor ?? Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
