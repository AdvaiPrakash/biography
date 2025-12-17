import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? profileImageBase64;
  final DateTime joinedAt;

  CustomerModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.profileImageBase64,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'profileImageBase64': profileImageBase64,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomerModel(
      id: doc.id,
      name: data['name'] as String,
      email: data['email'] as String,
      phone: data['phone'] as String,
      address: data['address'] as String,
      profileImageBase64: data['profileImageBase64'] as String?,
      joinedAt: DateTime.parse(data['joinedAt'] as String),
    );
  }


  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is CustomerModel &&
      other.id == id &&
      other.name == name &&
      other.email == email &&
      other.phone == phone;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      phone.hashCode;
  }
}
