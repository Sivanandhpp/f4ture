import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/feed_controller.dart';
import '../widgets/feed_post_item.dart';
import 'create_post_view.dart'; // Direct import or route

class FeedView extends GetView<FeedController> {
  const FeedView({super.key});

  // Custom Dark Colors
  static const Color kBackground = Color(0xFF121212);
  static const Color kSurface = Color(0xFF1E1E1E);
  static const Color kTextPrimary = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.camera_alt_outlined, color: kTextPrimary),
          onPressed: controller.captureAndCreatePost,
        ),
        title: const Text(
          'Feed',
          style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () => Get.to(() => const CreatePostView()),
              customBorder: const CircleBorder(),
              child: const Icon(Icons.add, color: kTextPrimary),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshFeed,
        color: AppColors.primary,
        backgroundColor: kSurface,
        child: Obx(() {
          if (controller.isLoading.value && controller.posts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (controller.posts.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.dynamic_feed, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "No posts yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            controller: controller.scrollController,
            itemCount: controller.posts.length + 1,
            itemBuilder: (context, index) {
              if (index == controller.posts.length) {
                return controller.isLoadingMore.value
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : const SizedBox(height: 80); // Bottom padding for navbar
              }
              return FeedPostItem(post: controller.posts[index]);
            },
          );
        }),
      ),
    );
  }
}
