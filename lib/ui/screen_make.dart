import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mc/ui/widget_baby.dart';
import 'package:mc/ui/widget_blank.dart';
import 'package:mc/ui/widget_caption.dart';
import 'package:mc/ui/widget_link.dart';
import 'package:mc/ui/widget_parent.dart';
import 'package:mc/ui/widget_sound.dart';

import '../config/config_app.dart';
import '../config/constant_app.dart';
import '../dto/info_parent.dart';
import '../util/util_image.dart';
import '../util/util_popup.dart';

enum MakeEnum {
  BLANK,
  PARENT,
  BABY,
  CAPTION,
  SOUND,
  LINK,
}

enum MakeBringEnum {
  GALLERY,
  CAMERA,
}

class MakeScreen extends StatefulWidget {
  const MakeScreen({super.key});

  @override
  State<MakeScreen> createState() => _MakeScreen();
}

class _MakeScreen extends State<MakeScreen> {
  ////////////////////////////////////////////////////////////////////////////////
  // variable

  MakeEnum _makeEnum = MakeEnum.BLANK;

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // object

  //Matrix4 matrix4 = Matrix4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
  final TransformationController _transformationController =
      TransformationController(
          Matrix4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1));

  late TapDownDetails _tapDownDetails;
  late ScaleUpdateDetails _scaleUpdateDetails;

  /// build 이후에 InteractiveViewer 화면 크기를 구할때 사용
  final GlobalKey _globalKey = GlobalKey();

  /// float 를 toggle 할때 사용
  late GlobalObjectKey<ExpandableFabState> _floatKey;

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# MakeScreen initState START');
    super.initState();

    ////////////////////////////////////////////////////////////////////////////////
    // for FAB
    _floatKey = GlobalObjectKey<ExpandableFabState>(context);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    if (ParentInfo.path != '') {
      dev.log('recall _setParentInfo');
      _setParentInfo(ParentInfo.path).then((_) => {});
      _makeEnum = MakeEnum.PARENT;

      // TODO : 나머지도 다시 초기화
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    /// build 이후 실행
    /// InteractiveViewer 실제 크기 구하기
    WidgetsBinding.instance.addPostFrameCallback((_) => _afterBuild(context));
    ////////////////////////////////////////////////////////////////////////////////

    dev.log('# MakeScreen initState END');
  }

  @override
  void dispose() {
    dev.log('# MakeScreen dispose START');
    super.dispose();

    _transformationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# MakeScreen build START');
    dev.log('makeType: $_makeEnum');

    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.black,
        title: Text('MAKE_NEW'.tr()),

        actions: [
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(10),
            //padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              onTap: _onTabDelete,
              onLongPress: _onLongPressDelete,
              child: Ink(
                child: const Icon(Icons.delete),
              ),
            ),
          ),
        ],
      ),

      body: Scaffold(
        backgroundColor: Colors.black87,
        body: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand, // 비로소 상하 center 에 오게됨
                children: <Widget>[
                  if (_makeEnum != MakeEnum.BLANK)
                    GestureDetector(
                      onTapDown: _onTapDown,
                      onDoubleTap: _onDoubleTap,
                      child: InteractiveViewer(
                        // for build 이후에 _initScreen 에서 InteractiveViewer 의 사이즈 구하기
                        key: _globalKey,
                        maxScale: AppConfig.MAKE_SCREEN_MAX,
                        minScale: AppConfig.MAKE_SCREEN_MIN,
                        transformationController: _transformationController,
                        panEnabled: true,
                        scaleEnabled: true,
                        constrained: true,
                        //panAxis: PanAxis.aligned,   // 중앙을 기준으로만 확대됨
                        //boundaryMargin: const EdgeInsets.all(20.0),   // 이동시키면 공백이 나타남
                        onInteractionStart: _onInteractionStart,
                        onInteractionEnd: _onInteractionEnd,
                        onInteractionUpdate: _onInteractionUpdate,
                        //child: Image.asset("assets/images/jeju.jpg"),
                        //child: CustomPaint(
                        //  painter: MyPainter(ParentInfo.image!),
                        //),
                        child: Image.file(File(ParentInfo.path)),
                      ),
                    ),
                  if (_makeEnum != MakeEnum.BLANK)
                    IgnorePointer(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          // size 안 정해도 동작함
                          painter: MakePainter(),
                        ),
                      ),
                    ),
                  if (_makeEnum == MakeEnum.BLANK)
                    Row(
                      key: _globalKey,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton.icon(
                            icon: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.lightGreen,
                            ),
                            label: Text('CAMERA'.tr()),
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.white),
                            //onPressed: _bringPressed(BringTypeEnum.CAMERA),
                            onPressed: () {
                              _bringParentPressed(MakeBringEnum.CAMERA);
                            }),
                        ElevatedButton.icon(
                            icon: const Icon(
                              Icons.photo,
                              color: Colors.amber,
                            ),
                            label: Text('GALLERY'.tr()),
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.white),
                            onPressed: () {
                              _bringParentPressed(MakeBringEnum.GALLERY);
                            }),
                      ],
                    ),
                  if (_makeEnum == MakeEnum.BLANK)
                    ExpandableFab(
                      key: _floatKey,
                      //duration: const Duration(seconds: 1),
                      distance: 60.0,
                      type: ExpandableFabType.up,
                      fanAngle: 90,
                      child: const Icon(Icons.library_add),
                      collapsedFabSize: ExpandableFabSize.small,
                      //foregroundColor: Colors.amber,
                      //backgroundColor: Colors.green,
                      closeButtonStyle: const ExpandableFabCloseButtonStyle(
                        child: Icon(Icons.close),
                        //foregroundColor: Colors.deepOrangeAccent,
                        //backgroundColor: Colors.lightGreen,
                      ),
                      onOpen: () => HapticFeedback.vibrate(),
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.open_in_browser,
                            color: Colors.white60,
                          ),
                          label: Text('LINK'.tr()),
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.pinkAccent),
                          onPressed: _fabLink,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.volume_up_rounded,
                            color: Colors.white60,
                          ),
                          label: Text('SOUND'.tr()),
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.lightGreen),
                          onPressed: _fabSound,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white60,
                          ),
                          label: Text('CAPTION'.tr()),
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.amberAccent),
                          onPressed: _fabCaption,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.photo_album,
                            color: Colors.white60,
                          ),
                          label: Text('BABY'.tr()),
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.orange),
                          onPressed: _fabBaby,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.aspect_ratio,
                            color: Colors.white60,
                          ),
                          label: Text("PARENT".tr()),
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.blueAccent),
                          onPressed: _fabParent,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(
              height: AppBar().preferredSize.height * 1.6,
              child: _chooseFb(_makeEnum),
            ),
          ],
        ),
      ),

      floatingActionButtonLocation: ExpandableFab.location,
      //floatingActionButtonLocation: _CenterDockedFloatingActionButtonLocation(),  // not working
      //floatingActionButtonLocation: CustomFabLocation(),                          // not working
    );
  }

  /// build 이후에 실행
  void _afterBuild(context) {
    dev.log('# MakeScreen _initScreen START');

    dev.log('AppBar().preferredSize.height: ${AppBar().preferredSize.height}');

    ////////////////////////////////////////////////////////////////////////////////
    /// InteractiveViewer 실제 크기 구하기
    RenderBox renderBox =
        _globalKey.currentContext!.findRenderObject() as RenderBox;
    Size screenSize = renderBox.size;
    dev.log('InteractiveViewer size: $screenSize');
    var wScreen = screenSize.width;
    var hScreen = screenSize.height;

    ParentInfo.wScreen = wScreen;
    ParentInfo.hScreen = hScreen;
    ////////////////////////////////////////////////////////////////////////////////
  }

  Widget _chooseFb(type) {
    switch (type) {
      case MakeEnum.BLANK:
        return const BlankWidget();
      case MakeEnum.PARENT:
        return const ParentWidget();
      case MakeEnum.BABY:
        return const BabyWidget();
      case MakeEnum.CAPTION:
        return const CaptionWidget();
      case MakeEnum.SOUND:
        return const SoundWidget();
      case MakeEnum.LINK:
        return const LinkWidget();
      default:
        return const BlankWidget();
    }
  }

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // Event Start //
  ////////////////////////////////////////////////////////////////////////////////
  void _bringParentPressed(MakeBringEnum type) async {
    dev.log('# MakeScreen _bringPressed START');

    XFile? xFile;
    if (type == MakeBringEnum.CAMERA) {
      xFile = await ImagePicker().pickImage(source: ImageSource.camera);
    } else {
      xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    }
    dev.log('file: ${xFile?.path}');
    if (xFile == null) return; // 취소한 경우

    // TODO : 모래시계 필요

    await _setParentInfo(xFile.path);

    setState(() {
      _makeEnum = MakeEnum.PARENT;
    });
    dev.log('# MakeScreen _bringPressed END');
  }

  void _onInteractionStart(ScaleStartDetails scaleStartDetails) {
    dev.log('_onInteractionStart focalPoint: ${scaleStartDetails.focalPoint}'
        ', localFocalPoint: ${scaleStartDetails.localFocalPoint}');
  }

  void _onInteractionEnd(ScaleEndDetails scaleEndDetails) {
    dev.log('_onInteractionEnd velocity: ${scaleEndDetails.velocity}');
    dev.log(
        ' _transformationController.value: ${_transformationController.value}');
    dev.log('_onInteractionEnd focalPoint: ${_scaleUpdateDetails.focalPoint}'
        ', localFocalPoint: ${_scaleUpdateDetails.localFocalPoint}'
        ', focalPointDelta: ${_scaleUpdateDetails.focalPointDelta}'
        ', scale: ${_scaleUpdateDetails.scale}'
        ', horizontalScale: ${_scaleUpdateDetails.horizontalScale}'
        ', verticalScale: ${_scaleUpdateDetails.verticalScale}'
        ', rotation: ${_scaleUpdateDetails.rotation}');

    // for debug
    Matrix4 matrix4 = _transformationController.value;
    double xStart = matrix4.entry(0, 3);
    double yStart = matrix4.entry(1, 3);
    Offset xyOffset = _tapDownDetails.localPosition;
    dev.log(
        '_onInteractionUpdate xyOffset: $xyOffset, xStart: $xStart, yStart: $yStart');

    // exponent 수정 (why?)
    String xStartStr = xStart.toString();
    String yStartStr = yStart.toString();
    dev.log('xStartStr: $xStartStr, yStartStr: $yStartStr');
    if (xStartStr.contains('e')) {
      xStart = 0;
      _transformationController.value.setEntry(0, 3, 0);
    }
    if (yStartStr.contains('e')) {
      yStart = 0;
      _transformationController.value.setEntry(1, 3, 0);
    }
  }

  /// 변경되는 값 : xStart, yStart, xyOffset
  void _onInteractionUpdate(ScaleUpdateDetails scaleUpdateDetails) {
    _scaleUpdateDetails = scaleUpdateDetails;

    // for debug
    Matrix4 matrix4 = _transformationController.value;
    double xStart = matrix4.entry(0, 3);
    double yStart = matrix4.entry(1, 3);
    Offset xyOffset = _tapDownDetails.localPosition;
    dev.log(
        '_onInteractionUpdate xyOffset: $xyOffset, xStart: $xStart, yStart: $yStart');

    // exponent 수정 (why?)
    String xStartStr = xStart.toString();
    String yStartStr = yStart.toString();
    dev.log('xStartStr: $xStartStr, yStartStr: $yStartStr');
    if (xStartStr.contains('e')) {
      xStart = 0;
      _transformationController.value.setEntry(0, 3, 0);
    }
    if (yStartStr.contains('e')) {
      yStart = 0;
      _transformationController.value.setEntry(1, 3, 0);
    }
  }

  /// 변경되는 값 : xyOffset
  /// 보정되는 값 : _transformationController.value 의 xStart, yStart
  void _onTapDown(TapDownDetails details) {
    // local x/y from image, global x/y from phone screen
    //dev.log('_onTapDown localPosition: ${details.localPosition}');
    dev.log(
        '_onTapDown _transformationController.value: ${_transformationController.value}');

    var floatKeyState = _floatKey.currentState;
    if (floatKeyState != null) {
      if (floatKeyState.isOpen) floatKeyState.toggle();
      return;
    }

    _tapDownDetails = details;

    // for debug
    Matrix4 matrix4 = _transformationController.value;
    double scale = matrix4.entry(0, 0);
    double xStart = matrix4.entry(0, 3);
    double yStart = matrix4.entry(1, 3);
    Offset xyOffset = _tapDownDetails.localPosition;
    dev.log(
        '_onTapDown scale: $scale, xyOffset: $xyOffset, xStart: $xStart, yStart: $yStart');

    // exponent 수정 (why?)
    String xStartStr = xStart.toString();
    String yStartStr = yStart.toString();
    dev.log('xStartStr: $xStartStr, yStartStr: $yStartStr');
    if (xStartStr.contains('e')) {
      xStart = 0;
      _transformationController.value.setEntry(0, 3, 0);
    }
    if (yStartStr.contains('e')) {
      yStart = 0;
      _transformationController.value.setEntry(1, 3, 0);
    }

  }

  /// 변경되는 값 : scale, xStart, yStart, xyOffset
  void _onDoubleTap() {
    //dev.log('_onDoubleTap localPosition: ${_tapDownDetails.localPosition}');
    //dev.log('_transformationController.value: ${_transformationController.value}');

    // for debug
    Matrix4 matrix4 = _transformationController.value;
    double scale = matrix4.entry(0, 0);
    double xStart = matrix4.entry(0, 3);
    double yStart = matrix4.entry(1, 3);
    Offset xyOffset = _tapDownDetails.localPosition;
    dev.log(
        '_onDoubleTap scale: $scale, xyOffset: $xyOffset, xStart: $xStart, yStart: $yStart');

    double scaleHalf = math.sqrt(AppConfig.MAKE_SCREEN_MAX);
    if (scale.round() == AppConfig.MAKE_SCREEN_MAX) {
      // 원복
      _transformationController.value = Matrix4.identity();
      dev.log('_onDoubleTap restore');
    } else if (scale < scaleHalf * 0.9) {
      // 10% 여유 주기
      _transformationController.value = Matrix4.identity()
        ..translate(
            -xyOffset.dx * (scaleHalf - 1), -xyOffset.dy * (scaleHalf - 1))
        ..scale(scaleHalf);
      dev.log('_onDoubleTap scale up: $scaleHalf');
    } else {
      _transformationController.value = Matrix4.identity()
        ..translate(xyOffset.dx * -(AppConfig.MAKE_SCREEN_MAX - 1),
            xyOffset.dy * -(AppConfig.MAKE_SCREEN_MAX - 1))
        ..scale(AppConfig.MAKE_SCREEN_MAX);
      dev.log('_onDoubleTap scale max: ${AppConfig.MAKE_SCREEN_MAX}');
    }

    setState(() {
      _makeEnum;
    });
  }

  void _onTabDelete() {
    dev.log('delete onTap');

    // TODO
  }

  void _onLongPressDelete() {
    dev.log('delete onLongPressed');

    PopupUtil.popupAlertOkCancel(context, 'INFO'.tr(), 'INIT_MAKE'.tr())
        .then((ret) {
      dev.log('popupAlertOkCancel: $ret');

      // example
      if (ret == null) {} // 팝업 바깥 영역을 클릭한 경우
      if (ret == AppConstant.OK) {
        // TODO : 모두 초기화하는 함수를 별도로 작성하고 호출
        ParentInfo.path = '';
        setState(() {
          _makeEnum = MakeEnum.BLANK;
        });
      }
    });
  }

  void _fabParent() {
    dev.log('_fabParent');

    var floatKeyState = _floatKey.currentState;
    if (floatKeyState != null) {
      floatKeyState.toggle();
      setState(() {
        _makeEnum = MakeEnum.PARENT;
      });
    }
  }

  void _fabBaby() {
    dev.log('_fabBaby');

    var floatKeyState = _floatKey.currentState;
    if (floatKeyState != null) {
      floatKeyState.toggle();
      setState(() {
        _makeEnum = MakeEnum.BABY;
      });
    }
  }

  void _fabCaption() {
    dev.log('_fabCaption');

    var floatKeyState = _floatKey.currentState;
    if (floatKeyState != null) {
      floatKeyState.toggle();
      setState(() {
        _makeEnum = MakeEnum.CAPTION;
      });
    }
  }

  void _fabSound() {
    dev.log('_fabSound');

    var floatKeyState = _floatKey.currentState;
    if (floatKeyState != null) {
      floatKeyState.toggle();
      setState(() {
        _makeEnum = MakeEnum.SOUND;
      });
    }
  }

  void _fabLink() {
    dev.log('_fabLink');

    var floatKeyState = _floatKey.currentState;
    if (floatKeyState != null) {
      floatKeyState.toggle();
      setState(() {
        _makeEnum = MakeEnum.LINK;
      });
    }
  }

////////////////////////////////////////////////////////////////////////////////
// Event END //
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
  Future _setParentInfo(path) async {
    ParentInfo.path = path;

    ////////////////////////////////////////////////////////////////////////////////
    ui.Image uiImage = await ImageUtil.loadUiImage(path);

    /// Parent 이미지 크기
    ParentInfo.wImage = uiImage.width;
    ParentInfo.hImage = uiImage.height;
    dev.log('image w: ${uiImage.width}, h: ${uiImage.height}');

    /// Parent 이미지가 InteractiveViewer 에 맞추어진 ratio 구하기
    var inScale = ImageUtil.calcFitRatioIn(
        ParentInfo.wScreen, ParentInfo.hScreen, uiImage.width, uiImage.height);
    ParentInfo.inScale = inScale;
    dev.log('inScale: $inScale');

    // blank
    var wReal = uiImage.width * inScale;
    var hReal = uiImage.height * inScale;
    if ((ParentInfo.wScreen - wReal) > (ParentInfo.hScreen - hReal)) {
      ParentInfo.xBlank = (ParentInfo.wScreen - wReal) / 2;
      ParentInfo.yBlank = 0;
    } else {
      ParentInfo.yBlank = (ParentInfo.hScreen - hReal) / 2;
      ParentInfo.xBlank = 0;
    }
    dev.log('xBlank: ${ParentInfo.xBlank}, yBlank: ${ParentInfo.yBlank}');

    dev.log('ParentInfo: $ParentInfo');
    ////////////////////////////////////////////////////////////////////////////////
  }
////////////////////////////////////////////////////////////////////////////////
}

////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////

class MakePainter extends CustomPainter {
  ////////////////////////////////////////////////////////////////////////////////
  late double wScreen;
  late double hScreen;

  int wImage = 0;
  int hImage = 0;

  double inScale = 0;

  double xBlank = 0;
  double yBlank = 0;

  double xStart = 0;
  double yStart = 0;

  double scale = 0;

  ////////////////////////////////////////////////////////////////////////////////

  /// InteractiveViewer 가 확대/축소될때는 호출되지 않음
  @override
  void paint(Canvas canvas, Size size) {
    // wScreen, hScreen 과 동일
    dev.log('# MakePainter paint START');

    initParentData();

    Paint paint = Paint()
      ..color = Colors.deepPurpleAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;
    Offset p1 = Offset(xBlank, yBlank);
    Offset p2 = Offset(
        wImage * inScale * 0.5 + xBlank, hImage * inScale * 0.5 + yBlank);

    canvas.drawLine(p1, p2, paint);
  }

  /// 그려야할 정보를 모두 검사해서 틀린 것이 있으면 다시 그리기
  @override
  bool shouldRepaint(MakePainter oldDelegate) {
    // TODO : impl
    // 다시 그려야할 정보 검사

    //return false;
    return true;
  }

  ////////////////////////////////////////////////////////////////////////////////
  void initParentData() {
    wScreen = ParentInfo.wScreen;
    hScreen = ParentInfo.hScreen;

    wImage = ParentInfo.wImage;
    hImage = ParentInfo.hImage;

    inScale = ParentInfo.inScale;

    xBlank = ParentInfo.xBlank;
    yBlank = ParentInfo.yBlank;

    xStart = ParentInfo.xStart;
    yStart = ParentInfo.yStart;

    scale = ParentInfo.scale;
  }
////////////////////////////////////////////////////////////////////////////////
}
