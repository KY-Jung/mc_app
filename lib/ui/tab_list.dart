import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mc/ui/page_imageview.dart';

class ListTab extends StatefulWidget {
  const ListTab({super.key});

  @override
  State<ListTab> createState() => ListTabState();
}

class ListTabState extends State<ListTab> {
  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# ListTab initState START');
    super.initState();

    dev.log('# ListTab initState END');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# ListTab build START');

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('LIST'.tr()),
            Text('McImageId is '),
            ElevatedButton(
              child: Text('plus 2'),
              onPressed: () {
              },
            ),
            ElevatedButton(
              child: Text('plus 3'),
              onPressed: () {
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Text('Image view', style: TextStyle(fontSize: 24)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ImageViewPage()),
          );
        },
      ),
    );
  }
  ////////////////////////////////////////////////////////////////////////////////

}
