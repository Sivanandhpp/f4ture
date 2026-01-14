import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/data/services/auth_service.dart';
import 'package:f4ture/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldbg, // Dark background
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: AppColors.appbarbg,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.scaffoldbg,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildSectionHeader('GENERAL'),
            _buildSettingTile(
              icon: Icons.person_outline,
              title: 'Account Security',
              subtitle: 'Password, Email, 2FA',
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Push, Email, SMS',
              onTap: () {},
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('APP'),
            _buildSettingTile(
              icon: Icons.dark_mode_outlined,
              title: 'Appearance',
              subtitle: 'Theme, Colors',
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'Version 1.0.0',
              onTap: () {},
            ),

            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  AuthService.to.clearUser();
                  Get.offAllNamed(Routes.AUTHENTICATION);
                },
                icon: const Icon(Icons.logout, size: 20, color: Colors.white),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 100), // Bottom padding for navbar
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[500],
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.appbarbg, // Dark Surface
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryLight),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.scaffolditems,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}
