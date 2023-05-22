import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jpeg_encode/jpeg_encode.dart';
import 'package:mc/config/constant_app.dart';
import 'package:mc/ui/popup_sign.dart';
import 'package:mc/ui/page_make.dart';
import 'package:mc/util/util_popup.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;

import '../config/color_app.dart';
import '../config/config_app.dart';
import '../dto/info_parent.dart';
import '../dto/info_shape.dart';
import '../painter/painter_make_parent_sign.dart';
import '../provider/provider_make.dart';
import '../provider/provider_parent.dart';
import '../util/util_file.dart';
import '../util/util_info.dart';
import 'mbs_sign.dart';

enum ParentBarEnum { FRAME, RESIZE, SIGN }

class ParentBar extends StatefulWidget {
  const ParentBar({super.key});

  //final void Function(bool isSize) callbackParentSizeInitScreen;
  //const ParentWidget({required this.callbackParentSizeInitScreen, super.key});
  //const ParentWidget({ Key? key, required this.callbackParentSizeInitScreen, }) : super(key: key);

  @override
  State<ParentBar> createState() => ParentBarState();
}

class ParentBarState extends State<ParentBar> {
  ////////////////////////////////////////////////////////////////////////////////
  List<bool> toggleSelectList = [false, false, false];

  //ParentBarEnum _makeParentEnum = ParentBarEnum.FRAME;

  late MakeProvider makeProvider;
  late ParentProvider parentProvider;
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# ParentBar initState START');
    super.initState();

    // resize 하다가 다른 bar 로 갔다가 다시 돌아온 경우 처리
    InfoUtil.initParentInfoBracket();

    ////////////////////////////////////////////////////////////////////////////////
    /// build 이후 실행
    /// SharedPreferences.getInstance() 는 initState/build 에서는 await 효과 없으므로
    /// build 이후에 다시 실행하는 것으로 수정함


    //WidgetsBinding.instance
    //    .addPostFrameCallback((_) => _loadPreferences(context));
    ////////////////////////////////////////////////////////////////////////////////

    /*
    // ######################################################################## //
    // TODO : 임시 사용, 초기 화면 지정
    makeParentEnum = MakeParentEnum.SIZE;
    toggleSelectList = [false, true, false];

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(
          'MakeParentEnum', EnumToString.convertToString(makeParentEnum));
    });
    // ######################################################################## //
    */

    dev.log('# ParentBar initState END');
  }

  @override
  void dispose() {
    dev.log('# ParentBar dispose START');
    super.dispose();

    // 마지막 상태 저장
    // 맨 나중에 호출되어서 아래코드 효과없음
    //ParentInfo.isSize = false;
    // 아래 코드는 에러 유발
    //widget.callbackParentSizeInitScreen();

    //InfoUtil.initParentInfoBracket();
    //makeProvider.setParentResize(false);
    //makeProvider.setParentResizeWithNoNotify(false);
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# ParentBar build START');

    ////////////////////////////////////////////////////////////////////////////////
    makeProvider = Provider.of<MakeProvider>(context);
    parentProvider = Provider.of<ParentProvider>(context);
    ////////////////////////////////////////////////////////////////////////////////


    ////////////////////////////////////////////////////////////////////////////////
    //toggleSelectList = [false, false, false];
    //switch (_makeParentEnum) {
    switch (parentProvider.parentBarEnum) {
      case ParentBarEnum.FRAME:
        dev.log('case ParentBarEnum.FRAME');
        toggleSelectList[0] = true;
        break;
      case ParentBarEnum.RESIZE:
        dev.log('case ParentBarEnum.RESIZE');
        toggleSelectList[1] = true;
        break;
      case ParentBarEnum.SIGN:
        dev.log('case ParentBarEnum.SIGN');
        toggleSelectList[2] = true;
        break;
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    double hBarDetail = AppBar().preferredSize.height *
        AppConfig.FUNCTIONBAR_HEIGHT *
        AppConfig.MAKE_FUNCTIONBAR_2 /
        (AppConfig.MAKE_FUNCTIONBAR_1 + AppConfig.MAKE_FUNCTIONBAR_2);
    double whPreSign = hBarDetail - 20 * 2;

    List<String> preSignList = <String>['A', 'B', 'C', '1', '2', '3', '4'];
    List<int> colorCodes = <int>[600, 500, 400, 300, 200, 100, 100];
    ////////////////////////////////////////////////////////////////////////////////

    return Scaffold(
      //backgroundColor: Colors.yellow,
      //backgroundColor: Colors.black87,
      backgroundColor: AppColors.MAKE_PARENT_FB_BACKGROUND,
      body: Column(
        children: <Widget>[
          Expanded(
            flex: AppConfig.MAKE_FUNCTIONBAR_1,
            child: ToggleButtons(
              color: Colors.grey,
              selectedColor: Colors.black,
              fillColor: Colors.white,
              //disabledColor: Colors.white10,
              renderBorder: true,
              borderRadius: BorderRadius.circular(10),
              borderWidth: 2,
              borderColor: Colors.white60,
              selectedBorderColor: Colors.white70,
              isSelected: toggleSelectList,
              //constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width * 0.25),
              onPressed: _toggleButtonsSelect,
              children: [
                Container(
                    //height: 40,
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.06),
                    child: Text(
                      'FRAME'.tr(),
                    )),
                Container(
                  //height: 40,
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.06),
                  child: Text(
                    'SIZE'.tr(),
                  ),
                ),
                Container(
                  //height: 40,
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.06),
                  child: Text(
                    'SIGN'.tr(),
                  ),
                ),
              ],
            ),
          ),
          if (parentProvider.parentBarEnum == ParentBarEnum.FRAME)
            Expanded(
              flex: AppConfig.MAKE_FUNCTIONBAR_2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    child:
                        Text('FRAME parentSize1'),
                    onPressed: () {},
                  ),
                  ElevatedButton(
                    child:
                        Text('FRAME parentSize2'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          if (parentProvider.parentBarEnum == ParentBarEnum.RESIZE)
            Expanded(
              flex: AppConfig.MAKE_FUNCTIONBAR_2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _onPressedSizeInit,
                    child: Text('SIZE_INIT'.tr()),
                  ),
                  ElevatedButton(
                    onPressed: _onPressedSizeSave,
                    child: Text('SIZE_SAVE'.tr()),
                  ),
                ],
              ),
            ),
          if (parentProvider.parentBarEnum == ParentBarEnum.SIGN)
            Expanded(
              flex: AppConfig.MAKE_FUNCTIONBAR_2,
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  InkWell(
                    onTap: _onTapNone,
                    child: Container(
                      width: whPreSign,
                      height: whPreSign,
                      //margin: const EdgeInsets.all(10),
                      margin: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                      alignment: Alignment.center,
                      color: Colors.black12,
                      child: Text(
                        'NONE'.tr(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.yellow[50],
                      //margin: const EdgeInsets.all(10),
                      margin: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(10),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: preSignList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Row(
                            children: [
                              InkWell(
                                onTap: () => _onTapPreSign(index),
                                child: Container(
                                  width: whPreSign,
                                  height: whPreSign,
                                  color: Colors.amber[colorCodes[index]],
                                  child: badges.Badge(
                                    badgeContent: Text('${index + 1}'),
                                    badgeStyle: badges.BadgeStyle(
                                      badgeColor: AppColors.BLUE_LIGHT,
                                    ),
                                    child: Center(
                                        child: Text('${preSignList[index]}')),
                                  ),
                                ),
                              ),
                              Container(
                                width: 20,
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(),
                      ),
                    ),
                  ),
                  SizedBox.fromSize(
                    size: const Size(AppConfig.SQUARE_BUTTON_SIZE,
                        AppConfig.SQUARE_BUTTON_SIZE),
                    child: ClipOval(
                      child: Material(
                        color: Colors.black38,
                        child: InkWell(
                          splashColor: Colors.grey,
                          onTap: _onTapSignNew,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Icon(Icons.edit),
                              Text('SIZE_SIGN_MAKE'.tr()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: (hBarDetail - AppConfig.SQUARE_BUTTON_SIZE) / 2,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////////
  /// 초기화가 필요한 항목들 처리
  /// 1. Frame 선택, 목록에서 없음 선택
  /// 2. Size 에서 화면과 버튼 초기화
  /// 3. Sign 에서 선택 초기화 안함

  /// frame, size, sign 선택 + 세부 항목


  // TODO : remove code and 미리 Provider 에 셋팅하는 것으로 변경
  void _loadPreferences(context) {
    dev.log('# ParentBar _loadPreferences START');
/*
    SharedPreferences.getInstance().then((prefs) {
      //SharedPreferences prefs = SharedPreferences.getInstance();
      bool isChanged = false;

      var retPrefs = prefs.getString('MakeParentEnum');
      if (retPrefs == null) {
        // 처음인 경우
        makeProvider.parentBarEnum = ParentBarEnum.FRAME;
        prefs.setString(
            'MakeParentEnum', EnumToString.convertToString(_makeParentEnum));
      } else {
        var retEnum = EnumToString.fromString(ParentBarEnum.values, retPrefs);
        if (retEnum == null) {
          // 에러 상황 (enum 에 없는 값이 저장된 경우)
          makeProvider.parentBarEnum = ParentBarEnum.FRAME;
          prefs.setString(
              'MakeParentEnum', EnumToString.convertToString(_makeParentEnum));
        } else {
          if (makeProvider.parentBarEnum != retEnum) {
            isChanged = true;
          }
          makeProvider.parentBarEnum = retEnum;
        }
      }
      dev.log('_makeParentEnum: ${}makeProvider.parentBarEnum}');

      toggleSelectList = [false, false, false];
      switch (_makeParentEnum) {
        case ParentBarEnum.FRAME:
          dev.log('case MakeParentEnum.FRAME');
          toggleSelectList[0] = true;

          if (!mounted) return;
          if (makeProvider.parentResize) {
            makeProvider.setParentResize(false);
          }
          break;
        case ParentBarEnum.RESIZE:
          dev.log('case MakeParentEnum.SIZE');
          toggleSelectList[1] = true;

          if (!mounted) return;
          if (!makeProvider.parentResize) {
            makeProvider.setParentResize(true);
          }
          break;
        case ParentBarEnum.SIGN:
          dev.log('case MakeParentEnum.SIGN');
          toggleSelectList[2] = true;

          if (!mounted) return;
          if (makeProvider.parentResize) {
            makeProvider.setParentResize(false);
          }
          break;
      }

      if (isChanged) {
        setState(() {});
      }

    });
*/
    dev.log('# ParentBar _loadPreferences END');
    //ParentInfo.xyOffset = const Offset(0, 0);
  }

  ////////////////////////////////////////////////////////////////////////////////
  // MakePage 의 _onTapDownAll 에서 toggle 처리를 하므로, 아래 코드 사용하지 않음
  void _onTapDownAll(TapDownDetails tapDownDetails) async {
    dev.log('# ParentBar _onTapDownAll');

    /*
    // fab close 처리 (provider 를 사용해서 닫기)
    if (makeProvider.fabOpen) {
      makeProvider.setFabOpen(false);
    }
    */
  }

  void _toggleButtonsSelect(idx) {
    dev.log('# ParentBar _toggleButtonsSelect START');
    dev.log('case idx: $idx');

    // for test
    //ParentInfo.printParent();

    toggleSelectList = [false, false, false];
    switch (idx) {
      case 0:
        //if (makeParentEnum == MakeParentEnum.FRAME)  return;
        //_makeParentEnum = ParentBarEnum.FRAME;
        parentProvider.setParentBarEnum(ParentBarEnum.FRAME);
        toggleSelectList[0] = true;
        break;
      case 1:
        //if (makeParentEnum == MakeParentEnum.SIZE)  return;
        //_makeParentEnum = ParentBarEnum.RESIZE;
        parentProvider.setParentBarEnum(ParentBarEnum.RESIZE);
        toggleSelectList[1] = true;

        InfoUtil.initParentInfoBracket();
        break;
      case 2:
        //if (makeParentEnum == MakeParentEnum.SIGN)  return;
        //_makeParentEnum = ParentBarEnum.SIGN;
        parentProvider.setParentBarEnum(ParentBarEnum.SIGN);
        toggleSelectList[2] = true;
        break;
    }
    //SharedPreferences.getInstance().then((prefs) {
    //  prefs.setString(
    //      'MakeParentEnum', EnumToString.convertToString(_makeParentEnum));
    //});

    /*
    // TODO : impl
    switch (_makeParentEnum) {
      case ParentBarEnum.FRAME:
        if (makeProvider.parentResize) {
          makeProvider.setParentResize(false);
        }
        //context.read<MakeProvider>().setParentSize(false);
        break;
      case ParentBarEnum.RESIZE:
        dev.log('case MakeParentEnum.RESIZE');
        InfoUtil.initParentInfoBracket();

        if (!makeProvider.parentResize) {
          makeProvider.setParentResize(true);
        }
        //context.read<MakeProvider>().setParentSize(true);
        break;
      case ParentBarEnum.SIGN:
        if (makeProvider.parentResize) {
          makeProvider.setParentResize(false);
        }
        //context.read<MakeProvider>().setParentSize(false);
        break;
    }
     */

    //ParentInfo.xyOffset = const Offset(0, 0);

    //setState(() {});
  }

  void _onPressedSizeInit() {
    dev.log('# ParentBar _onPressedSizeInit START');

    ParentInfo.leftTopOffset = Offset(
        ParentInfo.leftTopOffset.dx + 10, ParentInfo.leftTopOffset.dy + 10);
    ParentInfo.rightTopOffset = Offset(
        ParentInfo.rightTopOffset.dx - 10, ParentInfo.rightTopOffset.dy + 10);
    ParentInfo.leftBottomOffset = Offset(ParentInfo.leftBottomOffset.dx + 10,
        ParentInfo.leftBottomOffset.dy - 10);
    ParentInfo.rightBottomOffset = Offset(ParentInfo.rightBottomOffset.dx - 10,
        ParentInfo.rightBottomOffset.dy - 10);
    //makeProvider.setParentResize(true);   <-- 잘못된 코드
    parentProvider.setParentBarEnum(ParentBarEnum.RESIZE);    // for refresh
    //setState(() {});
    //context.read<MakeProvider>().setParentSize(true);

    Timer(const Duration(milliseconds: AppConfig.SIZE_INIT_INTERVAL), () {
      dev.log('# ParentBar _onPressedSizeInit Timer');
      InfoUtil.initParentInfoBracket();

      // 한번 더 refresh 해야 함
      //makeProvider.setParentResize(true);   <-- 잘못된 코드
      parentProvider.setParentBarEnum(ParentBarEnum.RESIZE);    // for refresh
      //setState(() {});
    });
  }

  void _onPressedSizeSave() async {
    dev.log('# ParentBar _onPressedSizeSave START');

    ////////////////////////////////////////////////////////////////////////////////
    bool leftTop =
        (ParentInfo.leftTopOffset.dx.toInt() == ParentInfo.xBlank.toInt() &&
            ParentInfo.leftTopOffset.dy.toInt() == ParentInfo.yBlank.toInt());
    bool rightTop = (ParentInfo.rightTopOffset.dx.toInt() ==
            (ParentInfo.wScreen - ParentInfo.xBlank).toInt() &&
        ParentInfo.rightTopOffset.dy.toInt() == ParentInfo.yBlank.toInt());
    bool leftBottom =
        (ParentInfo.leftBottomOffset.dx.toInt() == ParentInfo.xBlank.toInt() &&
            ParentInfo.leftBottomOffset.dy.toInt() ==
                (ParentInfo.hScreen - ParentInfo.yBlank).toInt());
    bool rightBottom = (ParentInfo.rightBottomOffset.dx.toInt() ==
            (ParentInfo.wScreen - ParentInfo.xBlank).toInt() &&
        ParentInfo.rightBottomOffset.dy.toInt() ==
            (ParentInfo.hScreen - ParentInfo.yBlank).toInt());

    // 변경된 것이 없으면 return
    if (leftTop && rightTop && leftBottom && rightBottom) {
      dev.log('_onPressedSizeSave SIZE_NO_CHANGE');
      PopupUtil.toastMsgShort('SIZE_NO_CHANGE'.tr());
      return;
    }
    ////////////////////////////////////////////////////////////////////////////////

    dev.log('_onPressedSizeSave SIZE_CHANGE');

    ////////////////////////////////////////////////////////////////////////////////
    // 새로 저장

    // 선택한 영역 구하기
    Offset leftTopOffset = ParentInfo.leftTopOffset;
    Offset rightTopOffset = ParentInfo.rightTopOffset;
    //Offset leftBottomOffset = ParentInfo.leftBottomOffset;
    Offset rightBottomOffset = ParentInfo.rightBottomOffset;
    double xBlank = ParentInfo.xBlank;
    double yBlank = ParentInfo.yBlank;
    double inScale = ParentInfo.inScale;
    Rect srcRect = Offset((leftTopOffset.dx - xBlank) / inScale,
            (leftTopOffset.dy - yBlank) / inScale) &
        Size((rightTopOffset.dx - leftTopOffset.dx) / inScale,
            (rightBottomOffset.dy - rightTopOffset.dy) / inScale);
    dev.log('srcRect: $srcRect');

    // 저장할 영역 구하기
    Rect dstRect = const Offset(0, 0) & Size(srcRect.width, srcRect.height);

    // 그리기
    ui.Image uiImage = await InfoUtil.loadUiImageFromPath(ParentInfo.path);
    ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder, dstRect);
    canvas.drawImageRect(uiImage, srcRect, dstRect, Paint());
    uiImage.dispose();

    // 새로 uiImage 생성
    ui.Image newImage = await pictureRecorder
        .endRecording()
        .toImage(srcRect.width.toInt(), srcRect.height.toInt());    // 여기서 scaling 안됨

    // 화면에 보여주기
    Widget imageWidget = RawImage(
      image: newImage,
    );
    double wPopup = ParentInfo.wScreen * 0.8;
    double hPopup = ParentInfo.hScreen * 0.4;
    if (!mounted) return;
    PopupUtil.popupImageOkCancel(context, 'CONFIRM'.tr(),
            'SIZE_SAVE_CONFIRM'.tr(), imageWidget, wPopup, hPopup)
        .then((ret) async {
      dev.log('popupImageOkCancel: $ret');

      // example
      if (ret == null) {
        // 팝업 바깥 영역을 클릭한 경우
        newImage.dispose();
        return;
      }
      if (ret == AppConstant.OK) {
        /*
        // 이전 파일 지우고 신규 파일명 구하기
        Directory appDir = await getApplicationDocumentsDirectory();
        dev.log('getApplicationDocumentsDirectory: $appDir');
        String newPath = '${appDir.path}/${AppConstant.PARENT_RESIZE_DIR}';
        dev.log('newPath: $newPath');
        File newPathFile = File(newPath);
        bool f = await newPathFile.exists(); // 항상 false --> ?
        try {
          if (f) {
            dev.log('newPathFile.exists: true');
            newPathFile.deleteSync(recursive: true);
          }
          newPathFile.deleteSync(recursive: true);
        } catch (e) {
          print(e);
        }
        String fileName = '${appDir.path}/${AppConstant.PARENT_RESIZE_DIR}/'
            '${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.jpg';
        File newImageFile = File(fileName);
        newImageFile.createSync(recursive: true);
        */
        ////////////////////////////////////////////////////////////////////////////////
        File newImageFile = await FileUtil.initTempDirAndFile(AppConstant.PARENT_RESIZE_DIR, 'jpg');
        dev.log('newImageFile.path: ${newImageFile.path}');

        /*
        // Uint8List 로 변환
        ByteData? rgbByte = await newImage.toByteData(format: ui.ImageByteFormat.rawRgba);
        Uint8List jpgByte = JpegEncoder().compress(
            rgbByte!.buffer.asUint8List(), newImage.width, newImage.height, 98);
        // byte 저장
        newImageFile.writeAsBytesSync(jpgByte.buffer.asUint8List(),
            flush: true, mode: FileMode.write);
        */
        await FileUtil.saveUiImageToJpg(newImage, newImageFile);
        dev.log('writeAsBytesSync end');
        ////////////////////////////////////////////////////////////////////////////////

        ////////////////////////////////////////////////////////////////////////////////
        // 화면 갱신
        await InfoUtil.setParentInfo(newImageFile.path);
        ParentInfo.makeBringEnum = MakePageBringEnum.RESIZE;
        ////////////////////////////////////////////////////////////////////////////////

        //makeProvider.setParentResize(true);   <-- 잘못된 코드
        dev.log('# ParentBar _onPressedSizeSave end');
        setState(() {});
      } else {
        newImage.dispose();
      }
    });
  }

  void _onTapSignNew() async {
    dev.log('# ParentBar _onTabSignNew START');

    ////////////////////////////////////////////////////////////////////////////////
    //parentProvider.initSignLines();
    //parentProvider.changeSignColorAndWidth(Colors.blue, AppConfig.SIGN_WIDTH_DEFAULT);    // TODO : from prefs

    //parentProvider.initShapeBackgroundUiImage();
    ////////////////////////////////////////////////////////////////////////////////

/*
    // tab_make 에서 미리 처리 (2023.05.19, KY.Jung)
    ////////////////////////////////////////////////////////////////////////////////
    // provider 데이터 넣기
    dev.log('loadShapeInfoList ${DateTime.now()}');
    List<ShapeInfo> shapeInfoList = await FileUtil.loadShapeInfoList();
    dev.log('${DateTime.now()} getShapeInfoList: $shapeInfoList');
    parentProvider.shapeInfoList = shapeInfoList;
    ////////////////////////////////////////////////////////////////////////////////
*/

    /*
    showDialog(
        context: context,
        barrierDismissible: true, // 바깥 영역 터치시 창닫기
        builder: (BuildContext context) {
          return const SignPopup();
        }
    );
    */
    if (!mounted) return;
    showModalBottomSheet(
        context: context,
        // 없으면 overflowed 에러 발생
        // A RenderFlex overflowed by 11 pixels on the bottom.
        isScrollControlled: true,
        enableDrag: false,    // sign 하기 위해 아래로 드래그할대 close 막기
        //barrierDismissible: true, // 바깥 영역 터치시 창닫기
        builder: (BuildContext context) {
          return const SignMbs();
        }
    );
  }

  ////////////////////////////////////////////////////////////////////////////////
  // Event Start //
  ////////////////////////////////////////////////////////////////////////////////
  void _onTapNone() {
    dev.log('# ParentBar _onTapNone START');
    //parentProvider.initSignLines();
    //parentProvider.initShapeBackgroundUiImage();
  }

  void _onTapPreSign(int index) {
    dev.log('# ParentBar _onTapPreSign START index: $index');
  }
////////////////////////////////////////////////////////////////////////////////
// Event Start //
////////////////////////////////////////////////////////////////////////////////
}
