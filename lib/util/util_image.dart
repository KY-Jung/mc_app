import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ImageUtil {

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

}
