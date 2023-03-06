import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

///提示工具
class DuToast{
  ///tip显示
  static void show(String tip){
    Fluttertoast.showToast(
      msg: tip,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0
    );
  }
}