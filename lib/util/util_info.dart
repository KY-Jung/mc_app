import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:flutter/material.dart';

class InfoUtil {

  ////////////////////////////////////////////////////////////////////////////////
  // 화면 계산 START
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

  /// sign board 크기 정할때 사용
  /// 폴더폰의 경우 길쭉하지 않은 화면이므로 계산한 값을 사용
  static double calcFitSign(wScreen, hScreen) {
    double ret_d = hScreen * 0.25;
    //dev.log('wScreen: $wScreen, hScreen: $hScreen, fit: $ret_d');
    return ret_d;
  }
  ////////////////////////////////////////////////////////////////////////////////
  // 화면 계산 END
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // grid 그리기 START
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
  // grid 그리기 END
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // Widget resize/rotate START
  ////////////////////////////////////////////////////////////////////////////////
  static Size calcRotateSize(w, h, angle) {
    double degree;
    double degree90;
    double angle90;

    degree = radianToDegree(angle);
    int quotientDegree = degree ~/ 90;
    double remainDegree = degree - quotientDegree * 90;
    degree90 = 90 - remainDegree.abs();
    angle90 = degreeToRadian(degree90);
    //dev.log('angle: $angle, angle90: $angle90');
    //dev.log('degree: $degree, degree90: $degree90');
    //dev.log('degree % 90: ${degree % 90}');

    double x_1 = math.sin(angle) * w;
    double x_2 = math.cos(angle) * w;
    //dev.log('x_1: $x_1, x_2: $x_2');
    double y_1 = math.sin(angle90) * h;
    double y_2 = math.cos(angle90) * h;
    //dev.log('y_1: $y_1, y_2: $y_2');

    x_1 = x_1.abs();
    x_2 = x_2.abs();
    y_1 = y_1.abs();
    y_2 = y_2.abs();

    Size size;

    int quotientAngle = angle ~/ (math.pi * 0.5);
    if (quotientAngle % 4 == 0 || quotientAngle % 4 == 2) {
      size = Size(x_1 + y_1, x_2 + y_2);
    } else {
      size = Size(x_1 + y_2, x_2 + y_1);
    }

    return size;
  }
  static double radianToDegree(double radian) {
    return radian * 180 / math.pi;
  }
  static double degreeToRadian(double degree) {
    return degree * math.pi / 180;
  }
  ////////////////////////////////////////////////////////////////////////////////
  // Widget resize/rotate END
  ////////////////////////////////////////////////////////////////////////////////

}

