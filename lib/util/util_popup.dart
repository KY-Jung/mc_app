import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PopupUtil {
  ////////////////////////////////////////////////////////////////////////////////
  /// 팝업 바깥을 누르면 null 반환
  static Future<dynamic> popupAlertOk(context, title, msg) {
    return showDialog(
      context: context,
      barrierDismissible: true, // 바깥 영역 터치시 창닫기
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.pop(context, 'OK'), // pop : 뒤로가기
              child: Text('OK'.tr())),
        ],
      ),
    );
  }

  /// 팝업 바깥을 누르면 null 반환
  static Future<dynamic> popupAlertOkCancel(context, title, msg) {
    return showDialog(
      context: context,
      barrierDismissible: true, // 바깥 영역 터치시 창닫기
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: Text('OK'.tr())),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, 'CANCEL'),
              child: Text('CANCEL'.tr())),
        ],
      ),
    );
  }

  /*
    static Future<dynamic> popupImageOkCancel(
      context, title, msg, Widget imageWidget) {
    return showDialog(
      context: context,
      barrierDismissible: true, // 바깥 영역 터치시 창닫기
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: imageWidget,
            ),
            Text(msg),
          ],
        ),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: Text('OK'.tr())),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, 'CANCEL'),
              child: Text('CANCEL'.tr())),
        ],
      ),
    );
  }
   */
  static Future<dynamic> popupImageOkCancel(
      context, title, msg, Widget imageWidget, wPopup, hPopup) {
    return showDialog(
      context: context,
      barrierDismissible: true, // 바깥 영역 터치시 창닫기
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: hPopup,
              width: wPopup,
              child: imageWidget,
            ),
            Text(msg),
          ],
        ),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: Text('OK'.tr())),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, 'CANCEL'),
              child: Text('CANCEL'.tr())),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  static void toastMsgShort(String msg) {

    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  static void toastMsgLong(String msg) {

    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
////////////////////////////////////////////////////////////////////////////////
}
