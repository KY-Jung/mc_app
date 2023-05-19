import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ImageViewPage extends StatefulWidget {
  const ImageViewPage({super.key});

  @override
  State<ImageViewPage> createState() => ImageViewPageState();
}

class ImageViewPageState extends State<ImageViewPage> {
  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# ImageViewPage initState START');
    super.initState();

    dev.log('# ImageViewPage initState END');
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
