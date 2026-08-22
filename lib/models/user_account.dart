class UserAccount {
  final int? id;
  final String name;
  final String email;
  final String passwordHash;
  final String? imagePath;
  final bool isAdmin;

  const UserAccount({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.imagePath,
    this.isAdmin = false,
  });

  factory UserAccount.fromMap(Map<String, Object?> map) => UserAccount(
    id: map['id'] as int?,
    name: map['name'] as String,
    email: map['email'] as String,
    passwordHash: map['passwordHash'] as String,
    imagePath: map['imagePath'] as String?,
    isAdmin: (map['isAdmin'] as int) == 1,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'email': email.toLowerCase(),
    'passwordHash': passwordHash,
    'imagePath': imagePath,
    'isAdmin': isAdmin ? 1 : 0,
  };
}
