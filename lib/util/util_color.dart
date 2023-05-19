import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ColorUtil {

  ////////////////////////////////////////////////////////////////////////////////

  static int convertColorToInt(Color color) {
    return color.value;
  }

  static Color convertIntToColor(int intColor) {
    return Color(intColor);
  }

  static String convertColorToString(Color color) {
    return color.value.toString();
  }

  ////////////////////////////////////////////////////////////////////////////////

}
