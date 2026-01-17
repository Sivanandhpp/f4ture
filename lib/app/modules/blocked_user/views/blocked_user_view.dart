import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/core/constants/app_styles.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:f4ture/app/data/models/user_model.dart';

class BlockedUserView extends StatelessWidget {
  const BlockedUserView({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve User Details passed as arguments
    final UserModel? user = Get.arguments as UserModel?;

    return Scaffold(
      backgroundColor: AppColors.scaffoldbg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Icon
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.block_rounded,
                  size: 64,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 40),
              // Title
              Text(
                'Account Disabled',
                style: AppFont.heading.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Message
              Text(
                'Sorry, your account has been disabled due to suspicious activity or inappropriate behavior.',
                style: AppFont.body.copyWith(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Contact Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.appbarbg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Text(
                      'Think this is a mistake?',
                      style: AppFont.body.copyWith(
                        fontSize: 14,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        String body =
                            'Hello Admin,\n\n'
                            'My account has been disabled. I believe this is a mistake. Please review my case.\n\n'
                            '--- User Details ---\n'
                            'Name: ${user?.name ?? "Unknown"}\n'
                            'Email: ${user?.email ?? "Unknown"}\n'
                            'Phone: ${user?.phone ?? "Unknown"}\n'
                            'Role: ${user?.role ?? "Unknown"}\n'
                            'User ID: ${user?.id ?? "Unknown"}\n'
                            'Status: ${user?.status ?? "Inactive"}\n'
                            '-------------------';

                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: 'sivanandhpp@gmail.com',
                          query:
                              {
                                    'subject':
                                        'Account Appeal: ${user?.name ?? "User"}',
                                    'body': body,
                                  }.entries
                                  .map(
                                    (e) =>
                                        '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
                                  )
                                  .join('&'),
                        );
                        if (!await launchUrl(emailLaunchUri)) {
                          Get.snackbar('Error', 'Could not launch email app');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.mail_outline_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Contact Support',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // ID Reference
              Text(
                'Reference ID: ${user?.id ?? "Unknown"}',
                style: const TextStyle(
                  color: Colors.white24,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
