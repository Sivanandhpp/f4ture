import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/event_schedule_controller.dart';

class EventScheduleView extends GetView<EventScheduleController> {
  const EventScheduleView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EventScheduleView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'EventScheduleView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
