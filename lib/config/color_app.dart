import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {
  ////////////////////////////////////////////////////////////////////////////////
  // MAKE fab button
  static const Color MAKE_PARENT_FAB_BACKGROUND = Colors.blueAccent;
  static const Color MAKE_BABY_FAB_BACKGROUND = Colors.orange;
  static const Color MAKE_CAPTION_FAB_BACKGROUND = Colors.amberAccent;
  static const Color MAKE_SOUND_FAB_BACKGROUND = Colors.lightGreen;
  static const Color MAKE_LINK_FAB_BACKGROUND = Colors.pinkAccent;

  // MAKE function bar
  static const Color MAKE_PARENT_FB_BACKGROUND = Color(0xffa8d4ff);
  static const Color MAKE_BABY_FB_BACKGROUND = Color(0xffffd4a8);
  static const Color MAKE_CAPTION_FB_BACKGROUND = Color(0xffffffa8);
  static const Color MAKE_SOUND_FB_BACKGROUND = Color(0xffa8ffa8);
  static const Color MAKE_LINK_FB_BACKGROUND = Color(0xffffa8ff);

  // MAKE SIGN
  static const Color MAKE_SIGN_BOARD = Color(0xffffffa8);

  ////////////////////////////////////////////////////////////////////////////////

  static Color BLUE_LIGHT = MAKE_PARENT_FB_BACKGROUND;
  static Color ORANGE_LIGHT = MAKE_BABY_FB_BACKGROUND;
  static Color YELLOW_LIGHT = MAKE_CAPTION_FB_BACKGROUND;
  static Color GREEN_LIGHT = MAKE_SOUND_FB_BACKGROUND;
  static Color PINK_LIGHT = MAKE_LINK_FB_BACKGROUND;

  ////////////////////////////////////////////////////////////////////////////////
  static BoxDecoration BOXDECO_YELLOW50 = BoxDecoration(color: Colors.yellow[50], boxShadow: [
    BoxShadow(
      color: Colors.grey.withOpacity(0.6),
      blurRadius: 6.0,
      spreadRadius: 1.0,
    ),
  ]);
  static BoxDecoration BOXDECO_GREEN50 = BoxDecoration(color: Colors.green[50], boxShadow: [
    BoxShadow(
      color: Colors.grey.withOpacity(0.6),
      blurRadius: 6.0,
      spreadRadius: 1.0,
    ),
  ]);
  static BoxDecoration BOXDECO_YELLOW50_BORDER = BoxDecoration(
    color: Colors.yellow[50],
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.6),
        blurRadius: 6.0,
        spreadRadius: 1.0,
      ),
    ],
    border: Border.all(color: Colors.grey),
  );
  static BoxDecoration BOXDECO_YELLOW50_GREY6_BORDER = BoxDecoration(
    color: Colors.yellow[50],
    border: Border.all(
      width: 6,
      color: Colors.grey,
    ),
  );
  static BoxDecoration BOXDECO_YELLOW50_BLACK2_BORDER = BoxDecoration(
    color: Colors.yellow[50],
    border: Border.all(
      width: 2,
      color: Colors.black,
    ),
  );
  static BoxDecoration BOXDECO_GREEN50_BORDER = BoxDecoration(
    color: Colors.green[50],
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.6),
        blurRadius: 6.0,
        spreadRadius: 1.0,
      ),
    ],
    border: Border.all(color: Colors.grey),
  );
  static BoxDecoration BOXDECO_GREEN100_BORDER = BoxDecoration(
    color: Colors.green[100],
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.6),
        blurRadius: 6.0,
        spreadRadius: 1.0,
      ),
    ],
    border: Border.all(color: Colors.grey),
  );
  static BoxDecoration BOXDECO_GREEN100_GREY6_BORDER = BoxDecoration(
    color: Colors.green[100],
    border: Border.all(
      width: 6,
      color: Colors.grey,
    ),
  );
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  static List<Color> DEFAULT_COLOR_LIST = <Color>[
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.black,
    Colors.grey,
    Colors.white
  ];
  static List<Color> DEFAULT_COLOR_LIST2 = <Color>[
    const Color(0xffff0000),
    const Color(0xffff8000),
    const Color(0xfffafc00),
    const Color(0xff00ff00),
    const Color(0xff0080ff),
    const Color(0xffff00ff),
    const Color(0xff000000),
    const Color(0xff828282),
    const Color(0xffffffff)
  ];
////////////////////////////////////////////////////////////////////////////////
}
