import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
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
  static Color convertStringToColor(String str) {
    int i = int.parse(str);
    return convertIntToColor(i);
  }
  static bool findColor(List<Color> colorList, Color color) {
    for (Color c in colorList) {
      if (c.value == color.value)   return true;
    }
    return false;
  }
  static void insertAndSet(List<Color> colorList, Color color, int max) {
    colorList.insert(0, color);
    for (int i = 1, j = colorList.length; i < j; i++) {
      if (color.value == colorList[i].value) {
        colorList.removeAt(i);
        break;
      }
    }
    if (colorList.length > max) {
      colorList.removeLast();
    }
  }
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////

  static Future<bool> colorPickerDialog(
      var context, Color firstColor, List<Color> recentColorList, var callbackColor) async {
    dev.log("# ColorUtil colorPickerDialog firstColor: $firstColor, recentColorList: $recentColorList");

    return ColorPicker(
      // Use the dialogPickerColor as start color.
      color: firstColor,
      // Update the dialogPickerColor using the callback.
      //onColorChanged: (Color color) => setState(() => dialogPickerColor = color),
      //onColorChanged: (Color color) {},
      onColorChanged: (Color color) => callbackColor(color),
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 175,
      title: Text('COLOR_SELECT_TITLE'.tr()),
      heading: const Text(
        ' ',
        //style: Theme.of(context).textTheme.titleSmall,
      ),
      subheading: Text(
        //'Select color shade',
        'COLOR_SELECT_SHADE'.tr(),
        //style: Theme.of(context).textTheme.titleSmall,
      ),
      wheelSubheading: Text(
        //'Selected color and its shades',
        'COLOR_SELECT_SHADE'.tr(),
        //style: Theme.of(context).textTheme.titleSmall,
      ),
      recentColorsSubheading: Text('COLOR_SELECT_RECENT'.tr()),
      showMaterialName: true,
      showColorName: true,
      //showColorCode: true,
      showColorCode: false,
      //copyPasteBehavior: const ColorPickerCopyPasteBehavior(
      //  longPressMenu: true,
      //),
      materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorCodeTextStyle: Theme.of(context).textTheme.bodySmall,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        //ColorPickerType.accent: true,
        ColorPickerType.accent: false,
        ColorPickerType.bw: false,
        //ColorPickerType.custom: true,
        ColorPickerType.custom: false,
        ColorPickerType.wheel: true,
      },
      //customColorSwatchesAndNames: colorsNameMap,
      showRecentColors: true,
      maxRecentColors: 6,
      //recentColors: const <Color>[Colors.amber, Colors.brown],
      recentColors: recentColorList,
      onRecentColorsChanged: (List<Color> colors) {
        print('onRecentColorsChanged: ${colors.length}');
      },
    ).showPickerDialog(
      context,
      // New in version 3.0.0 custom transitions support.
      transitionBuilder: (BuildContext context, Animation<double> a1, Animation<double> a2, Widget widget) {
        final double curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: widget,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      constraints: const BoxConstraints(minHeight: 460, minWidth: 300, maxWidth: 320),
    );
  }
////////////////////////////////////////////////////////////////////////////////
}
