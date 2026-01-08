import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/index.dart';
import '../controllers/authentication_controller.dart';

class AuthenticationView extends GetView<AuthenticationController> {
  const AuthenticationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image (placeholder)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                size: 120,
                color: Colors.white24,
              ),
            ),
          ),

          // Bottom Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: AppPadding.allMd,
              padding: AppPadding.allLg,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: AppRadius.radiusXxl,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Obx(
                () => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Text(
                      'Welcome to the future',
                      style: AppFont.heading.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    AppSpacing.verticalLg,

                    // OTP Sent Info (shown after sending OTP)
                    if (controller.isOtpSent.value) ...[
                      _buildOtpSentInfo(context),
                      AppSpacing.verticalMd,
                    ],

                    // Phone or OTP Field
                    if (!controller.isOtpSent.value)
                      _buildPhoneField(context)
                    else
                      _buildOtpField(context),

                    AppSpacing.verticalLg,

                    // Action Button
                    _buildActionButton(context),

                    AppSpacing.verticalMd,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpSentInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'OTP sent to ',
          style: AppFont.body.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        Text(
          controller.phoneNumber.value,
          style: AppFont.subtitle.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        AppSpacing.horizontalSm,
        GestureDetector(
          onTap: controller.editPhoneNumber,
          child: Text(
            'Edit',
            style: AppFont.body.copyWith(
              color: AppColors.secondary,
              fontWeight: AppFont.semiBold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(BuildContext context) {
    return TextField(
      controller: controller.phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: 'Enter phone number',
        prefixIcon: const Icon(Icons.phone_outlined),
        prefixText: '+91 ',
        prefixStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  Widget _buildOtpField(BuildContext context) {
    return TextField(
      controller: controller.otpController,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      style: TextStyle(
        fontSize: AppFont.sizeHeading,
        fontWeight: AppFont.semiBold,
        letterSpacing: 16,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        hintText: '● ● ● ● ● ●',
        hintStyle: TextStyle(
          letterSpacing: 8,
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return ElevatedButton(
      onPressed: controller.isLoading.value
          ? null
          : (controller.isOtpSent.value
                ? controller.verifyOtp
                : controller.sendOtp),
      style: ElevatedButton.styleFrom(
        padding: AppPadding.verticalMd,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
      ),
      child: controller.isLoading.value
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              controller.isOtpSent.value ? 'Verify' : 'Send OTP',
              style: AppFont.subtitle.copyWith(color: Colors.white),
            ),
    );
  }
}
