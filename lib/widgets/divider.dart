import 'package:flutter/material.dart';

///分隔条
class DividerWidget extends StatelessWidget {
  const DividerWidget({Key? key, this.height}) : super(key: key);

  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height?? 1,
      color: Colors.grey[100],
    );
  }
}
