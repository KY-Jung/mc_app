import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class BalanceTab extends StatefulWidget {
  const BalanceTab({super.key});

  @override
  State<BalanceTab> createState() => BalanceTabState();
}

class BalanceTabState extends State<BalanceTab> {
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

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('BALANCE'.tr()),
            Text('McImageId is '),
            ElevatedButton(
              child: Text('plus 가'),
              onPressed: () {
              },
            ),
            ElevatedButton(
              child: Text('plus 나'),
              onPressed: () {
              },
            ),
          ],
        ),
      ),
    );
  }
  ////////////////////////////////////////////////////////////////////////////////

}
