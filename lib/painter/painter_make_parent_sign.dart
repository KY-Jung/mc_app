import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../config/config_app.dart';
import '../dto/info_parent.dart';
import '../util/util_info.dart';

class MakeParentSignPainter extends CustomPainter {

  int width;
  int height;

  MakeParentSignPainter(this.width, this.height);

  /// InteractiveViewer 가 확대/축소될때는 호출되지 않음
  @override
  void paint(Canvas canvas, Size size) {
    // wScreen, hScreen 과 동일
    dev.log('# MakeParentSignPainter paint START');

    ////////////////////////////////////////////////////////////////////////////////
    // grid
    Paint gridPaint = Paint()
      //..color = Colors.red
      ..color = Colors.black12
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;
    //InfoUtil.drawGrid(canvas, width.toDouble(), height.toDouble(), width, height, 1.0, 0,
    //    0, 0.2, gridPaint);
    InfoUtil.drawGrid(canvas, width.toDouble(), height.toDouble(), 0, 0,
        0.5, gridPaint);
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
  bool shouldRepaint(MakeParentSignPainter oldDelegate) {
    // TODO : impl
    // 다시 그려야할 정보 검사

    //return false;
    return true;
  }

}
