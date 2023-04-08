import 'dart:developer' as dev;
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
  static MakeParentSizePointEnum makeParentSizePointEnum = MakeParentSizePointEnum.NONE;

  static void initAll() {

  }

  static void printParent() {
    dev.log('path: $path, wScreen: $wScreen, hScreen: $hScreen, '
        'wImage: $wImage, hImage: $hImage, '
        'xBlank: $xBlank, yBlank: $yBlank, xStart: $xStart, yStart: $yStart, '
        'xyOffset: $xyOffset, leftTopOffset: $leftTopOffset, rightTopOffset: $rightTopOffset, '
        'leftBottomOffset: $leftBottomOffset, rightBottomOffset: $rightBottomOffset, '
        'inScale: $inScale');
  }
}