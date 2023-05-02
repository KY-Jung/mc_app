import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mc/provider/provider_make.dart';
import 'package:mc/provider/provider_sign.dart';
import 'package:mc/ui/screen_imageview.dart';
import 'package:mc/ui/screen_index.dart';
import 'package:mc/ui/screen_splash.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // for SharedPreferences

  ////////////////////////////////////////////////////////////////////////////////
  // EasyLocalization
  final supportedLocales = [const Locale('en', 'US'), const Locale('ko', 'KR')];
  // easylocalization 초기화
  await EasyLocalization.ensureInitialized();
  ////////////////////////////////////////////////////////////////////////////////

  //runApp(const MyApp());
  // EasyLocalization
  runApp(
    EasyLocalization(
        ////////////////////////////////////////////////////////////////////////////////
        // 지원 언어 리스트
        supportedLocales: supportedLocales,
        //path: 언어 파일 경로
        path: 'assets/translations',
        //fallbackLocale supportedLocales에 설정한 언어가 없는 경우 설정되는 언어
        fallbackLocale: const Locale('en', 'US'),
        //startLocale을 지정하면 초기 언어가 설정한 언어로 변경됨
        //만일 이 설정을 하지 않으면 OS 언어를 따라 기본 언어가 설정됨
        //startLocale: Locale('ko', 'KR')
        ////////////////////////////////////////////////////////////////////////////////

        child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    dev.log('# MyApp build START');

    return MultiProvider(
      providers: [
        // MakeTap 에서 하면 이상하게 최상위로 올라가는 현상이 있어서 부득이 여기로 옴
        ChangeNotifierProvider<MakeProvider>(
          create: (context) => MakeProvider(),
        ),
        ChangeNotifierProvider<SignProvider>(
          create: (context) => SignProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'MC',
        routes: {
          '/': (context) => const SplashScreen(),
          '/index': (context) => const IndexScreen(),
          '/imageview': (context) => const ImageViewScreen(),
        },
        initialRoute: '/',
        debugShowCheckedModeBanner: false,
        // debug 라벨 없애기

        theme: ThemeData(
          primarySwatch: Colors.grey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),

        ////////////////////////////////////////////////////////////////////////////////
        // EasyLocalization
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        ////////////////////////////////////////////////////////////////////////////////
      ),
    );
  }
}
