import 'package:f4ture/app/modules/chat/controllers/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f4ture/app/data/services/auth_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/message_model.dart';

class ChatInput extends GetView<ChatController> {
  const ChatInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = AuthService.to.currentUser.value;
      if (controller.group.type == 'channel' && user?.role == 'attendee') {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF1E1E1E),
          child: SafeArea(
            child: Text(
              'Only admins can send messages in this channel',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ),
        );
      }

      if (controller.selectedAttachment.value != null) {
        return _buildAttachmentPreview(context);
      }
      return _buildTextInput();
    });
  }

  Widget _buildTextInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // kSurface
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3), // Dark shadow
            offset: const Offset(0, -2),
            blurRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              onPressed: controller.pickAttachment,
              icon: const Icon(Icons.add, color: AppColors.primary),
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 100),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C), // Dark grey input
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: controller.messageController,
                  maxLines: null,
                  style: const TextStyle(color: Colors.white), // White text
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(() {
              return CircleAvatar(
                backgroundColor: AppColors.primary,
                child: controller.isSending.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : IconButton(
                        onPressed: controller.sendTextMessage,
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentPreview(BuildContext context) {
    final file = controller.selectedAttachment.value!;
    final type = controller.attachmentType.value;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: controller.cancelAttachment,
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
                const Spacer(),
                const Text(
                  'Preview',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                const SizedBox(width: 48), // Balance for centering
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: (type == MessageType.image || type == MessageType.video)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: controller.selectedAttachmentBytes.value != null
                            ? (type == MessageType.image
                                  ? Image.memory(
                                      controller.selectedAttachmentBytes.value!,
                                      fit: BoxFit.contain,
                                    )
                                  : Container(
                                      // Video placeholder for preview
                                      color: Colors.black,
                                      child: const Center(
                                        child: Icon(
                                          Icons.play_circle,
                                          color: Colors.white,
                                          size: 48,
                                        ),
                                      ),
                                    ))
                            : Container(),
                      )
                    : Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.insert_drive_file,
                              size: 48,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              file.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Obx(() {
                if (controller.isSending.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ElevatedButton.icon(
                  onPressed: controller.sendAttachment,
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: const Text(
                    'Send',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
