import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'auth_service.dart';

class LocalChatService extends GetxService {
  static LocalChatService get to => Get.find();
  final _box = GetStorage();

  String _getKey(String groupId) {
    final userId = AuthService.to.currentUser.value?.id ?? 'anon';
    return 'last_read_${userId}_$groupId';
  }

  /// Marks a group as read at the current time
  void markAsRead(String groupId) {
    final key = _getKey(groupId);
    final now = DateTime.now().toIso8601String();
    _box.write(key, now);
  }

  /// Returns the last time the user opened this group chat
  DateTime? getLastRead(String groupId) {
    final key = _getKey(groupId);
    final val = _box.read(key);
    if (val == null) return null;
    return DateTime.tryParse(val);
  }
}
