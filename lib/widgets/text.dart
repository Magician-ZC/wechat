//更多文本组件
import 'package:flutter/material.dart';

class TextMaxLinesWidget extends StatefulWidget {
  const TextMaxLinesWidget({super.key, required this.content, this.maxLines});

  final String content;
  final int? maxLines;

  @override
  State<TextMaxLinesWidget> createState() => _TextMaxLinesWidgetState();
}

class _TextMaxLinesWidgetState extends State<TextMaxLinesWidget> {
  //内容
  late final String _content;
  //最大行数
  late final int _maxLines;
  //是否展开
  bool _isExpansion = false;

  @override
  void initState() {
    super.initState();
    _content = widget.content;
    _maxLines = widget.maxLines ?? 3;
  }

  //主视图
  Widget _mainView() {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      //将【TextSpan】树绘制到【Canvas】中的对象
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: _content,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black54,
          ),
        ),
        maxLines: _maxLines,
        textDirection: TextDirection.ltr,
      )..layout(
          //设置宽度约束
          maxWidth: constraints.maxWidth,
        );

      //1.不展开
      if (_isExpansion == false) {
        List<Widget> ws = [];
        //1.1检查是否超出高度，didExceedMaxLines 超出最大行数
        if (textPainter.didExceedMaxLines && _isExpansion == false) {
          ws.add(Text(
            _content,
            maxLines: _maxLines,
            overflow: TextOverflow.ellipsis, //隐藏超出内容，加上省略号
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
          ));
          ws.add(GestureDetector(
            onTap: () {
              _doExpansion();
            },
            child: const Text(
              "全文",
              style: TextStyle(
                fontSize: 15,
                color: Colors.blue,
              ),
            ),
          ));
        }
        //1.2 不超出显示全部
        else {
          ws.add(
            Text(
              _content,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: ws,
        );
      }
      //2.展开显示全部
      else {
        return Text(
          _content,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black54,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _mainView();
  }

  void _doExpansion() {
    setState(() {
      _isExpansion = !_isExpansion;
    });
  }
}
