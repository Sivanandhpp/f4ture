import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/core/utils/app_image_picker.dart';
import 'package:f4ture/app/data/models/event_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CreateEventController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Form Controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final venueController = TextEditingController();
  final ticketPriceController = TextEditingController(text: '0');
  final ticketUrlController = TextEditingController();
  final totalSeatsController = TextEditingController();

  // Observable Values
  final RxString selectedType = 'Concert'.obs;
  final RxInt selectedDay = 1.obs;
  final RxString selectedCurrency = 'INR'.obs;

  final Rx<DateTime?> startTime = Rx<DateTime?>(null);
  final Rx<DateTime?> endTime = Rx<DateTime?>(null);

  final RxBool isSoldOut = false.obs;
  final RxBool isFeatured = false.obs;

  // Image
  final Rx<XFile?> selectedBanner = Rx<XFile?>(null);
  final Rx<Uint8List?> selectedBannerBytes = Rx<Uint8List?>(null);

  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    venueController.dispose();
    ticketPriceController.dispose();
    ticketUrlController.dispose();
    totalSeatsController.dispose();
    super.onClose();
  }

  // --- Pickers ---

  Future<void> pickBannerImage() async {
    final result = await AppImagePicker.showImagePickerOptions();
    if (result != null) {
      selectedBanner.value = result.selectedImage;
      selectedBannerBytes.value = await result.selectedImage.readAsBytes();
    }
  }

  Future<void> pickDateTime(
    BuildContext context, {
    required bool isStart,
  }) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date != null) {
      // ignore: use_build_context_synchronously
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        if (isStart) {
          startTime.value = dateTime;
          // Reset end time if it's before new start time
          if (endTime.value != null && endTime.value!.isBefore(dateTime)) {
            endTime.value = null;
          }
        } else {
          if (startTime.value != null && dateTime.isBefore(startTime.value!)) {
            Get.snackbar(
              'Error',
              'End time cannot be before Start time',
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
            );
            return;
          }
          endTime.value = dateTime;
        }
      }
    }
  }

  // --- Save Logic ---

  Future<void> saveEvent() async {
    if (!formKey.currentState!.validate()) return;

    if (startTime.value == null || endTime.value == null) {
      Get.snackbar(
        'Required',
        'Please select Start and End times',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedBanner.value == null) {
      Get.snackbar(
        'Required',
        'Please select an Event Banner',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final docRef = _firestore.collection('events').doc();
      String? imageUrl;

      // Upload Image
      if (selectedBanner.value != null) {
        final ref = _storage.ref().child('event_banners/${docRef.id}.jpg');
        final bytes = await selectedBanner.value!.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        imageUrl = await ref.getDownloadURL();
      }

      final event = EventModel(
        eventId: docRef.id,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        type: selectedType.value,
        day: selectedDay.value,
        startTime: startTime.value!,
        endTime: endTime.value!,
        venue: venueController.text.trim(),
        imageUrl: imageUrl,
        ticketPrice: double.tryParse(ticketPriceController.text) ?? 0.0,
        currency: selectedCurrency.value,
        ticketPurchaseUrl: ticketUrlController.text.trim().isNotEmpty
            ? ticketUrlController.text.trim()
            : null,
        totalSeats: int.tryParse(totalSeatsController.text),
        availableSeats: int.tryParse(
          totalSeatsController.text,
        ), // Initially same as total
        isSoldOut: isSoldOut.value,
        isFeatured: isFeatured.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(event.toJson());

      Get.back();
      Get.snackbar(
        'Success',
        'Event created successfully!',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create event: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
