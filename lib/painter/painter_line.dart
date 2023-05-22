import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../config/config_app.dart';
import '../dto/info_parent.dart';
import '../util/util_info.dart';

class LinePainter extends CustomPainter {
  ////////////////////////////////////////////////////////////////////////////////
  double strokeWidth;
  Color? strokeColor;
  bool straight;

  //LinePainter(this.width, this.height, this.strokeWidth, this.strokeColor);
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
      //..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    Offset p1;
    Offset p2;
    double width = size.width;
    double height = size.height;
    double space = 0.2;
    int sw = strokeWidth.toInt();

    if (straight) {
      p1 = Offset(width * space, height * 0.5);
      p2 = Offset(width * (1 - space), height * 0.5);
      //dev.log('$i - p1: $p1 $i - p2: $p2');

      linePaint.strokeWidth = strokeWidth;
      canvas.drawLine(p1, p2, linePaint);

      return;
    }

    double swGap = (size.width * (1 - space * 2) - strokeWidth * 0.5) / sw;
    for (int i = 0, j = sw; i < j; i++) {
      p1 = Offset(width * space + i * swGap, height * 0.5);
      p2 = Offset(p1.dx + swGap, height * 0.5);
      //dev.log('$i - p1: $p1 $i - p2: $p2');

      linePaint.strokeWidth = (i + 1).toDouble();
      canvas.drawLine(p1, p2, linePaint);
    }

    //canvas.drawLine(p1, p2, linePaint);
    ////////////////////////////////////////////////////////////////////////////////
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return true;
  }

}