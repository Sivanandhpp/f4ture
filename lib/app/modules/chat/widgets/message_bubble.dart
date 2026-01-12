import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_video.dart';
import '../../../data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    if (message.type == MessageType.info ||
        message.type == MessageType.system) {
      return _buildInfoMessage();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[_buildAvatar(), const SizedBox(width: 8)],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: Get.width * 0.75),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? Get.theme.primaryColor : Colors.grey.shade200,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe
                          ? const Radius.circular(16)
                          : const Radius.circular(0),
                      bottomRight: isMe
                          ? const Radius.circular(0)
                          : const Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMe) ...[
                        Text(
                          message.senderName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      _buildContent(context),
                      const SizedBox(height: 4),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (message.status == MessageStatus.error)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 8),
              child: Text(
                'Failed to send',
                style: TextStyle(color: Colors.red.shade400, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return ClipOval(
      child: AppImage.network(
        url: message.senderAvatar ?? '',
        width: 28,
        height: 28,
        errorWidget: Container(
          width: 28,
          height: 28,
          color: Colors.grey.shade300,
          child: const Icon(Icons.person, size: 16, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final textColor = isMe ? Colors.white : Colors.black87;

    switch (message.type) {
      case MessageType.text:
        return Text(
          message.text ?? '',
          style: TextStyle(color: textColor, fontSize: 15),
        );
      case MessageType.image:
        return GestureDetector(
          onTap: () {
            if (message.mediaUrl != null) {
              Get.dialog(
                Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(color: Colors.black),
                      ),
                    ),
                    Center(
                      child: AppImage.network(
                        url: message.mediaUrl!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
          child: Hero(
            tag: message.id,
            child: AppImage.network(
              url: message.mediaUrl ?? '',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      case MessageType.video:
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(8),
          ),
          child: AppVideo.network(
            url: message.mediaUrl ?? '',
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case MessageType.file:
        return GestureDetector(
          onTap: () async {
            if (message.mediaUrl != null) {
              final uri = Uri.parse(message.mediaUrl!);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                Get.snackbar('Error', 'Could not open file');
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isMe ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.insert_drive_file,
                  color: isMe ? Colors.white : Colors.black54,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message.mediaName ?? 'File',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case MessageType.system:
        return Container(); // Handled in parent builder logic as specific 'SystemBubble' or handle here if we pass logic.
      // Better: Handle in the main switch.
      // Actually, system messages should be centered and distinct.
      // Since MessageBubble usually assumes left/right alignment based on `isMe`,
      // we might want to return a Centered Text here directly.
      // But `MessageBubble` has a lot of wrappers.

      default:
        return const SizedBox();
    }
  }

  Widget _buildFooter() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          DateFormat('hh:mm a').format(message.createdAt),
          style: TextStyle(
            fontSize: 10,
            color: isMe ? Colors.white70 : Colors.grey.shade600,
          ),
        ),
        if (isMe) ...[const SizedBox(width: 4), _buildStatusIcon()],
      ],
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color = Colors.white70;

    switch (message.status) {
      case MessageStatus.pending:
        icon = Icons.access_time;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.lightBlueAccent;
        break;
      case MessageStatus.error:
        icon = Icons.error_outline;
        color = Colors.redAccent;
        break;
    }

    return Icon(icon, size: 12, color: color);
  }

  Widget _buildInfoMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.text ?? '',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
          ),
        ),
      ),
    );
  }
}
