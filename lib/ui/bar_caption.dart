import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import '../config/color_app.dart';

class CaptionBar extends StatefulWidget {
  const CaptionBar({super.key});

  @override
  State<CaptionBar> createState() => CaptionBarState();
}

class CaptionBarState extends State<CaptionBar> {

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# CaptionBar initState START');
    super.initState();

    dev.log('# CaptionBar initState END');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# CaptionBar build START');

    return Scaffold(
      //backgroundColor: Colors.amberAccent,
      backgroundColor: AppColors.MAKE_CAPTION_FB_BACKGROUND,
      body: Center(child: Text('')),
    );
    ////////////////////////////////////////////////////////////////////////////////
  }

}
