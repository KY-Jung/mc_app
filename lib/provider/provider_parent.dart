import 'dart:developer' as dev;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../config/enum_app.dart';
import '../ui/bar_parent.dart';
import '../util/util_file.dart';
import '../util/util_info.dart';

class ParentProvider with ChangeNotifier {

  ////////////////////////////////////////////////////////////////////////////////
  // Bar START
  ////////////////////////////////////////////////////////////////////////////////
  // RESIZE 화면인지 구분하는 용도
  // (MakePage 에서 PARENT + RESIZE 상태인지 구분해서 처리하고 있음)

  // prefs 에 저장될 필요없음 (2023.05.18, KY.Jung)
  ParentBarEnum parentBarEnum = ParentBarEnum.FRAME;
  void setParentBarEnum(var value) {
    parentBarEnum = value;
    notifyListeners();
  }
  ////////////////////////////////////////////////////////////////////////////////
  // Bar END
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // 설정되어 있는지 여부를 결정
  String? path;
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // none, resize 여부만 구분
  MakePageBringEnum makeBringEnum = MakePageBringEnum.NONE;
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // 전체 크기
  double wScreen = 0;
  double hScreen = 0;

  // 이미지 크기
  int wImage = 0;
  int hImage = 0;

  // status bar + app bar 높이
  double hTopBlank = 0;
  // bottom bar 높이
  double hBottomBlank = 0;

  // Parent 이미지가 screen 에 맞추어진 비율
  double inScale = 0;

  // 빈 공간
  double xBlank = 0;
  double yBlank = 0;

  // 시작점 (확대될 경우 사용)
  double xStart = 0;
  double yStart = 0;
  // 확대했을 경우 비율
  double scale = 0;    // 사용하지 않음
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // for sign

  // 사인의 가로세로 크기
  double whSign = 0;
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  Offset xyOffset = const Offset(0, 0);    // for test
  Offset leftTopOffset = const Offset(0, 0);
  Offset rightTopOffset = const Offset(0, 0);
  Offset leftBottomOffset = const Offset(0, 0);
  Offset rightBottomOffset = const Offset(0, 0);

  // 선택된 bracket 12개 중 하나
  MakeParentResizePointEnum makeParentSizePointEnum = MakeParentResizePointEnum.NONE;
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // Parent START
  ////////////////////////////////////////////////////////////////////////////////
  // path 를 받아서
  // ui.Image 로 변환
  // 이미지 크기 구하기
  // Parent 이미지가 InteractiveViewer 에 맞추어진 ratio 구하기
  // blank 구하기
  // bracket offset 초기화
  Future<void> initParenProvider(String path) async {
    dev.log('initParenProvider path: $path');
    this.path = path;

    ui.Image uiImage = await FileUtil.loadUiImageFromPath(this.path!);

    /// Parent 이미지 크기
    wImage = uiImage.width;
    hImage = uiImage.height;
    dev.log('wImage: ${uiImage.width}, hImage: ${uiImage.height}');
    dev.log('wScreen: $wScreen, hScreen: $hScreen');

    /// Parent 이미지가 screen 에 맞추어진 ratio 구하기
    inScale = InfoUtil.calcFitRatioIn(
        wScreen, hScreen, uiImage.width, uiImage.height);
    dev.log('inScale: $inScale');

    // blank
    if (inScale < 1.0) {
      // 화면보다 큰 이미지인 경우
      double wReal = uiImage.width * inScale;
      double hReal = uiImage.height * inScale;
      dev.log('wReal: $wReal, hReal: $hReal');
      if ((wScreen - wReal) > (hScreen - hReal)) {
        xBlank = (wScreen - wReal) / 2;
        yBlank = 0.0;
      } else {
        yBlank = (hScreen - hReal) / 2;
        xBlank = 0.0;
      }
    } else {
      // 화면보다 작은 이미지인 경우
      xBlank = (wScreen - uiImage.width) * 0.5;
      yBlank = (hScreen - uiImage.height) * 0.5;
    }
    dev.log('xBlank: $xBlank, yBlank: $yBlank');

    uiImage.dispose();

    // offset
    clearParentBracket();
  }
  void clearParentProvider() {
    path = null;
  }
  Future<void> initParenProviderWithPath(String path) async {
    dev.log('initParenProviderWithPath path: $path');
    this.path = path;

    ui.Image uiImage = await FileUtil.loadUiImageFromPath(this.path!);

    /// Parent 이미지 크기
    wImage = uiImage.width;
    hImage = uiImage.height;
    dev.log('wImage: ${uiImage.width}, hImage: ${uiImage.height}');

    uiImage.dispose();

    // offset
    clearParentBracket();
  }
  void initParenProviderWithScreen(double w, double h) {
    dev.log('initParenProviderWithScreen w: $w, h: $h');

    wScreen = w;
    hScreen = h;

    /// Parent 이미지가 screen 에 맞추어진 ratio 구하기
    inScale = InfoUtil.calcFitRatioIn(wScreen, hScreen, wImage, hImage);
    dev.log('inScale: $inScale');

    // blank
    if (inScale < 1.0) {
      // 화면보다 큰 이미지인 경우
      double wReal = wImage * inScale;
      double hReal = hImage * inScale;
      dev.log('wReal: $wReal, hReal: $hReal');
      if ((wScreen - wReal) > (hScreen - hReal)) {
        xBlank = (wScreen - wReal) / 2;
        yBlank = 0.0;
      } else {
        yBlank = (hScreen - hReal) / 2;
        xBlank = 0.0;
      }
    } else {
      // 화면보다 작은 이미지인 경우
      xBlank = (wScreen - wImage) * 0.5;
      yBlank = (hScreen - hImage) * 0.5;
    }
    dev.log('xBlank: $xBlank, yBlank: $yBlank');

    // offset
    clearParentBracket();
  }

  /// bracket offset 초기화
  /// 1. setParentProvider
  /// 2. ParentBar 의 initState 에서 (다른 bar 로 갔다가 돌아온 경우 때문에)
  /// 3. Size 버튼 누른 경우
  void clearParentBracket() {
    // offset
    leftTopOffset = Offset(xBlank, yBlank);
    rightTopOffset = Offset(wScreen - xBlank, yBlank);
    leftBottomOffset = Offset(xBlank, hScreen - yBlank);
    rightBottomOffset = Offset(wScreen - xBlank, hScreen - yBlank);
  }

  // globalPosition
  Rect calcValidRect() {
    Rect validRect;

    double x;
    double x2;
    double y;
    double y2;

    x = xBlank;
    x2 = wScreen - xBlank;
    y = hTopBlank + yBlank;
    y2 = hTopBlank + hScreen - yBlank;

    validRect = Offset(x, y) & Size(x2 - x, y2 - y);

    return validRect;
  }
  ////////////////////////////////////////////////////////////////////////////////
  // Parent END
  ////////////////////////////////////////////////////////////////////////////////

  void printParent() {
    dev.log('path: $path, '
        'wScreen: $wScreen, hScreen: $hScreen, '
        'wImage: $wImage, hImage: $hImage, '
        'inScale: $inScale, '
        'xBlank: $xBlank, yBlank: $yBlank, '
        'xStart: $xStart, yStart: $yStart, '
        'scale: $scale, '
        'hTopBlank: $hTopBlank, hBottomBlank: $hBottomBlank, whSign: $whSign, '
        'xyOffset: $xyOffset, leftTopOffset: $leftTopOffset, rightTopOffset: $rightTopOffset, '
        'leftBottomOffset: $leftBottomOffset, rightBottomOffset: $rightBottomOffset, '
        'makeParentSizePointEnum: $makeParentSizePointEnum');
  }

}
