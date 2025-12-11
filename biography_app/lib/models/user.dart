enum UserType { admin, staff }

class User {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final UserType userType;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    required this.createdAt,
    this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'userType': userType.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      userType: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == map['userType'],
      ),
      createdAt: DateTime.parse(map['createdAt']),
      lastLogin: map['lastLogin'] != null
          ? DateTime.parse(map['lastLogin'])
          : null,
    );
  }
}
