import 'dart:async';
import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/config_app.dart';
import '../config/constant_app.dart';
import '../util/util_popup.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => SplashPageState();
}

/// 초기화면으로 이동하기 전에 splash 화면 표시
/// 2가지를 비동기로 실행
/// 2가지가 모두 만족하면 초기화면으로 이동
/// 일단 AppConfig.SPLASH_WAIT 초는 splash 화면 표시하고, 이후 0.1 초 마다 검사
/// 만약 메세지를 표시해야 한다면 AppConfig.SPLASH_WAIT 초 이후에 표시
class SplashPageState extends State<SplashPage> {
  ////////////////////////////////////////////////////////////////////////////////
  int checkCnt = 0;
  int checkCntAll = 2;
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# SplashPage initState START');

    super.initState();

    // for build 에서 화면을 보여주기 위해
    Timer(const Duration(milliseconds: 0), () {
      checkInit();
    });

    dev.log('# SplashPage initState END');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# SplashPage build START');

    return Scaffold(
      appBar: null,
      backgroundColor: Colors.black87,
      body: Center(
        child: Image.asset('assets/images/logo_transparent.png'),
      ),
    );
  }
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // 미리 체크할 것
  void checkInit() async {
    dev.log('# SplashPage checkInit START ${DateTime.now()}');

    // 처음 설치한 경우 키 생성하는 코드
    Timer(const Duration(milliseconds: 0), () {
      checkInitKey().then((isInit) {
        if (isInit) {
        } else {
          makeInitKey();
        }
        checkCnt++;
      }).catchError((e) {
        dev.log(e.toString());
        PopupUtil.popupAlertOk(context, 'ERROR'.tr(), e);
      });
    });

    // 표시해야할 메시지
    Timer(const Duration(milliseconds: 0), () {
      checkInitMsg().then((initMsg) {
        if (initMsg == null) {
          checkCnt++;
        } else {
          // 최소 splash 화면을 보여 주는 시간
          Timer(const Duration(milliseconds: AppConfig.SPLASH_WAIT), () {
            PopupUtil.popupAlertOk(context, '', initMsg).then((ret) {
              dev.log('popupAlertOk: $ret');

              // example
              if (ret == null) {} // 팝업 바깥 영역을 클릭한 경우
              if (ret == AppConstant.OK) {}

              checkCnt++;
            });
          });
        }
      }).catchError((e) {
        dev.log(e.toString());
        PopupUtil.popupAlertOk(context, 'ERROR'.tr(), e);
      });
    });

    // 최소 splash 화면을 보여 주는 시간
    Timer(const Duration(milliseconds: AppConfig.SPLASH_WAIT), () {
      Timer.periodic(const Duration(milliseconds: 100), (timer) {
        //dev.log('Timer.periodic');
        if (checkCnt >= checkCntAll) {
          timer.cancel();
          dev.log('Splash Timer cancel');

          dev.log('go /index ${DateTime.now()}');
          Navigator.of(context).pushReplacementNamed('/index');
          //Navigator.pushNamedAndRemoveUntil(context, '/index', (route) => false);
        }
      });
    });
    dev.log('# SplashPage checkInit END');
  }

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // TODO : 처음 설치할때 키 생성하는 코드 추가
  Future<bool> checkInitKey() async {
    dev.log('# SplashPage checkInitKey START');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isInit = prefs.getBool('is_init') ?? false;
    dev.log('is_init: $isInit');

    return isInit;
  }

  void makeInitKey() async {
    dev.log('# SplashPage makeInitKey START');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('is_init', true);
  }

  // TODO : network msg
  Future<String?> checkInitMsg() async {
    dev.log('# SplashPage checkInitMsg START');

    // ######################################################################## //
    // 메세지를 보여주고 싶을때 아래 2개를 번갈아 사용
    return null;
    //return 'msg return';
    // ######################################################################## //
  }
////////////////////////////////////////////////////////////////////////////////
}
