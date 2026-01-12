import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/manage_users_controller.dart';

class ManageUsersView extends GetView<ManageUsersController> {
  const ManageUsersView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ManageUsersView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ManageUsersView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
