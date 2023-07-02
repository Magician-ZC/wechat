import 'package:flutter/material.dart';
import 'package:wechat/api/timeline.dart';
import 'package:wechat/entity/index.dart';
import 'package:wechat/pages/index.dart';
import 'package:wechat/utils/index.dart';
import 'package:wechat/widgets/index.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../styles/index.dart';

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({Key? key}) : super(key: key);

  @override
  State<TimeLinePage> createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage>
    with SingleTickerProviderStateMixin {
  //用户资料
  UserModel? _user;
  //动态数据
  List<TimelineModel> _items = [];
  //滑动控制器
  final ScrollController _scrollController = ScrollController();
  //appbar 背景色
  Color? _appBarColor;

  //曾管理
  OverlayState? _overlayState;
  //遮罩层
  OverlayEntry? _shadeOverlayEntry;

  //更多按钮未知offset
  Offset _btnOffset = Offset.zero;

  //动画控制器
  late AnimationController _animationController;
  //动画tween
  late Animation<double> _sizeTween;

  //导入数据
  Future _loadData() async {
    var result = await TimelineApi.pageList();
    if (mounted) {
      setState(() {
        _items = result;
      });
    }
  }

  //获取更多按钮位置offset
  Offset _getBtnOffset(GlobalKey key) {
    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    return offset;
  }

  @override
  void initState() {
    super.initState();
    //初始化overlay
    _overlayState = Overlay.of(context);

    //初始化动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    //初始化动画tween
    _sizeTween = Tween(begin: 0.0, end: 200.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
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

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  //是否喜欢菜单
  Widget _buildIsLikeMenu() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(4),
      ),
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //喜欢
            if (constraints.maxWidth > 80)
              TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.favorite,
                    color: Colors.redAccent,
                    size: 16,
                  ),
                  label: Text(
                    '喜欢',
                    style: textStylePopMenu.copyWith(),
                  )),
            //评论
            if (constraints.maxWidth > 150)
              TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: Text(
                    '评论',
                    style: textStylePopMenu.copyWith(),
                  )),
          ],
        );
      }),
    );
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
    GlobalKey btnKey = GlobalKey();
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
                //时间,更多按钮
                const SpaceVerticalWidget(),
                Row(
                  children: [
                    //时间
                    Text(
                      item.publishDate ?? "",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    const SpaceHorizontalWidget(),
                    const Spacer(),
                    //更多按钮
                    GestureDetector(
                      onTap: () {
                        //获取按钮位置
                        var offset = _getBtnOffset(btnKey);
                        setState(() {
                          _btnOffset = offset;
                        });
                        //显示遮罩层
                        _onShowMenu(onTap: _onCloseMenu);
                      },
                      child: Container(
                        key: btnKey,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(2),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: const Icon(
                          Icons.more_horiz_outlined,
                        ),
                      ),
                    ),
                  ],
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

  //显示菜单
  _onShowMenu({Function()? onTap}) {
    _shadeOverlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: GestureDetector(
          onTap: onTap,
          child: Stack(children: [
            AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: Colors.black.withOpacity(0.4)),
            //菜单
            AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Positioned(
                      left: _btnOffset.dx - 5 - _sizeTween.value,
                      top: _btnOffset.dy - 10,
                      child: SizedBox(
                          width: _sizeTween.value,
                          height: 40,
                          child: _buildIsLikeMenu()));
                })
          ]),
        ),
      );
    });
    _overlayState?.insert(_shadeOverlayEntry!);

    //延迟显示菜单
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_animationController.status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
  }

  //关闭菜单
  _onCloseMenu() async {
    if (_animationController.status == AnimationStatus.completed) {
      await _animationController.reverse();
      _shadeOverlayEntry?.remove();
      _shadeOverlayEntry?.dispose();
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
