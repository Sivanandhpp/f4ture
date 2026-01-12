import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/core/index.dart';
import 'package:f4ture/app/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/manage_users_controller.dart';

class ManageUsersView extends GetView<ManageUsersController> {
  const ManageUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for contrast
      appBar: AppBar(
        title: Text(
          'Manage Users',
          style: AppFont.heading.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = controller.filteredUsers;
              if (users.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return _buildUserCard(context, users[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        onChanged: (val) => controller.searchQuery.value = val,
        decoration: InputDecoration(
          hintText: 'Search by Name, Email, or Phone',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      'All',
      'Jain',
      'Admin',
      'Core',
      'Lead',
      'Committee',
      'Attendee',
    ];
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white, // Keep background cohesive
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          return Obx(() {
            final isSelected = controller.selectedFilter.value == filter;
            return ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) controller.selectedFilter.value = filter;
              },
              selectedColor: _getRoleColor(filter),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.grey[300]!,
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          backgroundImage:
              user.profilePhoto != null && user.profilePhoto!.isNotEmpty
              ? NetworkImage(user.profilePhoto!)
              : null,
          child: (user.profilePhoto == null || user.profilePhoto!.isEmpty)
              ? Text(
                  user.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (user.status != 'active')
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Inactive',
                  style: TextStyle(fontSize: 10, color: Colors.red),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.email != null) ...[
              const SizedBox(height: 4),
              Text(
                user.email!,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                user.role.toUpperCase(),
                style: TextStyle(
                  color: _getRoleColor(user.role),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: _buildAdminActions(context, user),
      ),
    );
  }

  Widget _buildAdminActions(BuildContext context, UserModel user) {
    // Only show actions if Admin
    // In a real app we might verify current user role again, but UI can be permissive as logic is secured
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.grey),
      onSelected: (value) {
        if (value == 'edit_role') {
          _showRolePicker(context, user);
        } else if (value == 'toggle_status') {
          controller.toggleUserStatus(user.id, user.status != 'active');
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit_role',
          child: Row(
            children: [
              Icon(Icons.admin_panel_settings_outlined, size: 20),
              SizedBox(width: 8),
              Text('Change Role'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle_status',
          child: Row(
            children: [
              Icon(
                user.status == 'active'
                    ? Icons.block
                    : Icons.check_circle_outline,
                size: 20,
                color: user.status == 'active' ? Colors.red : Colors.green,
              ),
              SizedBox(width: 8),
              Text(user.status == 'active' ? 'Deactivate' : 'Activate'),
            ],
          ),
        ),
      ],
    );
  }

  void _showRolePicker(BuildContext context, UserModel user) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select New Role',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            ...['attendee', 'committee', 'lead', 'core', 'admin'].map((role) {
              return ListTile(
                title: Text(role.toUpperCase()),
                leading: Radio<String>(
                  value: role,
                  groupValue: user.role,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    Get.back(); // Close sheet
                    if (val != null) controller.updateUserRole(user.id, val);
                  },
                ),
                onTap: () {
                  Get.back();
                  controller.updateUserRole(user.id, role);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.redAccent;
      case 'core':
        return Colors.orange;
      case 'lead':
        return Colors.blue;
      case 'committee':
        return Colors.purple;
      case 'jain': // for filter chip
        return Colors.indigo;
      default: // attendee
        return AppColors.primary;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.perm_identity, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
