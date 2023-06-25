import 'dart:developer' as dev;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mc/config/config_app.dart';

import '../dto/info_dot.dart';
import '../dto/info_shapefile.dart';
import '../util/util_info.dart';

class MakeSignPainter extends CustomPainter {
  ////////////////////////////////////////////////////////////////////////////////
  // wh
  double width;
  double height;

  // sign
  ui.Image? signUiImage;

  // line
  List<List<DotInfo>> signLines;
  Color signColor;
  double signWidth;

  // background
  Color? signBackgroundColor;
  ui.Image? shapeBackgroundUiImage;

  // shape
  ShapeFileInfo? shapeFileInfo;
  Color? signShapeBorderColor;
  double signShapeBorderWidth;

  bool grid;
  ////////////////////////////////////////////////////////////////////////////////

  MakeSignPainter(
      this.width,
      this.height,
      this.signLines,
      this.signColor,
      this.signWidth,
      this.signBackgroundColor,
      this.shapeBackgroundUiImage,
      this.shapeFileInfo,
      this.signShapeBorderColor,
      this.signShapeBorderWidth,
      this.signUiImage,
      {this.grid = true});

  @override
  void paint(Canvas canvas, Size size) {
    dev.log('# MakeSignPainter paint START');
    dev.log(toString());

    ////////////////////////////////////////////////////////////////////////////////
    // sign 값을 그리는 범위
    Rect whRect = const Offset(0, 0) & Size(width, height);

    Path? shapePath;
    Path? borderPath;
    if (shapeFileInfo != null) {
      Float64List shapeMatrix = Float64List.fromList(
          [width / AppConfig.SVG_WH, 0, 0, 0, 0, height / AppConfig.SVG_WH, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
      shapePath = shapeFileInfo!.path.transform(shapeMatrix);

      Float64List borderMatrix = Float64List.fromList([
        (width - signShapeBorderWidth * 2) / AppConfig.SVG_WH,
        0,
        0,
        0,
        0,
        (height - signShapeBorderWidth * 2) / AppConfig.SVG_WH,
        0,
        0,
        0,
        0,
        1,
        0,
        signShapeBorderWidth,
        signShapeBorderWidth,
        0,
        1
      ]);
      borderPath = shapeFileInfo!.path.transform(borderMatrix);
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // background color
    if (signBackgroundColor != null) {
      Paint backgroundPaint = Paint()..color = signBackgroundColor!;
      if (shapeFileInfo == null) {
        canvas.drawRect(whRect, backgroundPaint);
      } else {
        if (shapeBackgroundUiImage == null) {
          // 여기서 하면 안됨
          //canvas.drawPath(shapePath!, backgroundPaint);
        }
      }
    }

    if (grid) {
      // grid
      // background color 다음에 해야 보기 좋음
      Paint gridPaint = Paint()
        ..color = Colors.black38
        ..strokeWidth = 1;
      InfoUtil.drawGrid(canvas, width, height, 0, 0, 0.5, gridPaint);
    }

    // shape
    if (shapeFileInfo != null) {
      if (signShapeBorderColor != null) {
        Paint shapePaint = Paint()..color = signShapeBorderColor!;
        canvas.drawPath(shapePath!, shapePaint); // 0 두께일 수 있음

        if (signBackgroundColor == null) {
          Paint shapePaint = Paint()..blendMode = BlendMode.clear; // transparent
          canvas.drawPath(borderPath!, shapePaint); // 0 두께일 수 있음
        }
      }
    }

    // background image 또는 background
    if (shapeFileInfo != null) {
      canvas.clipPath(borderPath!); // path 영역에서만 그리기가 동작함
    }

    if (shapeFileInfo != null) {
      if (shapeBackgroundUiImage != null) {
        int wShapeBackgroundUiImage = shapeBackgroundUiImage!.width;
        int hShapeBackgroundUiImage = shapeBackgroundUiImage!.height;
        dev.log('shapeBackgroundUiImage w: $wShapeBackgroundUiImage, h: $hShapeBackgroundUiImage');

        //canvas.drawImage(shapeBackgroundUiImage!,
        //    Offset((width - wShapeBackgroundUiImage) / 2, (height - hShapeBackgroundUiImage) / 2), Paint());
        Rect shapeBackgroundUiImageRect =
            Offset((width - wShapeBackgroundUiImage) / -2, (height - hShapeBackgroundUiImage) / -2) &
                Size(width, height);
        canvas.drawImageRect(shapeBackgroundUiImage!, shapeBackgroundUiImageRect, whRect, Paint());
      } else {
        if (signBackgroundColor != null) {
          Paint backgroundPaint = Paint()..color = signBackgroundColor!;
          canvas.drawPath(borderPath!, backgroundPaint);
        }
      }
    } else {
      if (shapeBackgroundUiImage != null) {
        int wShapeBackgroundUiImage = shapeBackgroundUiImage!.width;
        int hShapeBackgroundUiImage = shapeBackgroundUiImage!.height;
        dev.log('shapeBackgroundUiImage w: $wShapeBackgroundUiImage, h: $hShapeBackgroundUiImage');

        //canvas.drawImage(shapeBackgroundUiImage!,
        //    Offset((width - wShapeBackgroundUiImage) / 2, (height - hShapeBackgroundUiImage) / 2), Paint());
        Rect shapeBackgroundUiImageRect =
            Offset((width - wShapeBackgroundUiImage) / -2, (height - hShapeBackgroundUiImage) / -2) &
                Size(width, height);
        canvas.drawImageRect(shapeBackgroundUiImage!, shapeBackgroundUiImageRect, whRect, Paint());
      } else {
        if (signBackgroundColor != null) {
          Paint backgroundPaint = Paint()..color = signBackgroundColor!;
          //canvas.drawPath(borderPath!, backgroundPaint);
          canvas.drawRect(whRect, backgroundPaint);
        }
      }
      // 전체를 덮어썼기 때문에 다시 그려줌
      if (grid) {
        // grid
        // background color 다음에 해야 보기 좋음
        Paint gridPaint = Paint()
          ..color = Colors.black38
          ..strokeWidth = 1;
        InfoUtil.drawGrid(canvas, width, height, 0, 0, 0.5, gridPaint);
      }
    }

    if (signUiImage != null) {
      canvas.drawImage(signUiImage!, const Offset(0, 0), Paint());
    }

    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // sign 그리기
    Paint signPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    double dotWidth;
    List<Offset> offsetList = <Offset>[];
    Path path = Path();
    DotInfo dotInfo0; // 첫번째 dot
    for (List<DotInfo> oneLine in signLines) {
      dotInfo0 = oneLine.elementAt(0);
      signPaint.color = dotInfo0.color!;
      dotWidth = dotInfo0.size;
//dev.log('--dotWidth: $dotWidth');
      for (DotInfo dotInfo in oneLine) {
        if (whRect.contains(dotInfo.offset)) {
          if (dotInfo.size.toInt() == dotWidth.toInt()) {
            offsetList.add(dotInfo.offset);
          } else {
            offsetList.add(dotInfo.offset);

            path = Path();
            path.addPolygon(offsetList, false);
            signPaint.strokeWidth = dotWidth;
            canvas.drawPath(path, signPaint);

            offsetList.clear();
            offsetList.add(dotInfo.offset);
            dotWidth = dotInfo.size;
//dev.log('==dotWidth: $dotWidth');
          }
        } else {
          // 화면을 벗어난 경우
          if (offsetList.isNotEmpty) {
            path = Path();
            path.addPolygon(offsetList, false);
            signPaint.strokeWidth = dotWidth;
            canvas.drawPath(path, signPaint);

            offsetList.clear();
          }
          dotWidth = dotInfo.size;
        }
      }
      path = Path();
      path.addPolygon(offsetList, false);
      signPaint.strokeWidth = dotWidth;
//dev.log('~~~dotWidth: $dotWidth');
      canvas.drawPath(path, signPaint);

      offsetList.clear();
    }
    ////////////////////////////////////////////////////////////////////////////////
  }

  /// 그려야할 정보를 모두 검사해서 틀린 것이 있으면 다시 그리기
  @override
  bool shouldRepaint(MakeSignPainter oldDelegate) {
    // TODO : 체크 안되고 있음...?
    // 다시 그려야할 정보 검사

    if (oldDelegate.signLines.length != signLines.length) return true;
    if (oldDelegate.signLines.isEmpty && signLines.isEmpty) return true;
    if (oldDelegate.signLines.last.length != signLines.last.length) return true;

    dev.log('# MakeSignPainter paint return true');
    //return false;
    return true;
  }

  @override
  String toString() {
    return 'width: $width, height: $height, '
        'signColor: $signColor, signWidth: $signWidth, '
        'signBackgroundColor: $signBackgroundColor, '
        'shapeFileInfo: $shapeFileInfo, signShapeBorderColor: $signShapeBorderColor, signShapeBorderWidth: $signShapeBorderWidth';
  }

}
