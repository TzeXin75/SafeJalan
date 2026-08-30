class SafetyAnnouncement {
  const SafetyAnnouncement({
    this.id,
    required this.remoteId,
    required this.title,
    required this.message,
    required this.priority,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'pending',
    this.isDeleted = false,
  });

  final int? id;
  final String remoteId;
  final String title;
  final String message;
  final String priority;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final String syncStatus;
  final bool isDeleted;

  factory SafetyAnnouncement.fromLocalMap(Map<String, Object?> map) =>
      SafetyAnnouncement(
        id: map['id'] as int?,
        remoteId: map['remoteId'] as String,
        title: map['title'] as String,
        message: map['message'] as String,
        priority: map['priority'] as String,
        isActive: (map['isActive'] as int) == 1,
        createdAt: map['createdAt'] as String,
        updatedAt: map['updatedAt'] as String,
        syncStatus: map['syncStatus'] as String,
        isDeleted: (map['isDeleted'] as int) == 1,
      );

  factory SafetyAnnouncement.fromRemoteMap(Map<String, dynamic> map) =>
      SafetyAnnouncement(
        remoteId: map['id'] as String,
        title: map['title'] as String,
        message: map['message'] as String,
        priority: map['priority'] as String? ?? 'Normal',
        isActive: map['is_active'] as bool? ?? true,
        createdAt: map['created_at'] as String,
        updatedAt: map['updated_at'] as String,
        syncStatus: 'synced',
      );

  Map<String, Object?> toLocalMap() => {
    if (id != null) 'id': id,
    'remoteId': remoteId,
    'title': title,
    'message': message,
    'priority': priority,
    'isActive': isActive ? 1 : 0,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'syncStatus': syncStatus,
    'isDeleted': isDeleted ? 1 : 0,
  };

  Map<String, Object?> toRemoteMap() => {
    'id': remoteId,
    'title': title,
    'message': message,
    'priority': priority,
    'is_active': isActive,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  SafetyAnnouncement copyWith({
    int? id,
    String? title,
    String? message,
    String? priority,
    bool? isActive,
    String? updatedAt,
    String? syncStatus,
    bool? isDeleted,
  }) => SafetyAnnouncement(
    id: id ?? this.id,
    remoteId: remoteId,
    title: title ?? this.title,
    message: message ?? this.message,
    priority: priority ?? this.priority,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
  );
}
