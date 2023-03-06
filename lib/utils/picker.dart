
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:wechat/utils/config.dart';
import 'package:wechat/widgets/camera/camera.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
//选取器
class DuPicker{

  //底部弹出视图
  static Future<T?> showModalSheet<T>(BuildContext context,{Widget? child}) {
    return showModalBottomSheet<T>(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10)
            )
        ),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: child,
          );
        });
  }

  //相册
  static Future<List<AssetEntity>?> assets({
    required BuildContext context,
    List<AssetEntity>? selectedAssets,
    int maxAssets = maxAssets,
    RequestType requestType = RequestType.image, // 默认图片
  }) async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        selectedAssets: selectedAssets,
        requestType: requestType,
        maxAssets: maxAssets,
      ),
    );
    return result;
  }

  //拍摄照片
  static Future<AssetEntity?> takePhoto(BuildContext context) async {
    final result = await Navigator.of(context)
        .push<AssetEntity?>(MaterialPageRoute(builder: (context) {
      return const CameraPage();
    }));
    return result;
  }

  //拍摄视频
  static Future<AssetEntity?> takeVideo(BuildContext context) async {
    final filePath = await Navigator.of(context)
        .push<AssetEntity?>(MaterialPageRoute(builder: (context) {
      return const CameraPage(
        captureMode: CaptureMode.video,
        maxVideoDuration: Duration(seconds: 30),
      );
    }));
    return filePath;
  }
}