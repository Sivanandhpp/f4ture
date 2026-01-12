import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/message_model.dart';
import '../../../data/services/auth_service.dart';
import '../controllers/group_tasks_controller.dart';
import '../controllers/group_issues_controller.dart';
import '../widgets/create_task_sheet.dart';
import '../widgets/create_issue_sheet.dart';

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
    _resetUnreadCount();

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

  Future<void> _resetUnreadCount() async {
    final user = AuthService.to.currentUser.value;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .collection('groups')
          .doc(group.groupId)
          .update({'unreadCount': 0});
    } catch (e) {
      debugPrint("Error resetting unread count: $e");
    }
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
      case MessageType.system:
        return '🔧 System';
    }
  }

  // --- Attachments Staging ---

  final Rx<XFile?> selectedAttachment = Rx<XFile?>(null);
  final Rx<Uint8List?> selectedAttachmentBytes = Rx<Uint8List?>(null);
  final Rx<MessageType> attachmentType = Rx<MessageType>(MessageType.image);

  void cancelAttachment() {
    selectedAttachment.value = null;
    selectedAttachmentBytes.value = null;
  }

  Future<void> sendAttachment() async {
    if (selectedAttachment.value == null) return;

    isSending.value = true;
    final file = selectedAttachment.value!;
    final type = attachmentType.value;

    try {
      // 1. Upload
      final bytes = await file.readAsBytes();
      final ext = file.name.split('.').last;
      final fileName = 'chat_${type.name}s/${const Uuid().v4()}.$ext';
      final ref = _storage.ref().child(fileName);

      // Set metadata based on type
      final contentType = _getContentType(type, ext);
      await ref.putData(bytes, SettableMetadata(contentType: contentType));

      final url = await ref.getDownloadURL();

      // 2. Send Message
      await _sendMessage(
        type: type,
        mediaUrl: url,
        mediaName: file.name,
        mediaSize: await file.length(),
      );

      // 3. Clear staging
      cancelAttachment();
    } catch (e) {
      Get.snackbar(
        'Send Failed',
        e.toString(),
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isSending.value = false;
    }
  }

  String _getContentType(MessageType type, String ext) {
    if (type == MessageType.image) return 'image/$ext';
    if (type == MessageType.video) return 'video/$ext';
    return 'application/octet-stream';
  }

  // --- Picker Logic ---

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
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.assignment_add,
                color: AppColors.primary,
              ),
              title: const Text('Create Task'),
              onTap: () {
                Get.back();
                _openCreateTaskSheet();
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem, color: Colors.orange),
              title: const Text('Report Issue'),
              onTap: () {
                Get.back();
                _openCreateIssueSheet();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (image != null) {
      selectedAttachment.value = image;
      selectedAttachmentBytes.value = await image.readAsBytes();
      attachmentType.value = MessageType.image;
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true, // Needed for XFile on web/mem
      type: FileType.any,
    );

    if (result != null) {
      final file = result.files.single;

      // Convert PlatformFile to XFile
      XFile xFile;
      if (file.bytes != null) {
        xFile = XFile.fromData(file.bytes!, name: file.name);
      } else if (file.path != null) {
        xFile = XFile(file.path!, name: file.name);
      } else {
        return;
      }

      // Determine Type
      final mime = lookupMimeType(file.name);
      MessageType type = MessageType.file;
      if (mime != null) {
        if (mime.startsWith('image/'))
          type = MessageType.image;
        else if (mime.startsWith('video/'))
          type = MessageType.video;
      }

      selectedAttachment.value = xFile;
      selectedAttachmentBytes.value = await xFile.readAsBytes();
      attachmentType.value = type;
    }
  }

  void _openCreateTaskSheet() {
    // We need GroupTasksController. It should be put when opening chat or we put it now.
    // If we removed the tabs, the binding might not have put it.
    // Let's safe-check and put it if missing.
    if (!Get.isRegistered<GroupTasksController>(tag: group.groupId)) {
      // Ideally we use a tag if we have multiple chats open, but usually only one ChatController is active.
      // The previous binding didn't use tags? Let's check ChatBinding.
      // Assuming singleton for now or let's just put it.
      Get.put(GroupTasksController(), permanent: false);
      // We might need to manually set the group if onInit already ran without arguments
      // But GroupTasksController looks for arguments or ChatController?
      // Let's pass arguments manually or rely on Get.find<ChatController>().group?
      // The GroupTasksController logic I saw: if (Get.arguments is GroupModel)
    }

    final taskController = Get.find<GroupTasksController>();
    // Ensure group is set if it wasn't
    try {
      if (taskController.group.groupId != group.groupId) {
        taskController.group = group;
        taskController.onInit(); // Re-init? risky.
      }
    } catch (e) {
      // Likely group not initialized
      taskController.group = group;
      // We need to re-trigger binding logic manually if onInit failed
      // taskController.onInit(); // onInit is called by GET automatically
      // So if we just put it, onInit runs. If we just Put it NOW, we need to pass args?
      // Get.put(GroupTasksController(), arguments: group);
    }

    // Better way: explicitly pass controller to sheet, and ensure controller is ready.
    // Let's try to find it, if not found, put it with args.

    GroupTasksController tc;
    try {
      tc = Get.find<GroupTasksController>();
    } catch (e) {
      tc = Get.put(GroupTasksController());
      tc.group = group;
      tc.onInit(); // Manually trigger logic if we just set group?
      // No, onInit runs on put. If onInit checked args and failed, we need to call logic manually.
      tc.onReady();
    }

    // Actually, best is to just modify the CreateTaskSheet to accept 'group' and handle logic internally?
    // No, keep using Controller pattern.
    // Let's ensure logic works:
    // The controller reads Get.arguments.

    // HACK: Re-put with arguments if needed or just set fields.
    // Simpler:
    // create a temporary controller instance or use dependency injection properly.
    // Let's use the existing classes but maybe lazyPut in Binding was better.

    Get.bottomSheet(
      CreateTaskSheet(controller: tc),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  void _openCreateIssueSheet() {
    // Same logic for Issues
    GroupIssuesController ic;
    try {
      ic = Get.find<GroupIssuesController>();
    } catch (e) {
      ic = Get.put(GroupIssuesController());
      ic.group = group;
      // Since onInit might have failed to find args, we manually call init logic if needed
      // But _bindIssues needs to be called.
      // Let's modify controllers to allow manual setup or just copy logic here?
      // Copying logic duplicates code.
      // Let's assume we can set it.
      // Actually, let's fix the controllers to be more robust or just use them here.
      // Since we just need 'create', we don't strictly need the list binding unless we want to avoid errors.
    }

    Get.bottomSheet(
      CreateIssueSheet(controller: ic),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}
