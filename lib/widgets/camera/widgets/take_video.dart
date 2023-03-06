import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:wechat/widgets/camera/widgets/countdown.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class TakeVideoPage extends StatefulWidget {
  const TakeVideoPage(this.cameraState,{super.key,this.maxVideoDuration});

  final CameraState cameraState;
  final Duration? maxVideoDuration;

  @override
  State<TakeVideoPage> createState() => _TakeVideoPageState();
}

class _TakeVideoPageState extends State<TakeVideoPage> {

  @override
  void initState() {
    super.initState();
    widget.cameraState.captureState$.listen((event) async {
      if (event != null && event.status == MediaCaptureStatus.success) {
        String filePath = event.filePath;
        String fileTitle = filePath.split("/").last;
        File file = File(filePath);

        // 1 转换 AssetEntity
        final AssetEntity? asset = await PhotoManager.editor.saveVideo(
          file,
          title: fileTitle,
        );

        // 2 删除临时文件
        await file.delete();

        // ignore: use_build_context_synchronously
        Navigator.of(context).pop<AssetEntity?>(asset);
      }
    });
  }

  Widget _mainView() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.black54,
        height: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 切换摄像头
            AwesomeCameraSwitchButton(state: widget.cameraState),
            // 拍摄按钮
            AwesomeCaptureButton(state: widget.cameraState),
            // 倒计时
            if (widget.cameraState is VideoRecordingCameraState &&
                widget.maxVideoDuration != null)
              Countdown(
                time: widget.maxVideoDuration!,
                callback: () {
                  (widget.cameraState as VideoRecordingCameraState)
                      .stopRecording();
                },
              )
            else
              const SizedBox(width: 32 + 20 * 2),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _mainView();
  }
}
