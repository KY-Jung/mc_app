import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import '../dto/info_dot.dart';
import '../util/util_info.dart';

class MakeParentSignPainter extends CustomPainter {

  double width;
  double height;
  List<List<DotInfo>> lines;

  MakeParentSignPainter(this.width, this.height, this.lines);

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
    InfoUtil.drawGrid(canvas, width, height, 0, 0,
        0.5, gridPaint);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    Rect rect = const Offset(0, 0) & Size (width, height);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    //
    Paint signPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    double size;
    List<Offset> offsetList = <Offset>[];
    Path path = Path();
    DotInfo dotInfo0;   // 첫번째 dot
    for (List<DotInfo> oneLine in lines) {
      dotInfo0 = oneLine.elementAt(0);
      signPaint.color = dotInfo0.color!;
      size = dotInfo0.size;

      for (DotInfo dotInfo in oneLine) {
        if (rect.contains(dotInfo.offset)) {
          if (dotInfo.size.toInt() == size.toInt()) {
            offsetList.add(dotInfo.offset);
          } else {
            offsetList.add(dotInfo.offset);

            path = Path();
            path.addPolygon(offsetList, false);
            signPaint.strokeWidth = size;
            canvas.drawPath(path, signPaint);

            offsetList.clear();
            offsetList.add(dotInfo.offset);
            size = dotInfo.size;
          }
        } else {
          // 화면을 벗어난 경우
          if (offsetList.isNotEmpty) {
            path = Path();
            path.addPolygon(offsetList, false);
            signPaint.strokeWidth = size;
            canvas.drawPath(path, signPaint);

            offsetList.clear();
          }
          size = dotInfo.size;
        }
      }
      path = Path();
      path.addPolygon(offsetList, false);
      signPaint.strokeWidth = size;
      canvas.drawPath(path, signPaint);

      offsetList.clear();
    }
    ////////////////////////////////////////////////////////////////////////////////

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
