import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/config_app.dart';
import '../dto/info_parent.dart';
import '../ui/page_make.dart';

class BracketUtil {

  ////////////////////////////////////////////////////////////////////////////////
  // xyOffset 이 어느 bracket 에 포함되는지 결정할때 사용
  // xyOffset 을 받는다
  // ParentInfo 의 bracket offset 을 가져온다
  // bracket touch 영역에 속하는지 검사한다
  // MakeParentSizePointEnum 으로 반환한다
  static MakeParentResizePointEnum findBracketArea(Offset xyOffset,
      {Canvas? canvas, Paint? cornerPaint, Paint? bracketPaint}) {
    //dev.log('findBracketArea: $xyOffset');

    ////////////////////////////////////////////////////////////////////////////////
    Offset leftTopOffset = ParentInfo.leftTopOffset;
    Offset rightTopOffset = ParentInfo.rightTopOffset;
    Offset leftBottomOffset = ParentInfo.leftBottomOffset;
    Offset rightBottomOffset = ParentInfo.rightBottomOffset;

    double leftTopDiff = 0;
    double rightTopDiff = 0;
    double leftBottomDiff = 0;
    double rightBottomDiff = 0;
    double minDiff = 0;

    Size cornerSize = const Size(AppConfig.SIZE_BRACKET_CORNER_TOUCH,
        AppConfig.SIZE_BRACKET_CORNER_TOUCH);
    late Offset cornerOffset;
    late Rect cornerRect;

    double bracketLength = ParentInfo.wScreen * AppConfig.SIZE_BRACKET_LENGTH;
    if (bracketLength >
        (rightTopOffset.dx - leftTopOffset.dx) * 0.5) {
      bracketLength =
          (rightTopOffset.dx - leftTopOffset.dx) * 0.5;
    }

    Size barSizeH = Size(bracketLength, AppConfig.SIZE_BRACKET_BAR_TOUCH);
    Size barSizeV = Size(AppConfig.SIZE_BRACKET_BAR_TOUCH, bracketLength);
    late Offset barOffset;
    late Rect barRectHv;
    late Offset directionOffset;
    late double direction;
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    leftTopDiff = math.sqrt(math.pow(xyOffset.dx - leftTopOffset.dx, 2) + math.pow(xyOffset.dy - leftTopOffset.dy, 2));
    rightTopDiff = math.sqrt(math.pow(xyOffset.dx - rightTopOffset.dx, 2) + math.pow(xyOffset.dy - rightTopOffset.dy, 2));
    leftBottomDiff = math.sqrt(math.pow(xyOffset.dx - leftBottomOffset.dx, 2) + math.pow(xyOffset.dy - leftBottomOffset.dy, 2));
    rightBottomDiff = math.sqrt(math.pow(xyOffset.dx - rightBottomOffset.dx, 2) + math.pow(xyOffset.dy - rightBottomOffset.dy, 2));

    minDiff = leftTopDiff;
    if (minDiff > rightTopDiff)   minDiff = rightTopDiff;
    if (minDiff > leftBottomDiff)   minDiff = leftBottomDiff;
    if (minDiff > rightBottomDiff)   minDiff = rightBottomDiff;
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    if (minDiff.toInt() == leftTopDiff.toInt()) {
      cornerOffset = Offset(
          leftTopOffset.dx - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.5,           // TODO : 0.2 -> 0.5 로 변경
          leftTopOffset.dy - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.5);
      cornerRect = cornerOffset & cornerSize;
      if (canvas != null && cornerPaint != null) canvas.drawRect(cornerRect, cornerPaint);
      if (cornerRect.contains(xyOffset)) {
        return MakeParentResizePointEnum.LEFTTOP;
      }

      directionOffset = Offset(xyOffset.dx - leftTopOffset.dx, xyOffset.dy - leftTopOffset.dy);
      direction = directionOffset.direction;
      if (direction == 0 || (direction > 0 && direction < math.pi * 0.25) || (direction < 0 && direction > math.pi * -0.75)) {
        barOffset = Offset(
            (leftTopOffset.dx + AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.5),           // TODO : 0.8 -> 0.5 로 변경
            (leftTopOffset.dy - AppConfig.SIZE_BRACKET_BAR_TOUCH * 0.5));           // TODO : 0.2 -> 0.5 로 변경
        barRectHv = barOffset & barSizeH;
        if (canvas != null && bracketPaint != null) canvas.drawRect(barRectHv, bracketPaint);
        if (barRectHv.contains(xyOffset)) {
          return MakeParentResizePointEnum.LEFTTOPH;
        }
      } else {
        barOffset = Offset(
            (leftTopOffset.dx - AppConfig.SIZE_BRACKET_BAR_TOUCH * 0.5),           // TODO : 0.8 -> 0.5 로 변경
            (leftTopOffset.dy + AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.5));           // TODO : 0.2 -> 0.5 로 변경
        barRectHv = barOffset & barSizeV;
        if (canvas != null && bracketPaint != null) canvas.drawRect(barRectHv, bracketPaint);
        if (barRectHv.contains(xyOffset)) {
          return MakeParentResizePointEnum.LEFTTOPV;
        }
      }

    } else if (minDiff.toInt() == rightTopDiff.toInt()) {
      cornerOffset = Offset(
          rightTopOffset.dx - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.5,
          rightTopOffset.dy - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.5);
      cornerRect = cornerOffset & cornerSize;
      if (canvas != null && cornerPaint != null) canvas.drawRect(cornerRect, cornerPaint);
      if (cornerRect.contains(xyOffset)) {
        return MakeParentResizePointEnum.RIGHTTOP;
      }

      directionOffset = Offset(xyOffset.dx - rightTopOffset.dx, xyOffset.dy - rightTopOffset.dy);
      direction = directionOffset.direction;
      if (direction == math.pi || (direction < math.pi && direction > math.pi * 0.75) || (direction > math.pi * -1 && direction < math.pi * -0.25)) {
        barOffset = Offset(
            (rightTopOffset.dx -
                AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.5 - barSizeH.width),
            (rightTopOffset.dy - AppConfig.SIZE_BRACKET_BAR_TOUCH * 0.5));
        barRectHv = barOffset & barSizeH;
        if (canvas != null && bracketPaint != null) canvas.drawRect(barRectHv, bracketPaint);
        if (barRectHv.contains(xyOffset)) {
          return MakeParentResizePointEnum.RIGHTTOPH;
        }
      } else {
        barOffset = Offset(
            (rightTopOffset.dx - AppConfig.SIZE_BRACKET_BAR_TOUCH * 0.5),
            (rightTopOffset.dy + AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.5));
        barRectHv = barOffset & barSizeV;
        if (canvas != null && bracketPaint != null) canvas.drawRect(barRectHv, bracketPaint);
        if (barRectHv.contains(xyOffset)) {
          return MakeParentResizePointEnum.RIGHTTOPV;
        }
      }

    } else if (minDiff.toInt() == leftBottomDiff.toInt()) {
      cornerOffset = Offset(
          leftBottomOffset.dx - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.5,
          leftBottomOffset.dy - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.5);
      cornerRect = cornerOffset & cornerSize;
      if (canvas != null && cornerPaint != null) canvas.drawRect(cornerRect, cornerPaint);
      if (cornerRect.contains(xyOffset)) {
        return MakeParentResizePointEnum.LEFTBOTTOM;
      }

      directionOffset = Offset(xyOffset.dx - leftBottomOffset.dx, xyOffset.dy - leftBottomOffset.dy);
      direction = directionOffset.direction;
      if (direction == 0 || (direction > 0 && direction < math.pi * 0.75) || (direction < 0 && direction > math.pi * -0.25)) {
        barOffset = Offset(
            (leftBottomOffset.dx + AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.5),
            (leftBottomOffset.dy - AppConfig.SIZE_BRACKET_BAR_TOUCH * 0.5));
        barRectHv = barOffset & barSizeH;
        if (canvas != null && bracketPaint != null) canvas.drawRect(barRectHv, bracketPaint);
        if (barRectHv.contains(xyOffset)) {
          return MakeParentResizePointEnum.LEFTBOTTOMH;
        }
      } else {
        barOffset = Offset(
            (leftBottomOffset.dx - AppConfig.SIZE_BRACKET_BAR_TOUCH * 0.5),
            (leftBottomOffset.dy -
                AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.5 - barSizeH.width));
        barRectHv = barOffset & barSizeV;
        if (canvas != null && bracketPaint != null) canvas.drawRect(barRectHv, bracketPaint);
        if (barRectHv.contains(xyOffset)) {
          return MakeParentResizePointEnum.LEFTBOTTOMV;
        }
      }

    } else {
      cornerOffset = Offset(
          rightBottomOffset.dx - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.5,
          rightBottomOffset.dy - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.5);
      cornerRect = cornerOffset & cornerSize;
      if (canvas != null && cornerPaint != null) canvas.drawRect(cornerRect, cornerPaint);
      if (cornerRect.contains(xyOffset)) {
        return MakeParentResizePointEnum.RIGHTBOTTOM;
      }
      directionOffset = Offset(xyOffset.dx - rightBottomOffset.dx, xyOffset.dy - rightBottomOffset.dy);
      direction = directionOffset.direction;
      if (direction == math.pi || (direction < math.pi && direction > math.pi * 0.25) || (direction > math.pi * -1 && direction < math.pi * -0.75)) {
        barOffset = Offset(
            (rightBottomOffset.dx -
                AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.5 - barSizeH.width),
            (rightBottomOffset.dy - AppConfig.SIZE_BRACKET_BAR_TOUCH * 0.5));
        barRectHv = barOffset & barSizeH;
        if (canvas != null && bracketPaint != null) canvas.drawRect(barRectHv, bracketPaint);
        if (barRectHv.contains(xyOffset)) {
          return MakeParentResizePointEnum.RIGHTBOTTOMH;
        }
      } else {
        barOffset = Offset(
            (rightBottomOffset.dx - AppConfig.SIZE_BRACKET_BAR_TOUCH * 0.5),
            (rightBottomOffset.dy -
                AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.5 - barSizeH.width));
        barRectHv = barOffset & barSizeV;
        if (canvas != null && bracketPaint != null) canvas.drawRect(barRectHv, bracketPaint);
        if (barRectHv.contains(xyOffset)) {
          return MakeParentResizePointEnum.RIGHTBOTTOMV;
        }
      }
    }
    ////////////////////////////////////////////////////////////////////////////////

    return MakeParentResizePointEnum.NONE;
    /*
    dev.log('findBracketArea: $xyOffset');

    Offset leftTopOffset = ParentInfo.leftTopOffset;
    Offset rightTopOffset = ParentInfo.rightTopOffset;
    Offset leftBottomOffset = ParentInfo.leftBottomOffset;
    Offset rightBottomOffset = ParentInfo.rightBottomOffset;

    double bracketLength;

    Size cornerSize = const Size(AppConfig.SIZE_BRACKET_CORNER_TOUCH,
        AppConfig.SIZE_BRACKET_CORNER_TOUCH);
    Offset cornerOffset = Offset(
        leftTopOffset.dx - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.2,
        leftTopOffset.dy - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.2);
    Rect cornerRect = cornerOffset & cornerSize;
    if (canvas != null && paint != null) canvas.drawRect(cornerRect, paint);
    if (cornerRect.contains(xyOffset)) {
      if ((xyOffset.dx - leftTopOffset.dx).abs() <
          (xyOffset.dx - rightTopOffset.dx).abs()) {
        if ((xyOffset.dy - leftTopOffset.dy).abs() <
            (xyOffset.dy - leftBottomOffset.dy).abs()) {
          return MakeParentSizePointEnum.LEFTTOP;
        } else {
          return MakeParentSizePointEnum.LEFTBOTTOM;
        }
      } else {
        return MakeParentSizePointEnum.RIGHTTOP;
      }
    }
    cornerOffset = Offset(
        rightTopOffset.dx - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8,
        rightTopOffset.dy - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.2);
    cornerRect = cornerOffset & cornerSize;
    if (canvas != null && paint != null) canvas.drawRect(cornerRect, paint);
    if (cornerRect.contains(xyOffset)) {
      if ((xyOffset.dx - leftTopOffset.dx).abs() <
          (xyOffset.dx - rightTopOffset.dx).abs()) {
        return MakeParentSizePointEnum.LEFTTOP; // unnecessary
      } else {
        if ((xyOffset.dy - rightTopOffset.dy).abs() <
            (xyOffset.dy - rightBottomOffset.dy).abs()) {
          return MakeParentSizePointEnum.RIGHTTOP;
        } else {
          return MakeParentSizePointEnum.RIGHTBOTTOM;
        }
      }
    }
    cornerOffset = Offset(
        leftBottomOffset.dx - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.2,
        leftBottomOffset.dy - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8);
    cornerRect = cornerOffset & cornerSize;
    if (canvas != null && paint != null) canvas.drawRect(cornerRect, paint);
    if (cornerRect.contains(xyOffset)) {
      if ((xyOffset.dx - leftBottomOffset.dx).abs() <
          (xyOffset.dx - rightBottomOffset.dx).abs()) {
        if ((xyOffset.dy - leftTopOffset.dy).abs() <
            (xyOffset.dy - leftBottomOffset.dy).abs()) {
          return MakeParentSizePointEnum.LEFTTOP; // unnecessary
        } else {
          return MakeParentSizePointEnum.LEFTBOTTOM;
        }
      } else {
        return MakeParentSizePointEnum.RIGHTBOTTOM;
      }
    }
    cornerOffset = Offset(
        rightBottomOffset.dx - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8,
        rightBottomOffset.dy - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8);
    cornerRect = cornerOffset & cornerSize;
    if (canvas != null && paint != null) canvas.drawRect(cornerRect, paint);
    if (cornerRect.contains(xyOffset)) {
      if ((xyOffset.dx - leftBottomOffset.dx).abs() <
          (xyOffset.dx - rightBottomOffset.dx).abs()) {
        return MakeParentSizePointEnum.LEFTBOTTOM; // unnecessary
      } else {
        if ((xyOffset.dy - rightTopOffset.dy).abs() <
            (xyOffset.dy - rightBottomOffset.dy).abs()) {
          return MakeParentSizePointEnum.RIGHTTOP; // unnecessary
        } else {
          return MakeParentSizePointEnum.RIGHTBOTTOM;
        }
      }
    }

    Size barSizeH = Size(bracketLength, AppConfig.SIZE_BRACKET_BAR_TOUCH);
    Size barSizeV = Size(AppConfig.SIZE_BRACKET_BAR_TOUCH, bracketLength);
    Offset barOffset = Offset(
        (leftTopOffset.dx + AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8),
        (leftTopOffset.dy - AppConfig.SIZE_BRACKET_BAR_TOUCH * 0.2));
    Rect barRectHv = barOffset & barSizeH;
    if (canvas != null && paint != null) canvas.drawRect(barRectHv, paint);
    if (barRectHv.contains(xyOffset)) {
      if ((xyOffset.dx - leftTopOffset.dx).abs() <
          (xyOffset.dx - rightTopOffset.dx).abs()) {
        return MakeParentSizePointEnum.LEFTTOPH;
      } else {
        return MakeParentSizePointEnum.RIGHTTOPH;
      }
    }
    barOffset = Offset(
        (leftTopOffset.dx - AppConfig.SIZE_BRACKET_BAR_TOUCH * 0.2),
        (leftTopOffset.dy + AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8));
    barRectHv = barOffset & barSizeV;
    if (canvas != null && paint != null) canvas.drawRect(barRectHv, paint);
    if (barRectHv.contains(xyOffset)) {
      if ((xyOffset.dy - leftTopOffset.dy).abs() <
          (xyOffset.dy - leftBottomOffset.dy).abs()) {
        return MakeParentSizePointEnum.LEFTTOPV;
      } else {
        return MakeParentSizePointEnum.LEFTBOTTOMV;
      }
    }

    barOffset = Offset(
        (rightTopOffset.dx -
            AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8 -
            barSizeH.width),
        (rightTopOffset.dy - AppConfig.SIZE_BRACKET_BAR_TOUCH * 0.2));
    barRectHv = barOffset & barSizeH;
    if (canvas != null && paint != null) canvas.drawRect(barRectHv, paint);
    if (barRectHv.contains(xyOffset)) {
      return MakeParentSizePointEnum.RIGHTTOPH;
    }
    barOffset = Offset(
        (rightTopOffset.dx - AppConfig.SIZE_BRACKET_BAR_TOUCH * 0.8),
        (rightTopOffset.dy + AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8));
    barRectHv = barOffset & barSizeV;
    if (canvas != null && paint != null) canvas.drawRect(barRectHv, paint);
    if (barRectHv.contains(xyOffset)) {
      if ((xyOffset.dy - rightTopOffset.dy).abs() <
          (xyOffset.dy - rightBottomOffset.dy).abs()) {
        return MakeParentSizePointEnum.RIGHTTOPV;
      } else {
        return MakeParentSizePointEnum.RIGHTBOTTOMV;
      }
    }

    barOffset = Offset(
        (leftBottomOffset.dx + AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8),
        (leftBottomOffset.dy - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8));
    barRectHv = barOffset & barSizeH;
    if (canvas != null && paint != null) canvas.drawRect(barRectHv, paint);
    if (barRectHv.contains(xyOffset)) {
      if ((xyOffset.dx - leftBottomOffset.dx).abs() <
          (xyOffset.dx - rightBottomOffset.dx).abs()) {
        return MakeParentSizePointEnum.LEFTBOTTOMH;
      } else {
        return MakeParentSizePointEnum.RIGHTBOTTOMH;
      }
    }
    barOffset = Offset(
        (leftBottomOffset.dx - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.2),
        (leftBottomOffset.dy -
            AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8 -
            barSizeH.width));
    barRectHv = barOffset & barSizeV;
    if (canvas != null && paint != null) canvas.drawRect(barRectHv, paint);
    if (barRectHv.contains(xyOffset)) {
      return MakeParentSizePointEnum.LEFTBOTTOMV;
    }

    barOffset = Offset(
        (rightBottomOffset.dx -
            AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8 -
            barSizeH.width),
        (rightBottomOffset.dy - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8));
    barRectHv = barOffset & barSizeH;
    if (canvas != null && paint != null) canvas.drawRect(barRectHv, paint);
    if (barRectHv.contains(xyOffset)) {
      return MakeParentSizePointEnum.RIGHTBOTTOMH;
    }
    barOffset = Offset(
        (rightBottomOffset.dx - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8),
        (rightBottomOffset.dy -
            AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8 -
            barSizeH.width));
    barRectHv = barOffset & barSizeV;
    if (canvas != null && paint != null) canvas.drawRect(barRectHv, paint);
    if (barRectHv.contains(xyOffset)) {
      return MakeParentSizePointEnum.RIGHTBOTTOMV;
    }

    return MakeParentSizePointEnum.NONE;
    */
  }

  // 최소 넓이까지만 shrink 를 허용하기 위해 면적을 구할때 사용
  // xyOffset, MakeParentSizePointEnum 을 받아서 width/height 를 구한다
  // ParentInfo 의 bracket offset 을 가져온다
  // bracket touch 영역에 속하는지 검사한다
  // MakeParentSizePointEnum 으로 반환한다
  static Rect calcBracketRect(
      Offset xyOffset, MakeParentResizePointEnum makeParentSizePointEnum) {

    ////////////////////////////////////////////////////////////////////////////////
    double x = 0.0;
    double y = 0.0;
    double width = 0.0;
    double height = 0.0;

    Offset leftTopOffset = ParentInfo.leftTopOffset;
    Offset rightTopOffset = ParentInfo.rightTopOffset;
    Offset leftBottomOffset = ParentInfo.leftBottomOffset;
    Offset rightBottomOffset = ParentInfo.rightBottomOffset;
    ////////////////////////////////////////////////////////////////////////////////

    switch (makeParentSizePointEnum) {
      case MakeParentResizePointEnum.LEFTTOP:
        x = xyOffset.dx;
        y = xyOffset.dy;
        width = rightTopOffset.dx - x;
        height = rightBottomOffset.dy - y;
        break;
      case MakeParentResizePointEnum.RIGHTTOP:
        x = leftTopOffset.dx;
        y = xyOffset.dy;
        width = xyOffset.dx - leftTopOffset.dx;
        height = leftBottomOffset.dy - y;
        break;
      case MakeParentResizePointEnum.LEFTBOTTOM:
        x = xyOffset.dx;
        y = leftTopOffset.dy;
        width = rightTopOffset.dx - x;
        height = xyOffset.dy - rightTopOffset.dy;
        break;
      case MakeParentResizePointEnum.RIGHTBOTTOM:
        x = leftTopOffset.dx;
        y = leftTopOffset.dy;
        width = xyOffset.dx - leftTopOffset.dx;
        height = xyOffset.dy - leftTopOffset.dy;
        break;

      case MakeParentResizePointEnum.LEFTTOPH:
      case MakeParentResizePointEnum.RIGHTTOPH:
        x = leftTopOffset.dx;
        y = xyOffset.dy;
        width = rightTopOffset.dx - x;
        height = rightBottomOffset.dy - y;
        break;
      case MakeParentResizePointEnum.LEFTTOPV:
      case MakeParentResizePointEnum.LEFTBOTTOMV:
        x = xyOffset.dx;
        y = leftTopOffset.dy;
        width = rightTopOffset.dx - x;
        height = rightBottomOffset.dy - y;
        break;
      case MakeParentResizePointEnum.RIGHTTOPV:
      case MakeParentResizePointEnum.RIGHTBOTTOMV:
        x = leftTopOffset.dx;
        y = leftTopOffset.dy;
        width = xyOffset.dx - leftTopOffset.dx;
        height = rightBottomOffset.dy - y;
        break;
      case MakeParentResizePointEnum.LEFTBOTTOMH:
      case MakeParentResizePointEnum.RIGHTBOTTOMH:
        x = leftTopOffset.dx;
        y = leftTopOffset.dy;
        width = rightTopOffset.dx - leftTopOffset.dx;
        height = xyOffset.dy - leftTopOffset.dy;
        break;
      case MakeParentResizePointEnum.NONE:
        break;
    }
    Rect rect = Offset(x, y) & Size(width, height);

    return rect;
  }

  // ParentInfo 의 bracket offset 을 업데이트할때 사용
  static void updateBracketArea(
      Offset xyOffset, MakeParentResizePointEnum makeParentSizePointEnum) {

    switch (makeParentSizePointEnum) {
      case MakeParentResizePointEnum.LEFTTOP:
        ParentInfo.leftTopOffset = Offset(xyOffset.dx, xyOffset.dy);
        ParentInfo.rightTopOffset =
            Offset(ParentInfo.rightTopOffset.dx, xyOffset.dy);
        ParentInfo.leftBottomOffset =
            Offset(xyOffset.dx, ParentInfo.leftBottomOffset.dy);
        //ParentInfo.rightBottomOffset = Offset(ParentInfo.rightBottomOffset.dx, ParentInfo.rightBottomOffset.dy);
        break;
      case MakeParentResizePointEnum.RIGHTTOP:
        ParentInfo.leftTopOffset =
            Offset(ParentInfo.leftTopOffset.dx, xyOffset.dy);
        ParentInfo.rightTopOffset = Offset(xyOffset.dx, xyOffset.dy);
        //ParentInfo.leftBottomOffset = Offset(ParentInfo.leftBottomOffset.dx, ParentInfo.leftBottomOffset.dy);
        ParentInfo.rightBottomOffset =
            Offset(xyOffset.dx, ParentInfo.rightBottomOffset.dy);
        break;
      case MakeParentResizePointEnum.LEFTBOTTOM:
        ParentInfo.leftTopOffset =
            Offset(xyOffset.dx, ParentInfo.leftTopOffset.dy);
        //ParentInfo.rightTopOffset = Offset(ParentInfo.rightTopOffset.dx, ParentInfo.rightTopOffset.dy);
        ParentInfo.leftBottomOffset = Offset(xyOffset.dx, xyOffset.dy);
        ParentInfo.rightBottomOffset =
            Offset(ParentInfo.rightBottomOffset.dx, xyOffset.dy);
        break;
      case MakeParentResizePointEnum.RIGHTBOTTOM:
        //ParentInfo.leftTopOffset = Offset(ParentInfo.leftTopOffset.dx, ParentInfo.leftTopOffset.dy);
        ParentInfo.rightTopOffset =
            Offset(xyOffset.dx, ParentInfo.rightTopOffset.dy);
        ParentInfo.leftBottomOffset =
            Offset(ParentInfo.leftBottomOffset.dx, xyOffset.dy);
        ParentInfo.rightBottomOffset = Offset(xyOffset.dx, xyOffset.dy);
        break;

      case MakeParentResizePointEnum.LEFTTOPH:
      case MakeParentResizePointEnum.RIGHTTOPH:
        ParentInfo.leftTopOffset =
            Offset(ParentInfo.leftTopOffset.dx, xyOffset.dy);
        ParentInfo.rightTopOffset =
            Offset(ParentInfo.rightTopOffset.dx, xyOffset.dy);
        //ParentInfo.leftBottomOffset = Offset(ParentInfo.leftBottomOffset.dx, xyOffset.dy);
        //ParentInfo.rightBottomOffset = Offset(xyOffset.dx, xyOffset.dy);
        break;
      case MakeParentResizePointEnum.LEFTTOPV:
      case MakeParentResizePointEnum.LEFTBOTTOMV:
        ParentInfo.leftTopOffset =
            Offset(xyOffset.dx, ParentInfo.leftTopOffset.dy);
        //ParentInfo.rightTopOffset = Offset(xyOffset.dx, ParentInfo.rightTopOffset.dy);
        ParentInfo.leftBottomOffset =
            Offset(xyOffset.dx, ParentInfo.leftBottomOffset.dy);
        //ParentInfo.rightBottomOffset = Offset(xyOffset.dx, xyOffset.dy);
        break;
      case MakeParentResizePointEnum.RIGHTTOPV:
      case MakeParentResizePointEnum.RIGHTBOTTOMV:
        //ParentInfo.leftTopOffset = Offset(ParentInfo.leftTopOffset.dx, ParentInfo.leftTopOffset.dy);
        ParentInfo.rightTopOffset =
            Offset(xyOffset.dx, ParentInfo.rightTopOffset.dy);
        //ParentInfo.leftBottomOffset = Offset(ParentInfo.leftBottomOffset.dx, xyOffset.dy);
        ParentInfo.rightBottomOffset =
            Offset(xyOffset.dx, ParentInfo.rightBottomOffset.dy);
        break;

      case MakeParentResizePointEnum.LEFTBOTTOMH:
      case MakeParentResizePointEnum.RIGHTBOTTOMH:
        //ParentInfo.leftTopOffset = Offset(ParentInfo.leftTopOffset.dx, ParentInfo.leftTopOffset.dy);
        //ParentInfo.rightTopOffset = Offset(xyOffset.dx, ParentInfo.rightTopOffset.dy);
        ParentInfo.leftBottomOffset =
            Offset(ParentInfo.leftBottomOffset.dx, xyOffset.dy);
        ParentInfo.rightBottomOffset =
            Offset(ParentInfo.rightBottomOffset.dx, xyOffset.dy);
        break;
      case MakeParentResizePointEnum.NONE:
        break;
    }

  }

  // bracket 간에 침범할 수 없는 영역을 순식간에 넘어갔는지 검사
  static bool checkBracketCross(
      Offset xyOffset, MakeParentResizePointEnum makeParentSizePointEnum) {

    ////////////////////////////////////////////////////////////////////////////////
    Offset leftTopOffset = ParentInfo.leftTopOffset;
    Offset rightTopOffset = ParentInfo.rightTopOffset;
    Offset leftBottomOffset = ParentInfo.leftBottomOffset;
    Offset rightBottomOffset = ParentInfo.rightBottomOffset;
    ////////////////////////////////////////////////////////////////////////////////

    switch (makeParentSizePointEnum) {
      case MakeParentResizePointEnum.LEFTTOP:
        if (xyOffset.dx >= rightTopOffset.dx ||
            xyOffset.dy >= rightBottomOffset.dy) {
          dev.log('checkBracketCross: LEFTTOP');
          return false;
        } else {
          return true;
        }
      case MakeParentResizePointEnum.RIGHTTOP:
        if (xyOffset.dx <= leftTopOffset.dx ||
            xyOffset.dy >= leftBottomOffset.dy) {
          dev.log('checkBracketCross: RIGHTTOP');
          return false;
        } else {
          return true;
        }
      case MakeParentResizePointEnum.LEFTBOTTOM:
        if (xyOffset.dx >= rightBottomOffset.dx ||
            xyOffset.dy <= rightTopOffset.dy) {
          dev.log('checkBracketCross: LEFTBOTTOM');
          return false;
        } else {
          return true;
        }
      case MakeParentResizePointEnum.RIGHTBOTTOM:
        if (xyOffset.dx <= leftBottomOffset.dx ||
            xyOffset.dy <= leftTopOffset.dy) {
          dev.log('checkBracketCross: RIGHTBOTTOM');
          return false;
        } else {
          return true;
        }

      case MakeParentResizePointEnum.LEFTTOPH:
      case MakeParentResizePointEnum.RIGHTTOPH:
        if (xyOffset.dy >= leftBottomOffset.dy) {
          dev.log('checkBracketCross: LEFTTOPH');
          return false;
        } else {
          return true;
        }
      case MakeParentResizePointEnum.LEFTTOPV:
      case MakeParentResizePointEnum.LEFTBOTTOMV:
        if (xyOffset.dx >= rightBottomOffset.dx) {
          dev.log('checkBracketCross: LEFTTOPV');
          return false;
        } else {
          return true;
        }
      case MakeParentResizePointEnum.RIGHTTOPV:
      case MakeParentResizePointEnum.RIGHTBOTTOMV:
        if (xyOffset.dx <= leftBottomOffset.dx) {
          dev.log('checkBracketCross: RIGHTTOPV');
          return false;
        } else {
          return true;
        }
      case MakeParentResizePointEnum.LEFTBOTTOMH:
      case MakeParentResizePointEnum.RIGHTBOTTOMH:
        if (xyOffset.dy <= leftTopOffset.dy) {
          dev.log('checkBracketCross: LEFTBOTTOMH');
          return false;
        } else {
          return true;
        }
      case MakeParentResizePointEnum.NONE:
        return false;
    }
  }

  // blank 영역으로 넘어가는지 체크
  static bool checkBlankArea(
      Offset xyOffset, MakeParentResizePointEnum makeParentSizePointEnum) {

    switch (makeParentSizePointEnum) {
      case MakeParentResizePointEnum.LEFTTOP:
        if (xyOffset.dx < ParentInfo.xBlank ||
            xyOffset.dy < ParentInfo.yBlank) {
          //dev.log('checkBlankArea: LEFTTOP');
          return false;
        } else {
          return true;
        }
      case MakeParentResizePointEnum.RIGHTTOP:
        if (xyOffset.dx > ParentInfo.wScreen - ParentInfo.xBlank ||
            xyOffset.dy < ParentInfo.yBlank) {
          //dev.log('checkBlankArea: RIGHTTOP');
          return false;
        } else {
          return true;
        }
      case MakeParentResizePointEnum.LEFTBOTTOM:
        if (xyOffset.dx < ParentInfo.xBlank ||
            xyOffset.dy > ParentInfo.hScreen - ParentInfo.yBlank) {
          //dev.log('checkBlankArea: LEFTBOTTOM');
          return false;
        } else {
          return true;
        }
      case MakeParentResizePointEnum.RIGHTBOTTOM:
        if (xyOffset.dx > ParentInfo.wScreen - ParentInfo.xBlank ||
            xyOffset.dy > ParentInfo.hScreen - ParentInfo.yBlank) {
          //dev.log('checkBlankArea: RIGHTBOTTOM');
          return false;
        } else {
          return true;
        }
      case MakeParentResizePointEnum.LEFTTOPH:
      case MakeParentResizePointEnum.RIGHTTOPH:
        if (xyOffset.dy < ParentInfo.yBlank) {
          //dev.log('checkBlankArea: LEFTTOPH');
          return false;
        } else {
          return true;
        }
      case MakeParentResizePointEnum.LEFTTOPV:
      case MakeParentResizePointEnum.LEFTBOTTOMV:
        if (xyOffset.dx < ParentInfo.xBlank) {
          //dev.log('checkBlankArea: LEFTTOPV');
          return false;
        } else {
          return true;
        }
      case MakeParentResizePointEnum.RIGHTTOPV:
      case MakeParentResizePointEnum.RIGHTBOTTOMV:
        if (xyOffset.dx > ParentInfo.wScreen - ParentInfo.xBlank) {
          //dev.log('checkBlankArea: RIGHTTOPV');
          return false;
        } else {
          return true;
        }
      case MakeParentResizePointEnum.LEFTBOTTOMH:
      case MakeParentResizePointEnum.RIGHTBOTTOMH:
        if (xyOffset.dy > ParentInfo.hScreen - ParentInfo.yBlank) {
          //dev.log('checkBlankArea: LEFTBOTTOMH');
          return false;
        } else {
          return true;
        }
      case MakeParentResizePointEnum.NONE:
        return true;
    }
  }

  // grid 에 붙여도 되는지 검사하여 grid 에 붙은 offset 반환
  static Offset stickyBracketOffset(
      Offset xyOffset,
      double wScreen,
      double xBlank,
      double hScreen,
      double yBlank,
      double wDivideRatio,
      double hDivideRatio,
      double stickyRatio,
      MakeParentResizePointEnum makeParentSizePointEnum) {

    ////////////////////////////////////////////////////////////////////////////////
    double x = xyOffset.dx;
    double y = xyOffset.dy;
    double xNew = 0;
    double yNew = 0;

    double wGap = (wScreen - xBlank * 2) * wDivideRatio;
    double wMax = wGap * stickyRatio - wGap * 0.5; // 10 gap + 0.9 ratio --> 4
    double hGap = (hScreen - yBlank * 2) * hDivideRatio;
    double hMax = hGap * stickyRatio - hGap * 0.5;

    double wRemain = (x - xBlank) % wGap;
    double hRemain = (y - yBlank) % hGap;
    double wDiff = (wGap * 0.5) - wRemain;
    double hDiff = (hGap * 0.5) - hRemain;
    ////////////////////////////////////////////////////////////////////////////////

    if (wDiff.abs() > wMax) {
      if (wDiff < 0) {
        xNew = wGap * ((x - xBlank) ~/ wGap + 1) + xBlank;
      } else {
        xNew = ((x - xBlank) ~/ wGap) * wGap + xBlank;
      }
    } else {
      xNew = x;
    }
    if (hDiff.abs() > hMax) {
      if (hDiff < 0) {
        yNew = hGap * ((y - yBlank) ~/ hGap + 1) + yBlank;
      } else {
        yNew = ((y - yBlank) ~/ hGap) * hGap + yBlank;
      }
    } else {
      yNew = y;
    }

    switch (makeParentSizePointEnum) {
      case MakeParentResizePointEnum.LEFTTOP:
        break;
      case MakeParentResizePointEnum.RIGHTTOP:
        break;
      case MakeParentResizePointEnum.LEFTBOTTOM:
        break;
      case MakeParentResizePointEnum.RIGHTBOTTOM:
        break;
      case MakeParentResizePointEnum.LEFTTOPH:
      case MakeParentResizePointEnum.RIGHTTOPH:
        xNew = x;
        break;
      case MakeParentResizePointEnum.LEFTTOPV:
      case MakeParentResizePointEnum.LEFTBOTTOMV:
        yNew = y;
        break;
      case MakeParentResizePointEnum.RIGHTTOPV:
      case MakeParentResizePointEnum.RIGHTBOTTOMV:
        yNew = y;
        break;
      case MakeParentResizePointEnum.LEFTBOTTOMH:
      case MakeParentResizePointEnum.RIGHTBOTTOMH:
        xNew = x;
        break;
      case MakeParentResizePointEnum.NONE:
        break;
    }

    return Offset(xNew, yNew);
  }

}
