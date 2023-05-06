import 'dart:developer' as dev;
import 'dart:typed_data';
//import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mc/config/config_app.dart';
import 'package:svg_path_parser/svg_path_parser.dart';

import '../config/constant_app.dart';
import '../dto/info_dot.dart';
import '../util/util_info.dart';

class MakeParentSignPainter extends CustomPainter {

  double width;
  double height;
  List<List<DotInfo>> lines;
  ui.Image? shapeBackground;

  MakeParentSignPainter(this.width, this.height, this.lines, this.shapeBackground);

  @override
  void paint(Canvas canvas, Size size) async {
    // wScreen, hScreen 과 동일
    dev.log('# MakeParentSignPainter paint START');

    ////////////////////////////////////////////////////////////////////////////////
    // grid
    Paint gridPaint = Paint()
      //..color = Colors.red
      ..color = Colors.black38
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;
    //InfoUtil.drawGrid(canvas, width.toDouble(), height.toDouble(), width, height, 1.0, 0,
    //    0, 0.2, gridPaint);
    InfoUtil.drawGrid(canvas, width, height, 0, 0,
        0.5, gridPaint);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // svg 크기 조정
    Path svgPath = parseSvgPath('m12 23.1-1.45-1.608C5.4 15.804 2 12.052 2 7.45 2 3.698 4.42.75 7.5.75c1.74 0 3.41.987 4.5 2.546C13.09 1.736 14.76.75 16.5.75c3.08 0 5.5 2.948 5.5 6.699 0 4.604-3.4 8.355-8.55 14.055L12 23.1z');

    // org
    Float64List shapeMatrix = Float64List.fromList(
        [width / AppConfig.SVG_WH, 0, 0, 0,
          0, height / AppConfig.SVG_WH, 0, 0,
          0, 0, 1, 0,
          0, 0, 0, 1]);
    Path shapePath = svgPath.transform(shapeMatrix);

    //canvas.clipPath(shapePath);   // path 영역에서만 그리기가 동작함

    Paint borderPaint = Paint()
      ..color = Colors.green
    //..color = Colors.black12
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;
    canvas.drawPath(shapePath, borderPaint);
    dev.log('org width / AppConfig.SVG_WH: ${width / AppConfig.SVG_WH}');

    // border
    Float64List borderMatrix = Float64List.fromList(
        [(width - 20) / AppConfig.SVG_WH, 0, 0, 0,
          0, (height - 20) / AppConfig.SVG_WH, 0, 0,
          0, 0, 1, 0,
          10, 10, 0, 1]);
    Path borderPath = svgPath.transform(borderMatrix);
    dev.log('border (width - 20) / AppConfig.SVG_WH: ${(width - 20) / AppConfig.SVG_WH}');

    canvas.clipPath(borderPath);   // path 영역에서만 그리기가 동작함

    int? wUiImageShape = shapeBackground?.width;
    int? hUiImageShape = shapeBackground?.height;
    dev.log('shapeBackground w: $wUiImageShape, h: $hUiImageShape');

    if (shapeBackground != null)
      canvas.drawImage(shapeBackground!, Offset(0, -68 / 2), Paint());

    ////////////////////////////////////////////////////////////////////////////////


    ////////////////////////////////////////////////////////////////////////////////
    // sign 값을 그리는 범위
    Rect rect = const Offset(0, 0) & Size (width, height);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // sign 그리기
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
    // TODO : 체크 안되고 있음...?
    // 다시 그려야할 정보 검사

    if (oldDelegate.lines.length != lines.length)   return true;
    if (oldDelegate.lines.isEmpty && lines.isEmpty)   return true;
    if (oldDelegate.lines.last.length != lines.last.length)   return true;

    dev.log('# MakeParentSignPainter paint return true');
    //return false;
    return true;
  }

}
