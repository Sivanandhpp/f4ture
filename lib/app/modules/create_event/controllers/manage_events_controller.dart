import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/data/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManageEventsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<EventModel> events = <EventModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  void loadEvents() {
    isLoading.value = true;
    _firestore
        .collection('events')
        .snapshots()
        .listen(
          (snapshot) {
            events.value = snapshot.docs
                .map((doc) => EventModel.fromJson(doc.data()))
                .toList();
            // Sort by creation date descending
            events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            isLoading.value = false;
          },
          onError: (e) {
            isLoading.value = false;
            Get.snackbar('Error', 'Failed to load events: $e');
          },
        );
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      Get.snackbar(
        'Success',
        'Event deleted successfully',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete event: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
