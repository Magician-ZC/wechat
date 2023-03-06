import 'package:flutter/material.dart';
import 'package:wechat/pages/index.dart';
import 'package:wechat/utils/index.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({Key? key}) : super(key: key);

  @override
  State<TimeLinePage> createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  Widget _mainView() {
    return Center(
        child:
            ElevatedButton(onPressed: (_onPublish), child: const Text('发布')));
  }

  //发布事件
  _onPublish() async {
    final result = await DuBottomSheet().wxPicker<List<AssetEntity>>(context);
    if (result == null || result.isEmpty) {
      return;
    }
    //把输入压入发布界面
    if (mounted) {
      Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
        return PostEditPage(
            postType:
                (result.length == 1 && result.first.type == AssetType.video)
                    ? PostType.video
                    : PostType.image,
            selectedAssets: result);
      })));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _mainView());
  }
}
