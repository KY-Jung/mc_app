
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mc/provider/provider_mcImage.dart';
import 'package:mc/ui/tab_balance.dart';
import 'package:mc/ui/tab_list.dart';
import 'package:mc/ui/tab_make.dart';
import 'package:mc/ui/tab_public.dart';
import 'package:provider/provider.dart';

class IndexScreen extends StatelessWidget {

  const IndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<McImageProvider>(
          create: (context) => McImageProvider(),),
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

    /*
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
            title: Text('APP_SLOGAN'.tr()),
            centerTitle: true,
            
            leading: IconButton(icon: Icon(Icons.menu), onPressed: null),
            actions: [
              IconButton(icon: Icon(Icons.image), onPressed: null),
            ],
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
      debugShowCheckedModeBanner: false,    // debug 라벨 없애기
    );
    */
  }

}
