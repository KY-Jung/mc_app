
import 'dart:ui';

import '../ui/screen_make.dart';

class ParentInfo {

  static String path = '';
  static String resizePath = '';
  //static late ui.Image image;

  static late double wScreen;
  static late double hScreen;

  static int wImage = 0;
  static int hImage = 0;

  static double inScale = 0;

  static double xBlank = 0;
  static double yBlank = 0;

  static double xStart = 0;
  static double yStart = 0;

  static double scale = 0;

  static late Offset xyOffset;    // for test
  static late Offset leftTopOffset;
  static late Offset rightTopOffset;
  static late Offset leftBottomOffset;
  static late Offset rightBottomOffset;

  // 선택된 bracket 12개 중 하나
  static late MakeParentSizePointEnum makeParentSizePointEnum;

  static void initAll() {

  }
}