
import 'package:flutter/material.dart';

class SignFileInfo {

  late String fileName;
  late Image image;
  int cnt = 0;

  SignFileInfo(this.fileName, this.image);

  @override
  String toString() {
    return 'SignFileInfo{fileName: $fileName}';
  }
}