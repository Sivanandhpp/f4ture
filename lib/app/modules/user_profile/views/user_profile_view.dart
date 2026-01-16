import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/core/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';

import '../controllers/user_profile_controller.dart';

class UserProfileView extends GetView<UserProfileController> {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldbg,
      appBar: AppBar(
        backgroundColor: AppColors.appbarbg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            onPressed: () {}, // Edit profile stub
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
      body: Obx(() {
        final user = controller.currentUser.value;
        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // 1. Profile Header
              _buildProfileHeader(user),
              const SizedBox(height: 32),

              // 2. Stats Row (Placeholder)
              // _buildStatsRow(),
              // const SizedBox(height: 32),

              // 3. User Details
              _buildSectionTitle('Personal Information'),
              const SizedBox(height: 16),
              _buildInfoCard([
                _buildInfoRow(
                  Icons.email_outlined,
                  'Email',
                  user.email ?? 'Not provided',
                ),
                const Divider(color: Colors.white10),
                _buildInfoRow(Icons.phone_outlined, 'Phone', user.phone),
                const Divider(color: Colors.white10),
                _buildInfoRow(
                  Icons.verified_user_outlined,
                  'Status',
                  user.status.capitalizeFirst ?? user.status,
                  isStatus: true,
                  statusColor: user.status == 'active'
                      ? AppColors.success
                      : Colors.red,
                ),
              ]),

              const SizedBox(height: 32),

              // 4. Interests
              // if (user.interests.isNotEmpty) ...[
              //   _buildSectionTitle('Interests'),
              //   const SizedBox(height: 16),
              //   SizedBox(
              //     width: double.infinity,
              //     child: Wrap(
              //       spacing: 8,
              //       runSpacing: 10,
              //       children: user.interests.map((interest) {
              //         return Chip(
              //           label: Text(interest),
              //           backgroundColor: AppColors.appbarbg,
              //           labelStyle: const TextStyle(color: Colors.white),
              //           side: BorderSide(
              //             color: AppColors.primary.withOpacity(0.3),
              //           ),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(20),
              //           ),
              //         );
              //       }).toList(),
              //     ),
              //   ),
              //   const SizedBox(height: 32),
              // ],

              // 5. Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.dialog(
                      CupertinoAlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text('No'),
                            onPressed: () => Get.back(),
                          ),
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () {
                              Get.back(); // Close dialog
                              controller.logout();
                            },
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout, size: 20, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.2),
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.red.withOpacity(0.5)),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(var user) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.appbarbg,
            backgroundImage:
                user.profilePhoto != null && user.profilePhoto!.isNotEmpty
                ? NetworkImage(user.profilePhoto!)
                : null,
            child: user.profilePhoto == null || user.profilePhoto!.isEmpty
                ? const Icon(Icons.person, size: 60, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Text(
            user.role.toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildStatsRow() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 16),
  //     decoration: BoxDecoration(
  //       color: AppColors.appbarbg,
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: Colors.white10),
  //     ),
  //     child: const Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //       children: [
  //         _StatItem(label: 'Events', count: '12'),
  //         _VerticalDivider(),
  //         _StatItem(label: 'Points', count: '450'),
  //         _VerticalDivider(),
  //         _StatItem(label: 'Rank', count: '#3'),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[500],
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.appbarbg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String? value, {
    bool isStatus = false,
    Color? statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? 'N/A',
                  style: TextStyle(
                    color: isStatus
                        ? (statusColor ?? Colors.white)
                        : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String count;

  const _StatItem({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 30, width: 1, color: Colors.white10);
  }
}
