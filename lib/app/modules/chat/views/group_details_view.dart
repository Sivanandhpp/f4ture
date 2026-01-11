import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_image.dart';
import '../controllers/group_details_controller.dart';

class GroupDetailsView extends GetView<GroupDetailsController> {
  const GroupDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Register controller if not present (simple dependency injection for this sub-feature)
    // In strict binding architecture, this goes in Binding, but Get.put works for sub-views too if needed.
    // Better to have it in binding if route is named.

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS grouped background style
      appBar: AppBar(
        title: const Text('Group Info', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildDescriptionSection()),
            SliverToBoxAdapter(child: _buildMembersSection()),
            SliverToBoxAdapter(child: _buildExitButton()),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          // Group Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipOval(
              child: AppImage.network(
                url: controller.group.iconUrl,
                fit: BoxFit.cover,
                errorWidget: Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.groups, size: 50, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Name
          Text(
            controller.group.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          // Member Count
          Text(
            'Group · ${controller.members.length} members',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    final createdDate = DateFormat(
      'dd/MM/yyyy',
    ).format(controller.group.createdAt);
    final creatorName = controller.creator.value?.name ?? 'Unknown';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.group.description,
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Created on $createdDate by $creatorName',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${controller.members.length} Members',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Icon(Icons.search, color: AppColors.primary),
              ],
            ),
          ),

          // Add Member Button
          InkWell(
            onTap: () {
              // Placeholder for Add Member flow
              Get.snackbar('Upcoming', 'Add Member feature coming soon');
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Add Participants',
                    style: TextStyle(color: AppColors.primary, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const Divider(indent: 70, height: 1),

          // Member List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.members.length,
            separatorBuilder: (c, i) => const Divider(indent: 70, height: 1),
            itemBuilder: (context, index) {
              final member = controller.members[index];
              return _buildMemberTile(member);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(GroupMember member) {
    final isAdmin = member.role == 'admin';
    final name = member.user.name;
    final subText = member.user.phone.isNotEmpty
        ? member.user.phone
        : (member.user.email ?? '');

    return InkWell(
      onLongPress: () {
        if (controller.isCurrentUserAdmin.value) {
          _showAdminOptions(member);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            ClipOval(
              child: AppImage.network(
                url: member.user.profilePhoto ?? '',
                width: 40,
                height: 40,
                errorWidget: Container(
                  width: 40,
                  height: 40,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isAdmin) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: const Text(
                            'Group Admin',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subText,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdminOptions(GroupMember member) {
    if (member.role == 'admin') {
      // Options for existing admin
      Get.bottomSheet(
        Container(
          color: Colors.white,
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.remove_moderator, color: Colors.blue),
                title: const Text('Dismiss as Admin'),
                onTap: () {
                  Get.back();
                  controller.removeAdmin(member.user.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_remove, color: Colors.red),
                title: Text('Remove ${member.user.name}'),
                onTap: () {
                  Get.back();
                  controller.removeMember(member.user.id);
                },
              ),
              ListTile(
                title: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: () => Get.back(),
              ),
            ],
          ),
        ),
      );
    } else {
      // Options for regular member
      Get.bottomSheet(
        Container(
          color: Colors.white,
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.security, color: Colors.blue),
                title: const Text('Make Group Admin'),
                onTap: () {
                  Get.back();
                  controller.makeAdmin(member.user.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_remove, color: Colors.red),
                title: Text('Remove ${member.user.name}'),
                onTap: () {
                  Get.back();
                  controller.removeMember(member.user.id);
                },
              ),
              ListTile(
                title: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: () => Get.back(),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildExitButton() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      color: Colors.white,
      child: ListTile(
        leading: const Icon(Icons.exit_to_app, color: Colors.red),
        title: const Text(
          'Exit Group',
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
        onTap: () {
          Get.defaultDialog(
            title: 'Exit Group',
            middleText: 'Are you sure you want to exit this group?',
            textConfirm: 'Exit',
            confirmTextColor: Colors.white,
            onConfirm: () {
              Get.back();
              controller.exitGroup();
            },
            textCancel: 'Cancel',
            buttonColor: Colors.red,
          );
        },
      ),
    );
  }
}
