import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mc/ui/tab_balance.dart';
import 'package:mc/ui/tab_list.dart';
import 'package:mc/ui/tab_make.dart';
import 'package:mc/ui/tab_public.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage> {

  int _selectedIndex = 0;

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# IndexPage initState START');
    super.initState();

    dev.log('# IndexPage initState END');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# IndexPage build START');

    return Scaffold(
      appBar: AppBar(
        title: Text('APP_SLOGAN'.tr()),
        centerTitle: true,
        //backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            dev.log('leading pressed');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: () {
              dev.log('actions pressed');
            },
          ),
        ],
      ),
      body: Center(
        //child: _listTab.elementAt(_selectedIndex),
        child: [
          const MakeTab(),
          const ListTab(),
          const PublicTab(),
          const BalanceTab(),
        ].elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        //backgroundColor: Colors.black,
        //selectedItemColor: Colors.white,
        //unselectedItemColor: Colors.white60,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'MAKE'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications_none),
            label: 'LIST'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'PUBLIC'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: 'BALANCE'.tr(),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
////////////////////////////////////////////////////////////////////////////////

}
