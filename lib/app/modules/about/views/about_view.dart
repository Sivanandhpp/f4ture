import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/core/constants/app_styles.dart';
import '../controllers/about_controller.dart';

class AboutView extends GetView<AboutController> {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldbg,
      appBar: AppBar(
        title: Text(
          'About',
          style: AppFont.heading.copyWith(
            color: AppColors.scaffolditems,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.appbarbg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.scaffolditems),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Developer Profile Section
            _buildDeveloperProfile(),
            const SizedBox(height: 12),
            _buildLegalLink(
              title: 'Version 1.0.0',
              icon: Icons.info,
              onTap: () => controller.openUrl(
                '',
              ),
            ),

            const SizedBox(height: 32),

            // 2. Legal Section
            Text(
              'Legal',
              style: AppFont.title.copyWith(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 16),
            _buildLegalLink(
              title: 'Privacy Policy',
              icon: Icons.privacy_tip_outlined,
              onTap: () => controller.openUrl(
                'https://thef4turesummit.web.app/privacy-policy',
              ),
            ),
            const SizedBox(height: 12),
            _buildLegalLink(
              title: 'Terms & Conditions',
              icon: Icons.description_outlined,
              onTap: () => controller.openUrl(
                'https://thef4turesummit.web.app/terms-and-conditions',
              ),
            ),

            const SizedBox(height: 48),

            // 3. Danger Zone
            _buildDangerZone(),

            const SizedBox(height: 40),

            // Footer
            Center(
              child: Text(
                '© 2026 Future summit - All rights reserved\n Developed by Sivanandh P P',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperProfile() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.background, // Dark card color
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo
          Image.asset(
            'assets/images/logo.png',
            height: 60,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),

          Text(
            'This app is Developed for',
            style: TextStyle(
              color: Colors.black.withOpacity(0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'The Summit of Future 2026',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          // const SizedBox(height: 8),
          // Text(
          //   'by',
          //   style: TextStyle(
          //     color: Colors.white.withOpacity(0.6),
          //     fontSize: 12,
          //   ),
          // ),
          // const SizedBox(height: 8),

          // InkWell(
          //   onTap: () =>
          //       controller.openUrl('https://linkedin.com/in/sivanandhpp'),
          //   borderRadius: BorderRadius.circular(12),
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //     child: Text(
          //       'Sivanandh P P',
          //       style: TextStyle(
          //         color: AppColors.primary,
          //         fontWeight: FontWeight.bold,
          //         fontSize: 20,
          //         decoration: TextDecoration.underline,
          //         decorationColor: AppColors.primary.withOpacity(0.5),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildLegalLink({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danger Zone',
          style: AppFont.title.copyWith(color: AppColors.error, fontSize: 20),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: controller.deleteAccount,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.error.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.delete_forever, color: AppColors.error, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delete Account',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'This action can be reversed within 14 days.',
                        style: TextStyle(
                          color: AppColors.error.withOpacity(
                            0.8,
                          ), // or lighter red
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
