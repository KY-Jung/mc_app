
import 'package:flutter/material.dart';
import 'package:mc/ui/tab_balance.dart';
import 'package:mc/ui/tab_list.dart';
import 'package:mc/ui/tab_make.dart';
import 'package:mc/ui/tab_public.dart';

class IndexScreen extends StatelessWidget {

  const IndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
            title: const Text('Tabs Demo'),
          ),
          body: TabBarView(
            children: [
              MakeTab(),
              ListTab(),
              BalanceTab(),
              PublicTab(),
            ],
          ),
        ),
      ),
    );
  }

}
