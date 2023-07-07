class LikeModel {
  String? uid;
  String? nickname;
  String? avator;

  LikeModel({this.uid, this.nickname, this.avator});

  factory LikeModel.fromJson(Map<String, dynamic> json) => LikeModel(
        uid: json['uid'] as String?,
        nickname: json['nickname'] as String?,
        avator: json['avator'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'nickname': nickname,
        'avator': avator,
      };
}
