import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import '../config/config_app.dart';
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

  Offset? angleGuideOffset;
  double angleGuideRadian;
  ////////////////////////////////////////////////////////////////////////////////

  MakePainter(this.wScreen, this.hScreen, this.wImage, this.hImage, this.inScale,
      this.xBlank, this.yBlank, this.xStart, this.yStart, this.scale, this.angleGuideOffset,
      this.angleGuideRadian);

  /// InteractiveViewer 가 확대/축소될때는 호출되지 않음
  @override
  void paint(Canvas canvas, Size size) {
    // wScreen, hScreen 과 동일
    //dev.log('# MakePainter paint START size: $size');

    ////////////////////////////////////////////////////////////////////////////////
    // grid
    Paint gridPaint = Paint()
      ..color = Colors.white12
      //..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;
    //InfoUtil.drawGrid(canvas, wScreen, hScreen, wImage, hImage, inScale, xBlank,
    //    yBlank, AppConfig.SIZE_GRID_RATIO, gridPaint);
    InfoUtil.drawGrid(canvas, wScreen, hScreen, xBlank, yBlank,
        AppConfig.SIZE_GRID_RATIO, gridPaint);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // for test
    // Paint paint = Paint()
    //   ..color = Colors.deepPurpleAccent
    //   ..strokeCap = StrokeCap.round
    //   ..strokeWidth = 4.0;
    // Offset p1 = Offset(xBlank, yBlank);
    // Offset p2 = Offset(
    //     wImage * inScale * 0.5 + xBlank, hImage * inScale * 0.5 + yBlank);
    //
    // canvas.drawLine(p1, p2, paint);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // angle guide

    //dev.log('222 angleGuideOffset start: $angleGuideOffset');
    if (angleGuideOffset != null) {

      List<Offset> offsetList = InfoUtil.calcAngleGuideOffsetList(size, angleGuideOffset!, angleGuideRadian);
      //dev.log('angleGuideOffset start: $angleGuideOffset');

      Paint angleGuidePaint = Paint()
        ..color = Colors.orange
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1;
      Offset topOffset = offsetList[0];
      Offset bottomOffset = offsetList[1];
      Offset leftOffset = offsetList[2];
      Offset rightOffset = offsetList[3];

      //canvas.drawLine(topOffset, bottomOffset, angleGuidePaint);
      //canvas.drawLine(leftOffset, rightOffset, angleGuidePaint);
      InfoUtil.drawDashedLine(canvas, angleGuidePaint, topOffset, bottomOffset);
      InfoUtil.drawDashedLine(canvas, angleGuidePaint, leftOffset, rightOffset);
    }
    ////////////////////////////////////////////////////////////////////////////////

  }

  /// 그려야할 정보를 모두 검사해서 틀린 것이 있으면 다시 그리기
  @override
  bool shouldRepaint(MakePainter oldDelegate) {
    // TODO : impl
    // 다시 그려야할 정보 검사
/*
    if (ParentInfo.inScale != oldDelegate.inScale)  return true;
    if (ParentInfo.xStart != oldDelegate.xStart)  return true;
    if (ParentInfo.yStart != oldDelegate.yStart)  return true;
    if (ParentInfo.scale != oldDelegate.scale)  return true;
*/

    return false;
    //return true;
  }

}
