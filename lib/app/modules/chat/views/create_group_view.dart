import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/index.dart';
import '../../../data/services/auth_service.dart';
import '../../chat/widgets/user_selector.dart';
import '../controllers/chat_list_controller.dart';

class CreateGroupView extends GetView<ChatListController> {
  const CreateGroupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldbg,
      appBar: AppBar(
        title: const Text(
          'Create Group',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.appbarbg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
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
                          color: AppColors.appbarbg,
                          image: controller.selectedGroupIconBytes.value != null
                              ? DecorationImage(
                                  image: MemoryImage(
                                    controller.selectedGroupIconBytes.value!,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          border: Border.all(color: Colors.grey.shade700),
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
                fillColor: AppColors.appbarbg,
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.radiusMd,
                  borderSide: BorderSide(color: Colors.grey.shade800),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.radiusMd,
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                prefixIcon: Icon(Icons.group, color: Colors.grey.shade400),
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
                fillColor: AppColors.appbarbg,
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.radiusMd,
                  borderSide: BorderSide(color: Colors.grey.shade800),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.radiusMd,
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                prefixIcon: Icon(
                  Icons.info_outline,
                  color: Colors.grey.shade400,
                ),
              ),
              maxLines: 3,
            ),
            AppSpacing.verticalMd,

            // Group Type Selection
            Text(
              'Group Type',
              style: AppFont.body.copyWith(color: Colors.white70),
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
            AppSpacing.verticalMd,

            // Members Selection
            Text(
              'Members',
              style: AppFont.body.copyWith(color: Colors.white70),
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
                          label: Text(
                            member.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          deleteIcon: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white70,
                          ),
                          onDeleted: () => controller.removeMember(member),
                          backgroundColor: AppColors.appbarbg,
                          side: BorderSide(color: Colors.grey.shade700),
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
                    icon: const Icon(
                      Icons.person_add,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      controller.selectedMembers.isEmpty
                          ? 'Add Members (Required)'
                          : 'Add More Members',
                      style: const TextStyle(color: AppColors.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      side: const BorderSide(color: AppColors.primary),
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
      checkmarkColor: Colors.black, // Dark check for contrast on primary
      backgroundColor: AppColors.appbarbg,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? Colors.transparent : Colors.grey.shade700,
      ),
    );
  }
}
