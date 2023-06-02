import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../config/config_app.dart';

class SignClipper extends CustomClipper<Path> {

  ////////////////////////////////////////////////////////////////////////////////
  double width;
  double height;
  ////////////////////////////////////////////////////////////////////////////////

  SignClipper(this.width, this.height);

  @override
  Path getClip(Size size) {
    dev.log('# SignClipper getClip START');
    dev.log('width: $width, height: $height, size: $size');

    ////////////////////////////////////////////////////////////////////////////////
    // svg 크기 조정
    Path svgPath = parseSvgPathData('m12 23.1-1.45-1.608C5.4 15.804 2 12.052 2 7.45 2 3.698 4.42.75 7.5.75c1.74 0 3.41.987 4.5 2.546C13.09 1.736 14.76.75 16.5.75c3.08 0 5.5 2.948 5.5 6.699 0 4.604-3.4 8.355-8.55 14.055L12 23.1z');


    //InfoUtil.calcFitRatioOut(AppConfig.SVG_WH, AppConfig.SVG_WH, i_x2, i_y2);
    double diff = (size.width - size.height).abs();
    double whNew = width - diff;
    dev.log('diff: $diff, whNew: $whNew');
    dev.log('AppConfig.SVG_WH: ${AppConfig.SVG_WH}, whNew / AppConfig.SVG_WH: ${whNew / AppConfig.SVG_WH}');
//whNew = 153;
    Float64List scalingMatrix = Float64List.fromList(
        [whNew / AppConfig.SVG_WH, 0, 0, 0,
          0, whNew / AppConfig.SVG_WH, 0, 0,
          0, 0, 1, 0,
          0, 0, 0, 1]);
    svgPath = svgPath.transform(scalingMatrix);
    ////////////////////////////////////////////////////////////////////////////////

    return svgPath;
  }

  /// 그려야할 정보를 모두 검사해서 틀린 것이 있으면 다시 그리기
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // TODO : impl
    // 다시 그려야할 정보 검사

    return false;
  }

}
