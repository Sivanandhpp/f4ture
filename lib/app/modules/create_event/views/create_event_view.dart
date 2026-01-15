import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/create_event_controller.dart';

class CreateEventView extends GetView<CreateEventController> {
  const CreateEventView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldbg,
      appBar: AppBar(
        title: const Text(
          'Create Event',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.scaffoldbg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            return controller.isLoading.value
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: controller.saveEvent,
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  );
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Image
              GestureDetector(
                onTap: controller.pickBannerImage,
                child: Obx(() {
                  return Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.appbarbg,
                      borderRadius: BorderRadius.circular(12),
                      image: controller.selectedBannerBytes.value != null
                          ? DecorationImage(
                              image: MemoryImage(
                                controller.selectedBannerBytes.value!,
                              ),
                              fit: BoxFit.cover,
                            )
                          : (controller.existingBannerUrl.value != null
                                ? DecorationImage(
                                    image: NetworkImage(
                                      controller.existingBannerUrl.value!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null),
                      border: Border.all(color: Colors.grey.shade800),
                    ),
                    child:
                        (controller.selectedBannerBytes.value == null &&
                            controller.existingBannerUrl.value == null)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add Event Banner',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          )
                        : null,
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: controller.titleController,
                decoration: _inputDecoration('Event Title'),
                style: const TextStyle(color: Colors.white),
                validator: (v) => v!.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: controller.descriptionController,
                maxLines: 4,
                decoration: _inputDecoration('Description'),
                style: const TextStyle(color: Colors.white),
                validator: (v) => v!.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),

              // Type & Day Row
              Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      // Safe value selection logic
                      final validValue =
                          controller.eventTypes.contains(
                            controller.selectedType.value,
                          )
                          ? controller.selectedType.value
                          : (controller.eventTypes.isNotEmpty
                                ? controller.eventTypes.first
                                : null);

                      return DropdownButtonFormField<String>(
                        value: validValue,
                        decoration: _inputDecoration('Type'),
                        dropdownColor: AppColors.appbarbg,
                        style: const TextStyle(color: Colors.white),
                        items: controller.eventTypes
                            .map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text(
                                  t,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) controller.selectedType.value = v;
                        },
                      );
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() {
                      final validValue =
                          controller.availableDays.contains(
                            controller.selectedDay.value,
                          )
                          ? controller.selectedDay.value
                          : (controller.availableDays.isNotEmpty
                                ? controller.availableDays.first
                                : null);

                      return DropdownButtonFormField<int>(
                        value: validValue,
                        decoration: _inputDecoration('Day'),
                        dropdownColor: AppColors.appbarbg,
                        style: const TextStyle(color: Colors.white),
                        items: controller.availableDays.map((d) {
                          if (d == 0) {
                            return DropdownMenuItem(
                              value: d,
                              child: const Text(
                                'All Days',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }
                          final date = controller.eventDates[d];
                          final dateStr = date != null
                              ? DateFormat('MMM dd').format(date)
                              : '';
                          return DropdownMenuItem(
                            value: d,
                            child: Text(
                              'Day $d - $dateStr',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) controller.selectedDay.value = v;
                        },
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Time Row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.pickTime(context, isStart: true),
                      child: AbsorbPointer(
                        child: Obx(
                          () => TextFormField(
                            decoration: _inputDecoration('Start Time').copyWith(
                              suffixIcon: const Icon(
                                Icons.access_time,
                                color: Colors.grey,
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            controller: TextEditingController(
                              text: controller.startTime.value != null
                                  ? DateFormat(
                                      'hh:mm a',
                                    ).format(controller.startTime.value!)
                                  : '',
                            ),
                            validator: (v) => controller.startTime.value == null
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.pickTime(context, isStart: false),
                      child: AbsorbPointer(
                        child: Obx(
                          () => TextFormField(
                            decoration: _inputDecoration('End Time').copyWith(
                              suffixIcon: const Icon(
                                Icons.access_time,
                                color: Colors.grey,
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            controller: TextEditingController(
                              text: controller.endTime.value != null
                                  ? DateFormat(
                                      'hh:mm a',
                                    ).format(controller.endTime.value!)
                                  : '',
                            ),
                            validator: (v) => controller.endTime.value == null
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Venue
              Obx(() {
                // Ensure selected value exists
                final venues = controller.eventVenues;
                // Ideally we should use a dropdown, but previously it was text field.
                // Detailed request says "use drop down for ... venue".

                return DropdownButtonFormField<String>(
                  value: venues.contains(controller.venueController.text)
                      ? controller.venueController.text
                      : null,
                  decoration: _inputDecoration('Venue').copyWith(
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: Colors.grey,
                    ),
                  ),
                  dropdownColor: AppColors.appbarbg,
                  style: const TextStyle(color: Colors.white),
                  hint: const Text(
                    'Select Venue',
                    style: TextStyle(color: Colors.grey),
                  ),
                  items: venues
                      .map(
                        (v) => DropdownMenuItem(
                          value: v,
                          child: Text(
                            v,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) controller.venueController.text = v;
                  },
                  validator: (v) => controller.venueController.text.isEmpty
                      ? 'Venue is required'
                      : null,
                );
              }),

              const SizedBox(height: 24),
              Divider(color: Colors.grey.shade800),
              const SizedBox(height: 24),

              const Text(
                'Ticket Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Price & Currency (Fixed INR)
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: controller.ticketPriceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Price (0 for Free)'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.appbarbg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade800),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'INR',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Purchase URL
              TextFormField(
                controller: controller.ticketUrlController,
                keyboardType: TextInputType.url,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Ticket Purchase URL (Optional)'),
              ),
              const SizedBox(height: 16),

              // Seats
              TextFormField(
                controller: controller.totalSeatsController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Total Seats (Optional)'),
              ),

              const SizedBox(height: 24),

              // Toggles
              Obx(
                () => SwitchListTile(
                  title: const Text(
                    'Mark as Sold Out',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: controller.isSoldOut.value,
                  onChanged: (v) => controller.isSoldOut.value = v,
                  activeColor: Colors.red,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Obx(
                () => SwitchListTile(
                  title: const Text(
                    'Featured Event',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Show on Home Highlights',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                  value: controller.isFeatured.value,
                  onChanged: (v) => controller.isFeatured.value = v,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade400),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade800),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade800),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: AppColors.appbarbg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
