import 'dart:developer' as dev;

import 'package:flutter/material.dart';

class BlankWidget extends StatefulWidget {
  const BlankWidget({super.key});

  @override
  State<BlankWidget> createState() => _BlankWidget();
}

class _BlankWidget extends State<BlankWidget> {

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# BlankWidget initState START');
    super.initState();

    dev.log('# BlankWidget initState END');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# BlankWidget build START');

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(child: Text('')),
    );
    ////////////////////////////////////////////////////////////////////////////////
  }

}
