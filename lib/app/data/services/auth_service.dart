import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../data/services/notification_service.dart';

import '../../routes/app_pages.dart';
import '../models/user_model.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final _box = GetStorage();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  void _loadUser() {
    try {
      final userData = _box.read('user');
      if (userData != null) {
        currentUser.value = UserModel.fromJson(userData);
        // Sync with server in background
        syncUser();
        // Init Notifications
        if (Get.isRegistered<NotificationService>()) {
          Get.find<NotificationService>().init();
        }
      }
    } catch (e) {
      print('Error loading user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveUser(UserModel user) async {
    currentUser.value = user;
    await _box.write('user', user.toJson());
  }

  Future<void> clearUser() async {
    currentUser.value = null;
    await _box.remove('user');
    await _auth.signOut();
  }

  Future<void> syncUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final updatedUser = UserModel.fromJson(doc.data()!);
          await saveUser(updatedUser);
        }
      } catch (e) {
        print('Error syncing user: $e');
      }
    }
  }

  String determineInitialRoute() {
    final user = currentUser.value;
    if (user == null) {
      // Check if Firebase session exists but local storage is empty (edge case)
      if (_auth.currentUser != null) {
        // Attempt to sync immediately or just go to auth for safety
        return Routes.AUTHENTICATION;
      }
      return Routes.AUTHENTICATION;
    }

    if (user.role == 'attendee') {
      return Routes.HOME;
    } else {
      return Routes.SUPER_HOME;
    }
  }
}
