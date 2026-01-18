import 'package:f4ture/app/core/index.dart';
import 'package:f4ture/app/modules/chat/controllers/chat_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/group_model.dart';
import '../../../routes/app_pages.dart';
import 'create_group_view.dart';

class ChatsList extends GetView<ChatListController> {
  const ChatsList({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: AppColors.appbarbg, // Dark background
            expandedHeight: 120.0, // Increased for TabBar
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: 16,
                bottom: 64,
              ), // Adjust title position
              title: Text(
                'Communities',
                style: AppFont.heading.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.scaffolditems, // White title
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: AppColors.primary.withOpacity(
                      0.2,
                    ), // Neon glow effect
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'My Communities'),
                    Tab(text: 'Join Communities'),
                  ],
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
        body: TabBarView(
          children: [
            // Tab 1: My Communities (Existing Logic)
            _buildMyCommunities(),

            // Tab 2: Join Communities (New Logic)
            _buildJoinCommunities(),
          ],
        ),
      ),
    );
  }

  Widget _buildMyCommunities() {
    return StreamBuilder<List<GroupModel>>(
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
              'No communities joined yet',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 200),
          itemCount: groups.length,
          separatorBuilder: (context, index) =>
              Divider(color: Colors.grey.shade800, height: 1, indent: 82),
          itemBuilder: (context, index) {
            final group = groups[index];
            return _buildGroupTile(group);
          },
        );
      },
    );
  }

  Widget _buildJoinCommunities() {
    return Obx(() {
      if (controller.isPublicGroupsLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final publicGroups = controller.publicGroups;
      final myGroups = controller.myGroupIds;

      if (publicGroups.isEmpty) {
        return Center(
          child: Text(
            'No communities available',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.only(top: 10, bottom: 100),
        itemCount: publicGroups.length,
        separatorBuilder: (context, index) =>
            Divider(color: Colors.grey.shade800, height: 1, indent: 82),
        itemBuilder: (context, index) {
          final group = publicGroups[index];
          final isJoined = myGroups.contains(group.groupId);
          return _buildJoinableGroupTile(group, isJoined);
        },
      );
    });
  }

  Widget _buildJoinableGroupTile(GroupModel group, bool isJoined) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Group Icon
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade800,
            backgroundImage: NetworkImage(group.iconUrl),
            onBackgroundImageError: (_, __) => const Icon(Icons.group),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: AppFont.subtitle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${group.membersCount} members',
                  style: AppFont.caption.copyWith(color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          // Join Button or Joined Status
          if (isJoined)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.5)),
              ),
              child: const Text(
                'Joined',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: () => controller.joinGroup(group),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                shadowColor: AppColors.primary.withOpacity(0.3),
                elevation: 5,
              ),
              child: const Text('JOIN'),
            ),
        ],
      ),
    );
  }

  Widget _buildGroupTile(GroupModel group) {
    return InkWell(
      onTap: () {
        Get.toNamed(Routes.CHAT, arguments: group);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Group Icon
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey.shade800,
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
                          color: Colors.white, // White Name
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatTime(group.lastMessageAt),
                        style: AppFont.caption.copyWith(
                          color: Colors.grey.shade500,
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
                            color: group.unreadCount > 0
                                ? Colors.white
                                : Colors.grey.shade500,
                            fontSize: 15,
                            fontWeight: group.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (group.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            group.unreadCount > 99
                                ? '99+'
                                : group.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
