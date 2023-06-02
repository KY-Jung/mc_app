
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ShapeFileInfo {

  late String fileName;
  late SvgPicture image;
  late Path path;
  //late List<Path> pathList; // 실패 (2023.05.27, KY.Jung)

  @override
  String toString() {
    return 'ShapeFileInfo{fileName: $fileName}';
  }
}