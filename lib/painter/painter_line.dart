import 'dart:developer' as dev;

import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  ////////////////////////////////////////////////////////////////////////////////
  double strokeWidth;
  Color? strokeColor;
  bool straight;

  LinePainter(this.strokeWidth, this.strokeColor, {this.straight = true});
  ////////////////////////////////////////////////////////////////////////////////

  @override
  void paint(Canvas canvas, Size size) {
    dev.log('# LinePainter paint START');

    dev.log('# LinePainter size: $size');

    ////////////////////////////////////////////////////////////////////////////////
    // 사전 체크
    if (strokeColor == null)  return;

    if (strokeColor == Colors.white) {
      strokeColor = Colors.grey;
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // grid
    Paint linePaint = Paint()
      ..color = strokeColor!
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    Offset p1;
    Offset p2;
    double width = size.width;
    double height = size.height;
    double space = 0.2;
    int sw = strokeWidth.toInt();

    // border 인 경우
    if (straight) {
      p1 = Offset(width * space, height * 0.5);
      p2 = Offset(width * (1 - space), height * 0.5);
      //dev.log('$i - p1: $p1 $i - p2: $p2');

      linePaint.strokeWidth = strokeWidth;
      //dev.log('== ${linePaint.strokeWidth}');
      if (strokeWidth != 0) {
        canvas.drawLine(p1, p2, linePaint);
      }

      return;
    }

    // sign 인 경우
    double swGap = (size.width * (1 - space * 2) - strokeWidth * 0.5) / sw;
    for (int i = 0, j = sw; i < j; i++) {
      p1 = Offset(width * space + i * swGap, height * 0.5);
      p2 = Offset(p1.dx + swGap, height * 0.5);
      //dev.log('$i - p1: $p1 $i - p2: $p2');

      linePaint.strokeWidth = (i + 1).toDouble();
      //dev.log('==$i - linePaint.strokeWidth');
      canvas.drawLine(p1, p2, linePaint);
    }
    ////////////////////////////////////////////////////////////////////////////////
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return true;
  }

}
