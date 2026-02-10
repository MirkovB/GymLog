enum UserRole {
  guest,
  user,
  admin,
}

// Hardkodovani admin emaili
const List<String> ADMIN_EMAILS = ['admin@test.com'];

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    required this.role,
    required this.createdAt,
    this.lastLogin,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    final email = map['email'] ?? '';
    
    // Proveravamo da li je mejl u admin listi
    final isAdmin = ADMIN_EMAILS.contains(email);
    final role = isAdmin ? UserRole.admin : _parseRole(map['role']);
    
    return UserModel(
      id: id,
      email: email,
      displayName: map['displayName'],
      role: role,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastLogin: map['lastLogin'] != null
          ? DateTime.parse(map['lastLogin'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  static UserRole _parseRole(dynamic roleValue) {
    if (roleValue == null) return UserRole.user;
    if (roleValue is String) {
      switch (roleValue) {
        case 'admin':
          return UserRole.admin;
        case 'guest':
          return UserRole.guest;
        case 'user':
        default:
          return UserRole.user;
      }
    }
    return UserRole.user;
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isUser => role == UserRole.user;
  bool get isGuest => role == UserRole.guest;

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
