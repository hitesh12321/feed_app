// ignore_for_file: non_constant_identifier_names

class Post {
  String? id;
  String? created_at;
  String? media_mobile_url;
  String? media_raw_url;
  String? media_thumb_url;
  int? like_count;

  Post({
    this.id,
    this.created_at,
    this.media_mobile_url,
    this.media_raw_url,
    this.media_thumb_url,
    this.like_count,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String?,
      created_at: json['created_at'] as String?,
      media_mobile_url: json['media_mobile_url'] as String?,
      media_raw_url: json['media_raw_url'] as String?,
      media_thumb_url: json['media_thumb_url'] as String?,
      like_count: json['like_count'] as int?,
    );
  }

  Post copyWith({
    int? like_count,
    String? id,
    String? created_at,
    String? media_mobile_url,
    String? media_raw_url,
    String? media_thumb_url,
  }) {
    return Post(
      id: id ?? this.id,
      created_at: created_at ?? this.created_at,
      media_mobile_url: media_mobile_url ?? this.media_mobile_url,
      media_raw_url: media_raw_url ?? this.media_raw_url,
      media_thumb_url: media_thumb_url ?? this.media_thumb_url,
      like_count: like_count ?? this.like_count,
    );
  }
}
