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
          // Background Video
          AppVideo.background(assetPath: 'assets/videos/background.mp4'),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Obx(() {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Text(
                      'Welcome Back',
                      style: AppFont.heading.copyWith(
                        fontSize: 32,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      style: AppFont.body.copyWith(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Title for Step
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        controller.currentStep.value == AuthStep.emailInput
                            ? 'Enter your email'
                            : 'Enter your password',
                        key: ValueKey(controller.currentStep.value),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Inputs
                    if (controller.currentStep.value == AuthStep.emailInput)
                      _buildRoundedTextField(
                        textController: controller.emailController,
                        hint: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      )
                    else
                      _buildRoundedTextField(
                        textController: controller.passwordController,
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        autoFocus: true,
                      ),

                    const SizedBox(height: 24),

                    // Continue Button
                    _buildRoundedButton(
                      text: 'Continue',
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.onContinue,
                      isLoading: controller.isLoading.value,
                      color: AppColors.primary,
                      textColor: Colors.white,
                    ),

                    const SizedBox(height: 16),

                    // Or Divider
                    if (controller.currentStep.value ==
                        AuthStep.emailInput) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Google Sign In Button
                      _buildRoundedButton(
                        text: 'Login with Google',
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.loginWithGoogle,
                        isOutlined: true,
                        textColor: Colors.white,
                        icon: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.g_mobiledata, // Fallback if no asset
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ],

                    // Back Button (if in password step)
                    if (controller.currentStep.value == AuthStep.passwordInput)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: TextButton(
                          onPressed: controller.resetFlow,
                          child: const Text(
                            'Use a different email',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedTextField({
    required TextEditingController textController,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    bool autoFocus = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextField(
        controller: textController,
        obscureText: obscureText,
        keyboardType: keyboardType,
        autofocus: autoFocus,
        textInputAction: TextInputAction.go, // Shows arrow/go button
        onSubmitted: (_) {
          if (!controller.isLoading.value) {
            controller
                .onContinue(); // Explicitly calls logic from GetView controller
          }
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedButton({
    required String text,
    VoidCallback? onPressed,
    Color? color,
    Color? textColor,
    bool isOutlined = false,
    bool isLoading = false,
    Widget? icon,
  }) {
    return SizedBox(
      height: 56, // Fixed height for consistency
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
              child: _buildButtonContent(text, textColor, isLoading, icon),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color ?? AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: _buildButtonContent(text, textColor, isLoading, icon),
            ),
    );
  }

  Widget _buildButtonContent(
    String text,
    Color? textColor,
    bool isLoading,
    Widget? icon,
  ) {
    if (isLoading) {
      return const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[icon, const SizedBox(width: 12)],
        Text(
          text,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
