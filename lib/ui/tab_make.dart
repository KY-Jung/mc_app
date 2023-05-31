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
import '../dto/info_sign.dart';
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
          MaterialPageRoute(builder: (context) => const MakeScreen()),
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
              onPressed: () async {

                ////////////////////////////////////////////////////////////////////////////////
                // 초기화 START
                ////////////////////////////////////////////////////////////////////////////////
                await initMakePage();
                ////////////////////////////////////////////////////////////////////////////////
                // 초기화 END
                ////////////////////////////////////////////////////////////////////////////////

                if (!mounted) return;
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

  Future<void> initMakePage() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    ////////////////////////////////////////////////////////////////////////////////
    // sign
    if (parentProvider.signInfoList.isNotEmpty) {
      // 이미 초기화되어 있으므로, 있는 것 사용
      dev.log('이미 signInfoList 초기화되어 있으므로, 재사용');
    } else {
      // load
      dev.log('PNG 로딩 START: ${DateTime.now()}');
      List<SignInfo> signInfoList = await FileUtil.loadSignInfoList(AppConstant.SIGN_DIR);
      dev.log('PNG 로딩 ${signInfoList.length} END: ${DateTime.now()}');

      // prefs 읽기
      String? prefsSignInfoList = prefs.getString(AppConstant.PREFS_SIGNINFOLIST);
      if (prefsSignInfoList == null || prefsSignInfoList.isEmpty) {
        // 최초인 경우
        dev.log('signInfoList 최초인 경우');

        // 저장되어 있는것 무시
        signInfoList = [];
      } else {
        dev.log('prefsSignInfoList parsing');

        // prefs 의 내용으로 순서 조정
        List<String> prefsFileNameList = prefsSignInfoList!.split(AppConstant.PREFS_DELIM);
        // reordering
        dev.log('!!! prefs 목록을 기준으로 순서 조정');
        signInfoList = FileUtil.reorderSignInfoListWithFileNameList(signInfoList, prefsFileNameList, AppConstant.PREFS_DELIM2);
      }

      parentProvider.signInfoList = signInfoList;
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // line - color
    String? prefsRecentSignColor = prefs.getString(AppConstant.PREFS_RECENTSIGNCOLOR);

    // recent color list
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
    dev.log('initMakePage recentSignColorList: ${parentProvider.recentSignColorList}');

    // sign color
    if (parentProvider.recentSignColorList.isEmpty) {
      parentProvider.signColor = Colors.blue;
    } else {
      parentProvider.signColor = parentProvider.recentSignColorList.elementAt(0);
    }
    dev.log('initMakePage signColor: ${parentProvider.signColor}');

    // sign width
    double? prefsSignWidth = prefs.getDouble(AppConstant.PREFS_SIGNWIDTH);
    if (prefsSignWidth == null) {
      parentProvider.signWidth = 10;
    } else {
      parentProvider.signWidth = prefsSignWidth;
    }
    dev.log('initMakePage signWidth: ${parentProvider.signWidth}');
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // background - color
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
    dev.log('initMakePage recentSignBackgroundColorList: ${parentProvider.recentSignBackgroundColorList}');
    parentProvider.signBackgroundColor = null;
    dev.log('initMakePage signBackgroundColor: ${parentProvider.signBackgroundColor}');
    parentProvider.signBackgroundUiImage = null;
    dev.log('initMakePage shapeBackgroundUiImage: ${parentProvider.signBackgroundUiImage}');
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // shape
    if (parentProvider.shapeInfoList.isNotEmpty) {
      // 이미 초기화되어 있으므로, 있는 것 사용
      dev.log('이미 shapeInfoList 초기화되어 있으므로, 재사용');
    } else {
      // load
      dev.log('SVG 로딩 START: ${DateTime.now()}');
      List<ShapeInfo> shapeInfoList = await FileUtil.loadShapeInfoList();
      dev.log('SVG 로딩 ${shapeInfoList.length} END: ${DateTime.now()}');

      // prefs 읽기
      String? prefsShapeInfoList = prefs.getString(AppConstant.PREFS_SHAPEINFOLIST);
      if (prefsShapeInfoList == null || prefsShapeInfoList.isEmpty) {
        // 최초인 경우 prefs 에 목록 저장
        dev.log('shapeInfoList 최초인 경우 prefs 에 목록 저장');

        // save prefs
        List<String> fileNameList = FileUtil.extractFileNameFromInfoList(shapeInfoList);
        String fileNameStr = fileNameList.join(AppConstant.PREFS_DELIM);
        await prefs.setString(AppConstant.PREFS_SHAPEINFOLIST, fileNameStr);
      } else {
        dev.log('prefsShapeInfoList parsing');

        // 목록이 재배포되었다면 다시 저장
        List<String> fileNameList = FileUtil.extractFileNameFromInfoList(shapeInfoList);
        String fileNameStr = fileNameList.join(AppConstant.PREFS_DELIM);

        if (prefsShapeInfoList != fileNameStr) {
          dev.log('!!! load 파일 목록과 prefs 목록이 다르므로 순서 조정');
          // 파싱하여 사용
          fileNameList = prefsShapeInfoList!.split(AppConstant.PREFS_DELIM);
          dev.log('split fileNameList: $fileNameList');

          // reordering
          //FileUtil.reorderShapeInfoListWithFileNameList(shapeInfoList, fileNameList);
          FileUtil.reorderInfoListWithFileNameList(shapeInfoList, fileNameList);

          // 다시 저장
          fileNameList = FileUtil.extractFileNameFromInfoList(shapeInfoList);
          fileNameStr = fileNameList.join(AppConstant.PREFS_DELIM);
          await prefs.setString(AppConstant.PREFS_SHAPEINFOLIST, fileNameStr);
        } else {
          dev.log('load 파일 목록과 prefs 목록 동일');
        }
      }

      parentProvider.shapeInfoList = shapeInfoList;
    }

    // selected idx
    parentProvider.selectedShapeInfoIdx = -1;

    // shape - border color
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
    parentProvider.signShapeBorderColor = null;
    dev.log('initMakePage signShapeBorderColor: ${parentProvider.signShapeBorderColor}');

    // border width
    double? prefsShapeBorderWidth = prefs.getDouble(AppConstant.PREFS_SHAPEBORDERWIDTH);
    if (prefsShapeBorderWidth == null) {
      parentProvider.signShapeBorderWidth = 10;
    } else {
      parentProvider.signShapeBorderWidth = prefsShapeBorderWidth;
    }
    dev.log('initMakePage signShapeBorderWidth: ${parentProvider.signShapeBorderWidth}');
    ////////////////////////////////////////////////////////////////////////////////

  }

  void initPrefs() async {
    dev.log('initPrefs 초기화 START');

    // PREFS_SHAPEINFOLIST 초기화
    SharedPreferences prefs = await SharedPreferences.getInstance();

    ////////////////////////////////////////////////////////////////////////////////
    // sign
    await prefs.remove(AppConstant.PREFS_SIGNINFOLIST);

    // line
    await prefs.remove(AppConstant.PREFS_RECENTSIGNCOLOR);
    await prefs.remove(AppConstant.PREFS_SIGNWIDTH);

    // background
    await prefs.remove(AppConstant.PREFS_RECENTSIGNBACKGROUNDCOLOR);

    // shape
    await prefs.remove(AppConstant.PREFS_SHAPEINFOLIST);
    await prefs.remove(AppConstant.PREFS_RECENTSHAPEBORDERCOLOR);
    await prefs.remove(AppConstant.PREFS_SHAPEBORDERWIDTH);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // parentProvider
    parentProvider.recentSignColorList.clear();
    parentProvider.recentSignBackgroundColorList.clear();
    parentProvider.shapeInfoList.clear();
    parentProvider.recentSignShapeBorderColorList.clear();

    parentProvider.initAll(notify: false);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // 초기화 후에 하나도 안 보이므로 일단 모두 추가하기
    parentProvider.signInfoList = await FileUtil.loadSignInfoList(AppConstant.SIGN_DIR);
    ////////////////////////////////////////////////////////////////////////////////
    
    setState(() {});

    dev.log('initPrefs 초기화 END');
  }

}
