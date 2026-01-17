import 'package:f4ture/app/core/constants/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/feed_controller.dart';
import '../widgets/feed_post_item.dart';
import 'create_post_view.dart'; // Direct import or route
import '../widgets/create_post_card.dart';

class FeedView extends GetView<FeedController> {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldbg,
      body: RefreshIndicator(
        onRefresh: controller.refreshFeed,
        color: AppColors.primary,
        backgroundColor: AppColors.scaffoldbg,
        child: CustomScrollView(
          controller: controller.scrollController,
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.scaffoldbg,
              elevation: 0,
              floating: true,
              snap: true,
              pinned: true,
              expandedHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(
                  left: 16,
                  top: 16,
                ), // Adjust title position
                title: Text(
                  'Future Feed',
                  style: AppFont.heading.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.scaffolditems, // White title
                  ),
                ),
              ),
              centerTitle: false,
              // actions: [
              //   IconButton(
              //     icon: const Icon(
              //       Icons.camera_alt_outlined,
              //       color: AppColors.scaffolditems,
              //     ),
              //     onPressed: controller.captureAndCreatePost,
              //   ),
              //   // Add Icon
              //   Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //     child: InkWell(
              //       onTap: () => Get.to(() => const CreatePostView()),
              //       customBorder: const CircleBorder(),
              //       child: const Icon(
              //         Icons.add,
              //         color: AppColors.scaffolditems,
              //       ),
              //     ),
              //   ),
              // ],
            ),
            SliverToBoxAdapter(child: const CreatePostCard()),
            Obx(() {
              // 1. Loading State (Initial)
              if (controller.isLoading.value && controller.posts.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              final displayPosts = controller.filteredPosts;

              // 2. Empty State
              if (displayPosts.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody:
                      false, // Allow scroll even if empty to show search bar
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.dynamic_feed,
                          size: 64,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.searchQuery.value.isNotEmpty
                              ? "No matches found"
                              : "No posts yet",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // 3. List State
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  // Loader at the bottom (Only show if not searching, or handle separately)
                  // When searching, pagination is tricky with client-side filter.
                  // Showing loader only if NOT searching roughly.
                  if (index == displayPosts.length) {
                    if (controller.searchQuery.value.isNotEmpty) {
                      return const SizedBox(height: 80);
                    }
                    return controller.isLoadingMore.value
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : const SizedBox(
                            height: 80,
                          ); // Bottom padding for navbar
                  }
                  return FeedPostItem(post: displayPosts[index]);
                }, childCount: displayPosts.length + 1),
              );
            }),
          ],
        ),
      ),
    );
  }
}
