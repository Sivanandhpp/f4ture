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

  // Metadata Lists
  final RxList<String> eventTypes = <String>[].obs;
  final RxList<String> eventVenues = <String>[].obs;
  final RxMap<int, DateTime> eventDates = <int, DateTime>{}.obs;
  final RxList<int> availableDays = <int>[].obs;

  final RxBool isEditMode = false.obs;
  String? editingEventId;

  final RxnString existingBannerUrl = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchMetaData().then((_) {
      // Check for arguments after metadata is loaded to ensure lists are ready
      if (Get.arguments is EventModel) {
        final event = Get.arguments as EventModel;
        isEditMode.value = true;
        editingEventId = event.eventId;
        _prefillData(event);
      }
    });
  }

  void _prefillData(EventModel event) {
    titleController.text = event.title;
    descriptionController.text = event.description;
    venueController.text = event.venue;
    ticketPriceController.text = event.ticketPrice.toString();
    ticketUrlController.text = event.ticketPurchaseUrl ?? '';
    totalSeatsController.text = event.totalSeats?.toString() ?? '';

    // Ensure values exist in lists before setting, or handle gracefully
    if (eventTypes.contains(event.type)) {
      selectedType.value = event.type;
    }

    if (availableDays.contains(event.day)) {
      selectedDay.value = event.day;
    } else {
      // If for some reason the day isn't 'available' (e.g. metadata changed),
      // we might want to just show it anyway?
      // For now, if not found, it stays default (0).
      // But usually users want to see preserving data.
      // Given hardcoded dates, it should match 1-4.
    }

    startTime.value = event.startTime;
    endTime.value = event.endTime;
    selectedCurrency.value = event.currency;
    isSoldOut.value = event.isSoldOut;
    isFeatured.value = event.isFeatured;
    existingBannerUrl.value = event.imageUrl;
  }

  Future<void> fetchMetaData() async {
    try {
      // Fetch Types
      final typeDoc = await _firestore
          .collection('appMetaData')
          .doc('eventType')
          .get();
      if (typeDoc.exists) {
        final data = typeDoc.data()!;
        final types = data.values.map((e) => e.toString()).toList();
        eventTypes.assignAll(types);
        if (eventTypes.isNotEmpty) selectedType.value = eventTypes.first;
      }

      // Fetch Venues
      final venueDoc = await _firestore
          .collection('appMetaData')
          .doc('eventVenue')
          .get();
      if (venueDoc.exists) {
        final data = venueDoc.data()!;
        final venues = data.values.map((e) => e.toString()).toList();
        eventVenues.assignAll(venues);
      }

      // Fetch Dates - HARDCODED as per request
      final Map<int, DateTime> hardcodedDates = {
        0: DateTime(2026, 1, 29), // All Days (default to Day 1 date)
        1: DateTime(2026, 1, 29),
        2: DateTime(2026, 1, 30),
        3: DateTime(2026, 1, 31),
        4: DateTime(2026, 2, 1),
      };

      eventDates.value = hardcodedDates;

      // 0 represents "All Days"
      availableDays.assignAll([0, 1, 2, 3, 4]);

      // Default to "All Days" (0)
      if (availableDays.isNotEmpty) {
        selectedDay.value = 0;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load metadata: $e');
      if (availableDays.isEmpty) {
        availableDays.assignAll([0, 1]); // Fallback
        selectedDay.value = 0;
      }
    }
  }

  Future<void> pickBannerImage() async {
    final result = await AppImagePicker.showImagePickerOptions();
    if (result != null) {
      selectedBanner.value = result.selectedImage;
      selectedBannerBytes.value = await result.selectedImage.readAsBytes();
    }
  }

  Future<void> pickTime(BuildContext context, {required bool isStart}) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      // Get date from selectedDay
      final date = eventDates[selectedDay.value] ?? DateTime.now();

      final dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      if (isStart) {
        startTime.value = dateTime;
        if (endTime.value != null && endTime.value!.isBefore(dateTime)) {
          endTime.value = null;
        }
      } else {
        if (startTime.value != null && dateTime.isBefore(startTime.value!)) {
          Get.snackbar('Error', 'End time cannot be before Start time');
          return;
        }
        endTime.value = dateTime;
      }
    }
  }

  // --- Save Logic ---

  Future<void> saveEvent() async {
    if (!formKey.currentState!.validate()) return;

    if (startTime.value == null) {
      Get.snackbar(
        'Required',
        'Please select Start time',
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
      final docRef = isEditMode.value && editingEventId != null
          ? _firestore.collection('events').doc(editingEventId)
          : _firestore.collection('events').doc();

      String? imageUrl;

      // Upload Image (Only if new image selected)
      if (selectedBanner.value != null) {
        final ref = _storage.ref().child('event_banners/${docRef.id}.jpg');
        final bytes = await selectedBanner.value!.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        imageUrl = await ref.getDownloadURL();
      } else if (isEditMode.value && Get.arguments is EventModel) {
        // Keep existing image if no new one selected
        imageUrl = (Get.arguments as EventModel).imageUrl;
      }

      final event = EventModel(
        eventId: docRef.id,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        type: selectedType.value,
        day: selectedDay.value,
        startTime: startTime.value!,
        endTime: endTime.value,
        venue: venueController.text.trim(),
        imageUrl: imageUrl,
        ticketPrice: double.tryParse(ticketPriceController.text) ?? 0.0,
        currency: selectedCurrency.value,
        ticketPurchaseUrl: ticketUrlController.text.trim().isNotEmpty
            ? ticketUrlController.text.trim()
            : null,
        totalSeats: int.tryParse(totalSeatsController.text),
        availableSeats: int.tryParse(totalSeatsController.text),
        isSoldOut: isSoldOut.value,
        isFeatured: isFeatured.value,
        createdAt: isEditMode.value && Get.arguments is EventModel
            ? (Get.arguments as EventModel).createdAt
            : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditMode.value) {
        await docRef.update(event.toJson());
        Get.back(); // Return to Manage Events
        Get.snackbar(
          'Success',
          'Event updated successfully!',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      } else {
        await docRef.set(event.toJson());
        Get.back(); // Return to Manage Events
        Get.snackbar(
          'Success',
          'Event created successfully!',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save event: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
