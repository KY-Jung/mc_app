import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mc/config/constant_app.dart';
import 'package:mc/model/sqlite_mcuser.dart';
import 'package:mc/ui/page_make.dart';
import 'package:mc/util/util_popup.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dto/info_parent.dart';
import '../dto/info_shape.dart';
import '../model/mcuser.dart';

import '../provider/provider_make.dart';
import '../provider/provider_parent.dart';
import '../util/util_color.dart';
import '../util/util_file.dart';

class MakeTab extends StatefulWidget {
  const MakeTab({super.key});

  @override
  State<MakeTab> createState() => MakeTabState();
}

class MakeTabState extends State<MakeTab> {
  // initState 에서 build 후에 임시로 이동하기 위해 사용
  //final MakeScreen _makeScreen = const MakeScreen();

  ////////////////////////////////////////////////////////////////////////////////
  late MakeProvider makeProvider;
  late ParentProvider parentProvider;
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# MakeTab initState START');
    super.initState();

    /*
    // ######################################################################## //
    // TODO : 임시 사용, 초기 화면 지정
    WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => _makeScreen),
        ));
    // ######################################################################## //
    */

    dev.log('# MakeTab initState END');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# MakeTab build START');

    ////////////////////////////////////////////////////////////////////////////////
    //makeProvider = Provider.of<MakeProvider>(context, listen: false);
    makeProvider = Provider.of<MakeProvider>(context);
    parentProvider = Provider.of<ParentProvider>(context, listen: false);
    ////////////////////////////////////////////////////////////////////////////////

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('MAKE'.tr()),
            Text('McImageId is '),
            ElevatedButton(
              child: Text('MAKE_NEW'.tr()),
              onPressed: () {

                ////////////////////////////////////////////////////////////////////////////////
                // 초기화 START
                ////////////////////////////////////////////////////////////////////////////////
                initMakePage();
                ////////////////////////////////////////////////////////////////////////////////
                // 초기화 END
                ////////////////////////////////////////////////////////////////////////////////

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MakePage()),
                );
              },
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: Text('* PREFS 초기화 *'),
              onPressed: () async {
                initPrefs();
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
            PopupUtil.toastMsgShort(e.toString());
          });
          ////////////////////////////////////////////////////////////////////////////////
        },
      ),
    );
  }
  ////////////////////////////////////////////////////////////////////////////////

  void initMakePage() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    ////////////////////////////////////////////////////////////////////////////////
    // shape
    dev.log('shapeInfoList START');
    if (parentProvider.shapeInfoList.isNotEmpty) {
      // 이미 초기화되어 있으므로, 있는 것 사용
      dev.log('이미 초기화되어 있으므로, 있는 것 사용');
    } else {
      // load
      dev.log('SVG 로딩 START: ${DateTime.now()}');
      List<ShapeInfo> shapeInfoList = await FileUtil.loadShapeInfoList();
      dev.log('SVG 로딩 END: ${DateTime.now()}');
      parentProvider.shapeInfoList = shapeInfoList;

      // prefs 읽기
      String? prefsShapeInfoList = prefs.getString(AppConstant.PREFS_SHAPEINFOLIST);
      if (prefsShapeInfoList == null || prefsShapeInfoList.isEmpty) {
        // 최초인 경우
        dev.log('shapeInfoList 최초인 경우');

        // save prefs
        List<String> fileNameList = FileUtil.extractFileNameFromShapeInfoList(shapeInfoList);
        String fileNameStr = fileNameList.join(AppConstant.PREFS_DELIM);
        //dev.log('fileNameStr: $fileNameStr');
        await prefs.setString(AppConstant.PREFS_SHAPEINFOLIST, fileNameStr);
      } else {
        dev.log('prefsShapeInfoList parsing');

        // 파싱하여 사용
        List<String> fileNameList = prefsShapeInfoList!.split(AppConstant.PREFS_DELIM);
        dev.log('split fileNameList: $fileNameList');

        // reordering
        FileUtil.reorderingShapeInfoListWithFileNameList(shapeInfoList, fileNameList);
      }
    }
    parentProvider.selectedShapeInfoIdx = -1;
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // line - color
    dev.log('recentSignColorList START');
    String? prefsRecentSignColor = prefs.getString(AppConstant.PREFS_RECENTSIGNCOLOR);
    if (prefsRecentSignColor == null || prefsRecentSignColor.isEmpty) {
    } else {
      List<Color> recentSignColorList = [];
      List<String> recentSignColorStrList = prefsRecentSignColor!.split(AppConstant.PREFS_DELIM);
      for (String colorStr in recentSignColorStrList) {
        Color color = ColorUtil.convertStringToColor(colorStr);
        recentSignColorList.add(color);
      }
      parentProvider.recentSignColorList = recentSignColorList;
    }
    // 초기값 지정
    if (parentProvider.recentSignColorList.isEmpty) {
      parentProvider.signColor = Colors.blue;
    } else {
      parentProvider.signColor = parentProvider.recentSignColorList.elementAt(0);
    }
    parentProvider.signWidth = 10;
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // background - color
    dev.log('recentSignBackgroundColorList START');
    String? prefsSignBackgroundColor = prefs.getString(AppConstant.PREFS_RECENTSIGNBACKGROUNDCOLOR);
    if (prefsSignBackgroundColor == null || prefsSignBackgroundColor.isEmpty) {
    } else {
      List<Color> recentSignBackgroundColorList = [];
      List<String> recentSignBackgroundColorStrList = prefsSignBackgroundColor!.split(AppConstant.PREFS_DELIM);
      for (String colorStr in recentSignBackgroundColorStrList) {
        Color color = ColorUtil.convertStringToColor(colorStr);
        recentSignBackgroundColorList.add(color);
      }
      parentProvider.recentSignBackgroundColorList = recentSignBackgroundColorList;
    }
    // 초기값 지정 안함
    //if (parentProvider.recentSignBackgroundColorList.isEmpty)   parentProvider.signColor = Colors.yellow[50];
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // shape - border color
    dev.log('recentSignShapeBorderColorList START');
    String? prefsRecentSignShapeBorderColor = prefs.getString(AppConstant.PREFS_RECENTSHAPEBORDERCOLOR);
    if (prefsRecentSignShapeBorderColor == null || prefsRecentSignShapeBorderColor.isEmpty) {
    } else {
      List<Color> recentSignShapeBorderColorList = [];
      List<String> recentSignShapeBorderColorStrList = prefsRecentSignShapeBorderColor!.split(AppConstant.PREFS_DELIM);
      for (String colorStr in recentSignShapeBorderColorStrList) {
        Color color = ColorUtil.convertStringToColor(colorStr);
        recentSignShapeBorderColorList.add(color);
      }
      parentProvider.recentSignShapeBorderColorList = recentSignShapeBorderColorList;
    }
    // 초기값 지정 안함
    //if (parentProvider.recentSignShapeBorderColorList.isEmpty)   parentProvider.signShapeBorderColor = Colors.orange;
    parentProvider.signShapeBorderWidth = 10;
    ////////////////////////////////////////////////////////////////////////////////

  }

  void initPrefs() async {
    dev.log('initPrefs 초기화 START');

    // PREFS_SHAPEINFOLIST 초기화
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove(AppConstant.PREFS_SHAPEINFOLIST);
    parentProvider.shapeInfoList.clear();

    await prefs.remove(AppConstant.PREFS_RECENTSIGNCOLOR);
    parentProvider.recentSignColorList.clear();
    await prefs.remove(AppConstant.PREFS_RECENTSIGNBACKGROUNDCOLOR);
    parentProvider.recentSignBackgroundColorList.clear();
    await prefs.remove(AppConstant.PREFS_RECENTSHAPEBORDERCOLOR);
    parentProvider.recentSignShapeBorderColorList.clear();

    parentProvider.signBackgroundColor = null;
    parentProvider.signShapeBorderColor = null;
    parentProvider.signWidth = 10;
    parentProvider.signShapeBorderWidth = 10;


    setState(() {});

    dev.log('initPrefs 초기화 END');
  }

}
