import 'dart:developer' as dev;
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constant_app.dart';
import '../dto/info_dot.dart';
import '../dto/info_shapefile.dart';
import '../dto/info_signfile.dart';
import '../util/util_file.dart';
import '../util/util_info.dart';

class SignProvider with ChangeNotifier {

  ////////////////////////////////////////////////////////////////////////////////
  // ParentBar Sign START
  ////////////////////////////////////////////////////////////////////////////////
  int parentSignFileInfoIdx = -1;   // ParentBar 에서 설정됨
  Offset? parentSignOffset;         // MakePage 에서 설정됨
  // ParentBar --> MakePage
  void setParentSignFileInfoIdx(int idx, {bool notify = true}) {
    parentSignFileInfoIdx = idx;

    if (notify)   notifyListeners();
  }
  ////////////////////////////////////////////////////////////////////////////////
  // ParentBar Sign END
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // Sign init START
  ////////////////////////////////////////////////////////////////////////////////
  // signmbs 에서 작업한 내용 지우기
  void clearAll() {
    // sign
    selectedSignFileInfoIdx = -1;
    signUiImage?.dispose();
    signUiImage = null;

    // line
    signLines.clear();
    //signWidth = 10;
    SharedPreferences.getInstance().then((prefs) {
      signWidth = prefs.getDouble(AppConstant.PREFS_SIGNWIDTH) ?? 10;
    });

    // background
    signBackgroundColor = null;
    signBackgroundUiImage?.dispose();
    signBackgroundUiImage = null;

    // shape
    selectedSignShapeFileInfoIdx = -1;
    signShapeBorderColor = null;
    //signShapeBorderWidth = 10;
    SharedPreferences.getInstance().then((prefs) {
      signShapeBorderWidth = prefs.getDouble(AppConstant.PREFS_SIGNSHAPEBORDERWIDTH) ?? 10;
    });

  }
  ////////////////////////////////////////////////////////////////////////////////
  // init END
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // sign START
  ////////////////////////////////////////////////////////////////////////////////
  // signFileInfoList
  List<SignFileInfo> signFileInfoList = [];
  // SignMbs --> ParentBar
  void addSignFileInfoList(SignFileInfo signFileInfo, int max, {bool notify = true}) {
    signFileInfoList.insert(0, signFileInfo);
    if (signFileInfoList.length > max) {
      signFileInfoList.removeLast();
    }

    if (notify)   notifyListeners();
  }
  // shape info idx
  int selectedSignFileInfoIdx = -1;
  ui.Image? signUiImage;
  void clearSignUiImage() {
    signUiImage?.dispose();
    signUiImage = null;
  }
  ////////////////////////////////////////////////////////////////////////////////
  // sign END
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // Line START
  ////////////////////////////////////////////////////////////////////////////////
  // drawing
  List<List<DotInfo>> signLines = <List<DotInfo>>[];
  void drawSignLinesStart(Offset offset) {
    List<DotInfo> oneLine = <DotInfo>[];
    oneLine.add(DotInfo(offset, signWidth, signColor));
    signLines.add(oneLine);
  }
  void drawSignLines(Offset offset, double s) {
    signLines.last.add(DotInfo(offset, s, null));
  }
  void clearSignLines() {
    signLines.clear();
  }
  void undoSignLines() {
    if (signLines.isNotEmpty) {
      signLines.removeLast();
    }
  }

  // recent color
  List<Color> recentSignColorList = [];
  void addRecentSignColor(Color color, int max) {
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
  }
  // sign color
  late Color signColor;
  // sign width
  double signWidth = 10;
  ////////////////////////////////////////////////////////////////////////////////
  // Line END
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // Background START
  ////////////////////////////////////////////////////////////////////////////////
  // recent background color
  List<Color> recentSignBackgroundColorList = [];
  void addRecentSignBackgroundColor(Color color, int max) {
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
  }
  // background color
  Color? signBackgroundColor;
  // background image
  ui.Image? signBackgroundUiImage;
  Future<void> loadSignBackgroundUiImage(String path, double whSignBoard) async {
    dev.log('# signProvider loadSignBackgroundUiImage START');

    // 지우고 시작
    clearSignBackgroundUiImage();

    FileUtil.loadUiImageFromPath(path).then((image) async {
      dev.log('loadUiImageFromPath START');

      // 꽉찬 크기의 비율 구하기
      double scaleNew = InfoUtil.calcFitRatioOut(whSignBoard, whSignBoard, image.width, image.height);
      dev.log('scaleNew: $scaleNew');

      File newImageFile = await FileUtil.initTempDirAndFile(AppConstant.SIGN_SHAPEBACKGROUND_DIR, 'jpg');
      dev.log('newImageFile.path: ${newImageFile.path}');

      await FileUtil.resizeJpgWithFile(path, newImageFile.path, (image.width * scaleNew).toInt(), (image.height * scaleNew).toInt());

      FileUtil.loadUiImageFromPath(newImageFile.path).then((imageNew) {
        signBackgroundUiImage = imageNew;
        dev.log('loadUiImageFromPath2 w: ${imageNew.width}, h: ${imageNew.height}');
      });
    });
  }
  void clearSignBackgroundUiImage() {
    signBackgroundUiImage?.dispose();
    signBackgroundUiImage = null;
  }
  ////////////////////////////////////////////////////////////////////////////////
  // Background END
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // Shape START
  ////////////////////////////////////////////////////////////////////////////////
  // shapefileinfo list
  List<ShapeFileInfo> shapeFileInfoList = [];
  // shape info idx
  int selectedSignShapeFileInfoIdx = -1;
  // recent shape border color list
  List<Color> recentSignShapeBorderColorList = [];
  void addRecentSignShapeBorderColor(Color color, int max) {
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
  }
  // shape border color
  Color? signShapeBorderColor;
  // shape border width
  double signShapeBorderWidth = 10;
  ////////////////////////////////////////////////////////////////////////////////
  // Shape END
  ////////////////////////////////////////////////////////////////////////////////

}
