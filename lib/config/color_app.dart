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

  static BoxDecoration BOXDECO_GRAY = BoxDecoration(color: Colors.green[50], boxShadow: [
    BoxShadow(
      color: Colors.grey.withOpacity(0.6),
      blurRadius: 6.0,
      spreadRadius: 1.0,
    )
  ]);


}