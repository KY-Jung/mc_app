import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mc/provider/provider_mcImage.dart';
import 'package:mc/ui/tab_balance.dart';
import 'package:mc/ui/tab_list.dart';
import 'package:mc/ui/tab_make.dart';
import 'package:mc/ui/tab_public.dart';
import 'package:provider/provider.dart';

import '../provider/provider_make.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => IndexScreenState();
}

class IndexScreenState extends State<IndexScreen> {
  int _selectedIndex = 0;

  /*
  final List<Widget> _listTab = [
    const MakeTab(),
    const ListTab(),
    const PublicTab(),
    const BalanceTab(),
  ];
  */

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# IndexScreen initState START');
    super.initState();

    dev.log('# IndexScreen initState END');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# IndexScreen build START');

    return MultiProvider(
        providers: [
          ChangeNotifierProvider<McImageProvider>(
            create: (context) => McImageProvider(),
          ),
        ],
        child: Scaffold(
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
            // selectedItemColor: Colors.amber[800],
            onTap: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ));
  }
////////////////////////////////////////////////////////////////////////////////

/*
  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<McImageProvider>(
          create: (context) => McImageProvider(),
        ),
      ],
      child: MaterialApp(
        home: DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.home)),
                  Tab(icon: Icon(Icons.search)),
                  Tab(icon: Icon(Icons.shopping_cart)),
                  Tab(icon: Icon(Icons.person)),
                ],
              ),
              title: Text('APP_SLOGAN'.tr()),
              centerTitle: true,

              leading: const IconButton(icon: Icon(Icons.menu), onPressed: null),
              actions: const [
                IconButton(icon: Icon(Icons.image), onPressed: null),
              ],
            ),
            body: const TabBarView(
              children: [
                MakeTab(),
                ListTab(),
                BalanceTab(),
                PublicTab(),
              ],
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,    // debug 라벨 없애기
      ),
    );

  }
  */
}
