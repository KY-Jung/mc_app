
import 'dart:developer';

import 'package:mc/model/mcuser.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../config/constant_app.dart';

class McUserSqlite {

  late Database database;
  bool isInit = false;

  Future initDb() async {
    log('# McUserSqlite initDb START');

    if (isInit) {
      log('initDb return');
      return;
    }
    log('initDb openDatabase');

    ////////////////////////////////////////////////////////////////////////////////
    /*
    // 아래코드 동작하지 않음
    import 'package:flutter/foundation.dart';
    import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
    String osWeb;
    if (defaultTargetPlatform == TargetPlatform.android) {
      osWeb = AppConstant.ANDROID;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      osWeb = AppConstant.IOS;
    } else {
      osWeb = AppConstant.WEB;
    }
    log('OS/WEB: $osWeb');

    if (osWeb == AppConstant.WEB) {
      log('initDb $osWeb START');

      var factory = databaseFactoryFfiWeb;
      log('initDb $osWeb START2');
      database = await factory.openDatabase('mc_db.db');    // <- 이 코드에서 return 됨
      log('initDb $osWeb START3');
      //await database.execute('DROP TABLE IF EXISTS mc_user');
      await database.execute(
          'CREATE TABLE IF NOT EXISTS mc_user (email TEXT NOT NULL, signKey TEXT)');

      log('initDb $osWeb END');
      isInit = true;
      return;
    }
    */
    ////////////////////////////////////////////////////////////////////////////////

    database = await openDatabase(
      join(await getDatabasesPath(), 'mc_db.db'),
      onCreate: (db, version) async {
        log('initDb onCreate');
        await db.execute(
          'CREATE TABLE IF NOT EXISTS mc_user (email TEXT NOT NULL, signKey TEXT)',
        );

        isInit = true;
        return;
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        log('initDb onUpgrade');
        await db.execute(
          'DROP TABLE IF EXISTS mc_user',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS mc_user (email TEXT NOT NULL, signKey TEXT)',
        );

        isInit = true;
        return;
      },
      version: 2,
    );
  }

  Future<List<McUser>?> getUser() async {
    log('# McUserSqlite getUser START');

    List<Map<String, dynamic>> maps = await database.query('mc_user', columns: ['email', 'signKey']);
    if (maps.isEmpty) {
      log('getUser empty');
      return null;
    } else if (maps.length > 1) {
      log('### FATAL getUser: $maps, and delete all');
      await database.delete(
        'mc_user',
      );
      return null;
    } else {
      log('getUser: $maps');
      return List.generate(maps.length, (i) {
        return McUser(
          email: maps[i]['email'],
          signKey: maps[i]['signKey'],
        );
      });
    }
  }

  Future<int> setUser(user) async {
    log('# McUserSqlite setUser START');
    log('setUser: $user');

    return await database.insert(
      'mc_user',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

}