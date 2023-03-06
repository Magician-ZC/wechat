import 'package:flutter/material.dart';
import 'package:wechat/utils/config.dart';
import 'package:wechat/utils/index.dart';
import 'package:wechat/widgets/gallery.dart';
import 'package:wechat/widgets/index.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

enum PostType { image, video }

class PostEditPage extends StatefulWidget {
  const PostEditPage({super.key});

  @override
  State<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends State<PostEditPage> {

  // 发布类型
  PostType? postType;

  // 视频压缩文件
  CompressMediaFile? videoCompressFile;

  //已选中图片数组
  List<AssetEntity> _selectedAssets = [];

  //是否开始拖拽
  bool isDragNow = false;

  //是否将要删除
  bool isWillRemove = false;

  //是否将要排序
  bool isWillOrder = false;

  //被拖拽到的target id
  String targetAssId = "";

  //图片列表
  Widget _buildPhotosList() {
    return Padding(
      padding: const EdgeInsets.all(spacing),
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        final double width =
            (constraints.maxWidth - spacing * 2 - imagePadding * 2 * 3) / 3;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            //图片
            for (final asset in _selectedAssets) _buildPhotoItem(asset, width),
            //选择图片按钮
            if (_selectedAssets.length < maxAssets)
              _buildAddBtn(context, width),
          ],
        );
      }),
    );
  }

  //添加按钮
  Widget _buildAddBtn(BuildContext context, double width) {
    return GestureDetector(
      onTap: () async {
        //相册
       // var result = await DuPicker.assets(context: context);
       //  if (result == null) {
       //    return;
       //  }
       //  setState(() {
       //    _selectedAssets = result;
       //  });

       // 拍摄照片
       // var result = await DuPicker.takePhoto(context);
       // if (result == null) {
       //   return;
       // }
       // setState(() {
       //   postType = PostType.image;
       //   _selectedAssets.add(result);
       // });

       //拍视频
         var result = await DuPicker.takeVideo(context);
         if (result == null) {
           return;
         }
         setState(() {
             postType = PostType.video;
            _selectedAssets.clear();
             _selectedAssets.add(result);
         });
      },
      child: Container(
        color: Colors.black12,
        width: width,
        height: width,
        child: const Icon(
          Icons.add,
          size: 48,
          color: Colors.black26,
        ),
      ),
    );
  }

  //图片项
  Widget _buildPhotoItem(AssetEntity asset, double width) {
    return Draggable<AssetEntity>(
      //拖动的数据
      data: asset,
      //当拖动对象开始被拖动时调用
      onDragStarted: () {
        setState(() {
          isDragNow = true;
        });
      },
      //当拖动对象被放下时调用
      onDragEnd: (details) {
        setState(() {
          isDragNow = false;
          isWillOrder = false;
        });
      },
      //当draggable被放置在DragTarget接收时调用
      onDragCompleted: () {},
      //当draggable被放置但未被DragTarget接收时调用
      onDraggableCanceled: (velocity, offset) {
        setState(() {
          isDragNow = false;
          isWillOrder = false;
        });
      },
      //拖动进行时显示在指针下放的小部件
      feedback: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
        child: AssetEntityImage(
          asset,
          isOriginal: false,
          width: width,
          height: width,
          fit: BoxFit.cover,
        ),
      ),
      //当正在进行一个或多个拖动时显示的小部件而不是child
      childWhenDragging: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
        child: AssetEntityImage(
          asset,
          isOriginal: false,
          width: width,
          height: width,
          fit: BoxFit.cover,
          opacity: const AlwaysStoppedAnimation(0.2),
        ),
      ),

      child: DragTarget<AssetEntity>(
        builder: (context, candidateData, rejectedData) {
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return GalleryWidget(
                    initialIndex: _selectedAssets.indexOf(asset),
                    items: _selectedAssets);
              }));
            },
            child: Container(
              clipBehavior: Clip.antiAlias,
              padding: (isWillOrder && targetAssId == asset.id)
                  ? EdgeInsets.zero
                  : const EdgeInsets.all(imagePadding),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: (isWillOrder && targetAssId == asset.id)
                    ? Border.all(color: accentColor, width: imagePadding)
                    : null,
              ),
              child: AssetEntityImage(
                asset,
                isOriginal: false,
                width: width,
                height: width,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
        onWillAccept: (data) {
          // 排除自己
          if (data?.id == asset.id) {
            return false;
          }
          setState(() {
            isWillOrder = true;
            targetAssId = asset.id;
          });
          return true;
        },
        onAccept: (data) {
          // 0 当前元素位置
          int targetIndex = _selectedAssets.indexWhere((element) {
            return element.id == asset.id;
          });

          // 1 删除原来的
          _selectedAssets.removeWhere((element) {
            return element.id == data.id;
          });

          // 2 插入到目标前面
          _selectedAssets.insert(targetIndex, data);
          setState(() {
            isWillOrder = false;
            targetAssId = "";
          });
        },
        onLeave: (data) {
          setState(() {
            isWillOrder = false;
            targetAssId = "";
          });
        },
      ),
    );
  }

  //删除Bar
  Widget _buildRemoveBar() {
    return DragTarget<AssetEntity>(
      //调用以构建此小部件的内容
      builder: (context, candidateData, rejectedData) {
        return SizedBox(
          width: double.infinity,
          child: Container(
            height: 120,
            color: isWillRemove ? Colors.red[300] : Colors.red[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //图标
                Icon(
                  Icons.delete,
                  size: 32,
                  color: isWillRemove ? Colors.white : Colors.white70,
                ),
                //文字
                Text(
                  '拖拽到这里删除',
                  style: TextStyle(
                    color: isWillRemove ? Colors.white : Colors.white70,
                  ),
                )
              ],
            ),
          ),
        );
      },
      onWillAccept: (data) {
        setState(() {
          isWillRemove = true;
        });
        return true;
      },

      onAccept: (data) {
        setState(() {
          _selectedAssets.remove(data);
          isWillRemove = false;
        });
      },

      onLeave: (data) {
        setState(() {
          isWillRemove = false;
        });
      },
    );
  }

  //主视图
  Widget _mainView() {
    return Column(
      children: [
        //相册列表
        if(postType == PostType.image) _buildPhotosList(),

        //视频播放器
        if (postType == PostType.video)
          VideoPlayerWidget(
            initAsset: _selectedAssets.first,
            onCompleted: (value) => videoCompressFile = value,
          ),

        //添加按钮
        if(postType == null && _selectedAssets.isEmpty)
          Padding(
            padding: const EdgeInsets.all(spacing),
            child: _buildAddBtn(context, 100),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发布'),
      ),
      body: _mainView(),
      bottomSheet: isDragNow ? _buildRemoveBar() : const SizedBox.shrink(),
    );
  }
}
