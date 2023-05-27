
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ShapeInfo {

  late String fileName;
  late SvgPicture svgPicture;
  late Path path;
  //late List<Path> pathList; // 실패 (2023.05.27, KY.Jung)

  @override
  String toString() {
    return 'ShapeInfo{fileName: $fileName}';
  }
}