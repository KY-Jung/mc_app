import 'dart:developer' as dev;
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:image/image.dart' as IMG;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dto/info_parent.dart';

class InfoUtil {
  ////////////////////////////////////////////////////////////////////////////////
  // path 를 받아서
  // ui.Image 로 변환
  // 이미지 크기 구하기
  // Parent 이미지가 InteractiveViewer 에 맞추어진 ratio 구하기
  // blank 구하기
  // bracket offset 초기화
  static Future setParentInfo(path) async {
    dev.log('setParentInfo path: $path');
    ParentInfo.path = path;

    ui.Image uiImage = await InfoUtil.loadUiImageFromPath(path);

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

    uiImage.dispose();

    // offset
    initParentInfoBracket();
  }

  /// bracket offset 초기화
  /// 1. setParentInfo
  /// 2. ParentBar 의 initState 에서 (다른 bar 로 갔다가 돌아온 경우 때문에)
  /// 3. Size 버튼 누른 경우
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
  // asset/media 모두 사용
  static Future<ui.Image> loadUiImageFromPath(String path) async {
    Image image = Image.file(File(path));

    return changeImageToUiImage(image);
  }
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
  static Future<ui.Image> changeImageToUiImageSize(Image image, double width, double height) async {
    //final Image image = Image(image: AssetImage('assets/images/jeju.jpg'));
    Completer<ui.Image> completer = Completer<ui.Image>();
    image.image
        .resolve(ImageConfiguration(size: Size(width, height)))   // <-- size 지정해도 효과없음
        .addListener(ImageStreamListener((ImageInfo image, bool _) {
      completer.complete(image.image);
    }));
    ui.Image uiImage = await completer.future;

    return uiImage;
  }

  // 아래 함수는 asset 에서만 동작함
  // The asset does not exist or has empty data.
  static Future<ui.Image> loadUiImageFromAsset(String imageAssetPath, {int height = 0, int width = 0}) async {
    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    final codec = await ui.instantiateImageCodec(
      assetImageByteData.buffer.asUint8List(),
      targetHeight: (height == 0) ? null : height,
      targetWidth: (width == 0) ? null : width,
    );
    final image = (await codec.getNextFrame()).image;

    return image;
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

  /// 폴더폰의 경우 길쭉하지 않은 화면이므로 계산한 값을 사용
  static double calcFitSign(wScreen, hScreen) {
    double ret_d = hScreen * 0.25;
    //dev.log('wScreen: $wScreen, hScreen: $hScreen, fit: $ret_d');
    return ret_d;
  }
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  static void drawGridScale(Canvas canvas, double wScreen, double hScreen,
      int wImage, int hImage, double inScale, double xBlank, double yBlank,
      double gridRatio, Paint gridPaint) {

    // horizontal
    Offset startOffset = Offset(xBlank, yBlank);
    Offset endOffset = Offset(wScreen - xBlank, yBlank);
    // 가로 줄
    for (int i = 0, j = 9; i < j; i++) {
      startOffset = Offset(
          startOffset.dx,
          startOffset.dy +
              hImage *
                  ((inScale < 1.0) ? inScale : 1.0) *
                  gridRatio);
      endOffset = Offset(
          endOffset.dx,
          endOffset.dy +
              hImage *
                  ((inScale < 1.0) ? inScale : 1.0) *
                  gridRatio);
      canvas.drawLine(startOffset, endOffset, gridPaint);
    }

    // vertical
    startOffset = Offset(xBlank, yBlank);
    endOffset = Offset(xBlank, hScreen - yBlank);
    // 세로 줄
    for (int i = 0, j = 9; i < j; i++) {
      startOffset = Offset(
          startOffset.dx +
              wImage *
                  ((inScale < 1.0) ? inScale : 1.0) *
                  gridRatio,
          startOffset.dy);
      endOffset = Offset(
          endOffset.dx +
              wImage *
                  ((inScale < 1.0) ? inScale : 1.0) *
                  gridRatio,
          endOffset.dy);
      canvas.drawLine(startOffset, endOffset, gridPaint);
    }
  }
  static void drawGrid(Canvas canvas, double wScreen, double hScreen,
      double xBlank, double yBlank, double gridRatio, Paint gridPaint) {

    Offset startOffset = Offset(xBlank, yBlank);
    Offset endOffset = Offset(wScreen - xBlank, yBlank);
    // 가로 줄
    canvas.drawLine(startOffset, endOffset, gridPaint);
    for (int i = 0, j = (1 ~/ gridRatio); i < j; i++) {
      startOffset = Offset(
          startOffset.dx,
          startOffset.dy + (hScreen - yBlank * 2) * gridRatio);
      endOffset = Offset(
          endOffset.dx,
          endOffset.dy + (hScreen - yBlank * 2) * gridRatio);
      canvas.drawLine(startOffset, endOffset, gridPaint);
    }

    startOffset = Offset(xBlank, yBlank);
    endOffset = Offset(xBlank, hScreen - yBlank);
    // 세로 줄
    canvas.drawLine(startOffset, endOffset, gridPaint);
    for (int i = 0, j = (1 ~/ gridRatio); i < j; i++) {
      startOffset = Offset(
          startOffset.dx + (wScreen - xBlank * 2) * gridRatio,
          startOffset.dy);
      endOffset = Offset(
          endOffset.dx + (wScreen - xBlank * 2) * gridRatio,
          endOffset.dy);
      canvas.drawLine(startOffset, endOffset, gridPaint);
    }
  }
  ////////////////////////////////////////////////////////////////////////////////

}

