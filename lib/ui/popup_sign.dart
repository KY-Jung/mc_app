import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:image/image.dart' as IMG;

import 'package:easy_localization/easy_localization.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jpeg_encode/jpeg_encode.dart';
import 'package:mc/config/constant_app.dart';
import 'package:mc/ui/screen_make.dart';
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
import '../painter/painter_make_parent_sign.dart';
import '../provider/provider_make.dart';
import '../provider/provider_sign.dart';
import '../util/util_file.dart';
import '../util/util_info.dart';

class SignPopup extends StatefulWidget {
  const SignPopup({super.key});

  @override
  State<SignPopup> createState() => SignPopupState();
}

class SignPopupState extends State<SignPopup> {
  ////////////////////////////////////////////////////////////////////////////////
  late SignProvider signProvider;

  late double whSignBoard;
  late double hBarDetail;
  late double whPreSign;
  late double hAppBar;
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# SignPopup initState START');
    super.initState();

    dev.log('# SignPopup initState END');
  }

  @override
  void dispose() {
    dev.log('# SignPopup dispose START');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# SignPopup build START');

    ////////////////////////////////////////////////////////////////////////////////
    signProvider = Provider.of<SignProvider>(context);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // sign board wh
    whSignBoard = InfoUtil.calcFitSign(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
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

    List<String> preSignList = <String>['A', 'B', 'C', '1', '2', '3', '4'];
    List<int> colorCodes = <int>[600, 500, 400, 300, 200, 100, 100];

    return AlertDialog(
      title: Text('SIZE_SIGN_MAKE_TITLE'.tr()),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (DragStartDetails d) {
              signProvider.drawStart(d.localPosition);
            },
            onPanUpdate: (DragUpdateDetails dragUpdateDetails) {
              //double? primaryDelta = dragUpdateDetails.primaryDelta;  // 항상 null
              Offset offset = dragUpdateDetails.delta;
              //dev.log('offset: $offset');
              double delta =
                  math.sqrt(math.pow(offset.dx, 2) + math.pow(offset.dy, 2));
              //dev.log('delta: $delta');
              double newSize =
                  signProvider.size - signProvider.size / 10 * delta;

              signProvider.drawing(dragUpdateDetails.localPosition, newSize);
              //dev.log('onPanUpdate: ${signProvider.lines}');
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                /*
                Container(
                  decoration: AppColors.BOXDECO_YELLOW50,
                  width: whSignBoard,
                  height: whSignBoard,
                  child: Image.asset('assets/images/jeju.jpg', fit: BoxFit.cover),
                ),
                */
                /*
                SizedBox(
                  width: whSignBoard,
                  height: whSignBoard,
                  child: SvgPicture.asset(
                    '${AppConstant.SHAPE_DIR}ic_baby_heart.svg',
                    colorFilter: ColorFilter.mode(Colors.red, BlendMode.srcIn),
                    placeholderBuilder: (BuildContext context) => Container(
                      padding: const EdgeInsets.all(30.0),
                      child: const CircularProgressIndicator()),
                  ),
                ),
                SizedBox(
                  width: whSignBoard - 10,
                  height: whSignBoard - 10,
                  child: SvgPicture.asset(
                    '${AppConstant.SHAPE_DIR}ic_baby_heart.svg',
                    //bundle: Image.asset('assets/images/jeju.jpg'),
                    colorFilter: ColorFilter.mode(Colors.yellow[50]!, BlendMode.srcIn),
                  ),
                ),
                */
                /*
                Container(
                  alignment: Alignment.center,
                  width: whSignBoard * 1.3,
                  height: whSignBoard * 1.3,
                  child: ClipPath(
                    clipper: SignClipper(whSignBoard, whSignBoard),
                    child: Image.asset('assets/images/jeju.jpg', width: 1080, height: 1440),
                    //child: Image.asset('assets/images/jeju.jpg'),
                  ),
                ),
                */
                CustomPaint(
                    size: Size(whSignBoard, whSignBoard),
                    painter: MakeParentSignPainter(
                        whSignBoard, whSignBoard, signProvider.lines, signProvider.shapeBackground),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: AppColors.BOXDECO_GREEN50,
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
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: AppColors.BOXDECO_GREEN50,
            width: MediaQuery.of(context).size.width * 1.0,
            height: hAppBar * 3,
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: hAppBar * 0.5,
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
                          decoration: AppColors.BOXDECO_GREEN50,
                          child: Row(
                            children: <Widget>[
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    height: 8,
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        'COLOR'.tr(),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        'THICKNESS'.tr(),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 8,
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      height: 8,
                                    ),
                                    Expanded(
                                      child: Container(
                                        //color: Colors.yellow[50],
                                        margin: const EdgeInsets.fromLTRB(
                                            0, 10, 10, 10),
                                        child: ListView.separated(
                                          padding: const EdgeInsets.all(10),
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: preSignList.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Row(
                                              children: [
                                                InkWell(
                                                  onTap: () =>
                                                      _onTapPreSign(index),
                                                  child: Container(
                                                    width: whPreSign,
                                                    height: whPreSign,
                                                    color: Colors.amber[
                                                        colorCodes[index]],
                                                    child: badges.Badge(
                                                      badgeContent:
                                                          Text('${index + 1}'),
                                                      badgeStyle:
                                                          badges.BadgeStyle(
                                                        badgeColor: AppColors
                                                            .BLUE_LIGHT,
                                                      ),
                                                      child: Center(
                                                          child: Text(
                                                              '${preSignList[index]}')),
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
                                              (BuildContext context,
                                                      int index) =>
                                                  const Divider(),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.all(10),
                                        child: Slider(
                                          activeColor: Colors.white,
                                          inactiveColor: Colors.white,
                                          value: signProvider.size,
                                          onChanged: (size) {
                                            signProvider.changeSize(size);
                                            dev.log('Slider size: $size');
                                          },
                                          min: 1,
                                          max: AppConfig.SIGN_WIDTH_MAX,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: AppColors.BOXDECO_GREEN50,
                          child: Row(
                            children: <Widget>[
                              Column(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    height: 8,
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        'COLOR'.tr(),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        'BRING'.tr(),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 8,
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      height: 8,
                                    ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.all(10),
                                        child: Text(
                                          'COLOR'.tr(),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Expanded(
                                            child: ElevatedButton.icon(
                                                icon: const Icon(
                                                  Icons.photo,
                                                  color: Colors.amber,
                                                ),
                                                label: Text('GALLERY'.tr()),
                                                style: TextButton.styleFrom(
                                                    backgroundColor: Colors.white),
                                                onPressed: () {
                                                  _bringSignPressed(MakeBringEnum.GALLERY, whSignBoard);
                                                }),
                                          ),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                                icon: const Icon(
                                                  Icons.camera_alt_rounded,
                                                  color: Colors.lightGreen,
                                                ),
                                                label: Text('CAMERA'.tr()),
                                                style: TextButton.styleFrom(
                                                    backgroundColor: Colors.white),
                                                onPressed: () {
                                                  _bringSignPressed(MakeBringEnum.CAMERA, whSignBoard);
                                                }),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 8,
                                    ),
                                  ],
                                ),

                              ),
                            ],
                          ),

                        ),
                        Container(
                          decoration: AppColors.BOXDECO_GREEN50,
                          child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.photo,
                                color: Colors.amber,
                              ),
                              label: Text('GALLERY'.tr()),
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.white),
                              onPressed: () {
                                signProvider.loadShapeBackground('assets/images/jeju.jpg', whSignBoard);
                                //signProvider.loadShapeBackground('${AppConstant.SHAPE_DIR}ic_baby_heart.svg');
                              }),
                          /*
                          SvgPicture.asset(
                            '${AppConstant.SHAPE_DIR}ic_baby_heart.svg',
                            width: 10,
                            height: 10,
                          ),
                          */
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        ElevatedButton(
            onPressed: () => Navigator.pop(context, 'DELETE'),
            child: Text('DELETE'.tr())),
        ElevatedButton(
            onPressed: () => Navigator.pop(context, 'CANCEL'),
            child: Text('CANCEL'.tr())),
        ElevatedButton(
            onPressed: _onPressedOk,
            child: Text('OK'.tr())),
      ],
    );
  }

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // Event Start //
  ////////////////////////////////////////////////////////////////////////////////
  void _onTapNone() {
    dev.log('# SignPopup _onTapNone START');
    signProvider.initLines();
    signProvider.initShapeBackground();
  }

  void _onTapPreSign(int index) {
    dev.log('# SignPopup _onTapPreSign START index: $index');
  }

  void _bringSignPressed(MakeBringEnum type, double whSignBoard) async {
    dev.log('# SignPopup _bringSignPressed START');

    XFile? xFile;
    if (type == MakeBringEnum.CAMERA) {
      xFile = await ImagePicker().pickImage(source: ImageSource.camera);
    } else {
      xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    }
    dev.log('file: ${xFile?.path}');
    if (xFile == null) return; // 취소한 경우

    signProvider.loadShapeBackground(xFile!.path, whSignBoard);

    dev.log('# SignPopup _bringSignPressed END');
  }

  void _onPressedOk() async {
    dev.log('# SignPopup _onPressedOk START');

    Rect dstRect = const Offset(0, 0) & Size(whSignBoard, whSignBoard);

    ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder, dstRect);


    Path svgPath = parseSvgPath('m12 23.1-1.45-1.608C5.4 15.804 2 12.052 2 7.45 2 3.698 4.42.75 7.5.75c1.74 0 3.41.987 4.5 2.546C13.09 1.736 14.76.75 16.5.75c3.08 0 5.5 2.948 5.5 6.699 0 4.604-3.4 8.355-8.55 14.055L12 23.1z');

    // org
    Float64List shapeMatrix = Float64List.fromList(
        [whSignBoard / AppConfig.SVG_WH, 0, 0, 0,
          0, whSignBoard / AppConfig.SVG_WH, 0, 0,
          0, 0, 1, 0,
          0, 0, 0, 1]);
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
    Float64List borderMatrix = Float64List.fromList(
        [(whSignBoard - 20) / AppConfig.SVG_WH, 0, 0, 0,
          0, (whSignBoard - 20) / AppConfig.SVG_WH, 0, 0,
          0, 0, 1, 0,
          10, 10, 0, 1]);
    Path borderPath = svgPath.transform(borderMatrix);
    dev.log('border (width - 20) / AppConfig.SVG_WH: ${(whSignBoard - 20) / AppConfig.SVG_WH}');

    canvas.clipPath(borderPath);   // path 영역에서만 그리기가 동작함

    if (signProvider.shapeBackground != null)
      canvas.drawImage(signProvider.shapeBackground!, Offset(0, -68 / 2), Paint());



    ui.Image newImage = await pictureRecorder
        .endRecording()
        .toImage(dstRect.width.toInt(), dstRect.height.toInt());    // 여기서 scaling 안됨




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
