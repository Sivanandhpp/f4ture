import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f4ture/app/core/index.dart'; // Assuming AppColors, AppFont are here
import 'package:f4ture/app/core/widgets/app_image.dart'; // If you want to use AppImage for profile pic
import 'package:f4ture/app/data/services/auth_service.dart';
import 'package:f4ture/app/routes/app_pages.dart';
import 'package:f4ture/app/core/constants/app_colors.dart'; // Explicit import if needed

class SettingsTab extends GetView<AuthService> {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller is AuthService.to (GetView resolves this if put)
    // Or simpler: use AuthService.to directly if GetView isn't strict
    final auth = AuthService.to;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Obx(() {
        final user = auth.currentUser.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Top Section: Profile
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: AppImage.network(
                        url: user.profilePhoto ?? '',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          color: AppColors.primary.withOpacity(0.1),
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user.role.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Middle Section: Details
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  const Text(
                    'PERSONAL INFORMATION',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailItem(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user.email ?? 'Not provided',
                  ),
                  _buildDetailItem(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: user.phone,
                  ),
                  _buildDetailItem(
                    icon: Icons.verified_user_outlined,
                    label: 'Status',
                    value: user.status.capitalizeFirst ?? user.status,
                  ),
                  const SizedBox(height: 20),
                  if (user.interests.isNotEmpty) ...[
                    const Text(
                      'INTERESTS',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: user.interests
                          .map(
                            (interest) => Chip(
                              label: Text(interest),
                              backgroundColor: Colors.grey[100],
                              labelStyle: TextStyle(color: Colors.grey[800]),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),

            // Bottom Section: Logout
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await auth.clearUser();
                    Get.offAllNamed(Routes.AUTHENTICATION);
                  },
                  icon: const Icon(
                    Icons.logout,
                    size: 20,
                    color: Colors.white,
                  ), // Explicit color
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ), // Explicit color
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
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.grey[400]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
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
