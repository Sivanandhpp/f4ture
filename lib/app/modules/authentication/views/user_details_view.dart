import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/index.dart';
import '../controllers/user_details_controller.dart';

class UserDetailsView extends GetView<UserDetailsController> {
  const UserDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldbg,
      appBar: AppBar(
        title: const Text(
          'Complete Profile',
          style: TextStyle(color: AppColors.appbaritems),
        ),
        backgroundColor: AppColors.scaffoldbg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.appbaritems,
          ),
          onPressed: () => Get.back(),
        ),
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
                            color: Colors.grey.shade900,
                            image: controller.selectedImageBytes.value != null
                                ? DecorationImage(
                                    image: MemoryImage(
                                      controller.selectedImageBytes.value!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
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
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) {
                    // Skip Email, go to Phone
                    FocusScope.of(
                      context,
                    ).requestFocus(controller.phoneFocusNode);
                  },
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

                // Email Field (Read-only)
                TextField(
                  controller: controller.emailController,
                  readOnly: true,
                  // No focus logic needed as we skip it
                  style: const TextStyle(color: Colors.white70),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.email, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMd,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMd,
                      borderSide: BorderSide(color: Colors.grey.shade800),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMd,
                      borderSide: BorderSide(color: Colors.grey.shade800),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                  ),
                ),
                AppSpacing.verticalMd,

                // Phone Field
                TextField(
                  controller: controller.phoneController,
                  focusNode: controller.phoneFocusNode, // Assign Focus Node
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: const Icon(
                      Icons.phone,
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

                // Password Fields
                Obx(
                  () => TextField(
                    controller: controller.passwordController,
                    obscureText: !controller.isPasswordVisible.value,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {
                      FocusScope.of(
                        context,
                      ).requestFocus(controller.confirmPasswordFocusNode);
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.primary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          controller.isPasswordVisible.toggle();
                        },
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
                ),
                AppSpacing.verticalMd,

                Obx(
                  () => TextField(
                    controller: controller.confirmPasswordController,
                    focusNode: controller
                        .confirmPasswordFocusNode, // Assign Focus Node
                    obscureText: !controller.isConfirmPasswordVisible.value,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => controller.saveProfile(),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.primary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isConfirmPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          controller.isConfirmPasswordVisible.toggle();
                        },
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
                ),
                AppSpacing.verticalMd,

                AppSpacing.verticalLg,

                // // Interests
                // Text(
                //   'Select Interests (Multi-select)',
                //   style: AppFont.subtitle.copyWith(color: Colors.white),
                // ),
                // AppSpacing.verticalSm,
                // Wrap(
                //   spacing: 8,
                //   runSpacing: 8,
                //   children: controller.availableInterests.map((interest) {
                //     final isSelected = controller.selectedInterests.contains(
                //       interest,
                //     );
                //     return FilterChip(
                //       label: Text(interest),
                //       selected: isSelected,
                //       onSelected: (_) => controller.toggleInterest(interest),
                //       backgroundColor: Colors.grey.shade900,
                //       selectedColor: AppColors.primary,
                //       checkmarkColor: Colors.white,
                //       labelStyle: TextStyle(
                //         color: isSelected ? Colors.white : Colors.grey.shade400,
                //         fontWeight: isSelected
                //             ? FontWeight.bold
                //             : FontWeight.normal,
                //       ),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(20),
                //         side: BorderSide(
                //           color: isSelected
                //               ? AppColors.primary
                //               : Colors.grey.shade800,
                //         ),
                //       ),
                //     );
                //   }).toList(),
                // ),
                // AppSpacing.verticalXl,

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
