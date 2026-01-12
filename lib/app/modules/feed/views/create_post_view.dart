import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/feed_controller.dart';

class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key});

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  final FeedController controller = Get.find<FeedController>();
  final TextEditingController textController = TextEditingController();

  // Custom Dark Colors
  static const Color kBackground = Color(0xFF121212);
  static const Color kSurface = Color(0xFF1E1E1E);
  static const Color kInputBackground = Color(0xFF2C2C2C);
  static const Color kTextPrimary = Colors.white;
  static const Color kTextSecondary = Color(0xFFAAAAAA);
  static const Color kDivider = Color(0xFF333333);

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: kTextPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Create Post',
          style: TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            final isValid =
                textController.text.isNotEmpty ||
                controller.selectedMedia.isNotEmpty;
            return Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 10, bottom: 10),
              child: ElevatedButton(
                onPressed: controller.isCreatingPost.value
                    ? null
                    : (isValid
                          ? () => controller.createPost(
                              textController.text.trim(),
                            )
                          : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  elevation: 0,
                ),
                child: controller.isCreatingPost.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Post',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Caption Input Area
                  Container(
                    color: kSurface,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey[800],
                          // Placeholder for user avatar
                          child: const Icon(
                            Icons.person,
                            color: Colors.white70,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: textController,
                            onChanged: (_) => controller.selectedMedia
                                .refresh(), // Trigger rebuild for button validation
                            style: const TextStyle(
                              color: kTextPrimary,
                              fontSize: 18,
                              height: 1.4,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'What\'s on your mind?',
                              hintStyle: TextStyle(
                                color: kTextSecondary,
                                fontSize: 18,
                              ),
                              border: InputBorder.none,
                            ),
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            autofocus: true,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Media Preview
                  Obx(() {
                    if (controller.selectedMedia.isEmpty)
                      return const SizedBox.shrink();

                    return Container(
                      height: 320,
                      margin: const EdgeInsets.only(top: 2),
                      width: double.infinity,
                      color: kSurface,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.selectedMedia.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final file = controller.selectedMedia[index];
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(file.path),
                                  height: 288,
                                  width: 220,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => controller.removeMedia(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Bottom Actions
          Container(
            decoration: const BoxDecoration(
              color: kSurface,
              border: Border(top: BorderSide(color: kDivider, width: 0.5)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      "Add to your post",
                      style: TextStyle(
                        color: kTextPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.photo_library_rounded,
                        label: "Gallery",
                        color: const Color(0xFF4CAF50),
                        onTap: controller.pickMedia,
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.camera_alt_rounded,
                        label: "Camera",
                        color: const Color(0xFF2196F3),
                        onTap: controller.captureFromCamera,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: kInputBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: kTextSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
