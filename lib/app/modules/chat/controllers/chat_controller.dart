import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/app_image_picker.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/message_model.dart';
import '../../../data/services/auth_service.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late GroupModel group;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isSending = false.obs;

  DocumentSnapshot? _lastDocument;
  static const int _limit = 20;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    // Retrieve group from arguments
    if (Get.arguments is GroupModel) {
      group = Get.arguments as GroupModel;
    } else {
      Get.back(); // Error safety
      return;
    }

    _loadInitialMessages();

    // Pagination listener
    scrollController.addListener(_scrollListener);
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.hasClients &&
        scrollController.position.pixels >=
            scrollController.position.maxScrollExtent * 0.9 &&
        !isLoadingMore.value &&
        _hasMore) {
      _loadMoreMessages();
    }
  }

  // --- Message Loading ---

  void _loadInitialMessages() {
    messages.clear();
    _firestore
        .collection('groups')
        .doc(group.groupId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(_limit)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            // Just for the first batch to set _lastDocument if we haven't loaded more yet
            if (_lastDocument == null || messages.isEmpty) {
              _lastDocument = snapshot.docs.last;
            }

            // Map snapshot to models
            final newMessages = snapshot.docs
                .map((doc) => MessageModel.fromJson(doc.data()))
                .toList();

            // In a real infinite scroll with real-time updates, handling "newly arrived" vs "pagination"
            // can be tricky. Simplest approach for chat:
            // The stream gives us the LATEST X messages.
            // Pagination fetches OLDER messages.
            // We merge them. Use a Map or check IDs to avoid duplicates.

            _mergeMessages(newMessages);
          }
        });
  }

  Future<void> _loadMoreMessages() async {
    if (isLoadingMore.value || !_hasMore || _lastDocument == null) return;

    isLoadingMore.value = true;
    try {
      final snapshot = await _firestore
          .collection('groups')
          .doc(group.groupId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_limit)
          .get();

      if (snapshot.docs.isEmpty) {
        _hasMore = false;
      } else {
        _lastDocument = snapshot.docs.last;
        final oldMessages = snapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data()))
            .toList();
        _mergeMessages(oldMessages);
      }
    } catch (e) {
      debugPrint("Error loading more messages: $e");
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _mergeMessages(List<MessageModel> newBatch) {
    // Simple de-duplication
    final existingIds = messages.map((m) => m.id).toSet();
    final uniqueNew = newBatch
        .where((m) => !existingIds.contains(m.id))
        .toList();

    messages.addAll(uniqueNew);

    // Sort to be safe: Descending by date (newest first)
    messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // --- Sending Messages ---

  Future<void> sendTextMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    messageController.clear();
    await _sendMessage(text: text, type: MessageType.text);
  }

  Future<void> _sendMessage({
    String? text,
    String? mediaUrl,
    String? mediaName,
    int? mediaSize,
    String? thumbnailUrl,
    required MessageType type,
  }) async {
    final user = AuthService.to.currentUser.value;
    if (user == null) return;

    final id = const Uuid().v4();
    final now = DateTime.now();

    final newMessage = MessageModel(
      id: id,
      senderId: user.id,
      senderName: user.name,
      senderAvatar: user.profilePhoto,
      type: type,
      text: text,
      mediaUrl: mediaUrl,
      mediaName: mediaName,
      mediaSize: mediaSize,
      thumbnailUrl: thumbnailUrl,
      createdAt: now,
      status: MessageStatus.pending,
    );

    // Optimistic UI: Add to top
    messages.insert(0, newMessage);

    try {
      // Write to Firestore
      await _firestore
          .collection('groups')
          .doc(group.groupId)
          .collection('messages')
          .doc(id)
          .set({
            ...newMessage.toJson(),
            'status': MessageStatus.sent.name,
            'createdAt': FieldValue.serverTimestamp(), // Use server time
          });

      // Update group last message
      await _firestore.collection('groups').doc(group.groupId).update({
        'lastMessage': _getLastMessageText(type, text),
        'lastMessageAt': FieldValue.serverTimestamp(),
      });

      // Update local status (optional, stream will likely overwrite this)
      final index = messages.indexWhere((m) => m.id == id);
      if (index != -1) {
        messages[index] = newMessage.copyWith(status: MessageStatus.sent);
      }
    } catch (e) {
      // Error state
      final index = messages.indexWhere((m) => m.id == id);
      if (index != -1) {
        messages[index] = newMessage.copyWith(status: MessageStatus.error);
      }
      Get.snackbar(
        'Error',
        'Failed to send message',
        backgroundColor: Colors.redAccent,
      );
    }
  }

  String _getLastMessageText(MessageType type, String? text) {
    switch (type) {
      case MessageType.text:
        return text ?? '';
      case MessageType.image:
        return '📷 Image';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.file:
        return '📎 File';
      case MessageType.info:
        return 'ℹ️ Info';
    }
  }

  // --- Attachments ---

  Future<void> pickAttachment() async {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('File'),
              onTap: () {
                Get.back();
                _pickFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    // Reusing AppImagePicker logic but customizing for chat upload
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (image != null) {
      isSending.value = true;
      try {
        // Upload logic
        final bytes = await image.readAsBytes();
        final fileName = 'chat_images/${const Uuid().v4()}.jpg';
        final ref = _storage.ref().child(fileName);

        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        final url = await ref.getDownloadURL();

        await _sendMessage(type: MessageType.image, mediaUrl: url);
      } catch (e) {
        Get.snackbar('Upload Failed', e.toString());
      } finally {
        isSending.value = false;
      }
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.bytes != null) {
      // Note: On web bytes are available, on mobile we might need path.
      // FilePicker on mobile with `withData: true` might crash on large files.
      // Better to check platform.

      final file = result.files.single;
      isSending.value = true;

      try {
        final fileName = 'chat_files/${const Uuid().v4()}_${file.name}';
        final ref = _storage.ref().child(fileName);

        // Handle web vs mobile
        if (file.bytes != null) {
          await ref.putData(file.bytes!);
        } else if (file.path != null) {
          await ref.putFile(File(file.path!));
        }

        final url = await ref.getDownloadURL();

        // Determine type (simplified)
        final mime = lookupMimeType(file.name);
        MessageType type = MessageType.file;
        if (mime != null) {
          if (mime.startsWith('image/'))
            type = MessageType.image;
          else if (mime.startsWith('video/'))
            type = MessageType.video;
        }

        await _sendMessage(
          type: type,
          mediaUrl: url,
          mediaName: file.name,
          mediaSize: file.size,
        );
      } catch (e) {
        Get.snackbar('Upload Failed', e.toString());
      } finally {
        isSending.value = false;
      }
    }
  }
}
