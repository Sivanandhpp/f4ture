import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/core/constants/app_styles.dart';
import 'package:f4ture/app/data/models/user_model.dart';
import '../controllers/authentication_controller.dart';

class DeletedAccountView extends StatefulWidget {
  const DeletedAccountView({super.key});

  @override
  State<DeletedAccountView> createState() => _DeletedAccountViewState();
}

class _DeletedAccountViewState extends State<DeletedAccountView> {
  final AuthenticationController controller =
      Get.find<AuthenticationController>();
  late Timer _timer;
  final RxString timeLeftStr = ''.obs;
  DateTime? permanentDeletionTime;

  @override
  void initState() {
    super.initState();
    final UserModel? user = Get.arguments as UserModel?;
    if (user != null && user.deletedAt != null) {
      // 14 days after deletedAt
      permanentDeletionTime = user.deletedAt!.add(const Duration(days: 14));
      _startTimer();
    } else {
      // Fallback for missing data
      timeLeftStr.value = "Unknown";
    }
  }

  void _startTimer() {
    _updateTime(); // Initial update
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    if (permanentDeletionTime == null) return;

    final now = DateTime.now();
    final diff = permanentDeletionTime!.difference(now);

    if (diff.isNegative) {
      timeLeftStr.value = "Pending Deletion...";
      return;
    }

    final days = diff.inDays.toString().padLeft(2, '0');
    final hours = (diff.inHours % 24).toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');

    timeLeftStr.value = '$days : $hours : $minutes : $seconds';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  size: 64,
                  color: Colors.orangeAccent,
                ),
              ),
              const SizedBox(height: 40),
              // Title
              Text(
                'Account Deleted',
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
                'Your account is scheduled for permanent deletion. You can restore it within the grace period.',
                style: AppFont.body.copyWith(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Countdown
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 32,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    const Text(
                      'PERMANENT DELETION IN',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => Text(
                        timeLeftStr.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace', // Monospaced for numbers
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Reactivate Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.reactivateAccount(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    shadowColor: AppColors.primary.withOpacity(0.5),
                  ),
                  child: const Text(
                    'Reactivate Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              // Cancel / Sign ut
              TextButton(
                onPressed: () => controller.logout(), // Or just logout
                child: Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
