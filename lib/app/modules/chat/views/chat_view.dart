import 'package:f4ture/app/core/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_image.dart';
import '../../../data/services/auth_service.dart';
import '../controllers/chat_controller.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Hero(
              tag: controller.group.groupId,
              child: ClipOval(
                child: AppImage.network(
                  url: controller.group.iconUrl,
                  width: 40,
                  height: 40,
                  errorWidget: Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.group, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.group.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${controller.group.membersCount} members',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Open Group Info / Settings
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty &&
                  controller.isLoadingMore.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                controller: controller.scrollController,
                reverse: true,
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount:
                    controller.messages.length +
                    (controller.isLoadingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.messages.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final message = controller.messages[index];
                  final isMe =
                      message.senderId == AuthService.to.currentUser.value?.id;

                  return MessageBubble(message: message, isMe: isMe);
                },
              );
            }),
          ),
          const ChatInput(),
        ],
      ),
    );
  }
}
