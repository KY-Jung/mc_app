
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SignInfo {

  late String fileName;
  late Image image;
  int cnt = 0;

  SignInfo(this.fileName, this.image);

  @override
  String toString() {
    return 'SignInfo{fileName: $fileName}';
  }
}