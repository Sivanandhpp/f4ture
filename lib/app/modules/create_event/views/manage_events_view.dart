import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/manage_events_controller.dart';

class ManageEventsView extends GetView<ManageEventsController> {
  const ManageEventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldbg,
      appBar: AppBar(
        title: const Text(
          'Manage Events',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.appbarbg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.CREATE_EVENT),
        backgroundColor: AppColors.primary, // Neon Green
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Create Event',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.grey.shade700),
                const SizedBox(height: 16),
                Text(
                  'No events found',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 18),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.events.length,
          itemBuilder: (context, index) {
            final event = controller.events[index];
            return Card(
              color: AppColors.appbarbg,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade800),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(8),
                    image: event.imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(event.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: event.imageUrl == null
                      ? const Icon(Icons.event, color: Colors.grey)
                      : null,
                ),
                title: Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('MMM dd').format(event.startTime)} • ${event.venue}',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.isSoldOut ? 'SOLD OUT' : 'Available',
                      style: TextStyle(
                        color: event.isSoldOut ? Colors.red : AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Get.toNamed(Routes.CREATE_EVENT, arguments: event);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmDialog(context, event.eventId);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, String eventId) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.appbarbg,
        title: const Text(
          'Delete Event',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this event? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              controller.deleteEvent(eventId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
