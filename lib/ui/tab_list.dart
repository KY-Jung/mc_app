
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mc/provider/provider_mcImage.dart';
import 'package:mc/ui/screen_imageview.dart';
import 'package:provider/provider.dart';

class ListTab extends StatelessWidget {
  const ListTab({super.key});


  @override
  Widget build(BuildContext context) {
    //return Center(child: Text('LIST'.tr()));
    McImageProvider mcImageProvider = Provider.of<McImageProvider>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('LIST'.tr()),
            Text('McImageId is ${mcImageProvider.getImageId()}'),
            ElevatedButton(
              child: Text("plus 2"),
              onPressed: () {
                mcImageProvider.setImageId('${mcImageProvider.getImageId()} 2');
              },
            ),
            ElevatedButton(
              child: Text("plus 3"),
              onPressed: () {
                mcImageProvider.setImageId('${mcImageProvider.getImageId()} 3');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Text('Image view', style: TextStyle(fontSize:24)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ImageViewScreen()),
          );
        },
      ),
    );

  }
}
