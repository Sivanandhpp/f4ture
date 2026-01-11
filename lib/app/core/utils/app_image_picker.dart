import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mime/mime.dart';
import '../../core/index.dart';

/// Image picker result containing selected image details
class ImagePickerResult {
  final XFile selectedImage;
  final String mimeType;
  final int size;

  ImagePickerResult({
    required this.selectedImage,
    required this.mimeType,
    required this.size,
  });

  @override
  String toString() {
    return 'ImagePickerResult(path: ${selectedImage.path}, mimeType: $mimeType, size: ${size}bytes)';
  }
}

/// Centralized image picker widget with bottom sheet UI
class AppImagePicker {
  AppImagePicker._();

  static final ImagePicker _imagePicker = ImagePicker();

  /// Show image picker options and return selected image details
  static Future<ImagePickerResult?> showImagePickerOptions({
    String title = 'Choose Photo',
    bool showCamera = true,
    bool showGallery = true,
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 80,
    CameraDevice preferredCameraDevice = CameraDevice.front,
  }) async {
    ImagePickerResult? result;

    await Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface, // Used AppColors
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary, // Used AppColors
                ),
              ),
              const SizedBox(height: 20),

              // Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (showCamera)
                    _buildImagePickerOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () async {
                        final pickedResult = await _pickImage(
                          source: ImageSource.camera,
                          maxWidth: maxWidth,
                          maxHeight: maxHeight,
                          imageQuality: imageQuality,
                          preferredCameraDevice: preferredCameraDevice,
                        );
                        result = pickedResult;
                        Get.back();
                      },
                    ),
                  if (showGallery)
                    _buildImagePickerOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () async {
                        final pickedResult = await _pickImage(
                          source: ImageSource.gallery,
                          maxWidth: maxWidth,
                          maxHeight: maxHeight,
                          imageQuality: imageQuality,
                          preferredCameraDevice: preferredCameraDevice,
                        );
                        result = pickedResult;
                        Get.back();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Cancel button
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.textSecondary, // Used AppColors
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );

    return result;
  }

  /// Build individual picker option widget
  static Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Pick image from specified source with error handling
  static Future<ImagePickerResult?> _pickImage({
    required ImageSource source,
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 80,
    CameraDevice preferredCameraDevice = CameraDevice.front,
  }) async {
    try {
      // Check permissions
      final hasPermission = await _checkPermissions(source);
      if (!hasPermission) {
        Get.snackbar(
          'Permission Required',
          source == ImageSource.camera
              ? 'Camera permission is required to take photos'
              : 'Storage permission is required to access gallery',
          backgroundColor: AppColors.warning,
          colorText: Colors.black,
        );
        return null;
      }

      // Pick image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        preferredCameraDevice: preferredCameraDevice,
      );

      if (pickedFile != null) {
        final size = await pickedFile.length();
        final mimeType = lookupMimeType(pickedFile.path) ?? 'image/jpeg';

        debugPrint(
          'Image selected: ${pickedFile.path}, Size: $size, Mime: $mimeType',
        );

        return ImagePickerResult(
          selectedImage: pickedFile,
          mimeType: mimeType,
          size: size,
        );
      }
    } on PlatformException catch (e) {
      debugPrint('Platform exception while picking image: $e');

      String errorMessage = 'Failed to pick image. ';
      if (e.code == 'camera_access_denied') {
        errorMessage += 'Camera permission was denied.';
      } else if (e.code == 'photo_access_denied') {
        errorMessage += 'Photo library permission was denied.';
      } else if (e.code == 'invalid_image') {
        errorMessage += 'The selected file is not a valid image.';
      } else {
        errorMessage += 'Please try again or restart the app.';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      debugPrint('Unexpected error picking image: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }

    return null;
  }

  /// Check and request permissions based on image source
  static Future<bool> _checkPermissions(ImageSource source) async {
    if (source == ImageSource.camera) {
      final cameraStatus = await Permission.camera.request();
      return cameraStatus == PermissionStatus.granted;
    } else {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        // For Android 13+ (SDK 33), use photos permission
        // Simplified check, assuming photos permission for newer androids
        // In real app, check SDK version using device_info_plus if needed.
        // For simplicity, requesting storage and photos.

        final storage = await Permission.storage.status;
        if (storage.isGranted) return true;

        final photos = await Permission.photos.status;
        if (photos.isGranted) return true;

        // Request
        final storageResult = await Permission.storage.request();
        if (storageResult.isGranted) return true;

        final photosResult = await Permission.photos.request();
        return photosResult.isGranted;
      }
      // iOS / other / Web (permission_handler handles web generally or returns granted)
      final photos = await Permission.photos.request();
      return photos.isGranted;
    }
  }

  /// Quick access method for profile picture selection
  static Future<ImagePickerResult?> pickProfilePicture() async {
    return showImagePickerOptions(
      title: 'Choose Profile Photo',
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
  }

  /// Quick access method for product image selection
  static Future<ImagePickerResult?> pickProductImage() async {
    return showImagePickerOptions(
      title: 'Choose Product Photo',
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
  }
}
