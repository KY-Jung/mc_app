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
import '../dto/info_sign.dart';
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
  // init START
  ////////////////////////////////////////////////////////////////////////////////
  void initAll({bool notify = true}) {
    // sign
    selectedSignInfoIdx = -1;

    // line
    signLines.clear();
    //if (recentSignColorList.isEmpty) {
    //  signColor = Colors.blue;
    //} else {
    //  signColor = recentSignColorList[0];
    //}
    signWidth = 10;

    // background
    signBackgroundColor = null;
    signBackgroundUiImage?.dispose();
    signBackgroundUiImage = null;

    // shape
    selectedShapeInfoIdx = -1;
    signShapeBorderColor = null;
    signShapeBorderWidth = 10;

    if (notify)   notifyListeners();
  }
  ////////////////////////////////////////////////////////////////////////////////
  // init END
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // signInfoList START
  ////////////////////////////////////////////////////////////////////////////////
  // sign info list
  List<SignInfo> signInfoList = [];
  void addSignInfoList(SignInfo signInfo, int max, {bool notify = true}) {
    signInfoList.insert(0, signInfo);
    if (signInfoList.length > max) {
      signInfoList.removeLast();
    }

    if (notify)   notifyListeners();
  }
  // shape info idx
  int selectedSignInfoIdx = -1;
  void setSelectedSignInfoIdx(int idx) {
    selectedSignInfoIdx = idx;
    notifyListeners();
  }
  ////////////////////////////////////////////////////////////////////////////////
  // signInfoList END
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
  // Line START
  ////////////////////////////////////////////////////////////////////////////////
  // recent color
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
  // sign color
  late Color signColor;
  void setSignColor(Color color) {
    signColor = color;
    notifyListeners();
  }
  // sign width
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
  ////////////////////////////////////////////////////////////////////////////////
  // Line END
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // Background START
  ////////////////////////////////////////////////////////////////////////////////
  // recent background color
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
  // background color
  Color? signBackgroundColor;
  void setSignBackgroundColor(Color? color) {
    signBackgroundColor = color;
    notifyListeners();
  }
  // background image
  ui.Image? signBackgroundUiImage;
  Future<void> loadSignBackgroundUiImage(String path, double whSignBoard) async {
    dev.log('# ParentProvider loadSignBackgroundUiImage START');

    InfoUtil.loadUiImageFromPath(path).then((image) async {
      dev.log('loadUiImageFromPath START');

      // 꽉찬 크기의 비율 구하기
      double scaleNew = InfoUtil.calcFitRatioOut(whSignBoard, whSignBoard, image.width, image.height);
      dev.log('scaleNew: $scaleNew');

      File newImageFile = await FileUtil.initTempDirAndFile(AppConstant.SIGN_SHAPEBACKGROUND_DIR, 'jpg');
      dev.log('newImageFile.path: ${newImageFile.path}');

      await FileUtil.resizeJpgWithFile(path, newImageFile.path, (image.width * scaleNew).toInt(), (image.height * scaleNew).toInt());

      InfoUtil.loadUiImageFromPath(newImageFile.path).then((imageNew) {
        signBackgroundUiImage = imageNew;
        dev.log('loadUiImageFromPath2 w: ${imageNew.width}, h: ${imageNew.height}');

        notifyListeners();
      });
    });
  }
  void initSignBackgroundUiImage({bool notify = true}) {
    signBackgroundUiImage?.dispose();
    signBackgroundUiImage = null;
    if (notify)   notifyListeners();
  }
  ////////////////////////////////////////////////////////////////////////////////
  // Background END
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // Shape START
  ////////////////////////////////////////////////////////////////////////////////
  // shape info list
  List<ShapeInfo> shapeInfoList = [];
  /*
  void reorderShapeInfoList(List<String> fileNameList) {
    //FileUtil.reorderShapeInfoListWithFileNameList(shapeInfoList, fileNameList);
    FileUtil.reorderInfoListWithFileNameList(shapeInfoList, fileNameList);
    notifyListeners();
  }
  */
  // shape info idx
  int selectedShapeInfoIdx = -1;
  void setSelectedShapeInfoIdx(int idx) {
    selectedShapeInfoIdx = idx;
    notifyListeners();
  }
  // recent shape border color list
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
  // shape border color
  Color? signShapeBorderColor;
  void setSignShapeBorderColor(Color? color) {
    signShapeBorderColor = color;
    notifyListeners();
  }
  // shape border width
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
  // Shape END
  ////////////////////////////////////////////////////////////////////////////////

}
