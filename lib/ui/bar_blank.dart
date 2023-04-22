import 'dart:developer' as dev;

import 'package:flutter/material.dart';

class BlankBar extends StatefulWidget {
  const BlankBar({super.key});

  @override
  State<BlankBar> createState() => BlankBarState();
}

class BlankBarState extends State<BlankBar> {

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# BlankBar initState START');
    super.initState();

    dev.log('# BlankBar initState END');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# BlankBar build START');

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(child: Text('')),
    );
    ////////////////////////////////////////////////////////////////////////////////
  }

}
