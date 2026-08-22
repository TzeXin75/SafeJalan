class RoadReport {
  final int? id;
  final String? remoteId;
  final String title;
  final String category;
  final String severity;
  final String description;
  final String locationName;
  final String status;
  final String createdOn;
  final String updatedAt;
  final String reporterEmail;
  final double latitude;
  final double longitude;
  final String? imagePath;
  final int votes;
  final String syncStatus;
  final bool isDeleted;

  const RoadReport({
    this.id,
    this.remoteId,
    required this.title,
    required this.category,
    required this.severity,
    required this.description,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    this.status = 'Pending',
    this.imagePath,
    this.votes = 0,
    required this.createdOn,
    this.updatedAt = '',
    this.reporterEmail = '',
    this.syncStatus = 'pending',
    this.isDeleted = false,
  });

  factory RoadReport.fromLocalMap(Map<String, dynamic> data) => RoadReport(
    id: data['id'] as int?,
    remoteId: data['remoteId'] as String?,
    title: data['title'] as String,
    category: data['category'] as String,
    severity: data['severity'] as String,
    description: data['description'] as String,
    locationName: data['locationName'] as String,
    latitude: (data['latitude'] as num).toDouble(),
    longitude: (data['longitude'] as num).toDouble(),
    status: data['status'] as String,
    imagePath: data['imagePath'] as String?,
    votes: data['votes'] as int,
    createdOn: data['createdOn'] as String,
    updatedAt: data['updatedAt'] as String? ?? '',
    reporterEmail: data['reporterEmail'] as String? ?? '',
    syncStatus: data['syncStatus'] as String? ?? 'pending',
    isDeleted: (data['isDeleted'] as int? ?? 0) == 1,
  );

  factory RoadReport.fromRemoteMap(Map<String, dynamic> data) => RoadReport(
    remoteId: data['id'] as String,
    title: data['title'] as String,
    category: data['category'] as String,
    severity: data['severity'] as String,
    description: data['description'] as String,
    locationName: data['location_name'] as String,
    latitude: (data['latitude'] as num).toDouble(),
    longitude: (data['longitude'] as num).toDouble(),
    status: data['status'] as String,
    imagePath: data['image_url'] as String?,
    votes: data['votes'] as int? ?? 0,
    createdOn: data['created_on'] as String,
    updatedAt: data['updated_at'] as String? ?? '',
    reporterEmail: data['reporter_email'] as String? ?? '',
    syncStatus: 'synced',
  );

  Map<String, dynamic> toLocalMap() => {
    if (id != null) 'id': id,
    'remoteId': remoteId,
    'title': title,
    'category': category,
    'severity': severity,
    'description': description,
    'locationName': locationName,
    'latitude': latitude,
    'longitude': longitude,
    'status': status,
    'imagePath': imagePath,
    'votes': votes,
    'createdOn': createdOn,
    'updatedAt': updatedAt,
    'reporterEmail': reporterEmail,
    'syncStatus': syncStatus,
    'isDeleted': isDeleted ? 1 : 0,
  };

  Map<String, dynamic> toRemoteMap() => {
    'id': remoteId,
    'title': title,
    'category': category,
    'severity': severity,
    'description': description,
    'location_name': locationName,
    'latitude': latitude,
    'longitude': longitude,
    'status': status,
    'image_url': imagePath?.startsWith('http') == true ? imagePath : null,
    'votes': votes,
    'created_on': createdOn,
    'updated_at': updatedAt,
    'reporter_email': reporterEmail,
  };

  RoadReport copyWith({
    int? id,
    String? remoteId,
    String? status,
    int? votes,
    String? updatedAt,
    String? reporterEmail,
    String? syncStatus,
    bool? isDeleted,
    String? imagePath,
  }) => RoadReport(
    id: id ?? this.id,
    remoteId: remoteId ?? this.remoteId,
    title: title,
    category: category,
    severity: severity,
    description: description,
    locationName: locationName,
    latitude: latitude,
    longitude: longitude,
    status: status ?? this.status,
    imagePath: imagePath ?? this.imagePath,
    votes: votes ?? this.votes,
    createdOn: createdOn,
    updatedAt: updatedAt ?? this.updatedAt,
    reporterEmail: reporterEmail ?? this.reporterEmail,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
  );
}
