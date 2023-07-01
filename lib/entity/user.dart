// 用户
class UserModel {
  String? uid;
  String? nickname;
  String? avator;
  String? cover;

  UserModel({
    this.uid,
    this.nickname,
    this.avator,
    this.cover,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] as String?,
        nickname: json['nickname'] as String?,
        avator: json['avator'] as String?,
        cover: json['cover'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'nickname': nickname,
        'avator': avator,
        'cover': cover,
      };
}
