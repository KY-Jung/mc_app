import 'dart:developer' as dev;
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:dotted_border/dotted_border.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mc/config/constant_app.dart';
import 'package:mc/ui/popup_reorderlist.dart';
import 'package:mc/util/util_popup.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;

import '../config/color_app.dart';
import '../config/config_app.dart';
import '../dto/info_signfile.dart';
import '../painter/painter_line.dart';
import '../painter/painter_make_parent_sign.dart';
import '../provider/provider_sign.dart';
import '../util/util_color.dart';
import '../util/util_file.dart';
import '../util/util_info.dart';

class SignMbs extends StatefulWidget {
  const SignMbs({super.key});

  @override
  State<SignMbs> createState() => SignMbsState();
}

class SignMbsState extends State<SignMbs> {
  ////////////////////////////////////////////////////////////////////////////////
  late SignProvider signProvider;

  late double whSignBoard;
  late double hBarDetail;
  late double whPreSign;
  late double hAppBar;
  late double wScreen;

  /// shapelist 에서 OK 한 경우 선택된 shape 로 위치이동하기 위해 사용
  late ScrollController _preShapeController;

  /// signlist 에서 OK 한 경우 선택된 shape 로 위치이동하기 위해 사용
  late ScrollController _preSignController;

  /// signFileInfo 를 최초에는 mbs 의 parentSignInfoIdx 값을 보고 scroll 하기 위해 사용
  bool first = true;

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# SignMbs initState START');
    super.initState();

    ////////////////////////////////////////////////////////////////////////////////
    /// build 이후 실행
    /// InteractiveViewer 실제 크기를 구해서 ParentProvider wScreen/hScreen 에 저장
    WidgetsBinding.instance.addPostFrameCallback((_) => _afterBuild(context));
    ////////////////////////////////////////////////////////////////////////////////

    dev.log('# SignMbs initState END');
  }

  @override
  void dispose() {
    dev.log('# SignMbs dispose START');
    super.dispose();

    ////////////////////////////////////////////////////////////////////////////////
    // 다시 사용안하는 데이터 지우기
    // 나머지는 유지하고 initAll 에서만 모두 지우기
    // --> Sign 을 설정하는 기능을 위해 나갈때 모두 초기화로 변경 (2023.05.28, KY.Jung)
    //signProvider.initAll(notify: false);
    signProvider.clearAll();

    _preShapeController.dispose();
    _preSignController.dispose();
    ////////////////////////////////////////////////////////////////////////////////
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# SignMbs build START');

    ////////////////////////////////////////////////////////////////////////////////
    signProvider = Provider.of<SignProvider>(context);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // sign board wh
    whSignBoard = InfoUtil.calcFitSign(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    // bar 에서 2번째 높이
    hBarDetail = AppBar().preferredSize.height *
        AppConfig.FUNCTIONBAR_HEIGHT *
        AppConfig.MAKE_FUNCTIONBAR_2 /
        (AppConfig.MAKE_FUNCTIONBAR_1 + AppConfig.MAKE_FUNCTIONBAR_2);
    // pre sign 의 크기 (bar 에서 크기와 동일)
    whPreSign = hBarDetail - 20 * 2;

    hAppBar = AppBar().preferredSize.height;

    wScreen = MediaQuery.of(context).size.width;

    dev.log('whSignBoard: $whSignBoard, hBarDetail: $hBarDetail, whPreSign: $whPreSign, hAppBar: $hAppBar');
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    double listWidth = wScreen - (whPreSign + 10 * 2) * 2;
    double cntPreSign = listWidth / (whPreSign + 10);
    dev.log('cntPreSign: $cntPreSign');
    _preShapeController = ScrollController(
        initialScrollOffset:
            signProvider.selectedSignShapeFileInfoIdx * (whPreSign + 10) - (whPreSign) * cntPreSign * 0.5 - 10 * 0.5);

    // 처음위치는 parentSignInfoIdx 를 사용
    if (first) {
      _preSignController = ScrollController(
          initialScrollOffset:
              signProvider.parentSignFileInfoIdx * (whPreSign + 10) - (whPreSign) * cntPreSign * 0.5 - 10 * 0.5);
      first = false;
    } else {
      _preSignController = ScrollController(
          initialScrollOffset:
              signProvider.selectedSignFileInfoIdx * (whPreSign + 10) - (whPreSign) * cntPreSign * 0.5 - 10 * 0.5);
    }
    ////////////////////////////////////////////////////////////////////////////////

    dev.log('# signProvider.size ${signProvider.signWidth}');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 10),
        Row(
          // 맨 위 확인 버튼
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(onPressed: _onPresseClearAll, child: Text('SIGN_INIT_ALL'.tr())),
            ElevatedButton(onPressed: () => Navigator.pop(context, 'CANCEL'), child: Text('CANCEL'.tr())),
            ElevatedButton(onPressed: _onPressedOk, child: Text('OK'.tr())),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(
          height: 0,
          thickness: 1,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          // sign board
          behavior: HitTestBehavior.translucent,
          onPanStart: (DragStartDetails d) {
            if (signProvider.signWidth == 0) {
              return;
            }
            signProvider.drawSignLinesStart(d.localPosition);
            setState(() {});
          },
          onPanUpdate: (DragUpdateDetails dragUpdateDetails) {
            if (signProvider.signWidth == 0) {
              return;
            }
            //double? primaryDelta = dragUpdateDetails.primaryDelta;  // 항상 null
            Offset offset = dragUpdateDetails.delta;
            //dev.log('offset: $offset');
            double delta = math.sqrt(math.pow(offset.dx, 2) + math.pow(offset.dy, 2));
            //dev.log('delta: $delta');
            double newSize = signProvider.signWidth - signProvider.signWidth / 10 * delta;
            //dev.log('newSize: newSize');
            signProvider.drawSignLines(dragUpdateDetails.localPosition, newSize);
            //dev.log('onPanUpdate: ${signProvider.lines}');
            setState(() {});
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: AppColors.BOXDECO_YELLOW50,
                width: whSignBoard,
                height: whSignBoard,
                //child: Image.asset('assets/images/jeju.jpg', fit: BoxFit.cover),
              ),
              IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    size: Size(whSignBoard, whSignBoard),
                    painter: MakeParentSignPainter(
                      whSignBoard,
                      whSignBoard,
                      signProvider.signLines,
                      signProvider.signColor,
                      signProvider.signWidth,
                      signProvider.signBackgroundColor,
                      signProvider.signBackgroundUiImage,
                      (signProvider.selectedSignShapeFileInfoIdx == -1)
                          ? null
                          : signProvider.shapeFileInfoList[signProvider.selectedSignShapeFileInfoIdx],
                      signProvider.signShapeBorderColor,
                      signProvider.signShapeBorderWidth,
                      signProvider.signUiImage,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          // sign list
          decoration: AppColors.BOXDECO_GREEN50,
          child: SizedBox(
            height: hBarDetail,
            child: Row(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    if (signProvider.selectedSignFileInfoIdx != -1) {
                      signProvider.selectedSignFileInfoIdx = -1;
                      signProvider.clearSignUiImage();
                      setState(() {});
                    }
                  },
                  child: Container(
                    width: whPreSign,
                    height: whPreSign,
                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    alignment: Alignment.center,
                    decoration: (signProvider.selectedSignFileInfoIdx == -1)
                        ? BoxDecoration(color: Colors.grey, border: Border.all(color: Colors.black))
                        : BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: Text('NONE'.tr()),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.yellow[50],
                    //margin: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                    margin: const EdgeInsets.fromLTRB(0, 15, 10, 15),
                    child: ListView.separated(
                      controller: _preSignController,
                      //padding: const EdgeInsets.all(10),
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: signProvider.signFileInfoList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Row(
                          children: [
                            InkWell(
                              onTap: () => _onTapPreSign(index),
                              child: SizedBox(
                                width: whPreSign,
                                height: whPreSign,
                                child: badges.Badge(
                                  badgeContent: Text('${signProvider.signFileInfoList[index].cnt}'),
                                  badgeStyle: badges.BadgeStyle(
                                    badgeColor: AppColors.BLUE_LIGHT,
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: whPreSign,
                                    height: whPreSign,
                                    decoration: (signProvider.selectedSignFileInfoIdx == index)
                                        ? BoxDecoration(
                                            color: Colors.grey[200], border: Border.all(color: Colors.black))
                                        : const BoxDecoration(),
                                    child: signProvider.signFileInfoList[index].image,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 10,
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) => const Divider(),
                    ),
                  ),
                ),
                InkWell(
                  onTap: _onTapSignList,
                  child: Container(
                    width: whPreSign,
                    height: whPreSign,
                    margin: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                    alignment: Alignment.center,
                    color: Colors.black12,
                    child: const Icon(
                      Icons.miscellaneous_services,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          // tab
          decoration: AppColors.BOXDECO_GREEN50,
          height: hAppBar * 4.8,
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: hAppBar * 0.8,
                  child: TabBar(
                    onTap: (idx) {
                      dev.log('TabBar onTap: $idx');
                      //_afterBuild(context);
                    },
                    indicatorWeight: 3,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    //unselectedLabelStyle: TextStyle(fontSize: 16),
                    tabs: <Widget>[
                      Tab(text: 'LINE'.tr()),
                      Tab(text: 'BACKGROUND'.tr()),
                      Tab(text: 'SHAPE'.tr()),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: <Widget>[
                      Container(
                        // [첫번째 탭]
                        decoration: AppColors.BOXDECO_GREEN50,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              // listview color
                              flex: 1,
                              child: Row(
                                children: <Widget>[
                                  (signProvider.recentSignColorList.isEmpty)
                                      ? Container(
                                          margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                          width: whPreSign,
                                          height: whPreSign,
                                        )
                                      : InkWell(
                                          onTap: () {
                                            dev.log('recent click: ${signProvider.recentSignColorList.elementAt(0)}');
                                            signProvider.signColor = signProvider.recentSignColorList.elementAt(0);
                                            setState(() {});
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                            width: whPreSign,
                                            height: whPreSign,
                                            decoration: BoxDecoration(
                                              color: signProvider.recentSignColorList.elementAt(0),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                width: 2,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: ((signProvider.recentSignColorList.elementAt(0).value ==
                                                        signProvider.signColor.value) &&
                                                    !ColorUtil.findColor(AppColors.DEFAULT_COLOR_LIST,
                                                        signProvider.recentSignColorList.elementAt(0)))
                                                ? Text(
                                                    '✔',
                                                    style: TextStyle(
                                                        color: (signProvider.recentSignColorList.elementAt(0).value ==
                                                                Colors.black.value)
                                                            ? Colors.white
                                                            : Colors.black),
                                                  )
                                                : const Text(''),
                                          ),
                                        ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: ListView.separated(
                                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: 9,
                                        itemBuilder: (BuildContext context, int index) {
                                          return Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  dev.log(
                                                      'default color click idx: $index, color: ${AppColors.DEFAULT_COLOR_LIST[index]}');
                                                  signProvider.signColor = AppColors.DEFAULT_COLOR_LIST[index];
                                                  setState(() {});
                                                },
                                                child: Container(
                                                  width: whPreSign,
                                                  height: whPreSign,
                                                  color: AppColors.DEFAULT_COLOR_LIST[index],
                                                  alignment: Alignment.center,
                                                  child: (AppColors.DEFAULT_COLOR_LIST[index].value ==
                                                          signProvider.signColor.value)
                                                      ? Text(
                                                          '✔',
                                                          style: TextStyle(
                                                              color: (AppColors.DEFAULT_COLOR_LIST[index].value ==
                                                                      Colors.black.value)
                                                                  ? Colors.white
                                                                  : Colors.black),
                                                        )
                                                      : const Text(''),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                        separatorBuilder: (BuildContext context, int index) => const Divider(),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                    width: whPreSign,
                                    height: whPreSign,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      border: Border.all(
                                        width: 1,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: InkWell(
                                      onTap: () {
                                        _onTapColorPicker(signProvider.signColor, signProvider.recentSignColorList,
                                            _callbackSignColor);
                                      },
                                      child: GridView.builder(
                                        itemCount: AppColors.DEFAULT_COLOR_LIST.length, //item 개수
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                        ),
                                        itemBuilder: (BuildContext context, int index) {
                                          return Container(
                                            color: AppColors.DEFAULT_COLOR_LIST[index],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              height: 0,
                              thickness: 1,
                            ),
                            Expanded(
                              // slider thickness
                              flex: 1,
                              child: SizedBox(
                                height: hBarDetail,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      child: MaterialButton(
                                        height: 20,
                                        onPressed: () {
                                          signProvider.signWidth = 0;
                                          setState(() {});
                                        },
                                        color: Colors.lightBlue[100],
                                        textColor: Colors.black,
                                        padding: const EdgeInsets.all(0),
                                        //shape: const CircleBorder(),
                                        child: const Text('0'),
                                      ),
                                    ),
                                    SliderTheme(
                                      data: SliderThemeData(
                                        activeTrackColor: Colors.lightBlue[100],
                                        inactiveTrackColor: Colors.grey,
                                        //thumbColor: Colors.orange,
                                        thumbColor: signProvider.signColor,
                                        activeTickMarkColor: Colors.yellow,
                                        valueIndicatorColor: Colors.lightBlue[100],
                                        //valueIndicatorColor: signProvider.signColor,
                                        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                                        overlayShape: SliderComponentShape.noOverlay,
                                        showValueIndicator: ShowValueIndicator.always,
                                      ),
                                      child: Slider(
                                        value: signProvider.signWidth,
                                        min: 0,
                                        max: AppConfig.SIGN_WIDTH_MAX,
                                        divisions: AppConfig.SIGN_WIDTH_MAX.toInt() - 1,
                                        label:
                                            '${signProvider.signWidth.toInt()} / ${AppConfig.SIGN_WIDTH_MAX.toInt()}',
                                        onChangeStart: (newValue) {
                                          dev.log('- Slider signProvider.size: ${signProvider.signWidth}');
                                        },
                                        onChanged: (newValue) {
                                          signProvider.signWidth = newValue;
                                          dev.log('- Slider onChanged size: $newValue');
                                          setState(() {});
                                        },
                                        onChangeEnd: (newValue) {
                                          dev.log('- Slider onChangeEnd: $newValue');
                                          SharedPreferences.getInstance().then((prefs) {
                                            prefs.setDouble(AppConstant.PREFS_SIGNWIDTH, newValue);
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                      child: MaterialButton(
                                        height: 20,
                                        onPressed: () {
                                          signProvider.signWidth = AppConfig.SIGN_WIDTH_MAX;
                                          setState(() {});
                                        },
                                        color: Colors.lightBlue[100],
                                        textColor: Colors.black,
                                        padding: const EdgeInsets.all(0),
                                        //shape: const CircleBorder(),
                                        child: Text('${AppConfig.SIGN_WIDTH_MAX.toInt()}'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        color: Colors.white,
                                        //padding: const EdgeInsets.all(20),
                                        margin: const EdgeInsets.all(10),
                                        //padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                                        //margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                        child: SizedBox(
                                          width: 80,
                                          child: DottedBorder(
                                            color: Colors.grey,
                                            strokeWidth: 1,
                                            dashPattern: const [6, 4],
                                            child: CustomPaint(
                                              size: const Size(80, 30),
                                              painter: LinePainter(signProvider.signWidth, signProvider.signColor,
                                                  straight: false),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(
                              height: 0,
                              thickness: 1,
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  SizedBox(
                                    child: OutlinedButton(
                                        style: TextButton.styleFrom(
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        onPressed: () {
                                          signProvider.clearSignLines();
                                          setState(() {});
                                        },
                                        child: Text('SIGN_CLEAR'.tr())),
                                  ),
                                  SizedBox(
                                    child: OutlinedButton(
                                        style: TextButton.styleFrom(
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        onPressed: () {
                                          signProvider.undoSignLines();
                                          setState(() {});
                                        },
                                        child: Text('SING_UNDO'.tr())),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        // [두번째 탭]
                        decoration: AppColors.BOXDECO_GREEN50,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              // listview color
                              flex: 1,
                              child: Row(
                                children: [
                                  (signProvider.recentSignBackgroundColorList.isEmpty)
                                      ? Container(
                                          margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                          width: whPreSign,
                                          height: whPreSign,
                                        )
                                      : InkWell(
                                          onTap: () {
                                            dev.log(
                                                'recent click: ${signProvider.recentSignBackgroundColorList.elementAt(0)}');
                                            signProvider.signBackgroundColor =
                                                signProvider.recentSignBackgroundColorList.elementAt(0);
                                            setState(() {});
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                            width: whPreSign,
                                            height: whPreSign,
                                            decoration: BoxDecoration(
                                              color: signProvider.recentSignBackgroundColorList.elementAt(0),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                width: 2,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: ((signProvider.recentSignBackgroundColorList.elementAt(0).value ==
                                                        signProvider.signBackgroundColor?.value) &&
                                                    !ColorUtil.findColor(AppColors.DEFAULT_COLOR_LIST,
                                                        signProvider.recentSignBackgroundColorList.elementAt(0)))
                                                ? Text(
                                                    '✔',
                                                    style: TextStyle(
                                                        color: (signProvider.recentSignBackgroundColorList
                                                                    .elementAt(0)
                                                                    .value ==
                                                                Colors.black.value)
                                                            ? Colors.white
                                                            : Colors.black),
                                                  )
                                                : const Text(''),
                                          ),
                                        ),
                                  InkWell(
                                    onTap: () {
                                      signProvider.signBackgroundColor = null;
                                      setState(() {});
                                    },
                                    child: Container(
                                      width: whPreSign,
                                      height: whPreSign,
                                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: (signProvider.signBackgroundColor == null)
                                          ? const Text('✔', style: TextStyle(color: Colors.black))
                                          : const Text(''),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: ListView.separated(
                                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: 9,
                                        itemBuilder: (BuildContext context, int index) {
                                          return Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  dev.log(
                                                      'default color click idx: $index, color: ${AppColors.DEFAULT_COLOR_LIST[index]}');
                                                  signProvider.signBackgroundColor =
                                                      AppColors.DEFAULT_COLOR_LIST[index];
                                                  setState(() {});
                                                },
                                                child: Container(
                                                  width: whPreSign,
                                                  height: whPreSign,
                                                  color: AppColors.DEFAULT_COLOR_LIST[index],
                                                  alignment: Alignment.center,
                                                  child: (AppColors.DEFAULT_COLOR_LIST[index].value ==
                                                          signProvider.signBackgroundColor?.value)
                                                      ? Text(
                                                          '✔',
                                                          style: TextStyle(
                                                              color: (AppColors.DEFAULT_COLOR_LIST[index].value ==
                                                                      Colors.black.value)
                                                                  ? Colors.white
                                                                  : Colors.black),
                                                        )
                                                      : const Text(''),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                        separatorBuilder: (BuildContext context, int index) => const Divider(),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                    width: whPreSign,
                                    height: whPreSign,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      border: Border.all(
                                        width: 1,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: InkWell(
                                      onTap: () {
                                        _onTapColorPicker(signProvider.signBackgroundColor,
                                            signProvider.recentSignBackgroundColorList, _callbackSignBackgroundColor);
                                      },
                                      child: GridView.builder(
                                        itemCount: AppColors.DEFAULT_COLOR_LIST.length, //item 개수
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                        ),
                                        itemBuilder: (BuildContext context, int index) {
                                          return Container(
                                            color: AppColors.DEFAULT_COLOR_LIST[index],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              height: 0,
                              thickness: 1,
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  SizedBox(
                                    child: OutlinedButton(
                                        style: TextButton.styleFrom(
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        onPressed: () {
                                          if (signProvider.signBackgroundUiImage != null) {
                                            signProvider.clearSignBackgroundUiImage();
                                            setState(() {});
                                          }
                                        },
                                        child: Text('SIGN_CLEAR'.tr())),
                                  ),
                                  ElevatedButton.icon(
                                      icon: const Icon(
                                        Icons.photo,
                                        color: Colors.amber,
                                      ),
                                      label: Text('GALLERY'.tr()),
                                      style: TextButton.styleFrom(backgroundColor: Colors.white),
                                      onPressed: () async {
                                        //_bringSignPressed(MakePageBringEnum.GALLERY, whSignBoard);
                                        XFile? xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                                        dev.log('xFile: ${xFile?.path}');
                                        if (xFile != null) {
                                          await signProvider.loadSignBackgroundUiImage(xFile.path, whSignBoard);
                                          setState(() {});
                                        }
                                      }),
                                  ElevatedButton.icon(
                                      icon: const Icon(
                                        Icons.camera_alt_rounded,
                                        color: Colors.lightGreen,
                                      ),
                                      label: Text('CAMERA'.tr()),
                                      style: TextButton.styleFrom(backgroundColor: Colors.white),
                                      onPressed: () async {
                                        //_bringSignPressed(MakePageBringEnum.CAMERA, whSignBoard);
                                        XFile? xFile = await ImagePicker().pickImage(source: ImageSource.camera);
                                        dev.log('xFile2: ${xFile?.path}');
                                        if (xFile != null) {
                                          await signProvider.loadSignBackgroundUiImage(xFile.path, whSignBoard);
                                          setState(() {});
                                        }
                                      }),
                                ],
                              ),
                            ),
                            const Divider(
                              height: 0,
                              thickness: 1,
                            ),
                            Expanded(flex: 1, child: SizedBox(height: hBarDetail, child: const Text(' '))),
                          ],
                        ),
                      ),
                      Container(
                        // [세번째 탭]
                        decoration: AppColors.BOXDECO_GREEN50,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              // listview shape
                              flex: 1,
                              child: Row(
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      signProvider.selectedSignShapeFileInfoIdx = -1;
                                      setState(() {});
                                    },
                                    child: Container(
                                      width: whPreSign,
                                      height: whPreSign,
                                      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                      alignment: Alignment.center,
                                      decoration: (signProvider.selectedSignShapeFileInfoIdx == -1)
                                          ? BoxDecoration(color: Colors.grey, border: Border.all(color: Colors.black))
                                          : BoxDecoration(border: Border.all(color: Colors.grey)),
                                      child: Text('NONE'.tr()),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      color: Colors.yellow[50],
                                      margin: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                                      child: ListView.separated(
                                        controller: _preShapeController,
                                        padding: const EdgeInsets.all(10),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: signProvider.shapeFileInfoList.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          return Row(
                                            children: [
                                              InkWell(
                                                onTap: () => _onTapPreShape(index),
                                                child: Container(
                                                  width: whPreSign,
                                                  height: whPreSign,
                                                  decoration: (signProvider.selectedSignShapeFileInfoIdx == index)
                                                      ? BoxDecoration(
                                                          color: Colors.grey[200],
                                                          border: Border.all(color: Colors.black))
                                                      : const BoxDecoration(),
                                                  child: signProvider.shapeFileInfoList[index].image,
                                                ),
                                              ),
                                              Container(
                                                width: 10,
                                              ),
                                            ],
                                          );
                                        },
                                        separatorBuilder: (BuildContext context, int index) => const Divider(),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: _onTapShapeList,
                                    child: Container(
                                      width: whPreSign,
                                      height: whPreSign,
                                      margin: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                                      alignment: Alignment.center,
                                      color: Colors.black12,
                                      child: const Icon(
                                        Icons.miscellaneous_services,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              height: 0,
                              thickness: 1,
                            ),
                            Expanded(
                              // listview color
                              flex: 1,
                              child: Row(
                                children: [
                                  (signProvider.recentSignShapeBorderColorList.isEmpty)
                                      ? Container(
                                          margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                          width: whPreSign,
                                          height: whPreSign,
                                        )
                                      : InkWell(
                                          onTap: () {
                                            dev.log(
                                                'recent click: ${signProvider.recentSignShapeBorderColorList.elementAt(0)}');
                                            signProvider.signShapeBorderColor =
                                                signProvider.recentSignShapeBorderColorList.elementAt(0);
                                            setState(() {});
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                            width: whPreSign,
                                            height: whPreSign,
                                            decoration: BoxDecoration(
                                              color: signProvider.recentSignShapeBorderColorList.elementAt(0),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                width: 2,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: ((signProvider.recentSignShapeBorderColorList.elementAt(0).value ==
                                                        signProvider.signShapeBorderColor?.value) &&
                                                    !ColorUtil.findColor(AppColors.DEFAULT_COLOR_LIST,
                                                        signProvider.recentSignShapeBorderColorList.elementAt(0)))
                                                ? Text(
                                                    '✔',
                                                    style: TextStyle(
                                                        color: (signProvider.recentSignShapeBorderColorList
                                                                    .elementAt(0)
                                                                    .value ==
                                                                Colors.black.value)
                                                            ? Colors.white
                                                            : Colors.black),
                                                  )
                                                : const Text(''),
                                          ),
                                        ),
                                  InkWell(
                                    onTap: () {
                                      signProvider.signShapeBorderColor = null;
                                      setState(() {});
                                    },
                                    child: Container(
                                      width: whPreSign,
                                      height: whPreSign,
                                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: (signProvider.signShapeBorderColor == null)
                                          ? const Text('✔', style: TextStyle(color: Colors.black))
                                          : const Text(''),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: ListView.separated(
                                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: 9,
                                        itemBuilder: (BuildContext context, int index) {
                                          return Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  dev.log(
                                                      'default color click idx: $index, color: ${AppColors.DEFAULT_COLOR_LIST[index]}');
                                                  signProvider.signShapeBorderColor =
                                                      AppColors.DEFAULT_COLOR_LIST[index];
                                                  setState(() {});
                                                },
                                                child: Container(
                                                  width: whPreSign,
                                                  height: whPreSign,
                                                  color: AppColors.DEFAULT_COLOR_LIST[index],
                                                  alignment: Alignment.center,
                                                  child: (AppColors.DEFAULT_COLOR_LIST[index].value ==
                                                          signProvider.signShapeBorderColor?.value)
                                                      ? Text(
                                                          '✔',
                                                          style: TextStyle(
                                                              color: (AppColors.DEFAULT_COLOR_LIST[index].value ==
                                                                      Colors.black.value)
                                                                  ? Colors.white
                                                                  : Colors.black),
                                                        )
                                                      : const Text(''),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                        separatorBuilder: (BuildContext context, int index) => const Divider(),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                    width: whPreSign,
                                    height: whPreSign,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      border: Border.all(
                                        width: 1,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: InkWell(
                                      onTap: () {
                                        _onTapColorPicker(signProvider.signShapeBorderColor,
                                            signProvider.recentSignShapeBorderColorList, _callbackSignShapeBorderColor);
                                      },
                                      child: GridView.builder(
                                        itemCount: AppColors.DEFAULT_COLOR_LIST.length, //item 개수
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                        ),
                                        itemBuilder: (BuildContext context, int index) {
                                          return Container(
                                            color: AppColors.DEFAULT_COLOR_LIST[index],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              height: 0,
                              thickness: 1,
                            ),
                            Expanded(
                              // slider thickness
                              flex: 1,
                              child: SizedBox(
                                height: hBarDetail,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      child: MaterialButton(
                                        height: 20,
                                        onPressed: () {
                                          signProvider.signShapeBorderWidth = 0;
                                          setState(() {});
                                        },
                                        color: Colors.lightBlue[100],
                                        textColor: Colors.black,
                                        padding: const EdgeInsets.all(0),
                                        //shape: const CircleBorder(),
                                        child: const Text('0'),
                                      ),
                                    ),
                                    SliderTheme(
                                      data: SliderThemeData(
                                        activeTrackColor: Colors.lightBlue[100],
                                        inactiveTrackColor: Colors.grey,
                                        //thumbColor: Colors.orange,
                                        thumbColor: signProvider.signShapeBorderColor,
                                        activeTickMarkColor: Colors.yellow,
                                        valueIndicatorColor: Colors.lightBlue[100],
                                        //valueIndicatorColor: signProvider.signColor,
                                        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                                        overlayShape: SliderComponentShape.noOverlay,
                                        showValueIndicator: ShowValueIndicator.always,
                                      ),
                                      child: Slider(
                                        value: (signProvider.signShapeBorderColor == null)
                                            ? 0
                                            : signProvider.signShapeBorderWidth,
                                        min: 0,
                                        max: AppConfig.SIGN_WIDTH_MAX,
                                        divisions: AppConfig.SIGN_WIDTH_MAX.toInt() - 1,
                                        label:
                                            '${signProvider.signShapeBorderWidth.toInt()} / ${AppConfig.SIGN_WIDTH_MAX.toInt()}',
                                        onChangeStart: (newValue) {
                                          dev.log('- Slider signProvider.size: ${signProvider.signShapeBorderWidth}');
                                        },
                                        onChanged: (newValue) {
                                          if (signProvider.signShapeBorderColor != null) {
                                            signProvider.signShapeBorderWidth = newValue;
                                            setState(() {});
                                            dev.log('- Slider onChanged size: $newValue');
                                          }
                                        },
                                        onChangeEnd: (newValue) {
                                          dev.log('- Slider onChangeEnd: $newValue');
                                          SharedPreferences.getInstance().then((prefs) {
                                            prefs.setDouble(AppConstant.PREFS_SIGNSHAPEBORDERWIDTH, newValue);
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                      child: MaterialButton(
                                        height: 20,
                                        onPressed: () {
                                          signProvider.signShapeBorderWidth = AppConfig.SIGN_WIDTH_MAX;
                                          setState(() {});
                                        },
                                        color: Colors.lightBlue[100],
                                        textColor: Colors.black,
                                        padding: const EdgeInsets.all(0),
                                        //shape: const CircleBorder(),
                                        child: Text('${AppConfig.SIGN_WIDTH_MAX.toInt()}'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        color: Colors.white,
                                        //padding: const EdgeInsets.all(20),
                                        margin: const EdgeInsets.all(10),
                                        //padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                                        //margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                        child: SizedBox(
                                          width: 80,
                                          child: DottedBorder(
                                            color: Colors.grey,
                                            strokeWidth: 1,
                                            dashPattern: const [6, 4],
                                            child: CustomPaint(
                                              size: const Size(80, 30),
                                              painter: LinePainter(
                                                  signProvider.signShapeBorderWidth, signProvider.signShapeBorderColor,
                                                  straight: true),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// build 이후에 실행
  void _afterBuild(context) {
    dev.log('# SignMbs _afterBuild START');

    ////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////
  }
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // Event Start //
  ////////////////////////////////////////////////////////////////////////////////
  void _onTapColorPicker(Color? color, List<Color> colorList, var callback) async {
    dev.log('# SignMbs _onTapColorPicker START');

    // color picker 에서 초기 color 는 null 일 수 없음
    color ??= Colors.blue;

    final Color colorBeforeDialog = color;
    // Wait for the picker to close, if dialog was dismissed,
    // then restore the color we had before it was opened.
    if (!(await ColorUtil.colorPickerDialog(
        //context, signProvider.signColor, signProvider.recentSignColorList, _callbackSignColor))) {
        context,
        color,
        colorList,
        callback))) {
      //signProvider.setSignColor(colorBeforeDialog);
      callback(colorBeforeDialog);
    } else {
      //signProvider.addRecentColor(signProvider.signColor, AppConfig.SIGNCOLOR_SAVE_MAX);
      callback(null, recent: true);
    }
  }

  void _callbackSignColor(Color? color, {bool recent = false}) {
    color ??= signProvider.signColor;
    if (recent) {
      signProvider.addRecentSignColor(color, AppConfig.SIGNCOLOR_SAVE_MAX);
    }
    signProvider.signColor = color;
    setState(() {});
  }

  void _callbackSignBackgroundColor(Color? color, {bool recent = false}) {
    color ??= signProvider.signBackgroundColor;
    if (recent && color != null) {
      signProvider.addRecentSignBackgroundColor(color, AppConfig.SIGNCOLOR_SAVE_MAX);
    }
    signProvider.signBackgroundColor = color;
    setState(() {});
  }

  void _callbackSignShapeBorderColor(Color? color, {bool recent = false}) {
    color ??= signProvider.signShapeBorderColor;
    if (recent && color != null) {
      signProvider.addRecentSignShapeBorderColor(color, AppConfig.SIGNCOLOR_SAVE_MAX);
    }
    signProvider.signShapeBorderColor = color;
    setState(() {});
  }

  void _onTapPreSign(int idx) async {
    dev.log('# SignMbs _onTapPreSign START idx: $idx');

    if (idx == signProvider.selectedSignFileInfoIdx) {
      return;
    }
    signProvider.selectedSignFileInfoIdx = idx;

    ui.Image? signUiImage = await FileUtil.changeImageToUiImage(signProvider.signFileInfoList[idx].image);
    signProvider.clearSignUiImage();
    signProvider.signUiImage = signUiImage;

    setState(() {});
  }

  void _onTapPreShape(int idx) {
    dev.log('# SignMbs _onTapPreShape START idx: $idx');

    if (idx == signProvider.selectedSignShapeFileInfoIdx) {
      return;
    }

    signProvider.selectedSignShapeFileInfoIdx = idx;
    setState(() {});
  }

  void _onTapShapeList() {
    dev.log('# SignMbs _onTapShapeList START');

    double whShape = MediaQuery.of(context).size.width / 7;
    showDialog(
        context: context,
        barrierDismissible: true, // 바깥 영역 터치시 창닫기
        builder: (BuildContext context) {
          return ReorderListPopup(
              selectedIdx: signProvider.selectedSignShapeFileInfoIdx,
              infoList: signProvider.shapeFileInfoList,
              whShape: whShape,
              title: 'SHAPE_LIST'.tr(),
              badge: false,
              delete: false,
              heightRatio: 1.0);
        }).then((idx) async {
      dev.log('_onTapShapeList ret: $idx');
      if (idx == null || idx == 'CANCEL') {
      } else {
        signProvider.selectedSignShapeFileInfoIdx = idx;

        ////////////////////////////////////////////////////////////////////////////////
        // 현재 파일명 목록 구하기
        List<String> fileNameList = FileUtil.extractFileNameFromInfoList(signProvider.shapeFileInfoList);
        String fileNameStr = fileNameList.join(AppConstant.PREFS_DELIM);

        // prefs 의 파일명 목록 구하기
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? prefsShapeFileInfoList = prefs.getString(AppConstant.PREFS_SHAPEFILEINFOLIST);

        // 같지 않으면 prefs 저장
        if (fileNameStr != prefsShapeFileInfoList) {
          // save prefs
          dev.log('save prefs');
          await prefs.setString(AppConstant.PREFS_SHAPEFILEINFOLIST, fileNameStr);
        }
        ////////////////////////////////////////////////////////////////////////////////

        // 위치 조정
        if (signProvider.selectedSignShapeFileInfoIdx != -1) {
          double listWidth = wScreen - (whPreSign + 10 * 2) * 2;
          double cntPreSign = listWidth / (whPreSign + 10);
          dev.log('cntPreSign: $cntPreSign');

          _preShapeController.animateTo(
            signProvider.selectedSignShapeFileInfoIdx * (whPreSign + 10) - (whPreSign) * cntPreSign * 0.5 - 10 * 0.5,
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
          );
        }
      }
      setState(() {});
    });
  }

  void _onTapSignList() {
    dev.log('# SignMbs _onTapSignList START');

    double whShape = MediaQuery.of(context).size.width / 7;
    showDialog(
        context: context,
        barrierDismissible: true, // 바깥 영역 터치시 창닫기
        builder: (BuildContext context) {
          return ReorderListPopup(
              selectedIdx: signProvider.selectedSignFileInfoIdx,
              infoList: signProvider.signFileInfoList,
              whShape: whShape,
              title: 'SIGN_LIST'.tr(),
              badge: true,
              delete: true,
              heightRatio: 0.4);
        }).then((idx) async {
      dev.log('_onTapSignList idx: $idx');
      if (idx == null || idx == 'CANCEL') {
      } else {
        signProvider.selectedSignFileInfoIdx = idx;

        ////////////////////////////////////////////////////////////////////////////////
        // 현재 파일명 목록 구하기
        List<String> fileNameList =
            FileUtil.extractFileNameAndCntFromSignFileInfoList(signProvider.signFileInfoList, AppConstant.PREFS_DELIM2);
        String fileNameStr = fileNameList.join(AppConstant.PREFS_DELIM);
        dev.log('fileNameList: $fileNameList');
        dev.log('fileNameStr: $fileNameStr');

        // prefs 의 파일명 목록 구하기
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? prefsSignFileInfoList = prefs.getString(AppConstant.PREFS_SIGNFILEINFOLIST);
        dev.log('prefsSignFileInfoList: $prefsSignFileInfoList');

        // 같지 않으면 prefs 저장
        if (fileNameStr != prefsSignFileInfoList) {
          // save prefs
          dev.log('save prefs');

          List<String> fileNameList = FileUtil.extractFileNameAndCntFromSignFileInfoList(
              signProvider.signFileInfoList, AppConstant.PREFS_DELIM2);
          fileNameStr = fileNameList.join(AppConstant.PREFS_DELIM);

          await prefs.setString(AppConstant.PREFS_SIGNFILEINFOLIST, fileNameStr);
        }
        ////////////////////////////////////////////////////////////////////////////////

        // 위치 조정
        if (signProvider.selectedSignFileInfoIdx != -1) {
          double listWidth = wScreen - (whPreSign + 10 * 2) * 2;
          double cntPreSign = listWidth / (whPreSign + 10);
          dev.log('cntPreSign: $cntPreSign');

          _preSignController.animateTo(
            signProvider.selectedSignFileInfoIdx * (whPreSign + 10) - (whPreSign) * cntPreSign * 0.5 - 10 * 0.5,
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
          );
        }

        ui.Image? signUiImage = await FileUtil.changeImageToUiImage(signProvider.signFileInfoList[idx].image);
        signProvider.clearSignUiImage();
        signProvider.signUiImage = signUiImage;
      }
      setState(() {});
    });
  }

  void _onPresseClearAll() async {
    dev.log('# SignMbs _onPresseClearAll START');

    PopupUtil.popupAlertOkCancel(context, 'INFO'.tr(), 'SIGN_INIT_ALL'.tr()).then((ret) {
      dev.log('popupAlertOkCancel: $ret');

      // example
      if (ret == null) {
        // 팝업 바깥 영역을 클릭한 경우
        return;
      }
      if (ret == AppConstant.OK) {
        signProvider.clearAll();
        setState(() {});
      }
    });
  }

  void _onPressedOk() async {
    dev.log('# SignMbs _onPressedOk START');

    int statusSign;
    ////////////////////////////////////////////////////////////////////////////////
    // 상태 결정
    if (signProvider.signLines.isEmpty &&
        signProvider.signBackgroundColor == null &&
        signProvider.signBackgroundUiImage == null &&
        signProvider.selectedSignShapeFileInfoIdx == -1) {
      if (signProvider.selectedSignFileInfoIdx == -1) {
        // 아무 작업도 없음
        statusSign = 0;
      } else {
        // sign 만 있는 경우
        statusSign = 1;
      }
    } else {
      // 작업이 있는 경우
      statusSign = 2;
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    if (statusSign == 0) {
      dev.log('# SignMbs _onPressedOk 변경사항 없음');

      if (!mounted) return;
      Navigator.pop(context, 'CANCEL');

      return;
    }

    if (statusSign == 1) {
      dev.log('# SignMbs _onPressedOk 사인만 선택됨');

      if (!mounted) return;
      Navigator.pop(context, signProvider.selectedSignFileInfoIdx);

      return;
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // 저장 영역
    Rect dstRect = const Offset(0, 0) & Size(whSignBoard, whSignBoard);

    // PictureRecorder, Canvas 생성
    ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder, dstRect);

    // canvas 전달해서 그리기 요청
    MakeParentSignPainter makeParentSignPainter = MakeParentSignPainter(
        whSignBoard,
        whSignBoard,
        signProvider.signLines,
        signProvider.signColor,
        signProvider.signWidth,
        signProvider.signBackgroundColor,
        signProvider.signBackgroundUiImage,
        (signProvider.selectedSignShapeFileInfoIdx == -1)
            ? null
            : signProvider.shapeFileInfoList[signProvider.selectedSignShapeFileInfoIdx],
        signProvider.signShapeBorderColor,
        signProvider.signShapeBorderWidth,
        signProvider.signUiImage,
        grid: false);
    makeParentSignPainter.paint(canvas, Size(whSignBoard, whSignBoard));

    PopupUtil.popupImage2OkCancel(
        context,
        'INFO'.tr(),
        'SIGN_SAVE'.tr(),
        CustomPaint(painter: makeParentSignPainter),
        whSignBoard,
        whSignBoard,
        (signProvider.signFileInfoList.length >= AppConfig.SIGN_SAVE_MAX)
            ? signProvider.signFileInfoList.last.image
            : null,
        'SIGN_SAVE_DELETE'.tr(args: [AppConfig.SIGN_SAVE_MAX.toString()])).then((ret) async {
      dev.log('popupImage2OkCancel: $ret');

      // example
      if (ret == null) {
        // 팝업 바깥 영역을 클릭한 경우
        return;
      }
      if (ret == AppConstant.OK) {
        // 그린 이미지 가져오기
        ui.Image newImage = await pictureRecorder
            .endRecording()
            .toImage(dstRect.width.toInt(), dstRect.height.toInt()); // 여기서 scaling 안됨

        // 파일 저장
        File newImageFile = await FileUtil.createFile(AppConstant.SIGN_DIR, 'png');
        dev.log('newImageFile.path: ${newImageFile.path}');
        await FileUtil.saveUiImageToPng(newImage, newImageFile);
        dev.log('saveUiImageToPng end');

        // signFileInfoList 에 추가
        SignFileInfo signFileInfo = SignFileInfo(newImageFile.path, Image.file(newImageFile));
        signProvider.addSignFileInfoList(signFileInfo, AppConfig.SIGN_SAVE_MAX, notify: true);

        // prefs 에 반영
        List<String> fileNameList =
            FileUtil.extractFileNameAndCntFromSignFileInfoList(signProvider.signFileInfoList, AppConstant.PREFS_DELIM2);
        String fileNameStr = fileNameList.join(AppConstant.PREFS_DELIM);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(AppConstant.PREFS_SIGNFILEINFOLIST, fileNameStr);

        if (!mounted) return;
        Navigator.pop(context, signProvider.selectedSignFileInfoIdx); // 0 idx
      }
    });
    ////////////////////////////////////////////////////////////////////////////////
  }
////////////////////////////////////////////////////////////////////////////////
// Event Start //
////////////////////////////////////////////////////////////////////////////////
}
