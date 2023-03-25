import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/provider_mcImage.dart';

class BalanceTab extends StatefulWidget {
  const BalanceTab({super.key});

  @override
  State<BalanceTab> createState() => _BalanceTab();
}

class _BalanceTab extends State<BalanceTab> {
  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# BalanceTab initState START');
    super.initState();

    dev.log('# BalanceTab initState END');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# BalanceTab build START');

    McImageProvider mcImageProvider = Provider.of<McImageProvider>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('BALANCE'.tr()),
            Text('McImageId is ${mcImageProvider.getImageId()}'),
            ElevatedButton(
              child: Text("plus 가"),
              onPressed: () {
                mcImageProvider.setImageId('${mcImageProvider.getImageId()} 가');
              },
            ),
            ElevatedButton(
              child: Text("plus 나"),
              onPressed: () {
                mcImageProvider.setImageId('${mcImageProvider.getImageId()} 나');
              },
            ),
          ],
        ),
      ),
    );
  }
////////////////////////////////////////////////////////////////////////////////
}
