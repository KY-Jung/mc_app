import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import '../config/color_app.dart';

class LinkBar extends StatefulWidget {
  const LinkBar({super.key});

  @override
  State<LinkBar> createState() => LinkBarState();
}

class LinkBarState extends State<LinkBar> {

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# LinkBar initState START');
    super.initState();

    dev.log('# LinkBar initState END');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# LinkBar build START');

    return Scaffold(
      //backgroundColor: Colors.black87,
      //backgroundColor: Colors.pinkAccent,
      backgroundColor: AppColors.MAKE_LINK_FB_BACKGROUND,
      body: Center(child: Text('')),
    );
    ////////////////////////////////////////////////////////////////////////////////
  }

}
