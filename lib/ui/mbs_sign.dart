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

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# SignMbs initState START');
    super.initState();

    dev.log('# SignMbs initState END');
  }

  @override
  void dispose() {
    dev.log('# SignMbs dispose START');
    super.dispose();

    parentProvider.initSignLines(notify: false);
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

    dev.log('whSignBoard: ${whSignBoard}, hBarDetail: ${hBarDetail}, whPreSign: ${whPreSign}, hAppBar: ${hAppBar}');
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
        Row(    // 맨 위 확인 버튼
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(onPressed: () => Navigator.pop(context, 'DELETE'), child: Text('DELETE'.tr())),
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
        GestureDetector(    // sign board
          behavior: HitTestBehavior.translucent,
          onPanStart: (DragStartDetails d) {
            parentProvider.drawSignLinesStart(d.localPosition);
          },
          onPanUpdate: (DragUpdateDetails dragUpdateDetails) {
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
                        whSignBoard, whSignBoard, parentProvider.signLines, parentProvider.shapeBackgroundUiImage),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(    // sign list
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
                    color: Colors.black12,
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
                                  child: Center(child: Text(preSignList[index])),
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
        Container(    // tab
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
                        // 첫번째 탭
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
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                    width: whPreSign,
                                    height: whPreSign,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: 3,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: InkWell(
                                      onTap: _onTapNone,
                                      child: const Text('✔'),
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
                                                onTap: () => _onTapPreSign(index),
                                                child: Container(
                                                  width: whPreSign,
                                                  height: whPreSign,
                                                  color: AppColors.DEFAULT_COLOR_LIST[index],
                                                  alignment: Alignment.center,
                                                  child: const Text('✔', style: TextStyle(color:Colors.white)),
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
                                      onTap: _onTapColorPicker,
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
                                          parentProvider.changeSignWidth(1);
                                        },
                                        color: Colors.lightBlue,
                                        textColor: Colors.white,
                                        padding: const EdgeInsets.all(0),
                                        //shape: const CircleBorder(),
                                        child: const Text('0'),
                                      ),
                                    ),
                                    SliderTheme(
                                      data: SliderThemeData(
                                        activeTrackColor: Colors.lightBlue,
                                        inactiveTrackColor: Colors.grey,
                                        thumbColor: Colors.orange,
                                        activeTickMarkColor: Colors.yellow,
                                        valueIndicatorColor: Colors.lightBlue,
                                        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                                        overlayShape: SliderComponentShape.noOverlay,
                                      ),
                                      child: Slider(
                                        value: parentProvider.signWidth,
                                        min: 0,
                                        max: AppConfig.SIGN_WIDTH_MAX,
                                        divisions: AppConfig.SIGN_WIDTH_MAX.toInt() - 1,
                                        label: '${parentProvider.signWidth.toInt()} / ${AppConfig.SIGN_WIDTH_MAX.toInt()}',
                                        onChangeStart: (newValue) {
                                          dev.log('- Slider ParentProvider.size: ${parentProvider.signWidth}');
                                        },
                                        onChanged: (newValue) {
                                          parentProvider.changeSignWidth(newValue);
                                          dev.log('- Slider onChanged size: $newValue');
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                      child: MaterialButton(
                                        height: 20,
                                        onPressed: () {
                                          parentProvider.changeSignWidth(AppConfig.SIGN_WIDTH_MAX);
                                        },
                                        color: Colors.lightBlue,
                                        textColor: Colors.white,
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
                                              painter: LinePainter(parentProvider.signWidth, parentProvider.signColor),
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
                            Expanded(flex: 1, child: SizedBox(height: hBarDetail, child: const Text(' '))),
                          ],
                        ),
                      ),
                      Container(
                        // 두번째 탭
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
                                  InkWell(
                                    onTap: _onTapNone,
                                    child: Container(
                                      width: whPreSign,
                                      height: whPreSign,
                                      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                      alignment: Alignment.center,
                                      color: Colors.black12,
                                      child: Text('NONE'.tr()),
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
                                                onTap: () => _onTapPreSign(index),
                                                child: Container(
                                                  width: whPreSign,
                                                  height: whPreSign,
                                                  color: AppColors.DEFAULT_COLOR_LIST[index],
                                                  alignment: Alignment.center,
                                                  child: const Text('✔', style: TextStyle(color:Colors.white)),
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
                                      onTap: _onTapColorPicker,
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
                        // 세번째 탭
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
                                    onTap: _onTapNone,
                                    child: Container(
                                      width: whPreSign,
                                      height: whPreSign,
                                      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                      alignment: Alignment.center,
                                      color: Colors.black12,
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
                                        //itemCount: preSignList.length,
                                        itemCount: parentProvider.shapeInfoList.length,


                                        itemBuilder: (BuildContext context, int index) {
                                          return Row(
                                            children: [
                                              InkWell(
                                                onTap: () => _onTapPreSign(index),
                                                child: Container(
                                                  width: whPreSign,
                                                  height: whPreSign,
                                                  //color: Colors.amber[colorCodes[index]],
                                                  //child: Center(child: Text(preSignList[index])),
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
                                  InkWell(
                                    onTap: _onTapNone,
                                    child: Container(
                                      width: whPreSign,
                                      height: whPreSign,
                                      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                      alignment: Alignment.center,
                                      color: Colors.black12,
                                      child: Text('NONE'.tr()),
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
                                                onTap: () => _onTapPreSign(index),
                                                child: Container(
                                                  width: whPreSign,
                                                  height: whPreSign,
                                                  color: AppColors.DEFAULT_COLOR_LIST[index],
                                                  alignment: Alignment.center,
                                                  child: const Text('✔', style: TextStyle(color:Colors.white)),
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
                                      onTap: _onTapColorPicker,
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
                                          parentProvider.changeSignWidth(1);
                                        },
                                        color: Colors.blue,
                                        textColor: Colors.white,
                                        padding: const EdgeInsets.all(0),
                                        //shape: const CircleBorder(),
                                        child: const Text('0'),
                                      ),
                                    ),
                                    SliderTheme(
                                      data: SliderThemeData(
                                        activeTrackColor: Colors.blue,
                                        inactiveTrackColor: Colors.grey,
                                        thumbColor: Colors.orange,
                                        activeTickMarkColor: Colors.yellow,
                                        valueIndicatorColor: Colors.blue,
                                        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                                        overlayShape: SliderComponentShape.noOverlay,
                                        showValueIndicator: ShowValueIndicator.always,
                                      ),
                                      child: Slider(
                                        value: parentProvider.signWidth,
                                        min: 0,
                                        max: AppConfig.SIGN_WIDTH_MAX,
                                        divisions: AppConfig.SIGN_WIDTH_MAX.toInt() - 1,
                                        label: '${parentProvider.signWidth.toInt()} / ${AppConfig.SIGN_WIDTH_MAX.toInt()}',
                                        onChangeStart: (newValue) {
                                          dev.log('- Slider ParentProvider.size: ${parentProvider.signWidth}');
                                        },
                                        onChanged: (newValue) {
                                          parentProvider.changeSignWidth(newValue);
                                          dev.log('- Slider onChanged size: $newValue');
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                      child: MaterialButton(
                                        height: 20,
                                        onPressed: () {
                                          parentProvider.changeSignWidth(AppConfig.SIGN_WIDTH_MAX);
                                        },
                                        color: Colors.blue,
                                        textColor: Colors.white,
                                        padding: const EdgeInsets.all(0),
                                        //shape: const CircleBorder(),
                                        child: Text('${AppConfig.SIGN_WIDTH_MAX.toInt()}'),
                                      ),
                                    ),
                                    /*
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
                                              painter: LinePainter(ParentProvider.size, ParentProvider.color),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    */
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

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // Event Start //
  ////////////////////////////////////////////////////////////////////////////////
  void _onTapNone() {
    dev.log('# SignMbs _onTapNone START');
    parentProvider.initSignLines();
    parentProvider.initShapeBackgroundUiImage();
  }

  void _onTapColorPicker() {
    dev.log('# SignMbs _onTapColorPicker START');

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ColorPickerPage()),
    );
  }

  void _onTapPreSign(int index) {
    dev.log('# SignMbs _onTapPreSign START index: $index');
  }

  void _onTapShapeList() {
    dev.log('# SignMbs _onTapShapeList START');

    showDialog(
        context: context,
        barrierDismissible: true, // 바깥 영역 터치시 창닫기
        builder: (BuildContext context) {
          return const ShapeListPopup();
        }
    );
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
