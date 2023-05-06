import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../config/config_app.dart';
import '../dto/info_parent.dart';
import '../util/util_info.dart';

class MakePainter extends CustomPainter {
  ////////////////////////////////////////////////////////////////////////////////
  late double wScreen;
  late double hScreen;

  int wImage = 0;
  int hImage = 0;

  double inScale = 0;

  double xBlank = 0;
  double yBlank = 0;

  double xStart = 0;
  double yStart = 0;

  double scale = 0;

  Offset leftTopOffset = const Offset(0, 0);
  Offset rightTopOffset = const Offset(0, 0);
  Offset leftBottomOffset = const Offset(0, 0);
  Offset rightBottomOffset = const Offset(0, 0);
  ////////////////////////////////////////////////////////////////////////////////

  /// InteractiveViewer 가 확대/축소될때는 호출되지 않음
  @override
  void paint(Canvas canvas, Size size) {
    // wScreen, hScreen 과 동일
    dev.log('# MakePainter paint START');

    ////////////////////////////////////////////////////////////////////////////////
    initParentData();
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // grid
    Paint gridPaint = Paint()
      ..color = Colors.white30
      //..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;
    //InfoUtil.drawGrid(canvas, wScreen, hScreen, wImage, hImage, inScale, xBlank,
    //    yBlank, AppConfig.SIZE_GRID_RATIO, gridPaint);
    InfoUtil.drawGrid(canvas, wScreen, hScreen, xBlank, yBlank,
        AppConfig.SIZE_GRID_RATIO, gridPaint);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    Paint paint = Paint()
      ..color = Colors.deepPurpleAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;
    Offset p1 = Offset(xBlank, yBlank);
    Offset p2 = Offset(
        wImage * inScale * 0.5 + xBlank, hImage * inScale * 0.5 + yBlank);

    canvas.drawLine(p1, p2, paint);
    ////////////////////////////////////////////////////////////////////////////////
  }

  /// 그려야할 정보를 모두 검사해서 틀린 것이 있으면 다시 그리기
  @override
  bool shouldRepaint(MakePainter oldDelegate) {
    // TODO : impl
    // 다시 그려야할 정보 검사

    if (ParentInfo.leftTopOffset.dx != oldDelegate.leftTopOffset.dx)  return true;
    if (ParentInfo.leftTopOffset.dy != oldDelegate.leftTopOffset.dy)  return true;
    if (ParentInfo.rightTopOffset.dx != oldDelegate.rightTopOffset.dx)  return true;
    if (ParentInfo.rightTopOffset.dy != oldDelegate.rightTopOffset.dy)  return true;
    if (ParentInfo.leftBottomOffset.dx != oldDelegate.leftBottomOffset.dx)  return true;
    if (ParentInfo.leftBottomOffset.dy != oldDelegate.leftBottomOffset.dy)  return true;
    if (ParentInfo.rightBottomOffset.dx != oldDelegate.rightBottomOffset.dx)  return true;
    if (ParentInfo.rightBottomOffset.dy != oldDelegate.rightBottomOffset.dy)  return true;

    if (ParentInfo.inScale != oldDelegate.inScale)  return true;
    if (ParentInfo.xStart != oldDelegate.xStart)  return true;
    if (ParentInfo.yStart != oldDelegate.yStart)  return true;
    if (ParentInfo.scale != oldDelegate.scale)  return true;


    return false;
    //return true;
  }

  ////////////////////////////////////////////////////////////////////////////////
  void initParentData() {
    wScreen = ParentInfo.wScreen;
    hScreen = ParentInfo.hScreen;

    wImage = ParentInfo.wImage;
    hImage = ParentInfo.hImage;

    inScale = ParentInfo.inScale;

    xBlank = ParentInfo.xBlank;
    yBlank = ParentInfo.yBlank;

    xStart = ParentInfo.xStart;
    yStart = ParentInfo.yStart;

    scale = ParentInfo.scale;

    leftTopOffset = ParentInfo.leftTopOffset;
    rightTopOffset = ParentInfo.rightTopOffset;
    leftBottomOffset = ParentInfo.leftBottomOffset;
    rightBottomOffset = ParentInfo.rightBottomOffset;
  }
////////////////////////////////////////////////////////////////////////////////
}
