import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as IMG;
import 'package:path_provider/path_provider.dart';

import '../config/constant_app.dart';
import '../dto/info_dot.dart';
import '../dto/info_shape.dart';
import '../painter/clipper_sign.dart';
import '../ui/bar_parent.dart';
import '../util/util_file.dart';
import '../util/util_info.dart';

class ParentProvider with ChangeNotifier {

  ////////////////////////////////////////////////////////////////////////////////
  // Bar START
  ////////////////////////////////////////////////////////////////////////////////
  // RESIZE 화면인지 구분하는 용도
  // (MakePage 에서 PARENT + RESIZE 상태인지 구분해서 처리하고 있음)

  // prefs 에 저장될 필요없음 (2023.05.18, KY.Jung)
  ParentBarEnum parentBarEnum = ParentBarEnum.FRAME;
  void setParentBarEnum(var value) {
    parentBarEnum = value;
    notifyListeners();
  }
  ////////////////////////////////////////////////////////////////////////////////
  // Bar END
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // drawing START
  ////////////////////////////////////////////////////////////////////////////////
  List<List<DotInfo>> signLines = <List<DotInfo>>[];
  void drawSignLinesStart(Offset offset) {
    List<DotInfo> oneLine = <DotInfo>[];
    oneLine.add(DotInfo(offset, signWidth, signColor));
    signLines.add(oneLine);
    notifyListeners();
  }
  void drawSignLines(Offset offset, double s) {
    signLines.last.add(DotInfo(offset, s, null));
    notifyListeners();
  }
  void initSignLines({bool notify = true}) {
    signLines.clear();
    if (notify)   notifyListeners();
  }
  void undoSignLines({bool notify = true}) {
    if (signLines.isNotEmpty) {
      signLines.removeLast();
      if (notify)   notifyListeners();
    }
  }
  ////////////////////////////////////////////////////////////////////////////////
  // drawint END
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // sign width/color START
  ////////////////////////////////////////////////////////////////////////////////
  /*
  Color? _signColor;
  get signColor => _signColor;
  void setSignColor(Color color) {
    _signColor = color;
    notifyListeners();
  }
  */
  late Color signColor;
  void setSignColor(Color color) {
    signColor = color;
    notifyListeners();
  }
  double signWidth = 10;
  void setSignWidth(double size) {
    signWidth = size;
    notifyListeners();
  }
  void changeSignColorAndWidth(Color c, double s,{bool notify = true}) {
    signColor = c;
    signWidth = s;
    if (notify)   notifyListeners();
  }

  Color? signBackgroundColor;
  void setSignBackgroundColor(Color? color) {
    signBackgroundColor = color;
    notifyListeners();
  }

  Color? signShapeBorderColor;
  void setSignShapeBorderColor(Color? color) {
    signShapeBorderColor = color;
    notifyListeners();
  }
  double signShapeBorderWidth = 10;
  void setSignShapeBorderWidth(double size) {
    signShapeBorderWidth = size;
    notifyListeners();
  }
  void changeSignShapeBorderColorAndWidth(Color c, double s,{bool notify = true}) {
    signShapeBorderColor = c;
    signShapeBorderWidth = s;
    if (notify)   notifyListeners();
  }
  ////////////////////////////////////////////////////////////////////////////////
  // sign width/color END
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // background ui image START
  ////////////////////////////////////////////////////////////////////////////////
  // for shape
  ui.Image? shapeBackgroundUiImage;
  Future<void> loadShapeBackgroundUiImage(String path, double whSignBoard) async {
    dev.log('# ParentProvider loadShapeBackgroundUiImage START');

    InfoUtil.loadUiImageFromPath(path).then((image) async {
      dev.log('loadUiImageFromPath START');

      // 꽉찬 크기의 비율 구하기
      double scaleNew = InfoUtil.calcFitRatioOut(whSignBoard, whSignBoard, image.width, image.height);
      dev.log('scaleNew: $scaleNew');

      /*
      // 이전 파일 지우고 신규 파일명 구하기
      Directory appDir = await getApplicationDocumentsDirectory();
      dev.log('getApplicationDocumentsDirectory: $appDir');
      String newPath = '${appDir.path}/${AppConstant.SIGN_SHAPEBACKGROUND_DIR}';
      dev.log('newPath: $newPath');
      File newPathFile = File(newPath);
      bool f = await newPathFile.exists(); // 항상 false --> ?
      try {
        if (f) {
          dev.log('newPathFile.exists: true');
          newPathFile.deleteSync(recursive: true);
        }
        newPathFile.deleteSync(recursive: true);
      } catch (e) {
        print(e);
      }
      String fileName = '${appDir.path}/${AppConstant.SIGN_SHAPEBACKGROUND_DIR}/'
          '${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.jpg';
      */
      File newImageFile = await FileUtil.initTempDirAndFile(AppConstant.SIGN_SHAPEBACKGROUND_DIR, 'jpg');
      dev.log('newImageFile.path: ${newImageFile.path}');

      /*
      // resize 하여 저장
      final cmd = IMG.Command()
        ..decodeImageFile(path)
        ..copyResize(width: (image.width * scaleNew).toInt(), height: (image.height * scaleNew).toInt())
        ..writeToFile(newImageFile.path);
      await cmd.executeThread();
      */
      await FileUtil.resizeJpgWithFile(path, newImageFile.path, (image.width * scaleNew).toInt(), (image.height * scaleNew).toInt());

      InfoUtil.loadUiImageFromPath(newImageFile.path).then((imageNew) {
        shapeBackgroundUiImage = imageNew;
        dev.log(
            'loadUiImageFromPath2 w: ${imageNew.width}, h: ${imageNew.height}');

        notifyListeners();
      });
    });
  }
  void initShapeBackgroundUiImage({bool notify = true}) {
    shapeBackgroundUiImage?.dispose();
    shapeBackgroundUiImage = null;
    if (notify)   notifyListeners();
  }
  ////////////////////////////////////////////////////////////////////////////////
  // background ui image END
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // shapeinfo START
  ////////////////////////////////////////////////////////////////////////////////
  List<ShapeInfo> shapeInfoList = [];
  void reorderShapeInfoList(List<String> fileNameList) {
    FileUtil.reorderingShapeInfoListWithFileNameList(shapeInfoList, fileNameList);
    notifyListeners();
  }
  ////////////////////////////////////////////////////////////////////////////////
  // shapeinfo END
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // recent color START
  ////////////////////////////////////////////////////////////////////////////////
  List<Color> recentSignColorList = [];
  void addRecentSignColor(Color color, int max, {bool notify = true}) {
    recentSignColorList.insert(0, color);
    for (int i = 1, j = recentSignColorList.length; i < j; i++) {
      if (color.value == recentSignColorList[i].value) {
        recentSignColorList.removeAt(i);
        break;
      }
    }
    if (recentSignColorList.length > max) {
      recentSignColorList.removeLast();
    }
    if (notify)   notifyListeners();
  }

  List<Color> recentSignBackgroundColorList = [];
  void addRecentSignBackgroundColor(Color color, int max, {bool notify = true}) {
    recentSignBackgroundColorList.insert(0, color);
    for (int i = 1, j = recentSignBackgroundColorList.length; i < j; i++) {
      if (color.value == recentSignBackgroundColorList[i].value) {
        recentSignBackgroundColorList.removeAt(i);
        break;
      }
    }
    if (recentSignBackgroundColorList.length > max) {
      recentSignBackgroundColorList.removeLast();
    }
    if (notify)   notifyListeners();
  }

  List<Color> recentSignShapeBorderColorList = [];
  void addRecentSignShapeBorderColor(Color color, int max, {bool notify = true}) {
    recentSignShapeBorderColorList.insert(0, color);
    for (int i = 1, j = recentSignShapeBorderColorList.length; i < j; i++) {
      if (color.value == recentSignShapeBorderColorList[i].value) {
        recentSignShapeBorderColorList.removeAt(i);
        break;
      }
    }
    if (recentSignShapeBorderColorList.length > max) {
      recentSignShapeBorderColorList.removeLast();
    }
    if (notify)   notifyListeners();
  }
  ////////////////////////////////////////////////////////////////////////////////
  // recent color END
  ////////////////////////////////////////////////////////////////////////////////

}
