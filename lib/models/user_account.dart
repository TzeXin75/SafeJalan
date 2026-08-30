class UserAccount {
  final int? id;
  final String name;
  final String email;
  final String passwordHash;
  final String? imagePath;
  final bool isAdmin;
  final bool isActive;
  final String syncStatus;
  final String updatedAt;
  final String? previousEmail;

  UserAccount({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.imagePath,
    this.isAdmin = false,
    this.isActive = true,
    this.syncStatus = 'pending',
    String? updatedAt,
    this.previousEmail,
  }) : updatedAt = updatedAt ?? DateTime.now().toUtc().toIso8601String();

  factory UserAccount.fromMap(Map<String, Object?> map) => UserAccount(
    id: map['id'] as int?,
    name: map['name'] as String,
    email: map['email'] as String,
    passwordHash: map['passwordHash'] as String? ?? '',
    imagePath: map['imagePath'] as String?,
    isAdmin: (map['isAdmin'] as int? ?? 0) == 1,
    isActive: (map['isActive'] as int? ?? 1) == 1,
    syncStatus: map['syncStatus'] as String? ?? 'pending',
    updatedAt:
        map['updatedAt'] as String? ?? DateTime.now().toUtc().toIso8601String(),
    previousEmail: map['previousEmail'] as String?,
  );

  factory UserAccount.fromRemoteMap(Map<String, dynamic> map) => UserAccount(
    name: map['full_name'] as String? ?? '',
    email: map['email'] as String,
    passwordHash: map['password_hash'] as String? ?? '',
    imagePath: map['avatar_url'] as String?,
    isAdmin: map['is_admin'] as bool? ?? false,
    isActive: map['is_active'] as bool? ?? true,
    syncStatus: 'synced',
    updatedAt:
        map['updated_at'] as String? ??
        DateTime.now().toUtc().toIso8601String(),
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'email': email.toLowerCase(),
    'passwordHash': passwordHash,
    'imagePath': imagePath,
    'isAdmin': isAdmin ? 1 : 0,
    'isActive': isActive ? 1 : 0,
    'syncStatus': syncStatus,
    'updatedAt': updatedAt,
    'previousEmail': previousEmail,
  };

  Map<String, Object?> toRemoteMap() => {
    'email': email.toLowerCase(),
    'full_name': name,
    'password_hash': passwordHash,
    'is_admin': isAdmin,
    'is_active': isActive,
    'avatar_url': imagePath?.startsWith('http') == true ? imagePath : null,
    'updated_at': updatedAt,
  };
}
