import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mc/model/sqlite_mcuser.dart';
import 'package:mc/ui/screen_make.dart';
import 'package:mc/util/util_popup.dart';
import 'package:provider/provider.dart';

import '../model/mcuser.dart';

import '../provider/provider_mcImage.dart';

class MakeTab extends StatefulWidget {
  const MakeTab({super.key});

  @override
  State<MakeTab> createState() => _MakeTab();
}

class _MakeTab extends State<MakeTab> {

  final MakeScreen _makeScreen = const MakeScreen();

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# MakeTab initState START');
    super.initState();

    // ######################################################################## //
    // 자동 이동
    WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.push(context, MaterialPageRoute(builder: (context) => _makeScreen), ));
    // ######################################################################## //

    dev.log('# MakeTab initState END');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# MakeTab build START');

    McImageProvider mcImageProvider = Provider.of<McImageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('MAKE'.tr()),
              Text('McImageId is ${mcImageProvider.getImageId()}'),
              ElevatedButton(
                child: Text("MAKE_NEW".tr()),
                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => _makeScreen),
                  );

                },
              ),
            ],
          ),

      ),

      floatingActionButton: FloatingActionButton(
        child: const Text('+', style: TextStyle(fontSize: 24)),
        onPressed: () async {
          ////////////////////////////////////////////////////////////////////////////////
          McUserSqlite userSqlite = McUserSqlite();
          await userSqlite.initDb().then((_) async {
            List<McUser>? listUser = await userSqlite.getUser();
            if (listUser == null) {
              await userSqlite.setUser(
                  McUser(email: 'test_1@gainsys.kr', signKey: '123abc'));
            }
          }).catchError((e) {
            // browser or FATAL
            dev.log(e.toString());
            PopupUtil.popupToast(e.toString());
          });
          ////////////////////////////////////////////////////////////////////////////////
        },
      ),
    );
  }
////////////////////////////////////////////////////////////////////////////////
}
