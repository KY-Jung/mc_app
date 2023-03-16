
import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/constant_app.dart';
import '../util/util_popup.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

/// 초기화면으로 이동하기 전에 splash 화면 표시
/// 2가지를 비동기로 실행
/// 2가지가 모두 만족하면 초기화면으로 이동
/// 일단 3초는 splash 화면 표시하고, 이후 0.1 초 마다 검사
/// 만약 메세지를 표시해야 한다면 1초 이후에 표시
class _SplashScreenState extends State<SplashScreen> {

  ////////////////////////////////////////////////////////////////////////////////
  int checkCnt = 0;
  int checkCntAll = 2;
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    log('# SplashScreen initState START');

    super.initState();

    // for build 에서 화면을 보여주기 위해
    Timer(const Duration(milliseconds: 0), () {
      checkInit();
    });

    log('# SplashScreen initState END');
  }

  @override
  Widget build(BuildContext context) {
    log('# SplashScreen build START');

    return Scaffold(
      appBar: null,
      body: Center(
        //child: Text('Splash screen'),
        child: Image.asset('assets/images/logo_transparent.png'),
      ),
    );
  }
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // 미리 체크할 것
  void checkInit() async {
    log('# SplashScreen checkInit START');

    Timer(const Duration(milliseconds: 0), () {
      checkInitKey().then((isInit) {
        if (isInit) {
        } else {
          makeInitKey();
        }
        checkCnt++;
      }).catchError((e) {
        log(e.toString());
        PopupUtil.popupAlertOk(context, 'ERROR'.tr(), e);
      });
    });
    Timer(const Duration(milliseconds: 0), () {
      checkInitMsg().then((initMsg) {
        if (initMsg == null) {
          checkCnt++;
        } else {
          Timer(const Duration(milliseconds: 1000), () {    // 최소 splash 화면을 보여 주는 시간
            PopupUtil.popupAlertOk(context, '', initMsg
            ).then((ret) {
              log('popupAlertOk: $ret');
              if (ret == AppConstant.OK) {}   // example

              checkCnt++;
            });
          });
        }
      }).catchError((e) {
        log(e.toString());
        PopupUtil.popupAlertOk(context, 'ERROR'.tr(), e);
      });
    });

    Timer(const Duration(milliseconds: 1000), () {    // 최소 splash 화면을 보여 주는 시간
      Timer.periodic(const Duration(milliseconds: 100), (timer) {
        //log('Timer.periodic');
        if (checkCnt >= checkCntAll) {
          timer.cancel();
          log('Timer cancel');

          Navigator.of(context).pushReplacementNamed('/index');
          //Navigator.pushNamedAndRemoveUntil(context, '/index', (route) => false);
          log('go /index');
        }
      });
    });
    log('# checkInit END');
  }
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  Future<bool> checkInitKey() async {
    log('# SplashScreen checkInitKey START');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isInit = prefs.getBool('is_init') ?? false;
    log('is_init: $isInit');

    return isInit;
  }
  void makeInitKey() async {
    log('# SplashScreen makeInitKey START');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('is_init', true);
  }
  // network msg
  Future<String?> checkInitMsg() async {
    log('# SplashScreen checkInitMsg START');

    // 메세지를 보여주고 싶을때 아래 2개를 번갈아 사용
    return null;
    //return 'msg return';
  }
  ////////////////////////////////////////////////////////////////////////////////

}
