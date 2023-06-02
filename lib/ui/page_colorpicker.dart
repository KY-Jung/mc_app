import 'dart:developer' as dev;
import 'dart:async';
import 'package:flex_color_picker/flex_color_picker.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ColorPickerPage extends StatefulWidget {
  const ColorPickerPage({super.key});

  @override
  State<ColorPickerPage> createState() => ColorPickerPageState();
}

class ColorPickerPageState extends State<ColorPickerPage> {
  ////////////////////////////////////////////////////////////////////////////////
  // Color for the picker shown in Card on the screen.
  late Color screenPickerColor;

  // Color for the picker in a dialog using onChanged.
  late Color dialogPickerColor;

  // Color for picker using the color select dialog.
  late Color dialogSelectColor;

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // Define custom colors. The 'guide' color values are from
  // https://material.io/design/color/the-color-system.html#color-theme-creation
  static const Color guidePrimary = Color(0xFF6200EE);
  static const Color guidePrimaryVariant = Color(0xFF3700B3);
  static const Color guideSecondary = Color(0xFF03DAC6);
  static const Color guideSecondaryVariant = Color(0xFF018786);
  static const Color guideError = Color(0xFFB00020);
  static const Color guideErrorDark = Color(0xFFCF6679);
  static const Color blueBlues = Color(0xFF174378);

  // Make a custom ColorSwatch to name map from the above custom colors.
  final Map<ColorSwatch<Object>, String> colorsNameMap = <ColorSwatch<Object>, String>{
    ColorTools.createPrimarySwatch(guidePrimary): 'Guide Purple',
    ColorTools.createPrimarySwatch(guidePrimaryVariant): 'Guide Purple Variant',
    ColorTools.createAccentSwatch(guideSecondary): 'Guide Teal',
    ColorTools.createAccentSwatch(guideSecondaryVariant): 'Guide Teal Variant',
    ColorTools.createPrimarySwatch(guideError): 'Guide Error',
    ColorTools.createPrimarySwatch(guideErrorDark): 'Guide Error Dark',
    ColorTools.createPrimarySwatch(blueBlues): 'Blue blues',
  };

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    super.initState();
    screenPickerColor = Colors.blue; // Material blue.
    dialogPickerColor = Colors.red; // Material red.
    dialogSelectColor = const Color(0xFFA239CA); // A purple color.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('FlexColorPicker Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        children: <Widget>[
          ListTile(
            title: const Text('Click this color to change it in a dialog'),
            subtitle:
            /*
            Text(
              '${ColorTools.materialNameAndCode(dialogPickerColor, colorSwatchNameMap: colorsNameMap)} '
              'aka ${ColorTools.nameThatColor(dialogPickerColor)}',
            ),
             */
              const Text('select color'),
            trailing: ColorIndicator(
              width: 44,
              height: 44,
              borderRadius: 4,
              color: dialogPickerColor,
              onSelectFocus: false,
              onSelect: () async {
                // Store current color before we open the dialog.
                final Color colorBeforeDialog = dialogPickerColor;
                // Wait for the picker to close, if dialog was dismissed,
                // then restore the color we had before it was opened.
                if (!(await colorPickerDialog())) {
                  setState(() {
                    dialogPickerColor = colorBeforeDialog;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

////////////////////////////////////////////////////////////////////////////////

  Future<bool> colorPickerDialog() async {
    return ColorPicker(
      // Use the dialogPickerColor as start color.
      //color: dialogPickerColor,
      // Update the dialogPickerColor using the callback.
      onColorChanged: (Color color) => setState(() => dialogPickerColor = color),
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
      recentColors: const <Color>[Colors.amber, Colors.brown],
      onRecentColorsChanged: (List<Color> colors) {
        dev.log('onRecentColorsChanged: ${colors.length}');
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
}
