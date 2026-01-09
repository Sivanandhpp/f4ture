import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// Centralized image loader for both network & asset images with shimmer loading,
/// consistent error UI, and optional rounded corners.
class AppImage {
  AppImage._();

  /// Cached network image with shimmer loading and error widget. Border radius supported.
  static Widget network({
    required String url,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
    Duration fadeInDuration = const Duration(milliseconds: 300),
    BorderRadius? borderRadius,
  }) {
    // Short-circuit for empty/invalid URLs to avoid needless work and logs.
    if (url.trim().isEmpty) {
      return _wrapWithRadius(
        child: _errorOrDefault(errorWidget, width, height),
        radius: borderRadius,
      );
    }

    Widget imageWidget = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, _) => _shimmerPlaceholder(width, height),
      errorWidget: (context, _, __) =>
          _errorOrDefault(errorWidget, width, height),
      fadeInDuration: fadeInDuration,
    );
    return _wrapWithRadius(child: imageWidget, radius: borderRadius);
  }

  /// Asset image with consistent API to network.
  static Widget asset({
    required String path,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    final imageWidget = Image(
      image: AssetImage(path),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) =>
          _errorOrDefault(null, width, height),
    );

    return _wrapWithRadius(child: imageWidget, radius: borderRadius);
  }

  // --- Private helpers ----------------------------------------------------

  static Widget _wrapWithRadius({required Widget child, BorderRadius? radius}) {
    if (radius == null) return child;
    return ClipRRect(borderRadius: radius, child: child);
  }

  static Widget _shimmerPlaceholder(double? width, double? height) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        color: Colors.grey.shade300,
      ),
    );
  }

  static Widget _errorOrDefault(Widget? custom, double? width, double? height) {
    if (custom != null) return custom;
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
    );
  }
}
