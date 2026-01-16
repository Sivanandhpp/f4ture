import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:f4ture/app/data/models/event_model.dart';
import 'package:f4ture/app/modules/attendee/controllers/attendee_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum HomeState { countdown, live, post }

class HomeController extends GetxController with WidgetsBindingObserver {
  final ScrollController scrollController = ScrollController();
  final isVideoVisible = true.obs;

  late AttendeeController _attendeeController;
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;

  // Event Data
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<EventModel> events = <EventModel>[].obs;
  final Rx<HomeState> homeState = HomeState.countdown.obs;

  // Live/Upcoming
  final Rxn<EventModel> currentEvent = Rxn<EventModel>();
  final Rxn<EventModel> nextEvent = Rxn<EventModel>();
  final RxString currentDayLabel = ''.obs; // e.g., "Day 1"

  // Timer
  Timer? _timer;
  final RxString timeLeftStr = ''.obs; // DD:HH:MM:SS for countdown
  final RxString nextEventTimeLeft = ''.obs; // HH:MM for next event

  // Start Date: Jan 29, 2026
  // Start Date: Jan 29, 2026
  final DateTime eventStartDate = DateTime(2026, 1, 29);

  // Event Filtering for Home Tab
  final RxString selectedFilter = 'Featured'.obs;

  List<EventModel> get filteredEvents {
    if (events.isEmpty) return [];
    switch (selectedFilter.value) {
      case 'Featured':
        return events.where((e) => e.isFeatured == true).toList();
      case 'Concerts':
        return events.where((e) => e.type?.toLowerCase() == 'concert').toList();
      case 'Day 1':
        return events.where((e) => e.day == 1).toList();
      case 'Day 2':
        return events.where((e) => e.day == 2).toList();
      case 'Day 3':
        return events.where((e) => e.day == 3).toList();
      case 'Day 4':
        return events.where((e) => e.day == 4).toList();
      default:
        // Default to Featured if unknown filter, or empty
        return events.where((e) => e.isFeatured == true).toList();
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    try {
      _attendeeController = Get.find<AttendeeController>();
      ever(_attendeeController.tabIndex, (_) => _checkVisibility());
    } catch (e) {
      debugPrint('AttendeeController not found: $e');
    }

    fetchHomeEvents();
    _updateState(); // Initialize state immediately for countdown
    _startTimer();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    _timer?.cancel();
    super.onClose();
  }

  Future<void> fetchHomeEvents() async {
    try {
      // Fetch all events sorted by startTime
      final snapshot = await _firestore
          .collection('events')
          .orderBy('startTime')
          .get();

      if (snapshot.docs.isNotEmpty) {
        events.assignAll(
          snapshot.docs.map((doc) => EventModel.fromJson(doc.data())).toList(),
        );
        _updateState();
      }
    } catch (e) {
      debugPrint('Error fetching home events: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateState();
    });
  }

  void _updateState() {
    final now = DateTime.now();

    // 1. Check if before Event Start
    if (now.isBefore(eventStartDate)) {
      homeState.value = HomeState.countdown;
      final diff = eventStartDate.difference(now);

      final days = diff.inDays.toString().padLeft(2, '0');
      final hours = (diff.inHours % 24).toString().padLeft(2, '0');
      final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');

      timeLeftStr.value = '$days : $hours : $minutes : $seconds';
      return;
    }

    // 2. Check Day Logic (29 Jan - 1 Feb)
    homeState.value = HomeState.live;

    // Day Calculation
    // Day 1: 29 Jan
    // Day 2: 30 Jan...
    final diffDays = now.difference(eventStartDate).inDays + 1;
    if (diffDays >= 1 && diffDays <= 4) {
      currentDayLabel.value = 'Day $diffDays';
    } else if (diffDays > 4) {
      homeState.value = HomeState.post;
      currentDayLabel.value = 'Event Ended';
    } else {
      currentDayLabel.value = '';
    }

    // 3. Find Current and Next Event
    // Current: Started but not ended (or closest future if nothing running)
    // Actually, user wants:
    // "Current <next event...>"
    // Let's find the first event that hasn't ended yet

    final upcoming = events
        .where((e) => e.endTime == null || e.endTime!.isAfter(now))
        .toList();

    if (upcoming.isNotEmpty) {
      // Logic:
      // If we are IN an event (start < now < end), that's current.
      // If not, the immediate next start is current (as "Up Next").

      // Let's try to find an active event first
      final active = upcoming.firstWhereOrNull(
        (e) => e.startTime.isBefore(now),
      );

      if (active != null) {
        currentEvent.value = active;
        // Next is the one after active
        final index = upcoming.indexOf(active);
        if (index + 1 < upcoming.length) {
          nextEvent.value = upcoming[index + 1];
        } else {
          nextEvent.value = null;
        }
      } else {
        // No active event, so everything is future. Current is the first one.
        currentEvent.value = upcoming.first;
        if (upcoming.length > 1) {
          nextEvent.value = upcoming[1];
        } else {
          nextEvent.value = null;
        }
      }

      // Calc time left for NEXT event to START
      if (nextEvent.value != null) {
        final diff = nextEvent.value!.startTime.difference(now);
        if (diff.isNegative) {
          nextEventTimeLeft.value = 'Now';
        } else {
          final h = diff.inHours;
          final m = diff.inMinutes % 60;
          if (h > 0) {
            nextEventTimeLeft.value = '${h}h ${m}m';
          } else {
            nextEventTimeLeft.value = '${m}m';
          }
        }
      }
    } else {
      currentEvent.value = null;
      nextEvent.value = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
    _checkVisibility();
  }

  void _checkVisibility() {
    if (_appLifecycleState != AppLifecycleState.resumed) {
      if (isVideoVisible.value) isVideoVisible.value = false;
      return;
    }

    try {
      if (_attendeeController.tabIndex.value != 0) {
        if (isVideoVisible.value) isVideoVisible.value = false;
        return;
      }
    } catch (_) {}

    if (!isVideoVisible.value) isVideoVisible.value = true;
  }
}
