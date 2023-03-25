import 'dart:developer' as dev;
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PublicTab extends StatefulWidget {
  const PublicTab({super.key});

  @override
  State<PublicTab> createState() => _PublicTab();
}

class _PublicTab extends State<PublicTab> {
  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# PublicTab initState START');
    super.initState();

    dev.log('# PublicTab initState END');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# PublicTab build START');

    return Scaffold(
      body: Center(child: Text('PUBLIC'.tr())),
      floatingActionButton: FloatingActionButton(
        child: const Text('+', style: TextStyle(fontSize: 24)),
        onPressed: () async {
          _showBottomSheet();
          ////////////////////////////////////////////////////////////////////////////////
          //test1();
          //test2();
          ////////////////////////////////////////////////////////////////////////////////
        },
      ),
    );
    ////////////////////////////////////////////////////////////////////////////////
  }

  _showBottomSheet() {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('사진찍기'),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              thickness: 3,
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('라이브러리에서 불러오기'),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        );
      },
    );
  }

/*
  Future test1() async {
    print('test1 START');
    var ret;
    for (int i2 = 0, j2 = 10000000; i2 < j2; i2++) {
      for (int i = 0, j = 10000000; i < j; i++) {
        ret = pow(13, 123456789);
      }
      print('test1 $ret');
    }
  }

  Future test2() async {
    print('test2 START');
    var ret;
    for (int i2 = 0, j2 = 10000000; i2 < j2; i2++) {
      for (int i = 0, j = 10000000; i < j; i++) {
        ret = pow(13, 123456789);
      }
      print('test2 $ret');
    }
  }
  */
}
