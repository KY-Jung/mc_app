import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jpeg_encode/jpeg_encode.dart';
import 'package:mc/config/constant_app.dart';
import 'package:mc/ui/screen_make.dart';
import 'package:mc/util/util_popup.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;

import '../config/color_app.dart';
import '../config/config_app.dart';
import '../dto/info_parent.dart';
import '../painter/painter_make_parent_sign.dart';
import '../provider/provider_make.dart';
import '../util/util_info.dart';

enum MakeParentEnum { FRAME, SIZE, SIGN }

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
  List<bool> toggleSelectList = [true, false, false];

  MakeParentEnum _makeParentEnum = MakeParentEnum.FRAME;

  late MakeProvider makeProvider;

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# ParentBar initState START');
    super.initState();

    ////////////////////////////////////////////////////////////////////////////////
    /// build 이후 실행
    /// SharedPreferences.getInstance() 는 initState/build 에서는 await 효과 없으므로
    /// build 이후에 다시 실행하는 것으로 수정함
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _loadPreferences(context));
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

    InfoUtil.initParentInfoBracket();
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# ParentBar build START');

    makeProvider = Provider.of<MakeProvider>(context);

    double hBarDetail = AppBar().preferredSize.height *
        AppConfig.FUNCTIONBAR_HEIGHT *
        AppConfig.MAKE_FUNCTIONBAR_2 /
        (AppConfig.MAKE_FUNCTIONBAR_1 + AppConfig.MAKE_FUNCTIONBAR_2);
    double whPreSign = hBarDetail - 20 * 2;

    List<String> preSignList = <String>['A', 'B', 'C', '1', '2', '3', '4'];
    List<int> colorCodes = <int>[600, 500, 400, 300, 200, 100, 100];

    dev.log('# ParentBar build START2');

    return Scaffold(
      //backgroundColor: Colors.yellow,
      //backgroundColor: Colors.black87,
      backgroundColor: AppColors.MAKE_PARENT_FB_BACKGROUND,
      body: GestureDetector(
        onTapDown: _onTapDownAll,
        child: Column(
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
            if (_makeParentEnum == MakeParentEnum.FRAME)
              Expanded(
                flex: AppConfig.MAKE_FUNCTIONBAR_2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      child:
                          Text('FRAME parentSize: ${makeProvider.parentSize}'),
                      onPressed: () {},
                    ),
                    ElevatedButton(
                      child:
                          Text('FRAME parentSize: ${makeProvider.parentSize}'),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            if (_makeParentEnum == MakeParentEnum.SIZE)
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
            if (_makeParentEnum == MakeParentEnum.SIGN)
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
                        //color: Colors.yellow[50],
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
                                          child:
                                          Text('${preSignList[index]}')),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 20,
                                ),
                              ],
                            );
                          },
                          separatorBuilder:
                              (BuildContext context, int index) =>
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
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////////
  /// 초기화가 필요한 항목들 처리
  /// 1. Frame 선택, 목록에서 없음 선택
  /// 2. Size 에서 화면과 버튼 초기화
  /// 3. Sign 에서 선택 초기화 안함

  /// frame, size, sign 선택 + 세부 항목
  void _loadPreferences(context) {
    dev.log('# ParentBar _loadPreferences START');

    SharedPreferences.getInstance().then((prefs) {
      //SharedPreferences prefs = SharedPreferences.getInstance();
      bool isChanged = false;

      var retPrefs = prefs.getString('MakeParentEnum');
      if (retPrefs == null) {
        // 처음인 경우
        _makeParentEnum = MakeParentEnum.FRAME;
        prefs.setString(
            'MakeParentEnum', EnumToString.convertToString(_makeParentEnum));
      } else {
        var retEnum = EnumToString.fromString(MakeParentEnum.values, retPrefs);
        if (retEnum == null) {
          // 에러 상황 (enum 에 없는 값이 저장된 경우)
          _makeParentEnum = MakeParentEnum.FRAME;
          prefs.setString(
              'MakeParentEnum', EnumToString.convertToString(_makeParentEnum));
        } else {
          if (_makeParentEnum != retEnum) {
            isChanged = true;
          }
          _makeParentEnum = retEnum;
        }
      }
      dev.log('_makeParentEnum: $_makeParentEnum');

      toggleSelectList = [false, false, false];
      switch (_makeParentEnum) {
        case MakeParentEnum.FRAME:
          dev.log('case MakeParentEnum.FRAME');
          toggleSelectList[0] = true;

          if (!mounted) return;
          if (makeProvider.parentSize) {
            makeProvider.setParentSize(false);
          }
          break;
        case MakeParentEnum.SIZE:
          dev.log('case MakeParentEnum.SIZE');
          toggleSelectList[1] = true;

          if (!mounted) return;
          if (!makeProvider.parentSize) {
            makeProvider.setParentSize(true);
          }
          break;
        case MakeParentEnum.SIGN:
          dev.log('case MakeParentEnum.SIGN');
          toggleSelectList[2] = true;

          if (!mounted) return;
          if (makeProvider.parentSize) {
            makeProvider.setParentSize(false);
          }
          break;
      }

      if (isChanged) {
        setState(() {});
      }
    });

    dev.log('# ParentBar _loadPreferences END');
    //ParentInfo.xyOffset = const Offset(0, 0);
  }

  ////////////////////////////////////////////////////////////////////////////////
  // fab close 처리
  // 기존 이벤트는 그대로 처리
  void _onTapDownAll(TapDownDetails tapDownDetails) async {
    dev.log('_onTapDownAll');

    // fab close 처리 (provider 를 사용해서 닫기)
    if (makeProvider.fabOpen) {
      makeProvider.setFabOpen(false);
    }
  }

  void _toggleButtonsSelect(idx) {
    dev.log('# ParentBar _toggleButtonsSelect START');
    toggleSelectList = [false, false, false];
    switch (idx) {
      case 0:
        //if (makeParentEnum == MakeParentEnum.FRAME)  return;
        _makeParentEnum = MakeParentEnum.FRAME;
        toggleSelectList[0] = true;
        break;
      case 1:
        //if (makeParentEnum == MakeParentEnum.SIZE)  return;
        _makeParentEnum = MakeParentEnum.SIZE;
        toggleSelectList[1] = true;
        break;
      case 2:
        //if (makeParentEnum == MakeParentEnum.SIGN)  return;
        _makeParentEnum = MakeParentEnum.SIGN;
        toggleSelectList[2] = true;
        break;
    }
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(
          'MakeParentEnum', EnumToString.convertToString(_makeParentEnum));
    });

    // TODO : impl
    switch (_makeParentEnum) {
      case MakeParentEnum.FRAME:
        if (makeProvider.parentSize) {
          makeProvider.setParentSize(false);
        }
        //context.read<MakeProvider>().setParentSize(false);
        break;
      case MakeParentEnum.SIZE:
        dev.log('case MakeParentEnum.SIZE');
        if (!makeProvider.parentSize) {
          makeProvider.setParentSize(true);
        }
        //context.read<MakeProvider>().setParentSize(true);
        break;
      case MakeParentEnum.SIGN:
        if (makeProvider.parentSize) {
          makeProvider.setParentSize(false);
        }
        //context.read<MakeProvider>().setParentSize(false);
        break;
    }

    //ParentInfo.xyOffset = const Offset(0, 0);

    setState(() {});
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
    makeProvider.setParentSize(true);
    //context.read<MakeProvider>().setParentSize(true);

    Timer(const Duration(milliseconds: AppConfig.SIZE_INIT_INTERVAL), () {
      dev.log('# ParentBar _onPressedSizeInit Timer');
      InfoUtil.initParentInfoBracket();

      // 한번 더 refresh 해야 함
      makeProvider.setParentSize(true);
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

    if (leftTop && rightTop && leftBottom && rightBottom) {
      dev.log('_onPressedSizeSave SIZE_NO_CHANGE');
      PopupUtil.toastMsgShort('SIZE_NO_CHANGE'.tr());
      return;
    }
    ////////////////////////////////////////////////////////////////////////////////

    dev.log('_onPressedSizeSave SIZE_CHANGE');

    ////////////////////////////////////////////////////////////////////////////////
    // 새로 저장
    //ParentInfo.printParent();

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
    ui.Image uiImage = await InfoUtil.loadUiImage(ParentInfo.path);
    PictureRecorder pictureRecorder = PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder, dstRect);
    canvas.drawImageRect(uiImage, srcRect, dstRect, Paint());
    ui.Image newImage = await pictureRecorder
        .endRecording()
        .toImage(srcRect.width.toInt(), srcRect.height.toInt());

    //Image image = Image.file(File(ParentInfo.path));
    Widget imageWidget = RawImage(
      image: newImage,
    );
    //if (!mounted) return;
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
        return;
      }
      if (ret == AppConstant.OK) {
        // jpgByte 로 변환
        var rgbByte =
            await newImage.toByteData(format: ui.ImageByteFormat.rawRgba);
        var jpgByte = JpegEncoder().compress(
            rgbByte!.buffer.asUint8List(), newImage.width, newImage.height, 90);

        // byte 저장
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

        // new 파일 생성
        String fileName = '${appDir.path}/${AppConstant.PARENT_RESIZE_DIR}/'
            '${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.jpg';
        File newImageFile = File(fileName);
        newImageFile.createSync(recursive: true);

        // byte 저장
        newImageFile.writeAsBytesSync(jpgByte.buffer.asUint8List(),
            flush: true, mode: FileMode.write);
        dev.log('writeAsBytesSync end');
        ////////////////////////////////////////////////////////////////////////////////

        ////////////////////////////////////////////////////////////////////////////////
        // 화면 갱신
        await InfoUtil.setParentInfo(fileName);
        ParentInfo.makeBringEnum = MakeBringEnum.RESIZE;
        ////////////////////////////////////////////////////////////////////////////////

        if (!mounted) return;
        //if (!makeProvider.parentSize) {
        makeProvider.setParentSize(true);
        //}
        //context.read<MakeProvider>().setParentSize(false);
        //context.read<MakeProvider>().setParentSize(true);
        dev.log('# ParentBar _onPressedSizeSave end');
        setState(() {});
      }
    });
  }

  void _onTapSignNew() {
    dev.log('# ParentBar _onTabSignNew START');

    double whSignFit = InfoUtil.calcFitSign(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    double hBarDetail = AppBar().preferredSize.height *
        AppConfig.FUNCTIONBAR_HEIGHT *
        AppConfig.MAKE_FUNCTIONBAR_2 /
        (AppConfig.MAKE_FUNCTIONBAR_1 + AppConfig.MAKE_FUNCTIONBAR_2);
    double whPreSign = hBarDetail - 20 * 2;

    List<String> preSignList = <String>['A', 'B', 'C', '1', '2', '3', '4'];
    List<int> colorCodes = <int>[600, 500, 400, 300, 200, 100, 100];

    showDialog(
      context: context,
      barrierDismissible: true, // 바깥 영역 터치시 창닫기
      builder: (BuildContext context) => AlertDialog(
        title: Text("SIZE_SIGN_MAKE_TITLE".tr()),
        scrollable: true,
        content: Container(
          //color: Colors.white10,  // 효과없음
          // 최대로 맞추면 AlertDialog 에서 내부적으로 다시 조정함
          //width: MediaQuery.of(context).size.width * 1.0,
          // w, h 둘중 하나에 맞추어짐
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                //padding: const EdgeInsets.all(10),
                decoration:
                    BoxDecoration(color: AppColors.MAKE_SIGN_BOARD, boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    blurRadius: 6.0,
                    spreadRadius: 1.0,
                  ),
                ]),
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: Size(whSignFit, whSignFit),
                      painter: MakeParentSignPainter(
                          whSignFit.toInt(), whSignFit.toInt()),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                //color: Colors.green[50],
                decoration: BoxDecoration(color: Colors.green[50], boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    blurRadius: 6.0,
                    spreadRadius: 1.0,
                  ),
                ]),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 1.0,
                  height: hBarDetail,
                  child: Row(
                    children: <Widget>[
                      InkWell(
                        onTap: _onTapNone,
                        child: Container(
                          width: whPreSign,
                          height: whPreSign,
                          //margin: const EdgeInsets.all(10),
                          margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                                            child:
                                                Text('${preSignList[index]}')),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 20,
                                  ),
                                ],
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                //padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(color: Colors.green[50], boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    blurRadius: 6.0,
                    spreadRadius: 1.0,
                  ),
                ]),
                width: MediaQuery.of(context).size.width * 1.0,
                height: 160, // TODO : calc
                child: ContainedTabBarView(
                  tabBarProperties: TabBarProperties(
                    width: MediaQuery.of(context).size.width * 1.0,
                    height: 32,
                    // TODO : calc
                    position: TabBarPosition.top,
                    alignment: TabBarAlignment.center,
                    //indicatorColor: Colors.transparent,
                    labelColor: Colors.black87,
                    unselectedLabelColor: Colors.grey[400],
                    isScrollable: false,
                  ),
                  tabs: [
                    Text('TEXT'.tr()),
                    Text('BACKGROUND'.tr()),
                    Text('SHAPE'.tr()),
                  ],
                  views: [
                    Container(
                      decoration:
                          BoxDecoration(color: Colors.green[50], boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.6),
                          blurRadius: 6.0,
                          spreadRadius: 1.0,
                        ),
                      ]),
                      child: Row(
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  "COLOR".tr(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  "THICKNESS".tr(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    //color: Colors.yellow[50],
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
                                                      child:
                                                      Text('${preSignList[index]}')),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 20,
                                            ),
                                          ],
                                        );
                                      },
                                      separatorBuilder:
                                          (BuildContext context, int index) =>
                                      const Divider(),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    "COLOR33".tr(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration:
                          BoxDecoration(color: Colors.green[50], boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.6),
                          blurRadius: 6.0,
                          spreadRadius: 1.0,
                        ),
                      ]),
                      child: Text("222222222222"),
                    ),
                    Container(
                      decoration:
                          BoxDecoration(color: Colors.green[50], boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.6),
                          blurRadius: 6.0,
                          spreadRadius: 1.0,
                        ),
                      ]),
                      child: SvgPicture.asset(
                        '${AppConstant.SHAPE_DIR}ic_baby_heart.svg',
                        width: 10,
                        height: 10,
                      ),
                    ),
                  ],
                  onChange: (index) => print(index),
                ),

/*
                    DefaultTabController(
                  length: 3,
                  child: Column(
                    children: <Widget>[
                      TabBar(
                        tabs: <Widget>[
                          Tab(
                            icon: Icon(Icons.directions_car),
                            text: 'TEXT'.tr(),
                          ),
                          Tab(
                            icon: Icon(Icons.directions_transit),
                            text: 'BACKGROUND'.tr(),
                          ),
                          Tab(
                            icon: Icon(Icons.directions_transit),
                            text: 'SHAPE'.tr(),
                          ),
                        ],
                      ),
                      TabBarView(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.green[50],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.6),
                                    blurRadius: 6.0,
                                    spreadRadius: 1.0,
                                  ),
                                ]),
                            child: Row(
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        "COLOR".tr(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        "THICKNESS".tr(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                              "COLOR22",
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        "COLOR33333".tr(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.green[50],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.6),
                                    blurRadius: 6.0,
                                    spreadRadius: 1.0,
                                  ),
                                ]),
                            child: Text("222222222222"),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.green[50],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.6),
                                    blurRadius: 6.0,
                                    spreadRadius: 1.0,
                                  ),
                                ]),
                            child: SvgPicture.asset(
                              '${AppConstant.SHAPE_DIR}ic_baby_heart.svg',
                              width: 10,
                              height: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
*/
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.pop(context, 'DELETE'),
              child: Text('DELETE'.tr())),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, 'CANCEL'),
              child: Text('CANCEL'.tr())),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: Text('OK'.tr())),
        ],
        actionsAlignment: MainAxisAlignment.spaceEvenly,
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////////
  // Event Start //
  ////////////////////////////////////////////////////////////////////////////////
  void _onTapNone() {
    dev.log('# ParentBar _onTapNone START');
  }

  void _onTapPreSign(int index) {
    dev.log('# ParentBar _onTapPreSign START index: $index');
  }
////////////////////////////////////////////////////////////////////////////////
// Event Start //
////////////////////////////////////////////////////////////////////////////////
}
