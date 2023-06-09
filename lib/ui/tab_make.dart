import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mc/config/constant_app.dart';
import 'package:mc/model/sqlite_mcuser.dart';
import 'package:mc/ui/page_make.dart';
import 'package:mc/util/util_popup.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dto/info_shapefile.dart';
import '../dto/info_signfile.dart';
import '../model/mcuser.dart';

import '../provider/provider_make.dart';
import '../provider/provider_parent.dart';
import '../provider/provider_sign.dart';
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
  late SignProvider signProvider;

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
          MaterialPageRoute(builder: (context) => const MakePage()),
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
    signProvider = Provider.of<SignProvider>(context, listen: false);
    ////////////////////////////////////////////////////////////////////////////////

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('MAKE'.tr(), style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            ElevatedButton(
              child: Text('MAKE_NEW'.tr()),
              onPressed: () async {

                ////////////////////////////////////////////////////////////////////////////////
                // 있으면 재사용
                if (parentProvider.path != null) {
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MakePage()),
                  );
                  return;
                }
                ////////////////////////////////////////////////////////////////////////////////

                ////////////////////////////////////////////////////////////////////////////////
                // 초기화 START
                await initSignProvider();
                // 초기화 END
                ////////////////////////////////////////////////////////////////////////////////

                ////////////////////////////////////////////////////////////////////////////////
                // 없으면 parent 먼저 선택
                if (!mounted) return;
                await PopupUtil.popupImageBring(context, 'INFO'.tr(), 'PARENT_BRING'.tr()).then((ret) async {
                  dev.log('popupImageBring: $ret');

                  if (ret == null) {
                    // 팝업 바깥 영역을 클릭한 경우
                    return;
                  }
                  if (ret == AppConstant.CANCEL) {
                    return;
                  }

                  // path 저장 및 초기화
                  //await InfoUtil.setparentProvider(ret);
                  // make page 의 initState 에서 하는 것으로 수정
                  //parentProvider.setParenProvider(ret).then((_) => {});
                  // 여기서 하면 팝업이 빨리 사라지지 않는 경우가 있음 (2023.06.02, KY.Jung)
                  //await parentProvider.initParenProvider(ret);
                  await parentProvider.initParenProviderWithPath(ret);

                  // 페이지 이동
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MakePage()),
                  );
                });
                ////////////////////////////////////////////////////////////////////////////////
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('* clear PREFS *'),
              onPressed: () async {
                clearPrefs();
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('* loadSignFileAndSavePrefs *'),
              onPressed: () async {
                loadSignFileAndSavePrefs();
              },
            ),
            const SizedBox(height: 20),
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
              await userSqlite.setUser(McUser(email: 'test_1@gainsys.kr', signKey: '123abc'));
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

  Future<void> initSignProvider() async {
    dev.log('# MakeTab initSignProvider START');

    SharedPreferences prefs = await SharedPreferences.getInstance();

    ////////////////////////////////////////////////////////////////////////////////
    // ParentBar sign

    // parentSignFileInfoIdx
    signProvider.parentSignFileInfoIdx = -1;

    // parentSignOffset
    double? prefsParentSignOffsetX = prefs.getDouble(AppConstant.PREFS_PARENTSIGNOFFSET_X);
    double? prefsParentSignOffsetY = prefs.getDouble(AppConstant.PREFS_PARENTSIGNOFFSET_Y);
    if (prefsParentSignOffsetX == null || prefsParentSignOffsetY == null) {
      signProvider.parentSignOffset = null;
    } else {
      signProvider.parentSignOffset = Offset(prefsParentSignOffsetX, prefsParentSignOffsetY);
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // sign

    // signFileInfoList
    if (signProvider.signFileInfoList.isNotEmpty) {
      // 이미 초기화되어 있으므로, 있는 것 사용
      dev.log('이미 signFileInfoList 초기화되어 있으므로, 재사용');
    } else {
      // load
      dev.log('PNG 로딩 START: ${DateTime.now()}');
      List<SignFileInfo> signFileInfoList = await FileUtil.loadSignFileInfoList(AppConstant.SIGN_DIR);
      dev.log('PNG 로딩 ${signFileInfoList.length} END: ${DateTime.now()}');

      // prefs 읽기
      String? prefsSignFileInfoList = prefs.getString(AppConstant.PREFS_SIGNFILEINFOLIST);
      if (prefsSignFileInfoList == null || prefsSignFileInfoList.isEmpty) {
        // 최초인 경우
        dev.log('signFileInfoList prefs 에 없음');

        // 저장되어 있는것 무시
        signFileInfoList = [];
      } else {
        dev.log('prefsSignFileInfoList parsing');

        // prefs 의 내용으로 순서 조정
        List<String> prefsFileNameList = prefsSignFileInfoList.split(AppConstant.PREFS_DELIM);
        // reordering
        dev.log('!!! prefs 목록을 기준으로 순서 조정');
        /// fileNameList 에 없는 것은 반환하지 않음
        signFileInfoList = FileUtil.reorderSignFileInfoListWithFileNameList(
            signFileInfoList, prefsFileNameList, AppConstant.PREFS_DELIM2);
      }
      signProvider.signFileInfoList = signFileInfoList;
    }

    // selectedSignFileInfoIdx
    signProvider.selectedSignFileInfoIdx = -1;

    // selectedSignFileInfoIdx
    signProvider.clearSignUiImage();
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // line
    // recentSignColorList
    signProvider.signLines.clear();

    // recentSignColorList
    String? prefsRecentSignColor = prefs.getString(AppConstant.PREFS_RECENTSIGNCOLOR);
    if (prefsRecentSignColor == null || prefsRecentSignColor.isEmpty) {
    } else {
      List<Color> recentSignColorList = [];
      List<String> recentSignColorStrList = prefsRecentSignColor.split(AppConstant.PREFS_DELIM);
      for (String colorStr in recentSignColorStrList) {
        Color color = ColorUtil.convertStringToColor(colorStr);
        recentSignColorList.add(color);
      }
      signProvider.recentSignColorList = recentSignColorList;
    }
    dev.log('initMakePage recentSignColorList: ${signProvider.recentSignColorList}');

    // signColor
    if (signProvider.recentSignColorList.isEmpty) {
      signProvider.signColor = Colors.blue;
    } else {
      signProvider.signColor = signProvider.recentSignColorList.elementAt(0);
    }
    dev.log('initMakePage signColor: ${signProvider.signColor}');

    // signWidth
    double? prefsSignWidth = prefs.getDouble(AppConstant.PREFS_SIGNWIDTH);
    if (prefsSignWidth == null) {
      signProvider.signWidth = 10;
    } else {
      signProvider.signWidth = prefsSignWidth;
    }
    dev.log('initMakePage signWidth: ${signProvider.signWidth}');
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // background

    // recentSignBackgroundColorList
    String? prefsSignBackgroundColor = prefs.getString(AppConstant.PREFS_RECENTSIGNBACKGROUNDCOLOR);
    if (prefsSignBackgroundColor == null || prefsSignBackgroundColor.isEmpty) {
    } else {
      List<Color> recentSignBackgroundColorList = [];
      List<String> recentSignBackgroundColorStrList = prefsSignBackgroundColor.split(AppConstant.PREFS_DELIM);
      for (String colorStr in recentSignBackgroundColorStrList) {
        Color color = ColorUtil.convertStringToColor(colorStr);
        recentSignBackgroundColorList.add(color);
      }
      signProvider.recentSignBackgroundColorList = recentSignBackgroundColorList;
    }
    dev.log('initMakePage recentSignBackgroundColorList: ${signProvider.recentSignBackgroundColorList}');

    // signBackgroundColor
    signProvider.signBackgroundColor = null;
    dev.log('initMakePage signBackgroundColor: ${signProvider.signBackgroundColor}');

    // signBackgroundUiImage
    signProvider.clearSignBackgroundUiImage();
    dev.log('initMakePage shapeBackgroundUiImage: ${signProvider.signBackgroundUiImage}');
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // shape

    // shapeFileInfoList
    if (signProvider.shapeFileInfoList.isNotEmpty) {
      // 이미 초기화되어 있으므로, 있는 것 사용
      dev.log('이미 shapeFileInfoList 초기화되어 있으므로, 재사용');
    } else {
      // load
      dev.log('SVG 로딩 START: ${DateTime.now()}');
      List<ShapeFileInfo> shapeFileInfoList = await FileUtil.loadShapeFileInfoList();
      dev.log('SVG 로딩 ${shapeFileInfoList.length} END: ${DateTime.now()}');

      // prefs 읽기
      String? prefsShapeFileInfoList = prefs.getString(AppConstant.PREFS_SHAPEFILEINFOLIST);
      if (prefsShapeFileInfoList == null || prefsShapeFileInfoList.isEmpty) {
        // 최초인 경우 prefs 에 목록 저장
        dev.log('shapeFileInfoList 최초인 경우 prefs 에 목록 저장');

        // save prefs
        List<String> fileNameList = FileUtil.extractFileNameFromInfoList(shapeFileInfoList);
        String fileNameStr = fileNameList.join(AppConstant.PREFS_DELIM);
        await prefs.setString(AppConstant.PREFS_SHAPEFILEINFOLIST, fileNameStr);
      } else {
        dev.log('prefsShapeFileInfoList parsing');

        // 목록이 재배포되었다면 다시 저장
        List<String> fileNameList = FileUtil.extractFileNameFromInfoList(shapeFileInfoList);
        String fileNameStr = fileNameList.join(AppConstant.PREFS_DELIM);

        if (prefsShapeFileInfoList != fileNameStr) {
          dev.log('!!! load 파일 목록과 prefs 목록이 다르므로 순서 조정');
          // 파싱하여 사용
          fileNameList = prefsShapeFileInfoList.split(AppConstant.PREFS_DELIM);
          dev.log('split fileNameList: $fileNameList');

          // reordering
          //FileUtil.reorderShapeFileInfoListWithFileNameList(shapeFileInfoList, fileNameList);
          FileUtil.reorderInfoListWithFileNameList(shapeFileInfoList, fileNameList);

          // 다시 저장
          fileNameList = FileUtil.extractFileNameFromInfoList(shapeFileInfoList);
          fileNameStr = fileNameList.join(AppConstant.PREFS_DELIM);
          await prefs.setString(AppConstant.PREFS_SHAPEFILEINFOLIST, fileNameStr);
        } else {
          dev.log('load 파일 목록과 prefs 목록 동일');
        }
      }
      signProvider.shapeFileInfoList = shapeFileInfoList;
    }

    // selectedSignShapeFileInfoIdx
    signProvider.selectedSignShapeFileInfoIdx = -1;

    //  recentSignShapeBorderColorList
    String? prefsRecentSignShapeBorderColor = prefs.getString(AppConstant.PREFS_RECENTSHAPEBORDERCOLOR);
    if (prefsRecentSignShapeBorderColor == null || prefsRecentSignShapeBorderColor.isEmpty) {
    } else {
      List<Color> recentSignShapeBorderColorList = [];
      List<String> recentSignShapeBorderColorStrList = prefsRecentSignShapeBorderColor.split(AppConstant.PREFS_DELIM);
      for (String colorStr in recentSignShapeBorderColorStrList) {
        Color color = ColorUtil.convertStringToColor(colorStr);
        recentSignShapeBorderColorList.add(color);
      }
      signProvider.recentSignShapeBorderColorList = recentSignShapeBorderColorList;
    }

    // signShapeBorderColor
    signProvider.signShapeBorderColor = null;
    dev.log('initMakePage signShapeBorderColor: ${signProvider.signShapeBorderColor}');

    // signShapeBorderWidth
    double? prefsSignShapeBorderWidth = prefs.getDouble(AppConstant.PREFS_SIGNSHAPEBORDERWIDTH);
    if (prefsSignShapeBorderWidth == null) {
      signProvider.signShapeBorderWidth = 10;
    } else {
      signProvider.signShapeBorderWidth = prefsSignShapeBorderWidth;
    }
    dev.log('initMakePage signShapeBorderWidth: ${signProvider.signShapeBorderWidth}');
    ////////////////////////////////////////////////////////////////////////////////

    dev.log('# MakeTab initSignProvider EMD');
  }

  // for test
  void clearPrefs() async {
    dev.log('# MakeTab initPrefs 초기화 START');

    // PREFS_SHAPEFILEINFOLIST 초기화
    SharedPreferences prefs = await SharedPreferences.getInstance();

    ////////////////////////////////////////////////////////////////////////////////
    // SignProvider

    // signfile
    await prefs.remove(AppConstant.PREFS_SIGNFILEINFOLIST);
    await prefs.remove(AppConstant.PREFS_PARENTSIGNOFFSET_X);
    await prefs.remove(AppConstant.PREFS_PARENTSIGNOFFSET_Y);

    // line
    await prefs.remove(AppConstant.PREFS_RECENTSIGNCOLOR);
    await prefs.remove(AppConstant.PREFS_SIGNWIDTH);

    // background
    await prefs.remove(AppConstant.PREFS_RECENTSIGNBACKGROUNDCOLOR);

    // shape
    await prefs.remove(AppConstant.PREFS_SHAPEFILEINFOLIST);
    await prefs.remove(AppConstant.PREFS_RECENTSHAPEBORDERCOLOR);
    await prefs.remove(AppConstant.PREFS_SIGNSHAPEBORDERWIDTH);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // signProvider
    signProvider.signFileInfoList.clear();

    signProvider.recentSignColorList.clear();
    signProvider.recentSignBackgroundColorList.clear();

    signProvider.shapeFileInfoList.clear();
    signProvider.recentSignShapeBorderColorList.clear();

    signProvider.clearAll();
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // 초기화 후에 하나도 안 보이므로 일단 모두 추가하기
    loadSignFileAndSavePrefs();
    ////////////////////////////////////////////////////////////////////////////////

    setState(() {});

    dev.log('# MakeTab initPrefs 초기화 END');
  }

  void loadSignFileAndSavePrefs() async {
    dev.log('# MakeTab loadSignFileAndSavePrefs START');

    ////////////////////////////////////////////////////////////////////////////////
    // 초기화 후에 하나도 안 보이므로 일단 모두 추가하기
    signProvider.signFileInfoList = await FileUtil.loadSignFileInfoList(AppConstant.SIGN_DIR);
    dev.log('signProvider.signFileInfoList ${signProvider.signFileInfoList}');

    // prefs 에 반영
    List<String> fileNameList =
        FileUtil.extractFileNameAndCntFromSignFileInfoList(signProvider.signFileInfoList, AppConstant.PREFS_DELIM2);
    String fileNameStr = fileNameList.join(AppConstant.PREFS_DELIM);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(AppConstant.PREFS_SIGNFILEINFOLIST, fileNameStr);
    ////////////////////////////////////////////////////////////////////////////////
  }

}
