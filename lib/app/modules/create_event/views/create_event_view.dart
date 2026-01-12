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
      appBar: AppBar(
        title: const Text(
          'Create Event',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
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
                        child: CircularProgressIndicator(strokeWidth: 2),
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
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      image: controller.selectedBannerBytes.value != null
                          ? DecorationImage(
                              image: MemoryImage(
                                controller.selectedBannerBytes.value!,
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: controller.selectedBannerBytes.value == null
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
                validator: (v) => v!.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: controller.descriptionController,
                maxLines: 4,
                decoration: _inputDecoration('Description'),
                validator: (v) => v!.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),

              // Type & Day Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: controller.selectedType.value,
                      decoration: _inputDecoration('Type'),
                      items:
                          [
                                'Concert',
                                'Keynote',
                                'Panel',
                                'Workshop',
                                'Competition',
                                'Other',
                              ]
                              .map(
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                      onChanged: (v) => controller.selectedType.value = v!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: controller.selectedDay.value,
                      decoration: _inputDecoration('Day'),
                      items: [1, 2, 3, 4]
                          .map(
                            (d) => DropdownMenuItem(
                              value: d,
                              child: Text('Day $d'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => controller.selectedDay.value = v!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Time Row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          controller.pickDateTime(context, isStart: true),
                      child: AbsorbPointer(
                        child: Obx(
                          () => TextFormField(
                            decoration: _inputDecoration('Start Time').copyWith(
                              suffixIcon: const Icon(Icons.access_time),
                            ),
                            controller: TextEditingController(
                              text: controller.startTime.value != null
                                  ? DateFormat(
                                      'MM/dd hh:mm a',
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
                      onTap: () =>
                          controller.pickDateTime(context, isStart: false),
                      child: AbsorbPointer(
                        child: Obx(
                          () => TextFormField(
                            decoration: _inputDecoration('End Time').copyWith(
                              suffixIcon: const Icon(Icons.access_time),
                            ),
                            controller: TextEditingController(
                              text: controller.endTime.value != null
                                  ? DateFormat(
                                      'MM/dd hh:mm a',
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
              TextFormField(
                controller: controller.venueController,
                decoration: _inputDecoration(
                  'Venue',
                ).copyWith(prefixIcon: const Icon(Icons.location_on_outlined)),
                validator: (v) => v!.isEmpty ? 'Venue is required' : null,
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              const Text(
                'Ticket Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Price & Currency
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: controller.ticketPriceController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Price (0 for Free)'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: controller.selectedCurrency.value,
                      decoration: _inputDecoration('Currency'),
                      items: ['INR', 'USD', 'EUR']
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) => controller.selectedCurrency.value = v!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Purchase URL
              TextFormField(
                controller: controller.ticketUrlController,
                keyboardType: TextInputType.url,
                decoration: _inputDecoration('Ticket Purchase URL (Optional)'),
              ),
              const SizedBox(height: 16),

              // Seats
              TextFormField(
                controller: controller.totalSeatsController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Total Seats (Optional)'),
              ),

              const SizedBox(height: 24),

              // Toggles
              Obx(
                () => SwitchListTile(
                  title: const Text('Mark as Sold Out'),
                  value: controller.isSoldOut.value,
                  onChanged: (v) => controller.isSoldOut.value = v,
                  activeColor: Colors.red,
                ),
              ),
              Obx(
                () => SwitchListTile(
                  title: const Text('Featured Event'),
                  subtitle: const Text('Show on Home Highlights'),
                  value: controller.isFeatured.value,
                  onChanged: (v) => controller.isFeatured.value = v,
                  activeColor: AppColors.primary,
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
