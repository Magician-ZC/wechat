import 'package:flutter/material.dart';
import 'package:wechat/utils/config.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class PostEditPage extends StatefulWidget {
  const PostEditPage({super.key});

  @override
  State<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends State<PostEditPage> {
  //已选中图片数组
  List<AssetEntity> _selectedAssets = [];

  //图片列表
  Widget _buildPhotosList() {
    return Padding(
      padding: const EdgeInsets.all(spacing),
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        final double width = (constraints.maxWidth - spacing * 2) / 3;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            //图片
            for (final asset in _selectedAssets)
              _buildPhotoItem(asset, width),
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
                final List<AssetEntity>? result =
                    await AssetPicker.pickAssets(context,
                        pickerConfig: AssetPickerConfig(
                            selectedAssets: _selectedAssets,
                            maxAssets: maxAssets));
                setState(() {
                  _selectedAssets = result ?? [];
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
    return Container(
              clipBehavior: Clip.antiAlias,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(3)),
              child: AssetEntityImage(
                asset,
                isOriginal: false,
                width: width,
                height: width,
                fit: BoxFit.cover,
              ),
            );
  }

  //主视图
  Widget _mainView() {
    return Column(
      children: [
        //图片列表
        _buildPhotosList()
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
    );
  }
}
