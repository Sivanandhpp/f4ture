import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/index.dart';
import '../controllers/super_home_controller.dart';

class CreateGroupView extends GetView<SuperHomeController> {
  const CreateGroupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Create Group',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
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
                            color: const Color(0xFFD4D4D4),
                            image:
                                controller.selectedGroupIconBytes.value != null
                                ? DecorationImage(
                                    image: MemoryImage(
                                      controller.selectedGroupIconBytes.value!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            border: Border.all(color: const Color(0xFF7B7B7B)),
                          ),
                          child: controller.selectedGroupIcon.value == null
                              ? const Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: AppColors.textSecondary,
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
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Group Name',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  filled: true,

                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusMd,
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.group,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              AppSpacing.verticalMd,

              // Description
              TextField(
                controller: controller.groupDescriptionController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusMd,
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.info_outline,
                    color: AppColors.textSecondary,
                  ),
                ),
                maxLines: 3,
              ),
              AppSpacing.verticalMd,

              // Group Type Selection
              Text(
                'Group Type',
                style: AppFont.body.copyWith(color: AppColors.textSecondary),
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
      checkmarkColor: AppColors.card,
      backgroundColor: AppColors.card,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.card : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
