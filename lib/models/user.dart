enum UserRole { customer, seller, admin }

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? avatarUrl;
  final String? phone;
  final String? address;
  final DateTime createdAt;
  final String? token;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.customer,
    this.avatarUrl,
    this.phone,
    this.address,
    DateTime? createdAt,
    this.token,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: _parseRole(json['role']),
      avatarUrl: json['avatarUrl'],
      phone: json['phone'],
      address: json['address'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'avatarUrl': avatarUrl,
      'phone': phone,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'token': token,
    };
  }

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'seller':
        return UserRole.seller;
      default:
        return UserRole.customer;
    }
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? avatarUrl,
    String? phone,
    String? address,
    DateTime? createdAt,
    String? token,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      token: token ?? this.token,
    );
  }
}
