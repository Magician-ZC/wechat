
import 'package:flutter/material.dart';

///菜单项
class MenuItemModel{


  ///图标
  final IconData? icon;

  ///标题
  final String? title;

  ///右侧文字
  final String? right;

  ///点击事件
  final Function()? onTap;

  MenuItemModel({this.icon, this.title, this.right, this.onTap});
}