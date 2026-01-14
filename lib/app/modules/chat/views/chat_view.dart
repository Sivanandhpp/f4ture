import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f4ture/app/modules/chat/controllers/chat_controller.dart';
import 'package:f4ture/app/modules/chat/widgets/chat_input.dart';
import 'package:f4ture/app/modules/chat/widgets/message_bubble.dart';
import 'package:f4ture/app/data/services/auth_service.dart';
import 'package:f4ture/app/routes/app_pages.dart';
import 'package:f4ture/app/core/constants/app_colors.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldbg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.appbaritems),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () =>
              Get.toNamed(Routes.GROUP_DETAILS, arguments: controller.group),
          child: Row(
            children: [
              Hero(
                tag: controller.group.groupId,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(controller.group.iconUrl),
                  radius: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.group.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.appbaritems,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${controller.group.membersCount} members',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: AppColors.appbarbg,
        elevation: 0.5,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: AppColors.appbaritems),
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
                padding: const EdgeInsets.all(16),
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
