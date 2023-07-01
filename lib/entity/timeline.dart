import 'index.dart';

/// 朋友圈数据项
class TimelineModel {
  String? id;
  List<String>? images;
  VideoModel? video;
  String? content;
  String? postType;
  UserModel? user;
  String? publishDate;
  String? location;

  TimelineModel({
    this.id,
    this.images,
    this.video,
    this.content,
    this.postType,
    this.user,
    this.publishDate,
    this.location,
  });

  factory TimelineModel.fromJson(Map<String, dynamic> json) => TimelineModel(
        id: json['id'] as String?,
        images: json['images'].cast<String>(), // as List<String>?,
        video: json['video'] == null
            ? null
            : VideoModel.fromJson(json['video'] as Map<String, dynamic>),
        content: json['content'] as String?,
        postType: json['post_type'] as String?,
        user: json['user'] == null
            ? null
            : UserModel.fromJson(json['user'] as Map<String, dynamic>),
        publishDate: json['publishDate'] as String?,
        location: json['location'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'images': images,
        'video': video?.toJson(),
        'content': content,
        'post_type': postType,
        'user': user?.toJson(),
        'publishDate': publishDate,
        'location': location,
      };
}
