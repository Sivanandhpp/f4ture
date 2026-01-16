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
      backgroundColor: AppColors.scaffoldbg,
      appBar: AppBar(
        title: Text(
          'Manage Users',
          style: AppFont.heading.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.appbarbg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
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
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
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
      color: AppColors.appbarbg,
      child: TextField(
        onChanged: (val) => controller.searchQuery.value = val,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search by Name, Email, or Phone',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.black.withOpacity(0.3),
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
      color: AppColors.scaffoldbg,
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          return Obx(() {
            final isSelected = controller.selectedFilter.value == filter;
            return GestureDetector(
              onTap: () => controller.selectedFilter.value = filter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
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
        color: AppColors.appbarbg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
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
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (user.status != 'active')
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                ),
                child: const Text(
                  'Inactive',
                  style: TextStyle(fontSize: 10, color: Colors.redAccent),
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
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _getRoleColor(user.role).withOpacity(0.3),
                ),
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
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey[400]),
      color: AppColors.appbarbg,
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
              Icon(
                Icons.admin_panel_settings_outlined,
                size: 20,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text('Change Role', style: TextStyle(color: Colors.white)),
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
              Text(
                user.status == 'active' ? 'Deactivate' : 'Activate',
                style: const TextStyle(color: Colors.white),
              ),
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
          color: AppColors.appbarbg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select New Role',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ...['attendee', 'committee', 'lead', 'core', 'admin'].map((role) {
              return ListTile(
                title: Text(
                  role.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
                leading: Radio<String>(
                  value: role,
                  groupValue: user.role,
                  activeColor: AppColors.primary,
                  fillColor: MaterialStateProperty.resolveWith(
                    (states) => states.contains(MaterialState.selected)
                        ? AppColors.primary
                        : Colors.grey,
                  ),
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
        return Colors.purpleAccent;
      case 'jain': // for filter chip
        return Colors.indigoAccent;
      default: // attendee
        return AppColors.primary;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.perm_identity, size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
