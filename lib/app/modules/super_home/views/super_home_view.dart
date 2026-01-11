import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/index.dart';
import '../../../data/models/group_model.dart';
import '../controllers/super_home_controller.dart';
import 'create_group_view.dart';

class SuperHomeView extends GetView<SuperHomeController> {
  const SuperHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: Colors.black,
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                'F4ture',
                style: AppFont.heading.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.primary,
                  size: 28,
                ),
                onPressed: () => Get.to(() => const CreateGroupView()),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
        body: StreamBuilder<List<GroupModel>>(
          stream: controller.groupsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final groups = snapshot.data ?? [];

            if (groups.isEmpty) {
              return Center(
                child: Text(
                  'No groups yet',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: groups.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey.shade900,
                height: 1,
                indent: 82, // Align with text
              ),
              itemBuilder: (context, index) {
                final group = groups[index];
                return _buildGroupTile(group);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildGroupTile(GroupModel group) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to group chat
        Get.snackbar('Coming Soon', 'Chat feature is under development');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Group Icon
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey.shade900,
              backgroundImage: NetworkImage(group.iconUrl),
              onBackgroundImageError: (_, __) => const Icon(Icons.group),
            ),
            const SizedBox(width: 16),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        group.name,
                        style: AppFont.subtitle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatTime(group.lastMessageAt),
                        style: AppFont.caption.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          group.lastMessage,
                          style: AppFont.body.copyWith(
                            color: Colors.grey.shade500,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Optional: Unread badge can go here
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat.jm().format(date); // 12:00 PM
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat.E().format(date); // Mon
    } else {
      return DateFormat.yMd().format(date); // 1/1/2024
    }
  }
}
