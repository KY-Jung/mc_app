import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:dotted_border/dotted_border.dart';
import 'package:image/image.dart' as IMG;

import 'package:easy_localization/easy_localization.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jpeg_encode/jpeg_encode.dart';
import 'package:mc/config/constant_app.dart';
import 'package:mc/ui/page_make.dart';
import 'package:mc/ui/popup_shapelist.dart';
import 'package:mc/util/util_popup.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;
import 'package:svg_path_parser/svg_path_parser.dart';

import '../config/color_app.dart';
import '../config/config_app.dart';
import '../dto/info_parent.dart';
import '../painter/clipper_sign.dart';
import '../painter/painter_line.dart';
import '../painter/painter_make_parent_sign.dart';
import '../provider/provider_make.dart';
import '../provider/provider_parent.dart';
import '../util/util_color.dart';
import '../util/util_file.dart';
import '../util/util_info.dart';
import 'page_colorpicker.dart';

class SignMbs extends StatefulWidget {
  const SignMbs({super.key});

  @override
  State<SignMbs> createState() => SignMbsState();
}

class SignMbsState extends State<SignMbs> {
  ////////////////////////////////////////////////////////////////////////////////
  late ParentProvider parentProvider;

  late double whSignBoard;
  late double hBarDetail;
  late double whPreSign;
  late double hAppBar;
  late double wScreen;

  /// shapelist 에서 OK 한 경우 선택된 shape 로 위치이동하기 위해 사용
  late ScrollController _preShapeController;
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# SignMbs initState START');
    super.initState();

    ////////////////////////////////////////////////////////////////////////////////
    /// build 이후 실행
    /// InteractiveViewer 실제 크기를 구해서 ParentInfo wScreen/hScreen 에 저장
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
    parentProvider.initSignLines(notify: false);
    parentProvider.initShapeBackgroundUiImage(notify: false);
    ////////////////////////////////////////////////////////////////////////////////
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# SignMbs build START');

    ////////////////////////////////////////////////////////////////////////////////
    parentProvider = Provider.of<ParentProvider>(context);
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

    dev.log('whSignBoard: ${whSignBoard}, hBarDetail: ${hBarDetail}, whPreSign: ${whPreSign}, hAppBar: ${hAppBar}');
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    double listWidth = wScreen - (whPreSign + 10 * 2) * 2;
    double cntPreSign = listWidth / (whPreSign + 10);
    dev.log('cntPreSign: $cntPreSign');
    _preShapeController = ScrollController(initialScrollOffset: parentProvider.selectedShapeInfoIdx * (whPreSign + 10) - (whPreSign) * cntPreSign * 0.5 - 10 * 0.5);
    ////////////////////////////////////////////////////////////////////////////////

    // for test
    List<String> preSignList = <String>['A', 'B', 'C', '1', '2', '3', '4', '가', '나', '다', '1', '2', '3', '4'];
    List<int> colorCodes = <int>[600, 500, 400, 300, 200, 100, 100, 600, 500, 400, 600, 500, 400, 300];

    dev.log('# ParentProvider.size ${parentProvider.signWidth}');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(
          height: 10,
        ),
        Row(
          // 맨 위 확인 버튼
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(onPressed: _onPresseClearAll, child: Text('SIGN_INIT_ALL'.tr())),
            ElevatedButton(onPressed: () => Navigator.pop(context, 'CANCEL'), child: Text('CANCEL'.tr())),
            ElevatedButton(onPressed: _onPressedOk, child: Text('OK'.tr())),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        const Divider(
          height: 0,
          thickness: 1,
        ),
        const SizedBox(
          height: 10,
        ),
        GestureDetector(
          // sign board
          behavior: HitTestBehavior.translucent,
          onPanStart: (DragStartDetails d) {
            if (parentProvider.signWidth == 0) {
              return;
            }
            parentProvider.drawSignLinesStart(d.localPosition);
          },
          onPanUpdate: (DragUpdateDetails dragUpdateDetails) {
            if (parentProvider.signWidth == 0) {
              return;
            }
            //double? primaryDelta = dragUpdateDetails.primaryDelta;  // 항상 null
            Offset offset = dragUpdateDetails.delta;
            //dev.log('offset: $offset');
            double delta = math.sqrt(math.pow(offset.dx, 2) + math.pow(offset.dy, 2));
            //dev.log('delta: $delta');
            double newSize = parentProvider.signWidth - parentProvider.signWidth / 10 * delta;
            //dev.log('newSize: newSize');
            parentProvider.drawSignLines(dragUpdateDetails.localPosition, newSize);
            //dev.log('onPanUpdate: ${ParentProvider.lines}');
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
                        parentProvider.signLines,
                        parentProvider.signColor,
                        parentProvider.signWidth,
                        parentProvider.signBackgroundColor,
                        parentProvider.shapeBackgroundUiImage,
                        (parentProvider.selectedShapeInfoIdx == -1)
                            ? null
                            : parentProvider.shapeInfoList[parentProvider.selectedShapeInfoIdx],
                        parentProvider.signShapeBorderColor,
                        parentProvider.signShapeBorderWidth),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          // sign list
          decoration: AppColors.BOXDECO_GREEN50,
          child: SizedBox(
            //width: MediaQuery.of(context).size.width * 1.0,
            height: hBarDetail,
            child: Row(
              children: <Widget>[
                InkWell(
                  onTap: _onTapNone,
                  child: Container(
                    width: whPreSign,
                    height: whPreSign,
                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      //border: Border.all(color: Colors.grey),
                      color: Colors.grey,
                      border: Border.all(color: Colors.black),
                    ),
                    child: Text('NONE'.tr()),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.yellow[50],
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
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: whPreSign,
                                    height: whPreSign,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                    ),
                                    child: Text(preSignList[index]),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 20,
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) => const Divider(),
                    ),
                  ),
                ),
                InkWell(
                  onTap: _onTapNone,
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
        const SizedBox(
          height: 10,
        ),
        Container(
          // tab
          decoration: AppColors.BOXDECO_GREEN50,
          //width: MediaQuery.of(context).size.width * 1.0,
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
                                  (parentProvider.recentSignColorList.isEmpty)
                                      ? Container(
                                          margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                          width: whPreSign,
                                          height: whPreSign,
                                        )
                                      : InkWell(
                                          onTap: () {
                                            dev.log('recent click: ${parentProvider.recentSignColorList.elementAt(0)}');
                                            parentProvider
                                                .setSignColor(parentProvider.recentSignColorList.elementAt(0));
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                            width: whPreSign,
                                            height: whPreSign,
                                            decoration: BoxDecoration(
                                              color: parentProvider.recentSignColorList.elementAt(0),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                width: 2,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: ((parentProvider.recentSignColorList.elementAt(0).value ==
                                                        parentProvider.signColor.value) &&
                                                    !ColorUtil.findColor(AppColors.DEFAULT_COLOR_LIST,
                                                        parentProvider.recentSignColorList.elementAt(0)))
                                                ? Text(
                                                    '✔',
                                                    style: TextStyle(
                                                        color: (parentProvider.recentSignColorList.elementAt(0).value ==
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
                                                  parentProvider.setSignColor(AppColors.DEFAULT_COLOR_LIST[index]);
                                                },
                                                child: Container(
                                                  width: whPreSign,
                                                  height: whPreSign,
                                                  color: AppColors.DEFAULT_COLOR_LIST[index],
                                                  alignment: Alignment.center,
                                                  child: (AppColors.DEFAULT_COLOR_LIST[index].value ==
                                                          parentProvider.signColor.value)
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
                                      //onTap: _onTapColorPicker,
                                      onTap: () {
                                        _onTapColorPicker(parentProvider.signColor, parentProvider.recentSignColorList,
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
                                          parentProvider.setSignWidth(0);
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
                                        thumbColor: parentProvider.signColor,
                                        activeTickMarkColor: Colors.yellow,
                                        valueIndicatorColor: Colors.lightBlue[100],
                                        //valueIndicatorColor: parentProvider.signColor,
                                        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                                        overlayShape: SliderComponentShape.noOverlay,
                                        showValueIndicator: ShowValueIndicator.always,
                                      ),
                                      child: Slider(
                                        value: parentProvider.signWidth,
                                        min: 0,
                                        max: AppConfig.SIGN_WIDTH_MAX,
                                        divisions: AppConfig.SIGN_WIDTH_MAX.toInt() - 1,
                                        label:
                                            '${parentProvider.signWidth.toInt()} / ${AppConfig.SIGN_WIDTH_MAX.toInt()}',
                                        onChangeStart: (newValue) {
                                          dev.log('- Slider ParentProvider.size: ${parentProvider.signWidth}');
                                        },
                                        onChanged: (newValue) {
                                          parentProvider.setSignWidth(newValue);
                                          dev.log('- Slider onChanged size: $newValue');
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                      child: MaterialButton(
                                        height: 20,
                                        onPressed: () {
                                          parentProvider.setSignWidth(AppConfig.SIGN_WIDTH_MAX);
                                        },
                                        color: Colors.lightBlue[100],
                                        textColor: Colors.black,
                                        padding: const EdgeInsets.all(0),
                                        //shape: const CircleBorder(),
                                        child: Text('${AppConfig.SIGN_WIDTH_MAX.toInt()}'),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
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
                                              painter: LinePainter(parentProvider.signWidth, parentProvider.signColor,
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
                                          parentProvider.initSignLines();
                                        },
                                        child: Text('SIGN_CLEAR'.tr())),
                                  ),
                                  SizedBox(
                                    child: OutlinedButton(
                                        style: TextButton.styleFrom(
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        onPressed: () {
                                          parentProvider.undoSignLines();
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
                                  (parentProvider.recentSignBackgroundColorList.isEmpty)
                                      ? Container(
                                          margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                          width: whPreSign,
                                          height: whPreSign,
                                        )
                                      : InkWell(
                                          onTap: () {
                                            dev.log(
                                                'recent click: ${parentProvider.recentSignBackgroundColorList.elementAt(0)}');
                                            parentProvider.setSignBackgroundColor(
                                                parentProvider.recentSignBackgroundColorList.elementAt(0));
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                            width: whPreSign,
                                            height: whPreSign,
                                            decoration: BoxDecoration(
                                              color: parentProvider.recentSignBackgroundColorList.elementAt(0),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                width: 2,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: ((parentProvider.recentSignBackgroundColorList.elementAt(0).value ==
                                                        parentProvider.signBackgroundColor?.value) &&
                                                    !ColorUtil.findColor(AppColors.DEFAULT_COLOR_LIST,
                                                        parentProvider.recentSignBackgroundColorList.elementAt(0)))
                                                ? Text(
                                                    '✔',
                                                    style: TextStyle(
                                                        color: (parentProvider.recentSignBackgroundColorList
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
                                      parentProvider.setSignBackgroundColor(null);
                                    },
                                    child: Container(
                                      width: whPreSign,
                                      height: whPreSign,
                                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: (parentProvider.signBackgroundColor == null)
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
                                                  parentProvider
                                                      .setSignBackgroundColor(AppColors.DEFAULT_COLOR_LIST[index]);
                                                },
                                                child: Container(
                                                  width: whPreSign,
                                                  height: whPreSign,
                                                  color: AppColors.DEFAULT_COLOR_LIST[index],
                                                  alignment: Alignment.center,
                                                  child: (AppColors.DEFAULT_COLOR_LIST[index].value ==
                                                          parentProvider.signBackgroundColor?.value)
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
                                      //onTap: _onTapColorPicker,
                                      onTap: () {
                                        _onTapColorPicker(parentProvider.signBackgroundColor,
                                            parentProvider.recentSignBackgroundColorList, _callbackSignBackgroundColor);
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
                                          parentProvider.initShapeBackgroundUiImage(notify: true);
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
                                      onPressed: () {
                                        _bringSignPressed(MakePageBringEnum.GALLERY, whSignBoard);
                                      }),
                                  ElevatedButton.icon(
                                      icon: const Icon(
                                        Icons.camera_alt_rounded,
                                        color: Colors.lightGreen,
                                      ),
                                      label: Text('CAMERA'.tr()),
                                      style: TextButton.styleFrom(backgroundColor: Colors.white),
                                      onPressed: () {
                                        _bringSignPressed(MakePageBringEnum.CAMERA, whSignBoard);
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
                                      parentProvider.setSelectedShapeInfoIdx(-1);
                                    },
                                    child: Container(
                                      width: whPreSign,
                                      height: whPreSign,
                                      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                      alignment: Alignment.center,
                                      decoration: (parentProvider.selectedShapeInfoIdx == -1)
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
                                        itemCount: parentProvider.shapeInfoList.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          return Row(
                                            children: [
                                              InkWell(
                                                onTap: () => _onTapPreShape(index),
                                                child: Container(
                                                  width: whPreSign,
                                                  height: whPreSign,
                                                  decoration: (parentProvider.selectedShapeInfoIdx == index)
                                                      ? BoxDecoration(
                                                          color: Colors.grey[200],
                                                          border: Border.all(color: Colors.black))
                                                      : const BoxDecoration(),
                                                  child: parentProvider.shapeInfoList[index].svgPicture,
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
                                  (parentProvider.recentSignShapeBorderColorList.isEmpty)
                                      ? Container(
                                          margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                          width: whPreSign,
                                          height: whPreSign,
                                        )
                                      : InkWell(
                                          onTap: () {
                                            dev.log(
                                                'recent click: ${parentProvider.recentSignShapeBorderColorList.elementAt(0)}');
                                            parentProvider.setSignShapeBorderColor(
                                                parentProvider.recentSignShapeBorderColorList.elementAt(0));
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                            width: whPreSign,
                                            height: whPreSign,
                                            decoration: BoxDecoration(
                                              color: parentProvider.recentSignShapeBorderColorList.elementAt(0),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                width: 2,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: ((parentProvider.recentSignShapeBorderColorList.elementAt(0).value ==
                                                        parentProvider.signShapeBorderColor?.value) &&
                                                    !ColorUtil.findColor(AppColors.DEFAULT_COLOR_LIST,
                                                        parentProvider.recentSignShapeBorderColorList.elementAt(0)))
                                                ? Text(
                                                    '✔',
                                                    style: TextStyle(
                                                        color: (parentProvider.recentSignShapeBorderColorList
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
                                      parentProvider.setSignShapeBorderColor(null);
                                    },
                                    child: Container(
                                      width: whPreSign,
                                      height: whPreSign,
                                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: (parentProvider.signShapeBorderColor == null)
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
                                                  parentProvider
                                                      .setSignShapeBorderColor(AppColors.DEFAULT_COLOR_LIST[index]);
                                                },
                                                child: Container(
                                                  width: whPreSign,
                                                  height: whPreSign,
                                                  color: AppColors.DEFAULT_COLOR_LIST[index],
                                                  alignment: Alignment.center,
                                                  child: (AppColors.DEFAULT_COLOR_LIST[index].value ==
                                                          parentProvider.signShapeBorderColor?.value)
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
                                      //onTap: _onTapColorPicker,
                                      onTap: () {
                                        _onTapColorPicker(
                                            parentProvider.signShapeBorderColor,
                                            parentProvider.recentSignShapeBorderColorList,
                                            _callbackSignShapeBorderColor);
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
                                          parentProvider.setSignShapeBorderWidth(0);
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
                                        thumbColor: parentProvider.signShapeBorderColor,
                                        activeTickMarkColor: Colors.yellow,
                                        valueIndicatorColor: Colors.lightBlue[100],
                                        //valueIndicatorColor: parentProvider.signColor,
                                        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                                        overlayShape: SliderComponentShape.noOverlay,
                                        showValueIndicator: ShowValueIndicator.always,
                                      ),
                                      child: Slider(
                                        value: (parentProvider.signShapeBorderColor == null)
                                            ? 0
                                            : parentProvider.signShapeBorderWidth,
                                        min: 0,
                                        max: AppConfig.SIGN_WIDTH_MAX,
                                        divisions: AppConfig.SIGN_WIDTH_MAX.toInt() - 1,
                                        label:
                                            '${parentProvider.signShapeBorderWidth.toInt()} / ${AppConfig.SIGN_WIDTH_MAX.toInt()}',
                                        onChangeStart: (newValue) {
                                          dev.log(
                                              '- Slider ParentProvider.size: ${parentProvider.signShapeBorderWidth}');
                                        },
                                        onChanged: (newValue) {
                                          if (parentProvider.signShapeBorderColor != null) {
                                            parentProvider.setSignShapeBorderWidth(newValue);
                                            dev.log('- Slider onChanged size: $newValue');
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                      child: MaterialButton(
                                        height: 20,
                                        onPressed: () {
                                          parentProvider.setSignShapeBorderWidth(AppConfig.SIGN_WIDTH_MAX);
                                        },
                                        color: Colors.lightBlue[100],
                                        textColor: Colors.black,
                                        padding: const EdgeInsets.all(0),
                                        //shape: const CircleBorder(),
                                        child: Text('${AppConfig.SIGN_WIDTH_MAX.toInt()}'),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
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
                                              painter: LinePainter(parentProvider.signShapeBorderWidth,
                                                  parentProvider.signShapeBorderColor,
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
  void _onTapNone() {
    dev.log('# SignMbs _onTapNone START');
    dev.log('----------');
    dev.log('parentProvider.recentSignColorList: ${parentProvider.recentSignColorList}');
    dev.log('parentProvider.signColor: ${parentProvider.signColor}');
    dev.log('parentProvider.signWidth: ${parentProvider.signWidth}');
    dev.log('parentProvider.recentSignBackgroundColorList: ${parentProvider.recentSignBackgroundColorList}');
    dev.log('parentProvider.signBackgroundColor: ${parentProvider.signBackgroundColor}');
    dev.log('parentProvider.recentSignShapeBorderColorList: ${parentProvider.recentSignShapeBorderColorList}');
    dev.log('parentProvider.signShapeBorderColor: ${parentProvider.signShapeBorderColor}');
    dev.log('parentProvider.signShapeBorderWidth: ${parentProvider.signShapeBorderWidth}');
    dev.log('----------');
    dev.log('parentProvider.signLines: ${parentProvider.signLines}');
    dev.log('parentProvider.selectedShapeInfoIdx: ${parentProvider.selectedShapeInfoIdx}');
    dev.log('whPreSign: $whPreSign');
  }

  void _onTapColorPicker(Color? color, List<Color> colorList, var callback) async {
    dev.log('# SignMbs _onTapColorPicker START');

    // color picker 에서 초기 color 는 null 일 수 없음
    color ??= Colors.blue;

    //List<Color> listColor = List.from(parentProvider.recentSignColorList);
    //ColorUtil.insertAndSet(listColor, parentProvider.signColor, AppConfig.SIGNCOLOR_SAVE_MAX);
    final Color colorBeforeDialog = color;
    // Wait for the picker to close, if dialog was dismissed,
    // then restore the color we had before it was opened.
    if (!(await ColorUtil.colorPickerDialog(
        //context, parentProvider.signColor, parentProvider.recentSignColorList, _callbackSignColor))) {
        context,
        color,
        colorList,
        callback))) {
      //parentProvider.setSignColor(colorBeforeDialog);
      callback(colorBeforeDialog);
    } else {
      //parentProvider.addRecentColor(parentProvider.signColor, AppConfig.SIGNCOLOR_SAVE_MAX);
      callback(null, recent: true);
    }
  }

  void _callbackSignColor(Color? color, {bool recent = false}) {
    color ??= parentProvider.signColor;
    if (recent) {
      parentProvider.addRecentSignColor(color, AppConfig.SIGNCOLOR_SAVE_MAX, notify: false);
    }
    parentProvider.setSignColor(color);
  }

  void _callbackSignBackgroundColor(Color? color, {bool recent = false}) {
    color ??= parentProvider.signBackgroundColor;
    if (recent && color != null) {
      parentProvider.addRecentSignBackgroundColor(color, AppConfig.SIGNCOLOR_SAVE_MAX, notify: false);
    }
    parentProvider.setSignBackgroundColor(color);
  }

  void _callbackSignShapeBorderColor(Color? color, {bool recent = false}) {
    color ??= parentProvider.signShapeBorderColor;
    if (recent && color != null) {
      parentProvider.addRecentSignShapeBorderColor(color, AppConfig.SIGNCOLOR_SAVE_MAX, notify: false);
    }
    parentProvider.setSignShapeBorderColor(color);
  }

  void _onTapPreSign(int idx) {
    dev.log('# SignMbs _onTapPreSign START idx: $idx');
  }

  void _onTapPreShape(int idx) {
    dev.log('# SignMbs _onTapPreShape START idx: $idx');
    parentProvider.setSelectedShapeInfoIdx(idx);
  }

  void _onTapShapeList() {
    dev.log('# SignMbs _onTapShapeList START');

    /*
    showDialog(
        context: context,
        barrierDismissible: true, // 바깥 영역 터치시 창닫기
        builder: (BuildContext context) {
          return const ShapeListPopup();
        });
     */
    showDialog(
        context: context,
        barrierDismissible: true, // 바깥 영역 터치시 창닫기
        builder: (BuildContext context) {
          return const ShapeListPopup();
        }).then((ret) {
      dev.log('_onTapShapeList ret: $ret');
      if (ret == 'OK') {
        dev.log('_onTapShapeList OK');

        if (parentProvider.selectedShapeInfoIdx != -1) {
          double listWidth = wScreen - (whPreSign + 10 * 2) * 2;
          double cntPreSign = listWidth / (whPreSign + 10);
          dev.log('cntPreSign: $cntPreSign');

          _preShapeController.animateTo(
            parentProvider.selectedShapeInfoIdx * (whPreSign + 10) - (whPreSign) * cntPreSign * 0.5 - 10 * 0.5,
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
          );
        }
      }
    });
  }

  void _bringSignPressed(MakePageBringEnum type, double whSignBoard) async {
    dev.log('# SignMbs _bringSignPressed START');

    XFile? xFile;
    if (type == MakePageBringEnum.CAMERA) {
      xFile = await ImagePicker().pickImage(source: ImageSource.camera);
    } else {
      xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    }
    dev.log('file: ${xFile?.path}');
    if (xFile == null) return; // 취소한 경우

    await parentProvider.loadShapeBackgroundUiImage(xFile!.path, whSignBoard);

    dev.log('# SignMbs _bringSignPressed END');
  }

  void _onPresseClearAll() async {
    dev.log('# SignMbs _onPresseClearAll START');

    PopupUtil.popupAlertOkCancel(context, 'INFO'.tr(), 'SIGN_INIT_ALL'.tr())
        .then((ret) {
      dev.log('popupAlertOkCancel: $ret');

      // example
      if (ret == null) {
        // 팝업 바깥 영역을 클릭한 경우
        return;
      }
      if (ret == AppConstant.OK) {

        ////////////////////////////////////////////////////////////////////////////////
        // line
        parentProvider.signLines.clear();

        if (parentProvider.recentSignColorList.isNotEmpty) {
          parentProvider.signColor = parentProvider.recentSignColorList[0];
        }
        parentProvider.signWidth = 10;
        ////////////////////////////////////////////////////////////////////////////////

        ////////////////////////////////////////////////////////////////////////////////
        // background
        parentProvider.signBackgroundColor = null;
        parentProvider.shapeBackgroundUiImage = null;
        ////////////////////////////////////////////////////////////////////////////////

        ////////////////////////////////////////////////////////////////////////////////
        // shape
        parentProvider.selectedShapeInfoIdx = -1;
        if (parentProvider.recentSignShapeBorderColorList.isNotEmpty) {
          parentProvider.signShapeBorderColor = parentProvider.recentSignShapeBorderColorList[0];
        }
        parentProvider.signShapeBorderColor = null;
        parentProvider.signShapeBorderWidth = 10;
        ////////////////////////////////////////////////////////////////////////////////

        setState(() {});
      }
    });

  }

  void _onPressedOk() async {
    dev.log('# SignMbs _onPressedOk START');

    Rect dstRect = const Offset(0, 0) & Size(whSignBoard, whSignBoard);

    ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder, dstRect);

    Path svgPath = parseSvgPath(
        'm12 23.1-1.45-1.608C5.4 15.804 2 12.052 2 7.45 2 3.698 4.42.75 7.5.75c1.74 0 3.41.987 4.5 2.546C13.09 1.736 14.76.75 16.5.75c3.08 0 5.5 2.948 5.5 6.699 0 4.604-3.4 8.355-8.55 14.055L12 23.1z');

    // org
    Float64List shapeMatrix = Float64List.fromList(
        [whSignBoard / AppConfig.SVG_WH, 0, 0, 0, 0, whSignBoard / AppConfig.SVG_WH, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
    Path shapePath = svgPath.transform(shapeMatrix);

    //canvas.clipPath(shapePath);   // path 영역에서만 그리기가 동작함

    Paint borderPaint = Paint()
      ..color = Colors.green
      //..color = Colors.black12
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;
    canvas.drawPath(shapePath, borderPaint);
    dev.log('org width / AppConfig.SVG_WH: ${whSignBoard / AppConfig.SVG_WH}');

    // border
    Float64List borderMatrix = Float64List.fromList([
      (whSignBoard - 20) / AppConfig.SVG_WH,
      0,
      0,
      0,
      0,
      (whSignBoard - 20) / AppConfig.SVG_WH,
      0,
      0,
      0,
      0,
      1,
      0,
      10,
      10,
      0,
      1
    ]);
    Path borderPath = svgPath.transform(borderMatrix);
    dev.log('border (width - 20) / AppConfig.SVG_WH: ${(whSignBoard - 20) / AppConfig.SVG_WH}');

    canvas.clipPath(borderPath); // path 영역에서만 그리기가 동작함

    if (parentProvider.shapeBackgroundUiImage != null)
      canvas.drawImage(parentProvider.shapeBackgroundUiImage!, Offset(0, -68 / 2), Paint());

    ui.Image newImage =
        await pictureRecorder.endRecording().toImage(dstRect.width.toInt(), dstRect.height.toInt()); // 여기서 scaling 안됨

    File newImageFile = await FileUtil.initTempDirAndFile(AppConstant.SIGN_DIR, 'png');
    dev.log('newImageFile.path: ${newImageFile.path}');

    /*
    ByteData? jpgByte = await newImage.toByteData(format: ui.ImageByteFormat.png);
    // byte 저장
    newImageFile.writeAsBytesSync(jpgByte!.buffer.asUint8List(),
        flush: true, mode: FileMode.write);
    */
    await FileUtil.saveUiImageToPng(newImage, newImageFile);
    dev.log('writeAsBytesSync end');

    //Navigator.pop(context, 'OK');
  }
////////////////////////////////////////////////////////////////////////////////
// Event Start //
////////////////////////////////////////////////////////////////////////////////
}
