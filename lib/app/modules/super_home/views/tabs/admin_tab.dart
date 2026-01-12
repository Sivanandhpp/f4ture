import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/core/index.dart';
import 'package:f4ture/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../create_group_view.dart';

class AdminTab extends StatelessWidget {
  const AdminTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Admin Console',
          style: AppFont.heading.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildActionCard(
            context,
            title: 'Create Event',
            subtitle: 'Host a new concert, workshop, or meetup',
            icon: Icons.event,
            color: Colors.purple,
            onTap: () => Get.toNamed(Routes.CREATE_EVENT),
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            context,
            title: 'Create Group',
            subtitle: 'Start a new community or committee',
            icon: Icons.group_add,
            color: Colors.blue,
            onTap: () => Get.to(() => const CreateGroupView()),
          ),
          const SizedBox(height: 16),
          // Placeholder for future admin features
          _buildActionCard(
            context,
            title: 'Manage Users',
            subtitle: 'View and manage platform users',
            icon: Icons.manage_accounts,
            color: Colors.grey,
            onTap: () => Get.toNamed(Routes.MANAGE_USERS),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
