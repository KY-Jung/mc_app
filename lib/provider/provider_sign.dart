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
import '../painter/clipper_sign.dart';
import '../util/util_file.dart';
import '../util/util_info.dart';

class SignProvider with ChangeNotifier {

  ////////////////////////////////////////////////////////////////////////////////
  // for drawing

  List<List<DotInfo>> lines = <List<DotInfo>>[];
  double _size = 10;
  Color _color = Colors.black;

  double get size => _size;
  void changeSize(double size) {
    _size = size;
    notifyListeners();
  }

  Color get color => _color;
  void changeColor(Color color) {
    _color = color;
    notifyListeners();
  }

  void changeColorSize(Color c, double s) {
    _color = c;
    _size = s;
    notifyListeners();
  }

  void drawStart(Offset offset) {
    List<DotInfo> oneLine = <DotInfo>[];
    oneLine.add(DotInfo(offset, size, color));
    lines.add(oneLine);
    notifyListeners();
  }
  void drawing(Offset offset, double s) {
    lines.last.add(DotInfo(offset, s, null));
    notifyListeners();
  }
  void initLines() {
    lines.clear();
    notifyListeners();
  }
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // for shape

  ui.Image? shapeBackground;

  //ui.Image? get shapeBackground => _shapeBackground;
  void loadShapeBackground(String path, double whSignBoard) async {
    dev.log('# SignProvider loadShapeBackground START');

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
        shapeBackground = imageNew;
        dev.log(
            'loadUiImageFromPath2 w: ${imageNew.width}, h: ${imageNew.height}');

        notifyListeners();
      });
    });

  }
  void initShapeBackground() {
    shapeBackground?.dispose();
    shapeBackground = null;
    notifyListeners();
  }
  ////////////////////////////////////////////////////////////////////////////////

}
