import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

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
          ElevatedButton(onPressed: () => Navigator.pop(context, 'CANCEL'), child: Text('CANCEL'.tr())),
          ElevatedButton(onPressed: () => Navigator.pop(context, 'OK'), child: Text('OK'.tr())),
        ],
      ),
    );
  }

  static Future<dynamic> popupImageOkCancel(context, title, msg, Widget imageWidget, wPopup, hPopup) {
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
            const SizedBox(height: 20),
            Text(msg),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context, 'CANCEL'), child: Text('CANCEL'.tr())),
          ElevatedButton(onPressed: () => Navigator.pop(context, 'OK'), child: Text('OK'.tr())),
        ],
      ),
    );
  }

  // for Sign save and delete
  static Future<dynamic> popupImage2OkCancel(
      context, title, msg, Widget imageWidget, wPopup, hPopup, imageWidget2, msg2) {
    return showDialog(
      context: context,
      barrierDismissible: true, // 바깥 영역 터치시 창닫기
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: hPopup,
              width: wPopup,
              child: imageWidget,
            ),
            Text(msg),
            const SizedBox(height: 10),
            const Divider(
              height: 0,
              thickness: 1,
            ),
            (imageWidget2 == null)
                ? const SizedBox(height: 0)
                : Stack(
                    children: <Widget>[
                      SizedBox(
                        height: hPopup,
                        width: wPopup,
                        child: imageWidget2,
                      ),
                      SizedBox(
                        height: hPopup,
                        width: wPopup,
                        child: SvgPicture.asset('assets/svg/drag_handle_black_24dp.svg', fit: BoxFit.cover),
                      ),
                    ],
                  ),
            (imageWidget2 == null) ? const SizedBox(height: 0) : Text(msg2),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context, 'CANCEL'), child: Text('CANCEL'.tr())),
          ElevatedButton(onPressed: () => Navigator.pop(context, 'OK'), child: Text('OK'.tr())),
        ],
      ),
    );
  }
  static Future<dynamic> popupImageBring(
      context, title, msg) {
    dev.log('# PopupUtil popupImageBring START');
    return showDialog(
      context: context,
      barrierDismissible: true, // 바깥 영역 터치시 창닫기
      builder: (BuildContext context2) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(msg),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton.icon(
                    icon: const Icon(
                      Icons.photo,
                      color: Colors.amber,
                    ),
                    label: Text('GALLERY'.tr()),
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.white),
                    onPressed: () {
                      //XFile? xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                      //if (!context.mounted) return;
                      //Navigator.pop(context, xFile?.path);

                      //XFile? xFile = await ImagePicker().pickImage(source: ImageSource.gallery).then((xFile) {
                      ImagePicker().pickImage(source: ImageSource.gallery).then((xFile) {
                        Navigator.pop(context, xFile?.path);
                      });
                      //if (!context.mounted) return;

                    }),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.lightGreen,
                    ),
                    label: Text('CAMERA'.tr()),
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.white),
                    onPressed: () {
                      //XFile? xFile = await ImagePicker().pickImage(source: ImageSource.camera);
                      //if (!context.mounted) return;
                      //Navigator.pop(context, xFile?.path);
                      ImagePicker().pickImage(source: ImageSource.camera).then((xFile) {
                        Navigator.pop(context, xFile?.path);
                      });
                    }),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context, 'CANCEL'), child: Text('CANCEL'.tr())),
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
