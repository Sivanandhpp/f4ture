import 'dart:io';
import 'package:f4ture/app/modules/feed/controllers/feed_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f4ture/app/core/constants/app_colors.dart';

class PostCaptionView extends GetView<FeedController> {
  final File file;
  final bool isVideo;

  PostCaptionView({super.key, required this.file, required this.isVideo});

  final TextEditingController captionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'New Post',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Trigger upload
              controller.createPostFromGallery(
                caption: captionController.text.trim(),
                file: file,
                isVideo: isVideo,
              );
            },
            child: const Text(
              'Share',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Caption and Thumbnail Row
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade900,
                      image: isVideo
                          ? null
                          : DecorationImage(
                              image: FileImage(file),
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: isVideo
                        ? const Center(
                            child: Icon(Icons.videocam, color: Colors.white),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Caption Field
                  Expanded(
                    child: TextField(
                      controller: captionController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Write a caption...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey, height: 1),

            // Options (Placeholders for visual completeness)
            _buildOptionItem(Icons.location_on_outlined, 'Add Location'),
            _buildOptionItem(Icons.person_outline, 'Tag People'),
            _buildOptionItem(
              Icons.settings_accessibility_outlined,
              'Advanced Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        // Placeholder functionality
        Get.snackbar(
          'Coming Soon',
          '$title will be available soon!',
          backgroundColor: Colors.white.withOpacity(0.1),
          colorText: Colors.white,
        );
      },
    );
  }
}
