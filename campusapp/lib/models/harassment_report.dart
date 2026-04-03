class HarassmentReport {
  final String id;
  final String title;
  final String description;
  final DateTime incidentDate;
  final String location;
  final String reporterId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // New fields for staff visibility
  final String? reporterName;
  final String? reporterDept;
  final String? reporterPic;

  HarassmentReport({
    required this.id,
    required this.title,
    required this.description,
    required this.incidentDate,
    required this.location,
    required this.reporterId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.reporterName,
    this.reporterDept,
    this.reporterPic,
  });

  factory HarassmentReport.fromJson(Map<String, dynamic> json) {
    // Check if nested user object exists (from Staff/Admin join)
    final userData = json['users'];
    
    return HarassmentReport(
      id: json['report_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      incidentDate: DateTime.parse(json['incident_date'] as String),
      location: json['location'] as String,
      reporterId: json['reporter_id'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['created_at'] as String),
      reporterName: userData != null ? userData['full_name'] : null,
      reporterDept: userData != null ? userData['department'] : null,
      reporterPic: userData != null ? userData['profile_pic_url'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_id': id,
      'title': title,
      'description': description,
      'incident_date': "${incidentDate.year}-${incidentDate.month.toString().padLeft(2, '0')}-${incidentDate.day.toString().padLeft(2, '0')}",
      'location': location,
      'reporter_id': reporterId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
