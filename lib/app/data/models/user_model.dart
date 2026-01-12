class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String role;
  final String? committeeId;
  final String? profilePhoto;
  final String? qrCode;
  final String status;
  final List<String> interests;
  final String? fcmToken;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.committeeId,
    this.profilePhoto,
    this.qrCode,
    required this.status,
    required this.interests,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'committee_id': committeeId,
      'profile_photo': profilePhoto,
      'QR_code': qrCode,
      'status': status,
      'interests': interests,
      'fcmToken': fcmToken,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      role: json['role'] as String,
      committeeId: json['committee_id'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      qrCode: json['QR_code'] as String?,
      status: json['status'] as String,
      interests:
          (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      fcmToken: json['fcmToken'] as String?,
    );
  }
}
