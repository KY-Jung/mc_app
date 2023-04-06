import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ImageViewScreen extends StatefulWidget {
  const ImageViewScreen({super.key});

  @override
  State<ImageViewScreen> createState() => ImageViewScreenState();
}

class ImageViewScreenState extends State<ImageViewScreen> {
  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# ImageViewScreen initState START');
    super.initState();

    dev.log('# ImageViewScreen initState END');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IMAGE_VIEW'.tr()),
      ),
      body: Center(child: Text('IMAGE_VIEW'.tr())),
      floatingActionButton: FloatingActionButton(
        child: const Text('close', style: TextStyle(fontSize: 24)),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
////////////////////////////////////////////////////////////////////////////////
}
