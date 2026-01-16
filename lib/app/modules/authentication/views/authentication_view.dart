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
      backgroundColor: Colors.black, // Dark background for contrast
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Gradient (Subtle)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.grey.shade900],
              ),
            ),
          ),
          // Video Background
          Column(
            children: [
              Expanded(
                flex: 5,
                child: SizedBox(
                  child: AppVideo.background(
                    assetPath: 'assets/videos/background.mp4',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(flex: 5, child: Container()),
            ],
          ),

          // Gradient Overlay for better text/image visibility if needed
          Container(color: Colors.black.withOpacity(0.3)),

          // Main Layout
          Column(
            children: [
              // Top Area: Image & Video Background
              Expanded(
                flex: 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Logo Image
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(62.0),
                        child: Image.asset(
                          'assets/images/vishayam.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Area: Form Container
              Expanded(
                flex: 6,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF1E1E1E,
                    ), // Slightly lighter/distinct dark color
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: Obx(() {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title
                          Text(
                            'Welcome Back',
                            style: AppFont.heading.copyWith(
                              fontSize: 28,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to continue',
                            style: AppFont.body.copyWith(
                              color: Colors.white60,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 32),
                          // Title for Step
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              controller.currentStep.value ==
                                      AuthStep.emailInput
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
                          if (controller.currentStep.value ==
                              AuthStep.emailInput)
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
                              obscureText: !controller.isPasswordVisible.value,
                              autoFocus: true,
                              // Add visibility toggle
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isPasswordVisible.value
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white70,
                                ),
                                onPressed: () =>
                                    controller.isPasswordVisible.toggle(),
                              ),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
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
                              icon: Image.asset(
                                'assets/images/google.png',
                                height: 26,
                                width: 26,
                              ),
                            ),
                          ],

                          // Back Button (if in password step)
                          if (controller.currentStep.value ==
                              AuthStep.passwordInput)
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
              ),
            ],
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
    Widget? suffixIcon,
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
          suffixIcon: suffixIcon,
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
