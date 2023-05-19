
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ShapeInfo {

  late String fileName;
  late SvgPicture svgPicture;
  late Path path;

  @override
  String toString() {
    return 'ShapeInfo{fileName: $fileName}';
  }
}