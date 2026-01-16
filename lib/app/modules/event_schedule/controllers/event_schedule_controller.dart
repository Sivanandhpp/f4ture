import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:f4ture/app/data/models/event_model.dart';

class EventScheduleController extends GetxController {
  //TODO: Implement EventScheduleController

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<EventModel> events = <EventModel>[].obs;
  final RxBool isLoading = false.obs;

  // Search & Filter
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxList<String> eventTypes = <String>['All'].obs;

  List<EventModel> get filteredEvents {
    var filtered = events;

    // 1. Filter by Category
    if (selectedCategory.value != 'All') {
      filtered = filtered
          .where((event) => event.type == selectedCategory.value)
          .toList()
          .obs;
    }

    // 2. Filter by Search Query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase().trim();
      return filtered.where((event) {
        final matchesTitle = event.title.toLowerCase().contains(query);
        final matchesVenue = event.venue.toLowerCase().contains(query);
        return matchesTitle || matchesVenue;
      }).toList();
    }

    return filtered.toList();
  }

  /// Groups filtered events by day (1, 2, 3, 4).
  /// Returns a Map where key is Day Number and value is List of Events.
  Map<int, List<EventModel>> get eventsByDay {
    final Map<int, List<EventModel>> grouped = {1: [], 2: [], 3: [], 4: []};

    for (var event in filteredEvents) {
      // Assuming event.day is 1-based index (1-4)
      if (grouped.containsKey(event.day)) {
        grouped[event.day]!.add(event);
      } else {
        // Handle events with day 0 (All Days) or out of range by adding to all?
        // Or specific logic. For now, let's assign day 0 to Day 1 or ignore.
        if (event.day == 0) {
          grouped[1]!.add(event);
        }
      }
    }

    // Sort each day's events by start time
    grouped.forEach((key, list) {
      list.sort((a, b) => a.startTime.compareTo(b.startTime));
    });

    return grouped;
  }

  @override
  void onInit() {
    super.onInit();
    fetchEventTypes();
    fetchEvents();
  }

  Future<void> fetchEventTypes() async {
    try {
      final typeDoc = await _firestore
          .collection('appMetaData')
          .doc('eventType')
          .get();
      if (typeDoc.exists) {
        final data = typeDoc.data()!;
        final types = data.values.map((e) => e.toString()).toList();
        // Ensure 'All' is first
        eventTypes.assignAll(['All', ...types]);
      }
    } catch (e) {
      print('Error fetching event types: $e');
    }
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
