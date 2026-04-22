class UserLike {
  final String userId;
  final String postId;

  UserLike({required this.userId, required this.postId});

  factory UserLike.fromJson(Map<String, dynamic> json) {
    return UserLike(
      userId: json['user_id'] as String,
      postId: json['post_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'post_id': postId,
    };
  }

}