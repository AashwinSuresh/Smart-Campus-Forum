class PostModel {
  final String id;
  final String userName;
  final String userProfilePic;
  final DateTime postedTime; 
  final String title;
  final String content;
  final List<String> tags;    
  int likes;
  int commentCount;
  bool isLikedByMe;

  PostModel({
    required this.id,
    required this.userName,
    required this.userProfilePic,
    required this.postedTime,
    required this.title,
    required this.content,
    this.tags = const [],
    this.likes = 0,
    this.commentCount = 0,
    this.isLikedByMe = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'userProfilePic': userProfilePic,
        'postedTime': postedTime.toIso8601String(),
        'title': title,
        'content': content,
        'tags': tags,
        'likes': likes,
        'commentCount': commentCount,
        'isLikedByMe': isLikedByMe,
      };

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
        id: json['id'].toString(),
        userName: json['userName'] ?? 'Anonymous',
        userProfilePic: json['userProfilePic'] ?? '',
        postedTime: json['postedTime'] != null
            ? DateTime.parse(json['postedTime'])
            : DateTime.now(),
        title: json['title'] ?? '',
        content: json['content'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        likes: json['likes'] ?? 0,
        commentCount: json['commentCount'] ?? 0,
        isLikedByMe: json['isLikedByMe'] ?? false,
      );
}