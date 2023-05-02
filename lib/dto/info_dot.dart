
import 'package:flutter/material.dart';

class DotInfo {

  DotInfo(this.offset, this.size, this.color);

  Offset offset;
  double size;
  Color? color;   // drawStart 에서만 셋팅됨

  @override
  String toString() {
    return 'DotInfo{offset: $offset, size: $size, color: $color}';
  }

}