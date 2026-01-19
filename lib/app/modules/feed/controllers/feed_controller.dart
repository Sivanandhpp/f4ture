import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/post_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/auth_service.dart';
import '../widgets/comment_sheet.dart';
import 'package:image_cropper/image_cropper.dart'; // Add this
import '../views/post_caption_view.dart'; // Add this (create_post_view is already there)
import '../views/create_post_view.dart';

class FeedController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  static const int _limit = 10;

  // Search
  final RxString searchQuery = ''.obs;

  // Video Playback
  final RxString visiblePostId = ''.obs;

  List<PostModel> get filteredPosts {
    if (searchQuery.value.isEmpty) {
      return posts;
    }
    final query = searchQuery.value.toLowerCase().trim();
    return posts.where((post) {
      final matchesAuthor = post.authorName.toLowerCase().contains(query);
      final matchesText = post.text.toLowerCase().contains(query);
      return matchesAuthor || matchesText;
    }).toList();
  }

  final ScrollController scrollController = ScrollController();

  // Create Post State
  final RxList<XFile> selectedMedia = <XFile>[].obs;
  final RxBool isCreatingPost = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPosts();
    scrollController.addListener(_scrollListener);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent * 0.9 &&
        !isLoadingMore.value &&
        _hasMore) {
      loadMorePosts();
    }
  }

  Future<void> loadPosts() async {
    isLoading.value = true;
    try {
      final snapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(_limit)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        final newPosts = snapshot.docs
            .map((doc) => PostModel.fromJson(doc.data()))
            .toList();

        await _checkLikes(newPosts);
        posts.assignAll(newPosts);
      } else {
        _hasMore = false;
        posts.clear();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load feed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMorePosts() async {
    if (isLoadingMore.value || !_hasMore || _lastDocument == null) return;

    isLoadingMore.value = true;
    try {
      final snapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_limit)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        final newPosts = snapshot.docs
            .map((doc) => PostModel.fromJson(doc.data()))
            .toList();

        await _checkLikes(newPosts);

        final existingIds = posts.map((p) => p.postId).toSet();
        final uniquePosts = newPosts
            .where((p) => !existingIds.contains(p.postId))
            .toList();

        if (uniquePosts.isNotEmpty) {
          posts.addAll(uniquePosts);
        }

        if (snapshot.docs.length < _limit) {
          _hasMore = false;
        }
      }
    } catch (e) {
      debugPrint('Error loading more posts: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> _checkLikes(List<PostModel> fetchedPosts) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final List<String> likedPostIds = [];

    await Future.wait(
      fetchedPosts.map((post) async {
        final likeDoc = await _firestore
            .collection('posts')
            .doc(post.postId)
            .collection('likes')
            .doc(user.uid)
            .get();

        if (likeDoc.exists) {
          likedPostIds.add(post.postId);
        }
      }),
    );

    for (int i = 0; i < fetchedPosts.length; i++) {
      if (likedPostIds.contains(fetchedPosts[i].postId)) {
        fetchedPosts[i] = fetchedPosts[i].copyWith(isLikedByMe: true);
      }
    }
  }

  Future<void> toggleLike(PostModel post) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final index = posts.indexWhere((p) => p.postId == post.postId);
    if (index == -1) return;

    final isLiked = post.isLikedByMe;
    final newCount = isLiked ? post.likesCount - 1 : post.likesCount + 1;

    posts[index] = post.copyWith(
      isLikedByMe: !isLiked,
      likesCount: newCount < 0 ? 0 : newCount,
    );

    final postRef = _firestore.collection('posts').doc(post.postId);
    final likeRef = postRef.collection('likes').doc(user.uid);

    try {
      final batch = _firestore.batch();
      if (isLiked) {
        batch.delete(likeRef);
        batch.update(postRef, {'likesCount': FieldValue.increment(-1)});
      } else {
        batch.set(likeRef, {
          'userId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        batch.update(postRef, {'likesCount': FieldValue.increment(1)});
      }
      await batch.commit();
    } catch (e) {
      posts[index] = post;
      Get.snackbar('Error', 'Failed to update like');
    }
  }

  void openComments(PostModel post) {
    Get.bottomSheet(
      CommentSheet(postId: post.postId),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
    );
  }

  Future<void> createPostFromGallery({
    required String caption,
    required File file,
    required bool isVideo,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar(
        'Authentication Required',
        'Please log in to create a post',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isCreatingPost.value = true;
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final String postId = _firestore.collection('posts').doc().id;
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_post';
      final ref = FirebaseStorage.instance.ref().child(
        'posts/$postId/$fileName',
      );

      final contentType = isVideo ? 'video/mp4' : 'image/jpeg';
      final bytes = await file.readAsBytes();

      await ref.putData(bytes, SettableMetadata(contentType: contentType));
      final url = await ref.getDownloadURL();

      final post = PostModel(
        postId: postId,
        authorId: user.uid,
        authorName: AuthService.to.currentUser.value?.name ?? 'Unknown',
        authorAvatar: AuthService.to.currentUser.value?.profilePhoto ?? '',
        type: PostType.post,
        text: caption,
        mediaUrls: [url],
        createdAt: DateTime.now(),
        isLikedByMe: false,
      );

      await _firestore.collection('posts').doc(postId).set(post.toJson());

      if (Get.isDialogOpen ?? false) Get.back();

      // Close all screens until we're back at the feed
      Get.until((route) => route.isFirst);

      refreshFeed();

      Get.snackbar(
        'Success',
        'Post created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Error',
        'Failed to create post: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isCreatingPost.value = false;
    }
  }

  // Legacy method - keeping for reference or if any other part uses it
  Future<void> createPost(String text) async {
    if (text.isEmpty && selectedMedia.isEmpty) {
      Get.snackbar('Error', 'Please add some text or media');
      return;
    }
    await _createPostInternal(text, selectedMedia);
  }

  Future<void> _createPostInternal(String text, List<XFile> media) async {
    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar('Authentication Required', 'Please log in');
      return;
    }

    try {
      isCreatingPost.value = true;
      final String postId = _firestore.collection('posts').doc().id;
      final List<String> mediaUrls = [];

      if (media.isNotEmpty) {
        for (var file in media) {
          final String fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
          final ref = FirebaseStorage.instance.ref().child(
            'posts/$postId/$fileName',
          );
          final isVideo = file.path.toLowerCase().endsWith('.mp4');
          final contentType = isVideo ? 'video/mp4' : 'image/jpeg';
          final bytes = await file.readAsBytes();
          await ref.putData(bytes, SettableMetadata(contentType: contentType));
          final url = await ref.getDownloadURL();
          mediaUrls.add(url);
        }
      }

      final post = PostModel(
        postId: postId,
        authorId: user.uid,
        authorName: AuthService.to.currentUser.value?.name ?? 'Unknown',
        authorAvatar: AuthService.to.currentUser.value?.profilePhoto ?? '',
        type: PostType.post,
        text: text,
        mediaUrls: mediaUrls,
        createdAt: DateTime.now(),
        isLikedByMe: false,
      );

      await _firestore.collection('posts').doc(postId).set(post.toJson());
      selectedMedia.clear();
      refreshFeed();
      Get.back();
      Get.snackbar(
        'Success',
        'Post created successfully',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to create post: $e');
    } finally {
      isCreatingPost.value = false;
    }
  }

  Future<void> pickMedia() async {
    // TODO: Redirect to new CreatePostView if needed, or keep for simple flow
    Get.to(() => const CreatePostView());
  }

  Future<void> captureFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        selectedMedia.clear();
        selectedMedia.add(image);
        // If we want to stay in the gallery view but refresh, we just add it.
        // But if this is called from the Feed Card, we might want to go to the creation flow.
        // For now, let's assume this just adds to selection if inside the view.
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture image: $e');
    }
  }

  Future<void> captureAndCreatePost() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        // Enforce Crop
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 5),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Edit Photo',
              toolbarColor: Colors.black,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: true,
              backgroundColor: Colors.black,
            ),
            IOSUiSettings(
              title: 'Edit Photo',
              aspectRatioLockEnabled: true,
              resetAspectRatioEnabled: false,
            ),
          ],
        );

        if (croppedFile != null) {
          Get.to(
            () => PostCaptionView(file: File(croppedFile.path), isVideo: false),
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture image: $e');
    }
  }

  void removeMedia(int index) {
    if (index >= 0 && index < selectedMedia.length) {
      selectedMedia.removeAt(index);
    }
  }

  Future<void> refreshFeed() async {
    _lastDocument = null;
    _hasMore = true;
    await loadPosts();
  }

  Future<void> deletePost(PostModel post) async {
    // ... (same as before)
    final user = _auth.currentUser;
    final currentUserModel = AuthService.to.currentUser.value;
    final isAuthor = user != null && user.uid == post.authorId;
    final isAdmin = currentUserModel?.role == 'admin';

    if (!isAuthor && !isAdmin) {
      Get.snackbar('Error', 'You can only delete your own posts');
      return;
    }

    try {
      await _firestore.collection('posts').doc(post.postId).delete();
      posts.removeWhere((p) => p.postId == post.postId);
      Get.snackbar('Success', 'Post deleted', backgroundColor: Colors.green);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete post: $e');
    }
  }
}
