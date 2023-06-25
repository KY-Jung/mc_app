import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import '../config/config_app.dart';
import '../util/util_info.dart';

class MakeParentResizePainter extends CustomPainter {
  /*
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

  MakeParentResizePainter(this.wScreen, this.hScreen, this.wImage, this.hImage, this.inScale,
      this.xBlank, this.yBlank, this.xStart, this.yStart, this.scale,
      this.leftTopOffset, this.rightTopOffset, this.leftBottomOffset, this.rightBottomOffset);
  */
  ////////////////////////////////////////////////////////////////////////////////
  double wScreen;
  double hScreen;

  int wImage;
  int hImage;

  double inScale;

  double xBlank;
  double yBlank;

  double xStart;
  double yStart;

  double scale;

  Offset leftTopOffset;
  Offset rightTopOffset;
  Offset leftBottomOffset;
  Offset rightBottomOffset;
  ////////////////////////////////////////////////////////////////////////////////

  MakeParentResizePainter({
    required this.wScreen,
    required this.hScreen,
    required this.wImage,
    required this.hImage,
    required this.inScale,
    required this.xBlank,
    required this.yBlank,
    required this.xStart,
    required this.yStart,
    required this.scale,
    required this.leftTopOffset,
    required this.rightTopOffset,
    required this.leftBottomOffset,
    required this.rightBottomOffset,
  });

  /// InteractiveViewer 가 확대/축소될때는 호출되지 않음
  @override
  void paint(Canvas canvas, Size size) {
    // wScreen, hScreen 과 동일
    dev.log('# MakeParentResizePainter paint START');

    ////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    double bracketWidth = AppConfig.SIZE_BRACKET_WIDTH;
    double bracketLength;
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // grid
    Paint gridPaint = Paint()
      ..color = Colors.white30
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;
    InfoUtil.drawGrid(canvas, wScreen, hScreen, xBlank, yBlank,
        AppConfig.SIZE_GRID_RATIO, gridPaint);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // bracket
    Paint bracketPaint = Paint()
      ..color = Colors.white60
      ..strokeCap = StrokeCap.round
      ..strokeWidth = bracketWidth;
    // 최소치 검사
    double minArea = (wScreen - xBlank * 2) *
        (hScreen - yBlank * 2) *
        AppConfig.SIZE_SHRINK_MIN;
    double updateArea = (rightTopOffset.dx - leftTopOffset.dx) *
        (rightBottomOffset.dy - rightTopOffset.dy);
    //dev.log('--wScreen $wScreen, xBlank $xBlank, ');
    //dev.log('--hScreen $hScreen, yBlank $yBlank, ');
    //dev.log('--(wScreen - xBlank) ${ (wScreen - xBlank)}, (hScreen - yBlank) ${(hScreen - yBlank)}, ');
    //dev.log('--rightTopOffset.dx ${rightTopOffset.dx}, leftTopOffset.dx ${leftTopOffset.dx}, ');
    //dev.log('--rightBottomOffset.dy ${rightBottomOffset.dy}, rightTopOffset.dy ${rightTopOffset.dy}, ');
    //dev.log('--(rightTopOffset.dx - leftTopOffset.dx) ${ (rightTopOffset.dx - leftTopOffset.dx)}, (rightBottomOffset.dy - rightTopOffset.dy) ${(rightBottomOffset.dy - rightTopOffset.dy)}, ');
    //dev.log('--minArea $minArea, updateArea $updateArea, ');

    if (minArea >= updateArea * 0.9) {
      // 정확히 하면 catch 안됨
      bracketPaint.color = Colors.yellowAccent;
    }

    Offset leftTop = Offset(leftTopOffset.dx + bracketWidth / 2,
        leftTopOffset.dy + bracketWidth / 2);
    Offset rightTop = Offset(rightTopOffset.dx - bracketWidth / 2,
        rightTopOffset.dy + bracketWidth / 2);
    Offset leftBottom = Offset(leftBottomOffset.dx + bracketWidth / 2,
        leftBottomOffset.dy - bracketWidth / 2);
    Offset rightBottom = Offset(rightBottomOffset.dx - bracketWidth / 2,
        rightBottomOffset.dy - bracketWidth / 2);
    bracketLength = wScreen * AppConfig.SIZE_BRACKET_LENGTH;
    if (bracketLength > (rightTop.dx - leftTop.dx) * 0.5) {
      bracketLength = (rightTop.dx - leftTop.dx) * 0.5;
    }

    Offset leftTopH = Offset(leftTop.dx + bracketLength, leftTop.dy);
    Offset leftTopV = Offset(leftTop.dx, leftTop.dy + bracketLength);
    canvas.drawLine(leftTop, leftTopH, bracketPaint);
    canvas.drawLine(leftTop, leftTopV, bracketPaint);

    Offset rightTopH = Offset(rightTop.dx - bracketLength, rightTop.dy);
    Offset rightTopV = Offset(rightTop.dx, rightTop.dy + bracketLength);
    canvas.drawLine(rightTop, rightTopH, bracketPaint);
    canvas.drawLine(rightTop, rightTopV, bracketPaint);

    Offset leftBottomH = Offset(leftBottom.dx + bracketLength, leftBottom.dy);
    Offset leftBottomV = Offset(leftBottom.dx, leftBottom.dy - bracketLength);
    canvas.drawLine(leftBottom, leftBottomH, bracketPaint);
    canvas.drawLine(leftBottom, leftBottomV, bracketPaint);

    Offset rightBottomH =
        Offset(rightBottom.dx - bracketLength, rightBottom.dy);
    Offset rightBottomV =
        Offset(rightBottom.dx, rightBottom.dy - bracketLength);
    canvas.drawLine(rightBottom, rightBottomH, bracketPaint);
    canvas.drawLine(rightBottom, rightBottomV, bracketPaint);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // unselected
    Paint unselectedPaint = Paint()
      ..color = Colors.black54
      //..color = Colors.yellow
      ..strokeWidth = 1;
    Rect leftRect = Offset(xBlank, yBlank) &
        Size(leftTopOffset.dx - xBlank, hScreen - yBlank * 2);
    //dev.log('# leftRect $leftRect');
    canvas.drawRect(leftRect, unselectedPaint);
    Rect rightRect = Offset(rightTopOffset.dx, yBlank) &
        Size(wScreen - xBlank * 2 - (rightTopOffset.dx - xBlank),
            hScreen - yBlank * 2);
    //dev.log('# rightRect $rightRect');
    canvas.drawRect(rightRect, unselectedPaint);
    Rect topRect = Offset(leftTopOffset.dx, yBlank) &
        Size(rightTopOffset.dx - leftTopOffset.dx, leftTopOffset.dy - yBlank);
    //dev.log('# topRect $topRect');
    canvas.drawRect(topRect, unselectedPaint);
    Rect bottomRect = Offset(leftBottomOffset.dx, leftBottomOffset.dy) &
        Size(rightBottomOffset.dx - leftBottomOffset.dx,
            hScreen - yBlank - rightBottomOffset.dy);
    //dev.log('# bottomRect $bottomRect');
    canvas.drawRect(bottomRect, unselectedPaint);
    ////////////////////////////////////////////////////////////////////////////////

    /*
    ////////////////////////////////////////////////////////////////////////////////
    // for test
    Paint testPaint = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;
    Paint testPaint2 = Paint()
      ..color = Colors.yellow
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;
    MakeParentSizePointEnum makeParentSizeEnum =
          BracketUtil.findBracketArea(ParentInfo.xyOffset, canvas: canvas, cornerPaint: testPaint, bracketPaint: testPaint2);
      dev.log('findBracketArea makeParentSizeEnum: $makeParentSizeEnum');
    ////////////////////////////////////////////////////////////////////////////////
    */
  }

  /// 그려야할 정보를 모두 검사해서 틀린 것이 있으면 다시 그리기
  @override
  bool shouldRepaint(MakeParentResizePainter oldDelegate) {
    // 다시 그려야할 정보 검사
/*
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
*/

    dev.log('# MakeParentResizePainter shouldRepaint return false');
    //return false;
    return true;
  }

}
