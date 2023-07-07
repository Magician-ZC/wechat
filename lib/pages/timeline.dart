import 'package:flutter/material.dart';
import 'package:wechat/api/timeline.dart';
import 'package:wechat/entity/index.dart';
import 'package:wechat/pages/index.dart';
import 'package:wechat/utils/index.dart';
import 'package:wechat/widgets/index.dart';
import 'package:wechat/widgets/text.dart';
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

  //当前操作的item
  TimelineModel? _currentItem;

  //是否显示评论输入框
  bool _isShowInput = false;
  //是否展开表情列表
  bool _isShowEmoji = false;
  //是否输入内容
  bool _isInputWords = false;
  //评论输入框
  final TextEditingController _commentController = TextEditingController();
  //输入框焦点
  final FocusNode _focusNode = FocusNode();
  //键盘高度
  final double _keyboardHeight = 200;

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

    //监听滑动
    _scrollController.addListener(() {
      //滚动条超过200时，开始渐变
      if (_scrollController.position.pixels > 200) {
        //透明度系数
        double opacity = (_scrollController.position.pixels - 200) / 100;
        if (opacity < 0.85) {
          setState(() {
            _appBarColor = Colors.black.withOpacity(opacity);
          });
        }
      } else {
        setState(() {
          _appBarColor = null;
        });
      }
    });

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

    //监控输入
    _commentController.addListener(() {
      setState(() {
        _isInputWords = _commentController.text.isNotEmpty;
      });
    });

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
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  //点赞列表
  Widget _buildLikeList(TimelineModel item) {
    return Container(
      padding: const EdgeInsets.all(spacing),
      color: Colors.grey[100],
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //图标
        const Padding(
          padding: EdgeInsets.only(top: spacing),
          child: Icon(
            Icons.favorite_border_outlined,
            size: 20,
            color: Colors.black54,
          ),
        ),
        const SpaceHorizontalWidget(),
        //点赞列表
        Expanded(
            child: Wrap(spacing: 5, runSpacing: 5, children: [
          for (LikeModel item in item.likes ?? [])
            Image.network(
              item.avator ?? '',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            )
        ]))
      ]),
    );
  }

  //评论列表
  _buildCommentList(TimelineModel item) {
    return Container(
        padding: const EdgeInsets.all(spacing),
        color: Colors.grey[100],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //图标
            const Padding(
              padding: EdgeInsets.only(top: spacing),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 20,
                color: Colors.black54,
              ),
            ),
            const SpaceHorizontalWidget(),

            //右侧评论区
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (CommentModel comment in item.comments ?? [])
                  //评论项目
                  Row(
                    children: [
                      //头像
                      Image.network(
                        comment.user?.avator ?? '',
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                      ),
                      const SpaceHorizontalWidget(),

                      //昵称、时间、内容
                      Expanded(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //行 1 昵称 时间
                          Row(children: [
                            //昵称
                            Text(
                              comment.user?.nickname ?? '',
                              style: textStyleComment,
                            ),
                            const Spacer(),
                            //时间
                            Text(
                              DuTools.dateTimeFormat(comment.publishDate ?? ""),
                              style: textStyleComment,
                            )
                          ]),
                          //行 2 内容
                          Text(
                            comment.content ?? '',
                            style: textStyleComment,
                          )
                        ],
                      ))
                    ],
                  )
              ],
            ))
          ],
        ));
  }

  //是否喜欢菜单
  Widget _buildIsLikeMenu(TimelineModel? item) {
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
                  onPressed: () {
                    _onLike();
                  },
                  icon: Icon(
                    Icons.favorite,
                    color:
                        item?.isLike == true ? Colors.redAccent : Colors.white,
                    size: 16,
                  ),
                  label: Text(
                    item?.isLike == true ? '取消' : '喜欢',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //正文
        _buildContent(item),
        //点赞列表
        _buildLikeList(item),
        //评论列表
        _buildCommentList(item),
      ],
    );
  }

  ///正文、图片、视频
  Padding _buildContent(TimelineModel item) {
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
                TextMaxLinesWidget(content: item.content ?? ""),
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
                          _currentItem = item;
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
            AnimatedContainer(duration: const Duration(milliseconds: 300)),
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
                          child: _buildIsLikeMenu(_currentItem)));
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

  //点赞操作
  void _onLike() {
    //安全检查
    if (_currentItem == null) {
      return;
    }
    //设置状态
    setState(() {
      _currentItem?.isLike = !(_currentItem?.isLike ?? false);
    });

    //关闭菜单
    _onCloseMenu();

    //执行请求
    TimelineApi.like(_currentItem!.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //如果设置了extendBodyBehindAppBar为true，那么appbar将会覆盖在body上面
        extendBodyBehindAppBar: true,
        appBar: AppBarWidget(
          backgroundColor: _appBarColor,
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
