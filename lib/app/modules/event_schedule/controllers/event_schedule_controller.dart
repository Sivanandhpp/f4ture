import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:f4ture/app/data/models/event_model.dart';

class EventScheduleController extends GetxController {
  //TODO: Implement EventScheduleController

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<EventModel> events = <EventModel>[].obs;
  final RxBool isLoading = false.obs;

  // Search
  final RxString searchQuery = ''.obs;

  List<EventModel> get filteredEvents {
    if (searchQuery.value.isEmpty) {
      return events;
    }
    final query = searchQuery.value.toLowerCase().trim();
    return events.where((event) {
      final matchesTitle = event.title.toLowerCase().contains(query);
      final matchesVenue = event.venue.toLowerCase().contains(query);
      return matchesTitle || matchesVenue;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore
          .collection('events')
          .orderBy('startTime') // Ascending order
          .get();

      events.assignAll(
        snapshot.docs.map((doc) => EventModel.fromJson(doc.data())).toList(),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load schedule: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void refreshSchedule() => fetchEvents();
}
