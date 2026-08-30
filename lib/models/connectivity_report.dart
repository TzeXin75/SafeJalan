class ConnectivityReport {
  const ConnectivityReport({
    this.id,
    required this.remoteId,
    required this.issueType,
    required this.carrier,
    required this.notes,
    required this.area,
    required this.reporterEmail,
    this.status = 'Pending',
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'pending',
    this.isDeleted = false,
  });

  final int? id;
  final String remoteId;
  final String issueType;
  final String carrier;
  final String notes;
  final String area;
  final String reporterEmail;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String syncStatus;
  final bool isDeleted;

  factory ConnectivityReport.fromLocalMap(Map<String, Object?> map) =>
      ConnectivityReport(
        id: map['id'] as int?,
        remoteId: map['remoteId'] as String,
        issueType: map['issueType'] as String,
        carrier: map['carrier'] as String,
        notes: map['notes'] as String,
        area: map['area'] as String,
        reporterEmail: map['reporterEmail'] as String,
        status: map['status'] as String,
        createdAt: map['createdAt'] as String,
        updatedAt: map['updatedAt'] as String,
        syncStatus: map['syncStatus'] as String,
        isDeleted: (map['isDeleted'] as int) == 1,
      );

  factory ConnectivityReport.fromRemoteMap(Map<String, dynamic> map) =>
      ConnectivityReport(
        remoteId: map['id'] as String,
        issueType: map['issue_type'] as String,
        carrier: map['carrier'] as String,
        notes: map['notes'] as String? ?? '',
        area: map['area'] as String,
        reporterEmail: map['reporter_email'] as String? ?? '',
        status: map['status'] as String? ?? 'Pending',
        createdAt: map['created_at'] as String,
        updatedAt: map['updated_at'] as String,
        syncStatus: 'synced',
      );

  Map<String, Object?> toLocalMap() => {
    if (id != null) 'id': id,
    'remoteId': remoteId,
    'issueType': issueType,
    'carrier': carrier,
    'notes': notes,
    'area': area,
    'reporterEmail': reporterEmail.toLowerCase(),
    'status': status,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'syncStatus': syncStatus,
    'isDeleted': isDeleted ? 1 : 0,
  };

  Map<String, Object?> toRemoteMap() => {
    'id': remoteId,
    'issue_type': issueType,
    'carrier': carrier,
    'notes': notes,
    'area': area,
    'reporter_email': reporterEmail.toLowerCase(),
    'status': status,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  ConnectivityReport copyWith({
    int? id,
    String? status,
    String? updatedAt,
    String? syncStatus,
    bool? isDeleted,
  }) => ConnectivityReport(
    id: id ?? this.id,
    remoteId: remoteId,
    issueType: issueType,
    carrier: carrier,
    notes: notes,
    area: area,
    reporterEmail: reporterEmail,
    status: status ?? this.status,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
  );
}
