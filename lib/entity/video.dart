class VideoModel {
  String? cover;
  String? url;

  VideoModel({this.cover, this.url});

  factory VideoModel.fromJson(Map<String, dynamic> json) => VideoModel(
        cover: json['cover'] as String?,
        url: json['url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'cover': cover,
        'url': url,
      };
}
