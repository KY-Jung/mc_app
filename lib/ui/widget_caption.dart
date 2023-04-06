import 'dart:developer' as dev;

import 'package:flutter/material.dart';

class CaptionWidget extends StatefulWidget {
  const CaptionWidget({super.key});

  @override
  State<CaptionWidget> createState() => CaptionWidgetState();
}

class CaptionWidgetState extends State<CaptionWidget> {

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# CaptionWidget initState START');
    super.initState();

    dev.log('# CaptionWidget initState END');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# CaptionWidget build START');

    return Scaffold(
      backgroundColor: Colors.amberAccent,
      body: Center(child: Text('')),
    );
    ////////////////////////////////////////////////////////////////////////////////
  }

}
