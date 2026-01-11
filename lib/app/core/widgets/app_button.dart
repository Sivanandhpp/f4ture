import 'package:flutter/material.dart';
import '../../core/index.dart';

/// Primary button widget with consistent styling, loading state, and optional icon.
/// Supports both filled and outlined variants.
///
/// Usage:
/// ```dart
/// // Filled button (default)
/// AppButton(
///   text: 'Continue',
///   onPressed: () => handleContinue(),
///   isLoading: isSubmitting,
///   icon: Icons.arrow_forward,
/// )
///
/// // Outlined button
/// AppButton.outlined(
///   text: 'Previous',
///   onPressed: () => handlePrevious(),
///   icon: Icons.arrow_back,
/// )
/// ```
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.width,
    this.height = 56,
    this.icon,
    this.padding,
    this.variant = AppButtonVariant.filled,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  /// Creates an outlined button variant
  const AppButton.outlined({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.width,
    this.height = 56,
    this.icon,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  }) : variant = AppButtonVariant.outlined;

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final double? width;
  final double? height;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;
  final AppButtonVariant variant;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: variant == AppButtonVariant.filled
          ? _buildFilledButton()
          : _buildOutlinedButton(),
    );
  }

  /// Button is interactive when enabled and not loading
  bool get _isInteractive => enabled && !isLoading && onPressed != null;

  /// Builds filled button (primary style)
  Widget _buildFilledButton() {
    return ElevatedButton(
      onPressed: _isInteractive ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor:
            foregroundColor ??
            AppColors.surface, // Use surface (white) for text on primary
        disabledBackgroundColor: Colors.grey.shade300,
        disabledForegroundColor: Colors.grey.shade500,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLg,
        ), // Used AppRadius
        elevation: _isInteractive ? 2 : 0,
      ),
      child: _buildButtonContent(),
    );
  }

  /// Builds outlined button (secondary style)
  Widget _buildOutlinedButton() {
    return OutlinedButton(
      onPressed: _isInteractive ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor ?? AppColors.primary,
        disabledForegroundColor: Colors.grey.shade500,
        backgroundColor: backgroundColor ?? Colors.transparent,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLg,
        ), // Used AppRadius
        side: BorderSide(
          color: _isInteractive
              ? (borderColor ?? AppColors.primary)
              : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  /// Builds the button content - either loading indicator or text with optional icon
  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AppButtonVariant.filled
                ? (foregroundColor ?? AppColors.surface)
                : (foregroundColor ?? AppColors.primary),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: variant == AppButtonVariant.filled
                ? (foregroundColor ?? AppColors.surface)
                : (foregroundColor ?? AppColors.primary),
          ),
        ),
      ],
    );
  }
}

/// Button variant enum
enum AppButtonVariant { filled, outlined }
