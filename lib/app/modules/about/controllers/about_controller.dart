import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:f4ture/app/data/services/auth_service.dart';
import 'package:f4ture/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';


class AboutController extends GetxController {
  void openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar('Error', 'Could not launch url');
    }
  }

  void deleteAccount() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E), // AppColors.scaffoldbg
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Upon request, your account will be immediately deactivated and hidden from other users. You will have a 14-day grace period to reactivate your account by simply logging back in.\n\nIf you do not log in within these 14 days, your account and all associated personal data will be permanently deleted from our servers. This permanent deletion is irreversible.',
          style: TextStyle(color: Colors.white70),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog
              await _performDeletion();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeletion() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Set status to 'deleted'
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              'status': 'deleted',
              'deletedAt': FieldValue.serverTimestamp(),
            });

        await AuthService.to.clearUser();
        Get.offAllNamed(Routes.AUTHENTICATION);

        Get.snackbar(
          'Account Deleted',
          'Your account has been deactivated.',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete account: $e');
    }
  }
}
