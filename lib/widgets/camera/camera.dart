import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'widgets/take_photo.dart';
import 'widgets/take_video.dart';

class CameraPage extends StatelessWidget {
  const CameraPage(
      {super.key, this.captureMode = CaptureMode.photo, this.maxVideoDuration});

  /// 拍照、拍视频
  final CaptureMode captureMode;

  /// 视频最大时长 秒
  final Duration? maxVideoDuration;

  // 生成文件路径
  Future<String> _buildFilePath() async {
    // final extDir = await getApplicationDocumentsDirectory();
    final extDir = await getTemporaryDirectory();
    // 扩展名
    final extenName = captureMode == CaptureMode.photo ? 'jpg' : 'mp4';
    return '${extDir.path}/${const Uuid().v4()}.$extenName';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.custom(
        saveConfig: captureMode == CaptureMode.photo
            ? SaveConfig.photo(pathBuilder: _buildFilePath)
            : SaveConfig.video(pathBuilder: _buildFilePath),
        builder: (cameraState, previewSize, rect) {
          return cameraState.when(
            // 拍照
            onPhotoMode: (state) => TakePhotoPage(state),

            // 拍视频
            onVideoMode: (state) => TakeVideoPage(
              state,
              maxVideoDuration: maxVideoDuration,
            ),

            // 拍摄中
            onVideoRecordingMode: (state) => TakeVideoPage(
              state,
              maxVideoDuration: maxVideoDuration,
            ),

            // 启动摄像头
            onPreparingCamera: (state) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        // 生成规则
        imageAnalysisConfig: AnalysisConfig(
          //   cupertinoOptions: CupertinoAnalysisOptions.bgra8888(), // 图像格式
          outputFormat: InputAnalysisImageFormat.jpeg, // 图像格式
        ),
        // 经纬度, 墙
        // exifPreferences: ExifPreferences(
        //   saveGPSLocation: true,
        // ),
      ),
    );
  }
}
