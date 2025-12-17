import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id; // Firestore Doc ID
  final String name;
  final String email;
  final String phone;
  final String userType; // 'Admin' or 'Staff'
  final String password; // Simple for now
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    required this.password,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'userType': userType,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      userType: data['userType'] as String? ?? 'Staff',
      password: data['password'] as String? ?? '', // In a real app, this should be handled by Auth
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
