import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import '../config/color_app.dart';

class SoundBar extends StatefulWidget {
  const SoundBar({super.key});

  @override
  State<SoundBar> createState() => SoundBarState();
}

class SoundBarState extends State<SoundBar> {

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# SoundBar initState START');
    super.initState();

    dev.log('# SoundBar initState END');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# SoundBar build START');

    return Scaffold(
      //backgroundColor: Colors.lightGreen,
      backgroundColor: AppColors.MAKE_SOUND_FB_BACKGROUND,
      body: Center(child: Text('')),
    );
    ////////////////////////////////////////////////////////////////////////////////
  }

}
