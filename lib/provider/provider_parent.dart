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
  // prefs 에 저장될 필요없음 (2023.05.18, KY.Jung)
  var _parentBarEnum = ParentBarEnum.FRAME;
  get parentBarEnum => _parentBarEnum;
  void setParentBarEnum(var value) {
    _parentBarEnum = value;
    notifyListeners();
  }
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // for drawing

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

  double _signWidth = 10;
  double get signWidth => _signWidth;
  void changeSignWidth(double size) {
    _signWidth = size;
    notifyListeners();
  }

  Color _signColor = Colors.black;
  Color get signColor => _signColor;
  void changeSignColor(Color color) {
    _signColor = color;
    notifyListeners();
  }
  void changeSignColorAndWidth(Color c, double s) {
    _signColor = c;
    _signWidth = s;
    notifyListeners();
  }
  ////////////////////////////////////////////////////////////////////////////////

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

  List<ShapeInfo> shapeInfoList = [];
  void initShapeInfoList() {
    // 성능상의 이유로 실제 호출하지는 않음
    shapeInfoList.clear();
  }
  ////////////////////////////////////////////////////////////////////////////////

}
