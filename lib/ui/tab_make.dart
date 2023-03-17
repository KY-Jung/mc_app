import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mc/model/sqlite_mcuser.dart';
import 'package:mc/util/util_popup.dart';

import '../model/mcuser.dart';

class MakeTab extends StatefulWidget {
  const MakeTab({super.key});

  @override
  _MakeTab createState() => _MakeTab();
}

class _MakeTab extends State<MakeTab> {
  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# MakeTab initState START');
    super.initState();

    dev.log('# MakeTab initState END');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# MakeTab build START');

    return Scaffold(
      body: Center(child: Text('MAKE'.tr())),

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
