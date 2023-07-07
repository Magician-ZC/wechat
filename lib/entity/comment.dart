import 'package:wechat/entity/index.dart';

class CommentModel {
  UserModel? user;
  String? content;
  String? publishDate;

  CommentModel({this.user, this.content, this.publishDate});

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        user: json['user'] == null
            ? null
            : UserModel.fromJson(json['user'] as Map<String, dynamic>),
        content: json['content'] as String?,
        publishDate: json['publishDate'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'user': user?.toJson(),
        'content': content,
        'publishDate': publishDate,
      };
}
