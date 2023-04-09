import 'dart:developer' as dev;
import 'dart:ui';

import '../ui/screen_make.dart';

class ParentInfo {

  static String path = '';
  static MakeBringEnum makeBringEnum = MakeBringEnum.NONE;

  static double wScreen = 0;
  static double hScreen = 0;

  static int wImage = 0;
  static int hImage = 0;

  static double inScale = 0;

  static double xBlank = 0;
  static double yBlank = 0;

  static double xStart = 0;
  static double yStart = 0;

  static double scale = 0;

  static Offset xyOffset = const Offset(0, 0);    // for test
  static Offset leftTopOffset = const Offset(0, 0);
  static Offset rightTopOffset = const Offset(0, 0);
  static Offset leftBottomOffset = const Offset(0, 0);
  static Offset rightBottomOffset = const Offset(0, 0);

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
        'inScale: $inScale, makeParentSizePointEnum: $makeParentSizePointEnum');
  }
}