import 'dart:developer' as dev;

import 'package:flutter/material.dart';

class LinkWidget extends StatefulWidget {
  const LinkWidget({super.key});

  @override
  State<LinkWidget> createState() => LinkWidgetState();
}

class LinkWidgetState extends State<LinkWidget> {

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# LinkWidget initState START');
    super.initState();

    dev.log('# LinkWidget initState END');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# LinkWidget build START');

    return Scaffold(
      //backgroundColor: Colors.black87,
      backgroundColor: Colors.pinkAccent,
      body: Center(child: Text('')),
    );
    ////////////////////////////////////////////////////////////////////////////////
  }

}
