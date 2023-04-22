import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import '../config/color_app.dart';

class BabyBar extends StatefulWidget {
  const BabyBar({super.key});

  @override
  State<BabyBar> createState() => BabyBarState();
}

class BabyBarState extends State<BabyBar> {

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# BabyBar initState START');
    super.initState();

    dev.log('# BabyBar initState END');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# BabyBar build START');

    return Scaffold(
      //backgroundColor: Colors.orange,
      backgroundColor: AppColors.MAKE_BABY_FB_BACKGROUND,
      body: Center(child: Text('')),
    );
    ////////////////////////////////////////////////////////////////////////////////
  }

}
