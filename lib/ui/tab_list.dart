import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mc/provider/provider_mcImage.dart';
import 'package:mc/ui/screen_imageview.dart';
import 'package:provider/provider.dart';

class ListTab extends StatefulWidget {
  const ListTab({super.key});

  @override
  State<ListTab> createState() => _ListTab();
}

class _ListTab extends State<ListTab> {
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

    McImageProvider mcImageProvider = Provider.of<McImageProvider>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('LIST'.tr()),
            Text('McImageId is ${mcImageProvider.getImageId()}'),
            ElevatedButton(
              child: Text('plus 2'),
              onPressed: () {
                mcImageProvider.setImageId('${mcImageProvider.getImageId()} 2');
              },
            ),
            ElevatedButton(
              child: Text('plus 3'),
              onPressed: () {
                mcImageProvider.setImageId('${mcImageProvider.getImageId()} 3');
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
            MaterialPageRoute(builder: (context) => const ImageViewScreen()),
          );
        },
      ),
    );
  }
  ////////////////////////////////////////////////////////////////////////////////

}
