import 'package:flutter/material.dart';
import 'package:wechat/entity/index.dart';
import 'package:wechat/pages/index.dart';
import 'package:wechat/utils/index.dart';
import 'package:wechat/widgets/appbar.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({Key? key}) : super(key: key);

  @override
  State<TimeLinePage> createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  //用户资料
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    //设置用户资料
    _user = UserModel(
        nickname: "聆听风雨",
        avator:
            "https://ducafecat.oss-cn-beijing.aliyuncs.com/ducafecat/logo-500.png",
        cover:
            "https://ducafecat-pub.oss-cn-qingdao.aliyuncs.com/cover/activeprogrammer.jpg");
    //刷新界面
    if (mounted) {
      setState(() {});
    }
  }

  //头部
  Widget _buildHeader() {
    //获取屏幕宽度
    final width = MediaQuery.of(context).size.width;
    return _user == null
        ? const Text("loading")
        : Stack(
            children: [
              //背景
              SizedBox(
                width: width,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Image.network(
                    _user?.cover ?? "",
                    height: width * 0.75,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              //昵称、头像
              Positioned(
                right: spacing,
                bottom: 0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _user?.nickname ?? "",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          height: 1.5,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            )
                          ]),
                    ),
                    Image.network(
                      _user?.avator ?? "",
                      width: 75,
                      height: 75,
                      fit: BoxFit.cover,
                    )
                  ],
                ),
              )
            ],
          );
  }

  //主视图
  Widget _mainView() {
    return Column(
      children: [
        //头部
        _buildHeader(),
      ],
    );
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
    return Scaffold(
        //如果设置了extendBodyBehindAppBar为true，那么appbar将会覆盖在body上面
        extendBodyBehindAppBar: true,
        appBar: AppBarWidget(
          actions: [
            //拍照
            GestureDetector(
              onTap: _onPublish,
              child: const Padding(
                padding: EdgeInsets.only(right: spacing),
                child: Icon(Icons.camera_alt),
              ),
            )
          ],
        ),
        body: _mainView());
  }
}
