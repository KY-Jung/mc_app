import 'dart:developer' as dev;

import 'package:flutter/material.dart';

class SoundWidget extends StatefulWidget {
  const SoundWidget({super.key});

  @override
  State<SoundWidget> createState() => _SoundWidget();
}

class _SoundWidget extends State<SoundWidget> {

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# SoundWidget initState START');
    super.initState();

    dev.log('# SoundWidget initState END');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# SoundWidget build START');

    return  Scaffold(
      backgroundColor: Colors.lightGreen,
      body: Center(child: Text('')),
    );
    ////////////////////////////////////////////////////////////////////////////////
  }

}
