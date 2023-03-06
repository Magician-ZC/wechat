import 'package:flutter/material.dart';

///顶部导航栏
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget{
  const AppBarWidget({Key? key, this.backgroundColor, this.elevation, this.leading,this.actions}) : super(key: key);

  final Color? backgroundColor;
  final double? elevation;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(30);

  Widget _mainView(){
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation ?? 0,
      leading: leading,
      actions: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _mainView();
  }
}
