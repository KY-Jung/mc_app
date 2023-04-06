import 'dart:developer' as dev;

import 'package:flutter/material.dart';

class BabyWidget extends StatefulWidget {
  const BabyWidget({super.key});

  @override
  State<BabyWidget> createState() => BabyWidgetState();
}

class BabyWidgetState extends State<BabyWidget> {

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# BabyWidget initState START');
    super.initState();

    dev.log('# BabyWidget initState END');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# BabyWidget build START');

    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(child: Text('')),
    );
    ////////////////////////////////////////////////////////////////////////////////
  }

}
