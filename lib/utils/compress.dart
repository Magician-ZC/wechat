import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';

///压缩返回类型
class CompressMediaFile{
  ///缩略图
  final File? thumbnail;

  ///媒体文件
  final MediaInfo? video;

  CompressMediaFile({
    this.thumbnail,
    this.video,
  });

}

/// 压缩类
class DuCompress{
  ///压缩图片
  static Future<File?> image(File file,{
    int minWidth =1920,
    int minHeight = 1080,
  }) async {
    return await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        '${file.path}_temp.jpg',
      keepExif: true,
      quality: 88,
      format: CompressFormat.jpeg,
      minWidth: minWidth,
      minHeight: minHeight
    );
  }

  ///压缩视频
  static Future<CompressMediaFile> video(File file) async{
    var result = await Future.wait([
      VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.Res640x480Quality,
        deleteOrigin: false,
        includeAudio: true,
        frameRate: 25
      ),
      VideoCompress.getFileThumbnail(file.path,
        quality: 80,
        position: -1000
      )
    ]);

    return CompressMediaFile(
        video: result.first as MediaInfo,
        thumbnail: result.last as File,
    );
  }

  ///清理缓存
  static Future<bool?> clean() async {
    return await VideoCompress.deleteAllCache();
  }

  ///取消
  static Future<void> cancel() async {
    await VideoCompress.cancelCompression();
  }
}