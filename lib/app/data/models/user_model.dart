import 'package:cloud_firestore/cloud_firestore.dart';

/// User model for Firestore
class UserModel {
  final String id;
  final String? name;
  final String phone;
  final String? email;
  final String role;
  final String? committeeId;
  final String? profilePhoto;
  final String? qrCode;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    this.name,
    required this.phone,
    this.email,
    this.role = 'attendee',
    this.committeeId,
    this.profilePhoto,
    this.qrCode,
    this.status = 'active',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'],
      phone: data['phone'] ?? '',
      email: data['email'],
      role: data['role'] ?? 'attendee',
      committeeId: data['committee_id'],
      profilePhoto: data['profile_photo'],
      qrCode: data['QR_code'],
      status: data['status'] ?? 'active',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert UserModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'committee_id': committeeId,
      'profile_photo': profilePhoto,
      'QR_code': qrCode,
      'status': status,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? role,
    String? committeeId,
    String? profilePhoto,
    String? qrCode,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      committeeId: committeeId ?? this.committeeId,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      qrCode: qrCode ?? this.qrCode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
