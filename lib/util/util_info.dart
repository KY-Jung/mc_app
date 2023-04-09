import 'dart:developer' as dev;
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mc/config/constant_app.dart';

import '../config/config_app.dart';
import '../dto/info_parent.dart';
import '../ui/screen_make.dart';

class InfoUtil {
  ////////////////////////////////////////////////////////////////////////////////
  static Future setParentInfo(path) async {
    dev.log('setParentInfo path: $path');
    ParentInfo.path = path;

    ui.Image uiImage = await InfoUtil.loadUiImage(path);

    /// Parent 이미지 크기
    ParentInfo.wImage = uiImage.width;
    ParentInfo.hImage = uiImage.height;
    dev.log('wImage: ${uiImage.width}, hImage: ${uiImage.height}');

    /// Parent 이미지가 InteractiveViewer 에 맞추어진 ratio 구하기
    double inScale = InfoUtil.calcFitRatioIn(
        ParentInfo.wScreen, ParentInfo.hScreen, uiImage.width, uiImage.height);
    ParentInfo.inScale = inScale;
    dev.log('inScale: $inScale');

    // blank
    if (ParentInfo.inScale < 1.0) {
      // 화면보다 큰 이미지인 경우
      double wReal = uiImage.width * inScale;
      double hReal = uiImage.height * inScale;
      dev.log('wReal: $wReal, hReal: $hReal');
      if ((ParentInfo.wScreen - wReal) > (ParentInfo.hScreen - hReal)) {
        ParentInfo.xBlank = (ParentInfo.wScreen - wReal) / 2;
        ParentInfo.yBlank = 0;
      } else {
        ParentInfo.yBlank = (ParentInfo.hScreen - hReal) / 2;
        ParentInfo.xBlank = 0;
      }
    } else {
      // 화면보다 작은 이미지인 경우
      ParentInfo.xBlank = (ParentInfo.wScreen - uiImage.width) * 0.5;
      ParentInfo.yBlank = (ParentInfo.hScreen - uiImage.height) * 0.5;
    }
    dev.log('xBlank: ${ParentInfo.xBlank}, yBlank: ${ParentInfo.yBlank}');

    // offset
    initParentInfoBracket();
  }

  static void initParentInfoBracket() {
    // offset
    ParentInfo.leftTopOffset = Offset(ParentInfo.xBlank, ParentInfo.yBlank);
    ParentInfo.rightTopOffset =
        Offset(ParentInfo.wScreen - ParentInfo.xBlank, ParentInfo.yBlank);
    ParentInfo.leftBottomOffset =
        Offset(ParentInfo.xBlank, ParentInfo.hScreen - ParentInfo.yBlank);
    ParentInfo.rightBottomOffset = Offset(
        ParentInfo.wScreen - ParentInfo.xBlank,
        ParentInfo.hScreen - ParentInfo.yBlank);
  }

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  static MakeParentSizePointEnum findBracketArea(Offset xyOffset,
      {Canvas? canvas, Paint? paint}) {
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
      if ((xyOffset.dx - ParentInfo.leftTopOffset.dx).abs() < (xyOffset.dx - ParentInfo.rightTopOffset.dx).abs()) {
        if ((xyOffset.dy - ParentInfo.leftTopOffset.dy).abs() < (xyOffset.dy - ParentInfo.leftBottomOffset.dy).abs()) {
          return MakeParentSizePointEnum.LEFTTOP;
        } else {
          return MakeParentSizePointEnum.LEFTBOTTOM;
        }
      } else {
        return MakeParentSizePointEnum.RIGHTTOP;
      }
      //return MakeParentSizePointEnum.LEFTTOP;
    }
    cornerOffset = Offset(
        rightTopOffset.dx - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8,
        rightTopOffset.dy - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.2);
    cornerRect = cornerOffset & cornerSize;
    if (canvas != null && paint != null) canvas.drawRect(cornerRect, paint);
    if (cornerRect.contains(xyOffset)) {
      if ((xyOffset.dx - ParentInfo.leftTopOffset.dx).abs() < (xyOffset.dx - ParentInfo.rightTopOffset.dx).abs()) {
        return MakeParentSizePointEnum.LEFTTOP;   // unnecessary
      } else {
        if ((xyOffset.dy - ParentInfo.rightTopOffset.dy).abs() < (xyOffset.dy - ParentInfo.rightBottomOffset.dy).abs()) {
          return MakeParentSizePointEnum.RIGHTTOP;
        } else {
          return MakeParentSizePointEnum.RIGHTBOTTOM;
        }
      }
      //return MakeParentSizePointEnum.RIGHTTOP;
    }
    cornerOffset = Offset(
        leftBottomOffset.dx - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.2,
        leftBottomOffset.dy - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8);
    cornerRect = cornerOffset & cornerSize;
    if (canvas != null && paint != null) canvas.drawRect(cornerRect, paint);
    if (cornerRect.contains(xyOffset)) {
      if ((xyOffset.dx - ParentInfo.leftBottomOffset.dx).abs() < (xyOffset.dx - ParentInfo.rightBottomOffset.dx).abs()) {
        if ((xyOffset.dy - ParentInfo.leftTopOffset.dy).abs() < (xyOffset.dy - ParentInfo.leftBottomOffset.dy).abs()) {
          return MakeParentSizePointEnum.LEFTTOP;   // unnecessary
        } else {
          return MakeParentSizePointEnum.LEFTBOTTOM;
        }
      } else {
        return MakeParentSizePointEnum.RIGHTBOTTOM;
      }
      //return MakeParentSizePointEnum.LEFTBOTTOM;
    }
    cornerOffset = Offset(
        rightBottomOffset.dx - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8,
        rightBottomOffset.dy - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8);
    cornerRect = cornerOffset & cornerSize;
    if (canvas != null && paint != null) canvas.drawRect(cornerRect, paint);
    if (cornerRect.contains(xyOffset)) {

      if ((xyOffset.dx - ParentInfo.leftBottomOffset.dx).abs() < (xyOffset.dx - ParentInfo.rightBottomOffset.dx).abs()) {
        return MakeParentSizePointEnum.LEFTBOTTOM;    // unnecessary
      } else {
        if ((xyOffset.dy - ParentInfo.rightTopOffset.dy).abs() < (xyOffset.dy - ParentInfo.rightBottomOffset.dy).abs()) {
          return MakeParentSizePointEnum.RIGHTTOP;   // unnecessary
        } else {
          return MakeParentSizePointEnum.RIGHTBOTTOM;
        }
      }
      //return MakeParentSizePointEnum.RIGHTBOTTOM;
    }

    bracketLength = ParentInfo.wScreen / 6;
    if (bracketLength > (ParentInfo.rightTopOffset.dx - ParentInfo.leftTopOffset.dx) * 0.5) {
      bracketLength = (ParentInfo.rightTopOffset.dx - ParentInfo.leftTopOffset.dx) * 0.5;
    }

    Size barSizeH =
        Size(bracketLength, AppConfig.SIZE_BRACKET_BAR_TOUCH);
    Size barSizeV =
        Size(AppConfig.SIZE_BRACKET_BAR_TOUCH, bracketLength);
    Offset barOffset = Offset(
        (leftTopOffset.dx + AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8),
        (leftTopOffset.dy - AppConfig.SIZE_BRACKET_BAR_TOUCH * 0.2));
    Rect barRectHv = barOffset & barSizeH;
    if (canvas != null && paint != null) canvas.drawRect(barRectHv, paint);
    if (barRectHv.contains(xyOffset)) {
      if ((xyOffset.dx - ParentInfo.leftTopOffset.dx).abs() < (xyOffset.dx - ParentInfo.rightTopOffset.dx).abs()) {
        return MakeParentSizePointEnum.LEFTTOPH;
      } else {
        return MakeParentSizePointEnum.RIGHTTOPH;
      }
      return MakeParentSizePointEnum.LEFTTOPH;
    }
    barOffset = Offset(
        (leftTopOffset.dx - AppConfig.SIZE_BRACKET_BAR_TOUCH * 0.2),
        (leftTopOffset.dy + AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8));
    barRectHv = barOffset & barSizeV;
    if (canvas != null && paint != null) canvas.drawRect(barRectHv, paint);
    if (barRectHv.contains(xyOffset)) {
      if ((xyOffset.dy - ParentInfo.leftTopOffset.dy).abs() < (xyOffset.dy - ParentInfo.leftBottomOffset.dy).abs()) {
        return MakeParentSizePointEnum.LEFTTOPV;
      } else {
        return MakeParentSizePointEnum.LEFTBOTTOMV;
      }
      //return MakeParentSizePointEnum.LEFTTOPV;
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
      if ((xyOffset.dy - ParentInfo.rightTopOffset.dy).abs() < (xyOffset.dy - ParentInfo.rightBottomOffset.dy).abs()) {
        return MakeParentSizePointEnum.RIGHTTOPV;
      } else {
        return MakeParentSizePointEnum.RIGHTBOTTOMV;
      }
      //return MakeParentSizePointEnum.RIGHTTOPV;
    }

    barOffset = Offset(
        (leftBottomOffset.dx + AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8),
        (leftBottomOffset.dy - AppConfig.SIZE_BRACKET_CORNER_TOUCH * 0.8));
    barRectHv = barOffset & barSizeH;
    if (canvas != null && paint != null) canvas.drawRect(barRectHv, paint);
    if (barRectHv.contains(xyOffset)) {
      if ((xyOffset.dx - ParentInfo.leftBottomOffset.dx).abs() < (xyOffset.dx - ParentInfo.rightBottomOffset.dx).abs()) {
        return MakeParentSizePointEnum.LEFTBOTTOMH;
      } else {
        return MakeParentSizePointEnum.RIGHTBOTTOMH;
      }
      //return MakeParentSizePointEnum.LEFTBOTTOMH;
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
  }

  static Rect calcRect(
      Offset xyOffset, MakeParentSizePointEnum makeParentSizePointEnum) {
    double x = 0.0;
    double y = 0.0;
    double width = 0.0;
    double height = 0.0;

    switch (makeParentSizePointEnum) {
      case MakeParentSizePointEnum.LEFTTOP:
        x = xyOffset.dx;
        y = xyOffset.dy;
        width = ParentInfo.rightTopOffset.dx - x;
        height = ParentInfo.rightBottomOffset.dy - y;
        break;
      case MakeParentSizePointEnum.RIGHTTOP:
        x = ParentInfo.leftTopOffset.dx;
        y = xyOffset.dy;
        width = xyOffset.dx - ParentInfo.leftTopOffset.dx;
        height = ParentInfo.leftBottomOffset.dy - y;
        break;
      case MakeParentSizePointEnum.LEFTBOTTOM:
        x = xyOffset.dx;
        y = ParentInfo.leftTopOffset.dy;
        width = ParentInfo.rightTopOffset.dx - x;
        height = xyOffset.dy - ParentInfo.rightTopOffset.dy;
        break;
      case MakeParentSizePointEnum.RIGHTBOTTOM:
        x = ParentInfo.leftTopOffset.dx;
        y = ParentInfo.leftTopOffset.dy;
        width = xyOffset.dx - ParentInfo.leftTopOffset.dx;
        height = xyOffset.dy - ParentInfo.leftTopOffset.dy;
        break;

      case MakeParentSizePointEnum.LEFTTOPH:
      case MakeParentSizePointEnum.RIGHTTOPH:
        x = ParentInfo.leftTopOffset.dx;
        y = xyOffset.dy;
        width = ParentInfo.rightTopOffset.dx - x;
        height = ParentInfo.rightBottomOffset.dy - y;
        break;
      case MakeParentSizePointEnum.LEFTTOPV:
      case MakeParentSizePointEnum.LEFTBOTTOMV:
        x = xyOffset.dx;
        y = ParentInfo.leftTopOffset.dy;
        width = ParentInfo.rightTopOffset.dx - x;
        height = ParentInfo.rightBottomOffset.dy - y;
        break;
      case MakeParentSizePointEnum.RIGHTTOPV:
      case MakeParentSizePointEnum.RIGHTBOTTOMV:
        x = ParentInfo.leftTopOffset.dx;
        y = ParentInfo.leftTopOffset.dy;
        width = xyOffset.dx - ParentInfo.leftTopOffset.dx;
        height = ParentInfo.rightBottomOffset.dy - y;
        break;
      case MakeParentSizePointEnum.LEFTBOTTOMH:
      case MakeParentSizePointEnum.RIGHTBOTTOMH:
        x = ParentInfo.leftTopOffset.dx;
        y = ParentInfo.leftTopOffset.dy;
        width = ParentInfo.rightTopOffset.dx - ParentInfo.leftTopOffset.dx;
        height = xyOffset.dy - ParentInfo.leftTopOffset.dy;
        break;
    }
    Rect rect = Offset(x, y) & Size(width, height);
    return rect;
  }

  static void updateBracketArea(
      Offset xyOffset, MakeParentSizePointEnum makeParentSizePointEnum) {
    switch (makeParentSizePointEnum) {
      case MakeParentSizePointEnum.LEFTTOP:
        ParentInfo.leftTopOffset = Offset(xyOffset.dx, xyOffset.dy);
        ParentInfo.rightTopOffset =
            Offset(ParentInfo.rightTopOffset.dx, xyOffset.dy);
        ParentInfo.leftBottomOffset =
            Offset(xyOffset.dx, ParentInfo.leftBottomOffset.dy);
        //ParentInfo.rightBottomOffset = Offset(ParentInfo.rightBottomOffset.dx, ParentInfo.rightBottomOffset.dy);
        break;
      case MakeParentSizePointEnum.RIGHTTOP:
        ParentInfo.leftTopOffset =
            Offset(ParentInfo.leftTopOffset.dx, xyOffset.dy);
        ParentInfo.rightTopOffset = Offset(xyOffset.dx, xyOffset.dy);
        //ParentInfo.leftBottomOffset = Offset(ParentInfo.leftBottomOffset.dx, ParentInfo.leftBottomOffset.dy);
        ParentInfo.rightBottomOffset =
            Offset(xyOffset.dx, ParentInfo.rightBottomOffset.dy);
        break;
      case MakeParentSizePointEnum.LEFTBOTTOM:
        ParentInfo.leftTopOffset =
            Offset(xyOffset.dx, ParentInfo.leftTopOffset.dy);
        //ParentInfo.rightTopOffset = Offset(ParentInfo.rightTopOffset.dx, ParentInfo.rightTopOffset.dy);
        ParentInfo.leftBottomOffset = Offset(xyOffset.dx, xyOffset.dy);
        ParentInfo.rightBottomOffset =
            Offset(ParentInfo.rightBottomOffset.dx, xyOffset.dy);
        break;
      case MakeParentSizePointEnum.RIGHTBOTTOM:
        //ParentInfo.leftTopOffset = Offset(ParentInfo.leftTopOffset.dx, ParentInfo.leftTopOffset.dy);
        ParentInfo.rightTopOffset =
            Offset(xyOffset.dx, ParentInfo.rightTopOffset.dy);
        ParentInfo.leftBottomOffset =
            Offset(ParentInfo.leftBottomOffset.dx, xyOffset.dy);
        ParentInfo.rightBottomOffset = Offset(xyOffset.dx, xyOffset.dy);
        break;

      case MakeParentSizePointEnum.LEFTTOPH:
      case MakeParentSizePointEnum.RIGHTTOPH:
        ParentInfo.leftTopOffset =
            Offset(ParentInfo.leftTopOffset.dx, xyOffset.dy);
        ParentInfo.rightTopOffset =
            Offset(ParentInfo.rightTopOffset.dx, xyOffset.dy);
        //ParentInfo.leftBottomOffset = Offset(ParentInfo.leftBottomOffset.dx, xyOffset.dy);
        //ParentInfo.rightBottomOffset = Offset(xyOffset.dx, xyOffset.dy);
        break;
      case MakeParentSizePointEnum.LEFTTOPV:
      case MakeParentSizePointEnum.LEFTBOTTOMV:
        ParentInfo.leftTopOffset =
            Offset(xyOffset.dx, ParentInfo.leftTopOffset.dy);
        //ParentInfo.rightTopOffset = Offset(xyOffset.dx, ParentInfo.rightTopOffset.dy);
        ParentInfo.leftBottomOffset =
            Offset(xyOffset.dx, ParentInfo.leftBottomOffset.dy);
        //ParentInfo.rightBottomOffset = Offset(xyOffset.dx, xyOffset.dy);
        break;
      case MakeParentSizePointEnum.RIGHTTOPV:
      case MakeParentSizePointEnum.RIGHTBOTTOMV:
        //ParentInfo.leftTopOffset = Offset(ParentInfo.leftTopOffset.dx, ParentInfo.leftTopOffset.dy);
        ParentInfo.rightTopOffset =
            Offset(xyOffset.dx, ParentInfo.rightTopOffset.dy);
        //ParentInfo.leftBottomOffset = Offset(ParentInfo.leftBottomOffset.dx, xyOffset.dy);
        ParentInfo.rightBottomOffset =
            Offset(xyOffset.dx, ParentInfo.rightBottomOffset.dy);
        break;

      case MakeParentSizePointEnum.LEFTBOTTOMH:
      case MakeParentSizePointEnum.RIGHTBOTTOMH:
        //ParentInfo.leftTopOffset = Offset(ParentInfo.leftTopOffset.dx, ParentInfo.leftTopOffset.dy);
        //ParentInfo.rightTopOffset = Offset(xyOffset.dx, ParentInfo.rightTopOffset.dy);
        ParentInfo.leftBottomOffset =
            Offset(ParentInfo.leftBottomOffset.dx, xyOffset.dy);
        ParentInfo.rightBottomOffset =
            Offset(ParentInfo.rightBottomOffset.dx, xyOffset.dy);
        break;
    }
  }

  // 영역을 넘어가는지 체크
  static bool checkBracketCrossArea(
      Offset xyOffset, MakeParentSizePointEnum makeParentSizePointEnum) {
    switch (makeParentSizePointEnum) {
      case MakeParentSizePointEnum.LEFTTOP:
        if (xyOffset.dx >= ParentInfo.rightTopOffset.dx ||
            xyOffset.dy >= ParentInfo.rightBottomOffset.dy) {
          dev.log('checkBracketArea: LEFTTOP');
          return false;
        } else {
          return true;
        }
      case MakeParentSizePointEnum.RIGHTTOP:
        if (xyOffset.dx <= ParentInfo.leftTopOffset.dx ||
            xyOffset.dy >= ParentInfo.leftBottomOffset.dy) {
          dev.log('checkBracketArea: RIGHTTOP');
          return false;
        } else {
          return true;
        }
      case MakeParentSizePointEnum.LEFTBOTTOM:
        if (xyOffset.dx >= ParentInfo.rightBottomOffset.dx ||
            xyOffset.dy <= ParentInfo.rightTopOffset.dy) {
          dev.log('checkBracketArea: LEFTBOTTOM');
          return false;
        } else {
          return true;
        }
      case MakeParentSizePointEnum.RIGHTBOTTOM:
        if (xyOffset.dx <= ParentInfo.leftBottomOffset.dx ||
            xyOffset.dy <= ParentInfo.leftTopOffset.dy) {
          dev.log('checkBracketArea: RIGHTBOTTOM');
          return false;
        } else {
          return true;
        }
      case MakeParentSizePointEnum.LEFTTOPH:
      case MakeParentSizePointEnum.RIGHTTOPH:
        if (xyOffset.dy >= ParentInfo.leftBottomOffset.dy) {
          dev.log('checkBracketArea: LEFTTOPH');
          return false;
        } else {
          return true;
        }
      case MakeParentSizePointEnum.LEFTTOPV:
      case MakeParentSizePointEnum.LEFTBOTTOMV:
        if (xyOffset.dx >= ParentInfo.rightBottomOffset.dx) {
          dev.log('checkBracketArea: LEFTTOPV');
          return false;
        } else {
          return true;
        }
      case MakeParentSizePointEnum.RIGHTTOPV:
      case MakeParentSizePointEnum.RIGHTBOTTOMV:
        if (xyOffset.dx <= ParentInfo.leftBottomOffset.dx) {
          dev.log('checkBracketArea: RIGHTTOPV');
          return false;
        } else {
          return true;
        }
      case MakeParentSizePointEnum.LEFTBOTTOMH:
      case MakeParentSizePointEnum.RIGHTBOTTOMH:
        if (xyOffset.dy <= ParentInfo.leftTopOffset.dy) {
          dev.log('checkBracketArea: LEFTBOTTOMH');
          return false;
        } else {
          return true;
        }
    }
    return true;
  }

  // 영역을 넘어가는지 체크
  static bool checkBlankArea(
      Offset xyOffset, MakeParentSizePointEnum makeParentSizePointEnum) {
    switch (makeParentSizePointEnum) {
      case MakeParentSizePointEnum.LEFTTOP:
        if (xyOffset.dx < ParentInfo.xBlank ||
            xyOffset.dy < ParentInfo.yBlank) {
          //dev.log('checkBlankArea: LEFTTOP');
          return false;
        } else {
          return true;
        }
      case MakeParentSizePointEnum.RIGHTTOP:
        if (xyOffset.dx > ParentInfo.wScreen - ParentInfo.xBlank ||
            xyOffset.dy < ParentInfo.yBlank) {
          //dev.log('checkBlankArea: RIGHTTOP');
          return false;
        } else {
          return true;
        }
      case MakeParentSizePointEnum.LEFTBOTTOM:
        if (xyOffset.dx < ParentInfo.xBlank ||
            xyOffset.dy > ParentInfo.hScreen - ParentInfo.yBlank) {
          //dev.log('checkBlankArea: LEFTBOTTOM');
          return false;
        } else {
          return true;
        }
      case MakeParentSizePointEnum.RIGHTBOTTOM:
        if (xyOffset.dx > ParentInfo.wScreen - ParentInfo.xBlank ||
            xyOffset.dy > ParentInfo.hScreen - ParentInfo.yBlank) {
          //dev.log('checkBlankArea: RIGHTBOTTOM');
          return false;
        } else {
          return true;
        }
      case MakeParentSizePointEnum.LEFTTOPH:
      case MakeParentSizePointEnum.RIGHTTOPH:
        if (xyOffset.dy < ParentInfo.yBlank) {
          //dev.log('checkBlankArea: LEFTTOPH');
          return false;
        } else {
          return true;
        }
      case MakeParentSizePointEnum.LEFTTOPV:
      case MakeParentSizePointEnum.LEFTBOTTOMV:
        if (xyOffset.dx < ParentInfo.xBlank) {
          //dev.log('checkBlankArea: LEFTTOPV');
          return false;
        } else {
          return true;
        }
      case MakeParentSizePointEnum.RIGHTTOPV:
      case MakeParentSizePointEnum.RIGHTBOTTOMV:
        if (xyOffset.dx > ParentInfo.wScreen - ParentInfo.xBlank) {
          //dev.log('checkBlankArea: RIGHTTOPV');
          return false;
        } else {
          return true;
        }
      case MakeParentSizePointEnum.LEFTBOTTOMH:
      case MakeParentSizePointEnum.RIGHTBOTTOMH:
        if (xyOffset.dy > ParentInfo.hScreen - ParentInfo.yBlank) {
          //dev.log('checkBlankArea: LEFTBOTTOMH');
          return false;
        } else {
          return true;
        }
    }
    return true;
  }

  /*
  필요없음 --> 사용안함
  static void updateBracketList(Offset xyOffset,
      Offset leftTopOffset, Offset rightTopOffset, Offset leftBottomOffset, Offset rightBottomOffset,
      MakeParentSizePointEnum makeParentSizePointEnum) {

    switch (makeParentSizePointEnum) {
      case MakeParentSizePointEnum.LEFTTOP:
        leftTopOffset = Offset(xyOffset.dx, xyOffset.dy);
        rightTopOffset = Offset(ParentInfo.leftTopOffset.dx, xyOffset.dy);
        leftBottomOffset = Offset(xyOffset.dx, ParentInfo.leftBottomOffset.dy);
        //rightBottomOffset = Offset(ParentInfo.rightBottomOffset.dx, ParentInfo.rightBottomOffset.dy);
        break;
      case MakeParentSizePointEnum.RIGHTTOP:
        leftTopOffset = Offset(ParentInfo.leftTopOffset.dx, xyOffset.dy);
        rightTopOffset = Offset(xyOffset.dx, xyOffset.dy);
        //leftBottomOffset = Offset(ParentInfo.leftBottomOffset.dx, ParentInfo.leftBottomOffset.dy);
        rightBottomOffset = Offset(xyOffset.dx, ParentInfo.rightBottomOffset.dy);
        break;
      case MakeParentSizePointEnum.LEFTBOTTOM:
        leftTopOffset = Offset(xyOffset.dx, ParentInfo.leftTopOffset.dy);
        //rightTopOffset = Offset(ParentInfo.rightTopOffset.dx, ParentInfo.rightTopOffset.dy);
        leftBottomOffset = Offset(xyOffset.dx, xyOffset.dy);
        rightBottomOffset = Offset(ParentInfo.rightBottomOffset.dx, xyOffset.dy);
        break;
      case MakeParentSizePointEnum.RIGHTBOTTOM:
        //ParentInfo.leftTopOffset = Offset(ParentInfo.leftTopOffset.dx, ParentInfo.leftTopOffset.dy);
        rightTopOffset = Offset(xyOffset.dx, ParentInfo.rightTopOffset.dy);
        leftBottomOffset = Offset(ParentInfo.leftBottomOffset.dx, xyOffset.dy);
        rightBottomOffset = Offset(xyOffset.dx, xyOffset.dy);
        break;

      case MakeParentSizePointEnum.LEFTTOPH:
      case MakeParentSizePointEnum.RIGHTTOPH:
        leftTopOffset = Offset(ParentInfo.leftTopOffset.dx, xyOffset.dy);
        rightTopOffset = Offset(ParentInfo.rightTopOffset.dx, xyOffset.dy);
        //leftBottomOffset = Offset(ParentInfo.leftBottomOffset.dx, xyOffset.dy);
        //rightBottomOffset = Offset(xyOffset.dx, xyOffset.dy);
        break;
      case MakeParentSizePointEnum.LEFTTOPV:
      case MakeParentSizePointEnum.LEFTBOTTOMV:
        leftTopOffset = Offset(xyOffset.dx, ParentInfo.leftTopOffset.dy);
        //rightTopOffset = Offset(xyOffset.dx, ParentInfo.rightTopOffset.dy);
        leftBottomOffset = Offset(xyOffset.dx, ParentInfo.leftBottomOffset.dy);
        //rightBottomOffset = Offset(xyOffset.dx, xyOffset.dy);
        break;
      case MakeParentSizePointEnum.RIGHTTOPV:
      case MakeParentSizePointEnum.RIGHTBOTTOMV:
        //leftTopOffset = Offset(ParentInfo.leftTopOffset.dx, ParentInfo.leftTopOffset.dy);
        rightTopOffset = Offset(xyOffset.dx, ParentInfo.rightTopOffset.dy);
        //leftBottomOffset = Offset(ParentInfo.leftBottomOffset.dx, xyOffset.dy);
        rightBottomOffset = Offset(xyOffset.dx, ParentInfo.rightBottomOffset.dy);
        break;

      case MakeParentSizePointEnum.LEFTBOTTOMH:
      case MakeParentSizePointEnum.RIGHTBOTTOMH:
        //leftTopOffset = Offset(ParentInfo.leftTopOffset.dx, ParentInfo.leftTopOffset.dy);
        //rightTopOffset = Offset(xyOffset.dx, ParentInfo.rightTopOffset.dy);
        leftBottomOffset = Offset(ParentInfo.leftBottomOffset.dx, xyOffset.dy);
        rightBottomOffset = Offset(ParentInfo.rightBottomOffset.dx, xyOffset.dy);
        break;
    }
  }
*/

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  static Future<ui.Image> changeImageToUiImage(Image image) async {
    //final Image image = Image(image: AssetImage('assets/images/jeju.jpg'));
    Completer<ui.Image> completer = Completer<ui.Image>();
    image.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo image, bool _) {
      completer.complete(image.image);
    }));
    ui.Image uiImage = await completer.future;

    return uiImage;
  }

  static Future<ui.Image> loadUiImage(String path) async {
    Image image = Image.file(File(path));

    return changeImageToUiImage(image);
  }

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  /// 비율 계산
  /// x/y : 디바이스 화면, x2/y2 : 이미지
  /// x2/y2 가 x/y 안에 들어오도록 계산
  static double calcFitRatioIn(i_x, i_y, i_x2, i_y2) {
    double f_ret = 1.0;

    double f_x = (1.0 * i_x / i_x2);
    double f_y = (1.0 * i_y / i_y2);

    /// 작은 것을 기준으로 해야 화면에 넘치지 않음
    if (f_x < f_y) {
      //f_ret = Math.round(f_x * 10000.0f) / 10000.0f;
      f_ret = f_x;
    } else {
      //f_ret = Math.round(f_y * 10000.0f) / 10000.0f;
      f_ret = f_y;
    }

    return f_ret;
  }

  /// x/y 는 정사각형 vector, x2/y2 를 빈 곳이 안생기도록 축소
  static double calcFitRatioOut(i_x, i_y, i_x2, i_y2) {
    double f_ret = 1.0;

    double f_x = (1.0 * i_x / i_x2);
    double f_y = (1.0 * i_y / i_y2);

    /// 큰 것을 기준으로 해야 화면에 빈곳이 생기지 않음
    if (f_x > f_y) {
      //f_ret = Math.round(f_x * 10000.0f) / 10000.0f;
      f_ret = f_x;
    } else {
      //f_ret = Math.round(f_y * 10000.0f) / 10000.0f;
      f_ret = f_y;
    }

    return f_ret;
  }

  ////////////////////////////////////////////////////////////////////////////////

  static Offset stickyOffset(
      Offset xyOffset,
      double wScreen,
      double xBlank,
      double hScreen,
      double yBlank,
      double wDivideRatio,
      double hDivideRatio,
      double stickyRatio, MakeParentSizePointEnum makeParentSizePointEnum) {
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
      case MakeParentSizePointEnum.LEFTTOP:
        break;
      case MakeParentSizePointEnum.RIGHTTOP:
        break;
      case MakeParentSizePointEnum.LEFTBOTTOM:
        break;
      case MakeParentSizePointEnum.RIGHTBOTTOM:
        break;
      case MakeParentSizePointEnum.LEFTTOPH:
      case MakeParentSizePointEnum.RIGHTTOPH:
        xNew = x;
      break;
      case MakeParentSizePointEnum.LEFTTOPV:
      case MakeParentSizePointEnum.LEFTBOTTOMV:
        yNew = y;
      break;
      case MakeParentSizePointEnum.RIGHTTOPV:
      case MakeParentSizePointEnum.RIGHTBOTTOMV:
        yNew = y;
      break;
      case MakeParentSizePointEnum.LEFTBOTTOMH:
      case MakeParentSizePointEnum.RIGHTBOTTOMH:
        xNew = x;
      break;
    }

    return Offset(xNew, yNew);
  }
}
