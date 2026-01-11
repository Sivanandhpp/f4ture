import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/index.dart';
import '../controllers/user_profile_controller.dart';

class UserProfileView extends GetView<UserProfileController> {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Complete Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPadding.allLg,
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Image Picker
                Center(
                  child: GestureDetector(
                    onTap: controller.pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            image: controller.selectedImage.value != null
                                ? DecorationImage(
                                    image: FileImage(
                                      controller.selectedImage.value!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            color: Colors.grey.shade900,
                          ),
                          child: controller.selectedImage.value == null
                              ? Icon(
                                  Icons.person_outline,
                                  size: 60,
                                  color: Colors.grey.shade400,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AppSpacing.verticalXl,

                // Name Field
                TextField(
                  controller: controller.nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: const Icon(
                      Icons.person,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMd,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMd,
                      borderSide: BorderSide(color: Colors.grey.shade800),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMd,
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                  ),
                ),
                AppSpacing.verticalMd,

                // Email Field (Optional)
                TextField(
                  controller: controller.emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email (Optional)',
                    labelStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: const Icon(
                      Icons.email,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMd,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMd,
                      borderSide: BorderSide(color: Colors.grey.shade800),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMd,
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                  ),
                ),
                AppSpacing.verticalLg,

                // Interests
                Text(
                  'Select Interests (Multi-select)',
                  style: AppFont.subtitle.copyWith(color: Colors.white),
                ),
                AppSpacing.verticalSm,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.availableInterests.map((interest) {
                    final isSelected = controller.selectedInterests.contains(
                      interest,
                    );
                    return FilterChip(
                      label: Text(interest),
                      selected: isSelected,
                      onSelected: (_) => controller.toggleInterest(interest),
                      backgroundColor: Colors.grey.shade900,
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade400,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade800,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                AppSpacing.verticalXl,

                // Save Button
                AppButton(
                  text: 'Save & Continue',
                  onPressed: controller.saveProfile,
                  isLoading: controller.isLoading.value,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
