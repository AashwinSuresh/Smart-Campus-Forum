class BackupLostFoundItem {
  final String id;
  final String itemName;
  final String type; // "lost" or "found"
  final String location;
  final String phoneNumber;
  final String status; // "open" or "closed"
  final DateTime createdAt;
  final String userId;
  final String? reporterName; // Added to capture full name from joined users table
  final String? imageUrl; // Added image URL

  BackupLostFoundItem({
    required this.id,
    required this.itemName,
    required this.type,
    required this.location,
    required this.phoneNumber,
    required this.status,
    required this.createdAt,
    required this.userId,
    this.reporterName,
    this.imageUrl,
  });

  factory BackupLostFoundItem.fromJson(Map<String, dynamic> json) {
    return BackupLostFoundItem(
      id: json['id'] ?? '',
      itemName: json['item_name'] ?? '',
      type: json['type'] ?? 'lost',
      location: json['location'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      status: json['status'] ?? 'open',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      userId: json['user_id'] ?? '',
      reporterName: json['users'] is Map 
          ? (json['users']['full_name'] ?? json['users']['name']) 
          : null,
      imageUrl: json['image_url'], // Added image_url parsing
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_name': itemName,
      'type': type,
      'location': location,
      'phone_number': phoneNumber,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'image_url': imageUrl, // Added image_url to json
    };
  }
}
