class UserNotificationItem {
  final int? id;
  final String remoteId;
  final String eventKey;
  final String userEmail;
  final String reportRemoteId;
  final String title;
  final String message;
  final String type;
  final String createdAt;
  final String? readAt;
  final String syncStatus;

  const UserNotificationItem({
    this.id,
    required this.remoteId,
    required this.eventKey,
    required this.userEmail,
    required this.reportRemoteId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.readAt,
    this.syncStatus = 'pending',
  });

  bool get isRead => readAt != null && readAt!.isNotEmpty;

  factory UserNotificationItem.fromLocalMap(Map<String, dynamic> data) =>
      UserNotificationItem(
        id: data['id'] as int?,
        remoteId: data['remoteId'] as String,
        eventKey: data['eventKey'] as String,
        userEmail: data['userEmail'] as String,
        reportRemoteId: data['reportRemoteId'] as String,
        title: data['title'] as String,
        message: data['message'] as String,
        type: data['type'] as String,
        createdAt: data['createdAt'] as String,
        readAt: data['readAt'] as String?,
        syncStatus: data['syncStatus'] as String? ?? 'pending',
      );

  factory UserNotificationItem.fromRemoteMap(Map<String, dynamic> data) =>
      UserNotificationItem(
        remoteId: data['id'] as String,
        eventKey: data['event_key'] as String,
        userEmail: data['user_email'] as String,
        reportRemoteId: data['report_id'] as String,
        title: data['title'] as String,
        message: data['message'] as String,
        type: data['type'] as String,
        createdAt: data['created_at'] as String,
        readAt: data['read_at'] as String?,
        syncStatus: 'synced',
      );

  Map<String, dynamic> toLocalMap() => {
    if (id != null) 'id': id,
    'remoteId': remoteId,
    'eventKey': eventKey,
    'userEmail': userEmail.toLowerCase(),
    'reportRemoteId': reportRemoteId,
    'title': title,
    'message': message,
    'type': type,
    'createdAt': createdAt,
    'readAt': readAt,
    'syncStatus': syncStatus,
  };

  Map<String, dynamic> toRemoteMap() => {
    'id': remoteId,
    'event_key': eventKey,
    'user_email': userEmail.toLowerCase(),
    'report_id': reportRemoteId,
    'title': title,
    'message': message,
    'type': type,
    'created_at': createdAt,
    'read_at': readAt,
  };

  UserNotificationItem copyWith({
    int? id,
    String? readAt,
    String? syncStatus,
  }) => UserNotificationItem(
    id: id ?? this.id,
    remoteId: remoteId,
    eventKey: eventKey,
    userEmail: userEmail,
    reportRemoteId: reportRemoteId,
    title: title,
    message: message,
    type: type,
    createdAt: createdAt,
    readAt: readAt ?? this.readAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
}
