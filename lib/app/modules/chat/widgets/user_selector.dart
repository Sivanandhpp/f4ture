import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f4ture/app/core/index.dart';
import 'package:f4ture/app/data/models/user_model.dart';
import 'package:f4ture/app/data/services/auth_service.dart';

class UserSelector extends StatefulWidget {
  final List<String> alreadySelectedIds;
  final Function(List<UserModel>) onSelectionChanged;

  const UserSelector({
    super.key,
    required this.alreadySelectedIds,
    required this.onSelectionChanged,
  });

  @override
  State<UserSelector> createState() => _UserSelectorState();
}

class _UserSelectorState extends State<UserSelector> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  final Set<String> _selectedIds = {};
  final Map<String, UserModel> _userMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(widget.alreadySelectedIds);
    _fetchUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        return user.name.toLowerCase().contains(query) ||
            (user.email?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  Future<void> _fetchUsers() async {
    try {
      final currentUserId = AuthService.to.currentUser.value?.id;
      final snapshot = await _firestore.collection('users').get();

      final users = snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .where((u) => u.id != currentUserId) // Exclude self
          .toList();

      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        for (var u in users) {
          _userMap[u.id] = u;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('Error', 'Failed to load users');
    }
  }

  void _toggleSelection(UserModel user) {
    setState(() {
      if (_selectedIds.contains(user.id)) {
        _selectedIds.remove(user.id);
      } else {
        _selectedIds.add(user.id);
      }
    });

    final selectedUsers = _selectedIds
        .map((id) => _userMap[id])
        .whereType<UserModel>()
        .toList();

    widget.onSelectionChanged(selectedUsers);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.scaffoldbg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Members',
                  style: AppFont.heading.copyWith(
                    fontSize: 20,
                    color: AppColors.appbaritems,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: AppColors.appbaritems),
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                hintStyle: TextStyle(color: AppColors.appbaritems),
                fillColor: AppColors.textPrimary.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                ? Center(
                    child: Text(
                      'No users found',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      final isSelected = _selectedIds.contains(user.id);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.profilePhoto != null
                              ? NetworkImage(user.profilePhoto!)
                              : null,
                          backgroundColor: Colors.grey.shade200,
                          child: user.profilePhoto == null
                              ? Text(
                                  user.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                  ),
                                )
                              : null,
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          user.email ?? user.phone,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        trailing: Checkbox(
                          value: isSelected,
                          activeColor: AppColors.primary,
                          shape: const CircleBorder(),
                          onChanged: (_) => _toggleSelection(user),
                        ),
                        onTap: () => _toggleSelection(user),
                      );
                    },
                  ),
          ),

          // Selected Summary
          if (_selectedIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Text(
                      '${_selectedIds.length} selected',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
