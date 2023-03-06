import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wechat/utils/index.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../widgets/index.dart';

enum PickType { camera, asset }

///微信底部弹出
class DuBottomSheet {
  DuBottomSheet({this.selectAssets});

  final List<AssetEntity>? selectAssets;

  ///选择拍摄、相机资源
  Future<T?> wxPicker<T>(BuildContext context) {
    return DuPicker.showModalSheet<T>(context,
        child: _buildAssetCamera(context));
  }

  //相册，相机
  Widget _buildAssetCamera(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        //拍摄
        _buildBtn(Text('拍摄'), onTap: () {
          DuPicker.showModalSheet(context,
              child: _buildMediaImageVideo(context, pickType: PickType.camera));
        }),
        const DividerWidget(),
        //相册
        _buildBtn(Text('相册'), onTap: () {
          DuPicker.showModalSheet(context,
              child: _buildMediaImageVideo(context, pickType: PickType.asset));
        }),
        const DividerWidget(
          height: 6,
        ),
        //取消
        _buildBtn(Text('取消'), onTap: () {
          Navigator.pop(context);
        }),
      ],
    );
  }

  //图片，视频
  Widget _buildMediaImageVideo(BuildContext context, {PickType? pickType}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        //图片
        _buildBtn(const Text('图片'), onTap: () async {
          List<AssetEntity>? result;
          if (pickType == PickType.asset) {
            result = await DuPicker.assets(
                context: context,
                requestType: RequestType.image,
                selectedAssets: selectAssets);
          } else if (pickType == PickType.camera) {
            final asset = await DuPicker.takePhoto(context);
            if (asset == null) {
              return;
            }
            if (selectAssets == null) {
              result = [asset];
            } else {
              result = [...selectAssets!, asset];
            }
          }
          _popRoute(context, result: result);
        }),
        const DividerWidget(),
        //视频
        _buildBtn(const Text('视频'), onTap: () async {
          List<AssetEntity>? result;
          if (pickType == PickType.asset) {
            result = await DuPicker.assets(
                context: context,
                requestType: RequestType.video,
                selectedAssets: selectAssets,
                maxAssets: 1);
          } else if (pickType == PickType.camera) {
            final asset = await DuPicker.takeVideo(context);
            if (asset == null) {
              return;
            }
            result = [asset];
          }
          _popRoute(context, result: result);
        }),
        const DividerWidget(
          height: 6,
        ),
        //取消
        _buildBtn(Text('取消'), onTap: () {
          _popRoute(context);
        }),
      ],
    );
  }

  //返回
  void _popRoute(BuildContext context, {result}) {
    Navigator.pop(context);
    Navigator.pop(context, result);
  }

  ///按钮
  InkWell _buildBtn(Widget child, {Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(alignment: Alignment.center, height: 40, child: child),
    );
  }
}
