import 'package:flutter/material.dart';
import 'package:wechat/api/timeline.dart';
import 'package:wechat/entity/index.dart';
import 'package:wechat/pages/index.dart';
import 'package:wechat/utils/index.dart';
import 'package:wechat/widgets/index.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({Key? key}) : super(key: key);

  @override
  State<TimeLinePage> createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  //用户资料
  UserModel? _user;
  //动态数据
  List<TimelineModel> _items = [];
  //滑动控制器
  final ScrollController _scrollController = ScrollController();
  //appbar 背景色
  Color? _appBarColor;

  //导入数据
  Future _loadData() async {
    var result = await TimelineApi.pageList();
    if (mounted) {
      setState(() {
        _items = result;
      });
    }
  }

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
    //载入数据
    _loadData();
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

  //列表
  Widget _buildList() {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (context, index) {
        var item = _items[index];
        return _buildListItem(item);
      },
      childCount: _items.length,
    ));
  }

  ///列表项
  Widget _buildListItem(TimelineModel item) {
    int imgCount = item.images?.length ?? 0;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //头像
          Image.network(
            item.user?.avator ?? "",
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
          //右侧
          const SpaceHorizontalWidget(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //昵称
                Text(
                  item.user?.nickname ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SpaceVerticalWidget(),
                //正文
                Text(
                  item.content ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SpaceVerticalWidget(),
                //9宫格图片列表
                LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  //计算每个图片的宽度
                  double imgWidget = imgCount == 1
                      ? constraints.maxWidth * 0.7
                      : imgCount == 2
                          ? (constraints.maxWidth - spacing) / 2
                          : (constraints.maxWidth - spacing * 2) / 3;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: item.images!.map((e) {
                      return SizedBox(
                        width: imgWidget,
                        height: imgWidget,
                        child: Image.network(
                          DuTools.imageUrlFormat(e),
                          fit: BoxFit.cover,
                        ),
                      );
                    }).toList(),
                  );
                }),
                //位置
                const SpaceVerticalWidget(),
                Text(
                  item.location ?? "",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                //时间
                const SpaceVerticalWidget(),
                Text(
                  item.publishDate ?? "",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                const SpaceVerticalWidget(),
              ],
            ),
          )
        ],
      ),
    );
  }

  //主视图
  Widget _mainView() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // 头部
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildHeader(),
          ),
        ),
        // 数据列表
        _buildList(),
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
