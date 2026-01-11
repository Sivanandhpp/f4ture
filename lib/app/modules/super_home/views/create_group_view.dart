import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/index.dart';
import '../controllers/super_home_controller.dart';

class CreateGroupView extends GetView<SuperHomeController> {
  const CreateGroupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('New Group', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPadding.allLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Group Icon Picker
              Center(
                child: Obx(
                  () => GestureDetector(
                    onTap: controller.pickGroupIcon,
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade900,
                            image: controller.selectedGroupIcon.value != null
                                ? DecorationImage(
                                    image: FileImage(
                                      controller.selectedGroupIcon.value!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            border: Border.all(color: Colors.grey.shade800),
                          ),
                          child: controller.selectedGroupIcon.value == null
                              ? const Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AppSpacing.verticalXl,

              // Group Name
              TextField(
                controller: controller.groupNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Group Name',
                  labelStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusMd,
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.group, color: Colors.grey),
                ),
              ),
              AppSpacing.verticalMd,

              // Description
              TextField(
                controller: controller.groupDescriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusMd,
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.info_outline,
                    color: Colors.grey,
                  ),
                ),
                maxLines: 3,
              ),
              AppSpacing.verticalMd,

              // Group Type Selection
              Text(
                'Group Type',
                style: AppFont.body.copyWith(color: Colors.grey.shade400),
              ),
              AppSpacing.verticalSm,
              Obx(
                () => Row(
                  children: [
                    _buildTypeChip('Public', 'public'),
                    AppSpacing.horizontalSm,
                    _buildTypeChip('Private', 'private'),
                    AppSpacing.horizontalSm,
                    _buildTypeChip('Committee', 'committee'),
                  ],
                ),
              ),
              AppSpacing.verticalXl,

              // Create Button
              Obx(
                () => AppButton(
                  text: 'Create Group',
                  onPressed: controller.createGroup,
                  isLoading: controller.isLoading.value,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, String value) {
    final isSelected = controller.selectedType.value == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) controller.selectedType.value = value;
      },
      backgroundColor: Colors.grey.shade900,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey.shade400,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
