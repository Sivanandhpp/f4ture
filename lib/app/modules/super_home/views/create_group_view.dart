import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/index.dart';
import '../../../data/services/auth_service.dart';
import '../../super_home/widgets/user_selector.dart';
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
      body: SingleChildScrollView(
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
                          image: controller.selectedGroupIconBytes.value != null
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
            // Members Selection
            Text(
              'Members',
              style: AppFont.body.copyWith(color: AppColors.textSecondary),
            ),
            AppSpacing.verticalSm,
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.selectedMembers.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.selectedMembers.map((member) {
                        return Chip(
                          label: Text(member.name),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => controller.removeMember(member),
                          backgroundColor: AppColors.card,
                          side: BorderSide(color: Colors.grey.shade300),
                        );
                      }).toList(),
                    ),
                  if (controller.selectedMembers.isNotEmpty)
                    AppSpacing.verticalSm,

                  OutlinedButton.icon(
                    onPressed: () {
                      Get.bottomSheet(
                        UserSelector(
                          alreadySelectedIds: controller.selectedMembers
                              .map((m) => m.id)
                              .toList(),
                          onSelectionChanged: (selected) {
                            controller.updateSelectedMembers(selected);
                          },
                        ),
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: Text(
                      controller.selectedMembers.isEmpty
                          ? 'Add Members (Required)'
                          : 'Add More Members',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
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
    );
  }

  Widget _buildTypeChip(String label, String value) {
    // Restrict 'committee' to admin, lead, core
    if (value == 'committee') {
      final user = AuthService.to.currentUser.value;
      if (user != null) {
        final role = user.role.toLowerCase();
        if (role != 'admin' && role != 'lead' && role != 'core') {
          return const SizedBox.shrink(); // Hide option
        }
      }
    }

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
