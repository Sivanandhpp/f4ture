import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/post_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/auth_service.dart';
import '../widgets/comment_sheet.dart';
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

        // Parallel check for "liked by me"
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

        // Deduplicate
        final existingIds = posts.map((p) => p.postId).toSet();
        final uniquePosts = newPosts
            .where((p) => !existingIds.contains(p.postId))
            .toList();

        if (uniquePosts.isNotEmpty) {
          posts.addAll(uniquePosts);
        }

        // If we fetched docs but they were all duplicates, we might need to fetch more?
        // For simplicity in this iteration, we accept it.
        // If snapshot size < limit, we reached end.
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

    // Check 'likes' subcollection for each post
    // Optimisation: We could store 'likedBy' array in post doc if small scale,
    // but for scalability subcollection is better.
    // Reading 10 subcollections docs is fine.

    // Using Future.wait
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

    // Update models
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

    // Optimistic Update
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
        // Unlike
        batch.delete(likeRef);
        batch.update(postRef, {'likesCount': FieldValue.increment(-1)});
      } else {
        // Like
        batch.set(likeRef, {
          'userId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        batch.update(postRef, {'likesCount': FieldValue.increment(1)});
      }

      await batch.commit();
    } catch (e) {
      // Revert on error
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

  // Create Post State
  final RxList<XFile> selectedMedia = <XFile>[].obs;
  final RxBool isCreatingPost = false.obs;

  Future<void> pickMedia() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> media = await picker
          .pickMultipleMedia(); // Supports mixed

      if (media.isNotEmpty) {
        selectedMedia.addAll(media);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick media: $e');
    }
  }

  Future<void> captureFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        selectedMedia.add(image);
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
        selectedMedia
            .clear(); // Clear previous selections if any, or keep? Better clear for a fresh "Quick Shot"
        selectedMedia.add(image);
        Get.to(() => const CreatePostView());
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

  Future<void> createPost(String text) async {
    if (text.isEmpty && selectedMedia.isEmpty) {
      Get.snackbar('Error', 'Please add some text or media');
      return;
    }

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
      final String postId = _firestore.collection('posts').doc().id;
      final List<String> mediaUrls = [];

      // Upload Media
      if (selectedMedia.isNotEmpty) {
        for (var file in selectedMedia) {
          final String fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
          final ref = FirebaseStorage.instance.ref().child(
            'posts/$postId/$fileName',
          );

          final isVideo =
              file.path.toLowerCase().endsWith('.mp4') ||
              file.path.toLowerCase().endsWith('.mov');
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
        type: mediaUrls.isEmpty
            ? PostType.post
            : PostType.post, // Could detect Reel if video
        text: text,
        mediaUrls: mediaUrls,
        createdAt: DateTime.now(),
        isLikedByMe: false,
      );

      await _firestore.collection('posts').doc(postId).set(post.toJson());

      // Cleanup
      selectedMedia.clear();
      refreshFeed(); // Refresh list
      Get.back(); // Close CreatePostView
      Get.snackbar(
        'Success',
        'Post created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
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

  // Refresh functionality
  Future<void> refreshFeed() async {
    _lastDocument = null;
    _hasMore = true;
    await loadPosts();
  }

  Future<void> deletePost(PostModel post) async {
    final user = _auth.currentUser;
    final currentUserModel = AuthService.to.currentUser.value;

    // Check if user is author OR admin
    final isAuthor = user != null && user.uid == post.authorId;
    final isAdmin = currentUserModel?.role == 'admin';

    if (!isAuthor && !isAdmin) {
      Get.snackbar('Error', 'You can only delete your own posts');
      return;
    }

    try {
      // 1. Delete from Firestore
      await _firestore.collection('posts').doc(post.postId).delete();

      // 2. Remove from local list
      posts.removeWhere((p) => p.postId == post.postId);

      Get.snackbar(
        'Success',
        'Post deleted',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete post: $e');
    }
  }
}
