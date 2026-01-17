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
              // 1. Banner Image
              GestureDetector(
                onTap: controller.pickBannerImage,
                child: Obx(() {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.appbarbg,
                      borderRadius: BorderRadius.circular(16),
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
                      border: Border.all(color: Colors.white10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child:
                        (controller.selectedBannerBytes.value == null &&
                            controller.existingBannerUrl.value == null)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 50,
                                color: AppColors.primary,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Upload Event Banner',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // 2. Basic Info
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.titleController,
                decoration: _inputDecoration('Event Title'),
                style: const TextStyle(color: Colors.white),
                validator: (v) => v!.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.descriptionController,
                maxLines: 4,
                decoration: _inputDecoration('Description'),
                style: const TextStyle(color: Colors.white),
                validator: (v) => v!.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 24),

              // 3. Date & Time
              _buildSectionHeader('Date & Time'),
              const SizedBox(height: 16),
              // Day Selection (Chips)
              Obx(() {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: controller.availableDays.map((day) {
                    final isSelected = controller.selectedDay.value == day;
                    final date = controller.eventDates[day];
                    final dateStr = day == 0
                        ? 'Jan 29-Feb 1'
                        : (date != null
                              ? DateFormat('MMM dd').format(date)
                              : '');

                    return ChoiceChip(
                      label: Text(
                        day == 0 ? 'All Days' : 'Day $day ($dateStr)',
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) controller.selectedDay.value = day;
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.appbarbg,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.white12,
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 16),
              // Time Row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.pickTime(context, isStart: true),
                      child: Obx(
                        () => _buildTimeCard(
                          'Start Time (Optional)',
                          controller.startTime.value,
                          Icons.wb_sunny_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.pickTime(context, isStart: false),
                      child: Obx(
                        () => _buildTimeCard(
                          'End Time (Optional)',
                          controller.endTime.value,
                          Icons.nightlight_round,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. Categorization
              _buildSectionHeader('Categorization'),
              const SizedBox(height: 16),
              // Type Dropdown
              Obx(() {
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
                  decoration: _inputDecoration('Event Type'),
                  dropdownColor: AppColors.appbarbg,
                  style: const TextStyle(color: Colors.white),
                  items: controller.eventTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) controller.selectedType.value = v;
                  },
                );
              }),
              const SizedBox(height: 16),
              // Track Chips (Optional)
              const Text(
                'Track (Optional)',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Obx(() {
                if (controller.eventTracks.isEmpty) {
                  return const Text(
                    'No tracks available',
                    style: TextStyle(color: Colors.white24),
                  );
                }
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: controller.eventTracks.map((track) {
                    final isSelected = controller.selectedTrack.value == track;
                    return FilterChip(
                      label: Text(track),
                      selected: isSelected,
                      onSelected: (selected) {
                        controller.selectedTrack.value = selected
                            ? track
                            : null;
                      },
                      selectedColor: AppColors.secondary,
                      backgroundColor: AppColors.appbarbg,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.secondary
                              : Colors.white12,
                        ),
                      ),
                      checkmarkColor: Colors.black,
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 24),

              // 5. Venue & Tickets
              _buildSectionHeader('Venue & Tickets'),
              const SizedBox(height: 16),
              Obx(() {
                final venues = controller.eventVenues;
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
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) controller.venueController.text = v;
                  },
                  validator: (v) => controller.venueController.text.isEmpty
                      ? 'Venue is required'
                      : null,
                );
              }),
              const SizedBox(height: 16),
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
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.appbarbg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
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
              TextFormField(
                controller: controller.ticketUrlController,
                keyboardType: TextInputType.url,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Ticket Purchase URL (Optional)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.totalSeatsController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Total Seats (Optional)'),
              ),
              const SizedBox(height: 24),

              // 6. Settings
              _buildSectionHeader('Settings'),
              const SizedBox(height: 12),
              Obx(
                () => SwitchListTile(
                  title: const Text(
                    'Mark as Sold Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  value: controller.isSoldOut.value,
                  onChanged: (v) => controller.isSoldOut.value = v,
                  activeColor: Colors.redAccent,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Obx(
                () => SwitchListTile(
                  title: const Text(
                    'Featured Event',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Show on Home Highlights',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
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

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          height: 20,
          width: 4,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeCard(String label, DateTime? time, IconData icon) {
    final hasTime = time != null;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.appbarbg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasTime ? AppColors.primary.withOpacity(0.5) : Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasTime ? DateFormat('hh:mm a').format(time) : '--:--',
            style: TextStyle(
              color: hasTime ? Colors.white : Colors.white38,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
