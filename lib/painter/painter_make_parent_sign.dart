import 'dart:developer' as dev;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mc/config/config_app.dart';
import 'package:svg_path_parser/svg_path_parser.dart';

import '../config/constant_app.dart';
import '../dto/info_dot.dart';
import '../dto/info_shape.dart';
import '../util/util_info.dart';

class MakeParentSignPainter extends CustomPainter {
  ////////////////////////////////////////////////////////////////////////////////
  // wh
  double width;
  double height;

  // line
  List<List<DotInfo>> signLines;
  Color signColor;
  double signWidth;

  // background
  Color? signBackgroundColor;
  ui.Image? shapeBackgroundUiImage;

  // shape
  ShapeInfo? shapeInfo;
  Color? signShapeBorderColor;
  double signShapeBorderWidth;

  ////////////////////////////////////////////////////////////////////////////////

  MakeParentSignPainter(
      this.width,
      this.height,
      this.signLines,
      this.signColor,
      this.signWidth,
      this.signBackgroundColor,
      this.shapeBackgroundUiImage,
      this.shapeInfo,
      this.signShapeBorderColor,
      this.signShapeBorderWidth);

  @override
  void paint(Canvas canvas, Size size) async {
    dev.log('# MakeParentSignPainter paint START');
    dev.log(toString());

    ////////////////////////////////////////////////////////////////////////////////
    // sign 값을 그리는 범위
    Rect whRect = const Offset(0, 0) & Size(width, height);

    Path? shapePath;
    Path? borderPath;
    if (shapeInfo != null) {
      Float64List shapeMatrix = Float64List.fromList(
          [width / AppConfig.SVG_WH, 0, 0, 0,
            0, height / AppConfig.SVG_WH, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1]);
      shapePath = shapeInfo!.path.transform(shapeMatrix);

      Float64List borderMatrix = Float64List.fromList(
          [(width - signShapeBorderWidth * 2) / AppConfig.SVG_WH, 0, 0, 0,
            0, (height - signShapeBorderWidth * 2) / AppConfig.SVG_WH, 0, 0,
            0, 0, 1, 0,
            signShapeBorderWidth, signShapeBorderWidth, 0, 1]);
      borderPath = shapeInfo!.path.transform(borderMatrix);
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // background color
    if (signBackgroundColor != null) {
      Paint backgroundPaint = Paint()
        ..color = signBackgroundColor!;
      if (shapeInfo == null) {
        canvas.drawRect(whRect, backgroundPaint);
      } else {
        if (shapeBackgroundUiImage == null) {
          // 여기서 하면 안됨
          //canvas.drawPath(shapePath!, backgroundPaint);
        }
      }
    }

    // grid
    // background color 다음에 해야 보기 좋음
    Paint gridPaint = Paint()
      ..color = Colors.black38
      ..strokeWidth = 1;
    InfoUtil.drawGrid(canvas, width, height, 0, 0, 0.5, gridPaint);

    // shape
    if (shapeInfo != null) {
      if (signShapeBorderColor != null) {
        Paint shapePaint = Paint()
          ..color = signShapeBorderColor!;
        canvas.drawPath(shapePath!, shapePaint);  // 0 두께일 수 있음

        if (signBackgroundColor == null) {
          Paint shapePaint = Paint()
            ..blendMode = BlendMode.clear;    // transparent
          canvas.drawPath(borderPath!, shapePaint);  // 0 두께일 수 있음
        }
      }
    }

    // background image 또는 background
    if (shapeInfo != null) {
      canvas.clipPath(borderPath!); // path 영역에서만 그리기가 동작함
    }

    if (shapeInfo != null) {
      if (shapeBackgroundUiImage != null) {
        int wShapeBackgroundUiImage = shapeBackgroundUiImage!.width;
        int hShapeBackgroundUiImage = shapeBackgroundUiImage!.height;
        dev.log('shapeBackgroundUiImage w: $wShapeBackgroundUiImage, h: $hShapeBackgroundUiImage');

        canvas.drawImage(shapeBackgroundUiImage!,
            Offset((width - wShapeBackgroundUiImage) / 2, (height - hShapeBackgroundUiImage) / 2), Paint());
      } else {
        if (signBackgroundColor != null) {
          Paint backgroundPaint = Paint()
            ..color = signBackgroundColor!;
          canvas.drawPath(borderPath!, backgroundPaint);
        }
      }
    }



    /*
    // background image
    if (shapeBackgroundUiImage != null) {
      int wShapeBackgroundUiImage = shapeBackgroundUiImage!.width;
      int hShapeBackgroundUiImage = shapeBackgroundUiImage!.height;
      dev.log('shapeBackgroundUiImage w: $wShapeBackgroundUiImage, h: $hShapeBackgroundUiImage');

      canvas.drawImage(shapeBackgroundUiImage!, Offset((width - wShapeBackgroundUiImage) / 2, (height - hShapeBackgroundUiImage) / 2), Paint());
    }
    */



/*
    Path svgPath = parseSvgPath(
        'm12 23.1-1.45-1.608C5.4 15.804 2 12.052 2 7.45 2 3.698 4.42.75 7.5.75c1.74 0 3.41.987 4.5 2.546C13.09 1.736 14.76.75 16.5.75c3.08 0 5.5 2.948 5.5 6.699 0 4.604-3.4 8.355-8.55 14.055L12 23.1z');

    // svg path 를 width/height 에 맞추기
    dev.log('org width/AppConfig.SVG_WH: ${width / AppConfig.SVG_WH}');
    Float64List shapeMatrix = Float64List.fromList(
        [width / AppConfig.SVG_WH, 0, 0, 0, 0, height / AppConfig.SVG_WH, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
    Path shapePath = svgPath.transform(shapeMatrix);

    // background color
    Paint borderPaint = Paint()
      ..color = Colors.green;
    canvas.drawPath(shapePath, borderPaint);


    // border
    Float64List borderMatrix = Float64List.fromList([
      (width - 20) / AppConfig.SVG_WH, 0, 0, 0,
      0, (height - 20) / AppConfig.SVG_WH, 0, 0,
      0, 0, 1, 0,
      10, 10, 0, 1
    ]);
    Path borderPath = svgPath.transform(borderMatrix);
    dev.log('border (width - 20) / AppConfig.SVG_WH: ${(width - 20) / AppConfig.SVG_WH}');

    canvas.clipPath(borderPath); // path 영역에서만 그리기가 동작함

    int? wUiImageShape = shapeBackgroundUiImage?.width;
    int? hUiImageShape = shapeBackgroundUiImage?.height;
    dev.log('shapeBackground w: $wUiImageShape, h: $hUiImageShape');

    if (shapeBackgroundUiImage != null) canvas.drawImage(shapeBackgroundUiImage!, Offset(0, -68 / 2), Paint());
*/
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // sign 값을 그리는 범위
    //Rect whRect = const Offset(0, 0) & Size(width, height);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // sign 그리기
    Paint signPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    double size;
    List<Offset> offsetList = <Offset>[];
    Path path = Path();
    DotInfo dotInfo0; // 첫번째 dot
    for (List<DotInfo> oneLine in signLines) {
      dotInfo0 = oneLine.elementAt(0);
      signPaint.color = dotInfo0.color!;
      size = dotInfo0.size;
//dev.log('--size: $size');
      for (DotInfo dotInfo in oneLine) {
        if (whRect.contains(dotInfo.offset)) {
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
//dev.log('==size: $size');
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
//dev.log('~~~size: $size');
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

    if (oldDelegate.signLines.length != signLines.length) return true;
    if (oldDelegate.signLines.isEmpty && signLines.isEmpty) return true;
    if (oldDelegate.signLines.last.length != signLines.last.length) return true;

    dev.log('# MakeParentSignPainter paint return true');
    //return false;
    return true;
  }

  @override
  String toString() {
    return 'width: $width, height: $height, '
        'signColor: $signColor, signWidth: $signWidth, '
        'signBackgroundColor: $signBackgroundColor, '
        'shapeInfo: $shapeInfo, signShapeBorderColor: $signShapeBorderColor, signShapeBorderWidth: $signShapeBorderWidth';
  }
}
