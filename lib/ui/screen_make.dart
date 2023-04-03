import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:enum_to_string/enum_to_string.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

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
enum MakeParentSizeEnum {
  NONE,
  EDIT,
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
                      //onPanUpdate: _onPanUpdate,    // onInteractionUpdate 과 중복 문제 발생
                      //onPanEnd: _onPanEnd,
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
                        //onInteractionStart: _onInteractionStart,
                        //onInteractionEnd: _onInteractionEnd,
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
                          //painter: MakePainter(),
                          painter: (ParentInfo.isSize) ? MakeParentSizePainter() : MakePainter(),
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
                  //if (_makeEnum == MakeEnum.BLANK)
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
        return ParentWidget(callbackParentSizeInitScreen: _callbackParentSizeInitScreen);
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

  /// 변경되는 값 : xStart, yStart, xyOffset
  void _onInteractionUpdate(ScaleUpdateDetails scaleUpdateDetails) async {
    _scaleUpdateDetails = scaleUpdateDetails;

    ////////////////////////////////////////////////////////////////////////////////
    // for debug
    Matrix4 matrix4 = _transformationController.value;
    double xStart = matrix4.entry(0, 3);
    double yStart = matrix4.entry(1, 3);
    Offset xyOffset = _scaleUpdateDetails.localFocalPoint;
    dev.log(
        '_onInteractionUpdate xyOffset: $xyOffset, xStart: $xStart, yStart: $yStart');
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // return 하는 경우
    if (_makeEnum == MakeEnum.PARENT) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var retPrefs = prefs.getString('MakeParentEnum');
      if (retPrefs == null) {
        // 처음인 경우
      } else {
        var retEnum = EnumToString.fromString(MakeParentEnum.values, retPrefs);
        if (retEnum == null) {
          // 에러 상황 (enum 에 없는 값이 저장된 경우)
        } else {
          if (retEnum == MakeParentEnum.SIZE) {
            dev.log('MakeParentEnum.SIZE return');
            return;
          }
        }
      }
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
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
    ////////////////////////////////////////////////////////////////////////////////
  }

  /// 변경되는 값 : xyOffset
  /// 보정되는 값 : _transformationController.value 의 xStart, yStart
  void _onTapDown(TapDownDetails details) async {
    // local x/y from image, global x/y from phone screen
    //dev.log('_onTapDown localPosition: ${details.localPosition}');
    dev.log(
        '_onTapDown _transformationController.value: ${_transformationController.value}');

    _tapDownDetails = details;

    ////////////////////////////////////////////////////////////////////////////////
    var floatKeyState = _floatKey.currentState;
    if (floatKeyState != null) {
      if (floatKeyState.isOpen) {
        floatKeyState.toggle();
        return;
      }
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // return 하는 경우
    if (_makeEnum == MakeEnum.PARENT) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var retPrefs = prefs.getString('MakeParentEnum');
      if (retPrefs == null) {
        // 처음인 경우
      } else {
        var retEnum = EnumToString.fromString(MakeParentEnum.values, retPrefs);
        if (retEnum == null) {
          // 에러 상황 (enum 에 없는 값이 저장된 경우)
        } else {
          if (retEnum == MakeParentEnum.SIZE) {
            dev.log('MakeParentEnum.SIZE return');
            return;
          }
        }
      }
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // for debug
    Matrix4 matrix4 = _transformationController.value;
    double scale = matrix4.entry(0, 0);
    double xStart = matrix4.entry(0, 3);
    double yStart = matrix4.entry(1, 3);
    Offset xyOffset = _tapDownDetails.localPosition;
    dev.log(
        '_onTapDown scale: $scale, xyOffset: $xyOffset, xStart: $xStart, yStart: $yStart');
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
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
    ////////////////////////////////////////////////////////////////////////////////

  }

  /// 변경되는 값 : scale, xStart, yStart, xyOffset
  void _onDoubleTap() async {
    //dev.log('_onDoubleTap localPosition: ${_tapDownDetails.localPosition}');
    //dev.log('_transformationController.value: ${_transformationController.value}');

    ////////////////////////////////////////////////////////////////////////////////
    // for debug
    Matrix4 matrix4 = _transformationController.value;
    double scale = matrix4.entry(0, 0);
    double xStart = matrix4.entry(0, 3);
    double yStart = matrix4.entry(1, 3);
    Offset xyOffset = _tapDownDetails.localPosition;
    dev.log(
        '_onDoubleTap scale: $scale, xyOffset: $xyOffset, xStart: $xStart, yStart: $yStart');
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // Size 인 경우
    if (_makeEnum == MakeEnum.PARENT) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var retPrefs = prefs.getString('MakeParentEnum');
      if (retPrefs == null) {
        // 처음인 경우
      } else {
        var retEnum = EnumToString.fromString(MakeParentEnum.values, retPrefs);
        if (retEnum == null) {
          // 에러 상황 (enum 에 없는 값이 저장된 경우)
        } else {
          if (retEnum == MakeParentEnum.SIZE) {
            dev.log('MakeParentEnum.SIZE return');
            return;
          }
        }
      }
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // 확대/원복
    double scaleHalf = math.sqrt(AppConfig.MAKE_SCREEN_MAX);
    if (scale.round() == AppConfig.MAKE_SCREEN_MAX) {
      // restore
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
    ////////////////////////////////////////////////////////////////////////////////

    setState(() {

    });
  }

  void _onTabDelete() {
    dev.log('_onTabDelete');

    // TODO
  }

  void _onLongPressDelete() {
    dev.log('_onLongPressDelete');

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
    }

    ParentInfo.isSize = false;
    setState(() {
      _makeEnum = MakeEnum.PARENT;
    });
  }

  void _fabBaby() {
    dev.log('_fabBaby');

    var floatKeyState = _floatKey.currentState;
    if (floatKeyState != null) {
      floatKeyState.toggle();
    }

    ParentInfo.isSize = false;
    setState(() {
      _makeEnum = MakeEnum.BABY;
    });
  }

  void _fabCaption() {
    dev.log('_fabCaption');

    var floatKeyState = _floatKey.currentState;
    if (floatKeyState != null) {
      floatKeyState.toggle();
    }

    ParentInfo.isSize = false;
    setState(() {
      _makeEnum = MakeEnum.CAPTION;
    });
  }

  void _fabSound() {
    dev.log('_fabSound');

    var floatKeyState = _floatKey.currentState;
    if (floatKeyState != null) {
      floatKeyState.toggle();
    }

    ParentInfo.isSize = false;
    setState(() {
      _makeEnum = MakeEnum.SOUND;
    });
  }

  void _fabLink() {
    dev.log('_fabLink');

    var floatKeyState = _floatKey.currentState;
    if (floatKeyState != null) {
      floatKeyState.toggle();
    }

    ParentInfo.isSize = false;
    setState(() {
      _makeEnum = MakeEnum.LINK;
    });
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

  ////////////////////////////////////////////////////////////////////////////////
  // callback START //
  ////////////////////////////////////////////////////////////////////////////////
  void _callbackParentSizeInitScreen() {
    dev.log('_initSaveParentScreen');

    // restore
    _transformationController.value = Matrix4.identity();

    setState(() {
    });
  }
  ////////////////////////////////////////////////////////////////////////////////
  // callback END //
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

    ////////////////////////////////////////////////////////////////////////////////
    initParentData();
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    Paint paint = Paint()
      ..color = Colors.deepPurpleAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;
    Offset p1 = Offset(xBlank, yBlank);
    Offset p2 = Offset(
        wImage * inScale * 0.5 + xBlank, hImage * inScale * 0.5 + yBlank);

    canvas.drawLine(p1, p2, paint);
    ////////////////////////////////////////////////////////////////////////////////
  }

  /// 그려야할 정보를 모두 검사해서 틀린 것이 있으면 다시 그리기
  @override
  bool shouldRepaint(MakePainter oldDelegate) {
    // TODO : impl
    // 다시 그려야할 정보 검사

    return false;
    //return true;
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

class MakeParentSizePainter extends CustomPainter {
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
    dev.log('# MakeParentSizePainter paint START');

    ////////////////////////////////////////////////////////////////////////////////
    initParentData();
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    double bracketWidth = 8;
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // grid
    Paint paintGrid = Paint()
      ..color = Colors.white30
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;
    Offset startOffset = Offset(xBlank, yBlank);
    Offset endOffset = Offset(ParentInfo.wScreen - xBlank, yBlank);
    for (int i = 0, j = 9; i < j; i++) {
      dev.log('xxx: ${startOffset.dy + ParentInfo.hImage * ParentInfo.inScale * 0.1}');
      startOffset = Offset(startOffset.dx, startOffset.dy + ParentInfo.hImage * ParentInfo.inScale * 0.1);
      endOffset = Offset(endOffset.dx, endOffset.dy + ParentInfo.hImage * ParentInfo.inScale * 0.1);
      canvas.drawLine(startOffset, endOffset, paintGrid);
    }
    startOffset = Offset(xBlank, yBlank);
    endOffset = Offset(xBlank, ParentInfo.hScreen - yBlank);
    for (int i = 0, j = 9; i < j; i++) {
      dev.log('YYY: ${startOffset.dy + ParentInfo.hImage * ParentInfo.inScale * 0.1}');
      startOffset = Offset(startOffset.dx + ParentInfo.wImage * ParentInfo.inScale * 0.1, startOffset.dy);
      endOffset = Offset(endOffset.dx + ParentInfo.wImage * ParentInfo.inScale * 0.1, endOffset.dy);
      canvas.drawLine(startOffset, endOffset, paintGrid);
    }

    // bracket
    Paint paintBracket = Paint()
      ..color = Colors.white60
      ..strokeCap = StrokeCap.round
      ..strokeWidth = bracketWidth;
    Offset leftTop = Offset(xBlank + bracketWidth / 2, yBlank + bracketWidth / 2);
    Offset leftTopW = Offset(leftTop.dx + ParentInfo.wScreen / 4, leftTop.dy);
    Offset leftTopH = Offset(leftTop.dx, leftTop.dy + ParentInfo.wScreen / 4);
    canvas.drawLine(leftTop, leftTopW, paintBracket);
    canvas.drawLine(leftTop, leftTopH, paintBracket);

    Offset rightTop = Offset(ParentInfo.wScreen - xBlank - bracketWidth / 2, yBlank + bracketWidth / 2);
    Offset rightTopW = Offset(rightTop.dx - ParentInfo.wScreen / 4, rightTop.dy);
    Offset rightTopH = Offset(rightTop.dx, rightTop.dy + ParentInfo.wScreen / 4);
    canvas.drawLine(rightTop, rightTopW, paintBracket);
    canvas.drawLine(rightTop, rightTopH, paintBracket);

    Offset leftBottom = Offset(xBlank + bracketWidth / 2, ParentInfo.hScreen - yBlank - bracketWidth / 2);
    Offset leftBottomW = Offset(leftBottom.dx + ParentInfo.wScreen / 4, leftBottom.dy);
    Offset leftBottomH = Offset(leftBottom.dx, leftBottom.dy - ParentInfo.wScreen / 4);
    canvas.drawLine(leftBottom, leftBottomW, paintBracket);
    canvas.drawLine(leftBottom, leftBottomH, paintBracket);

    Offset rightBottom = Offset(ParentInfo.wScreen - xBlank - bracketWidth / 2, ParentInfo.hScreen - yBlank - bracketWidth / 2);
    Offset rightBottomW = Offset(rightBottom.dx - ParentInfo.wScreen / 4, rightBottom.dy);
    Offset rightBottomH = Offset(rightBottom.dx, rightBottom.dy - ParentInfo.wScreen / 4);
    canvas.drawLine(rightBottom, rightBottomW, paintBracket);
    canvas.drawLine(rightBottom, rightBottomH, paintBracket);
    ////////////////////////////////////////////////////////////////////////////////


    ////////////////////////////////////////////////////////////////////////////////


    ////////////////////////////////////////////////////////////////////////////////

  }

  /// 그려야할 정보를 모두 검사해서 틀린 것이 있으면 다시 그리기
  @override
  bool shouldRepaint(MakeParentSizePainter oldDelegate) {
    // TODO : impl
    // 다시 그려야할 정보 검사

    return false;
    //return true;
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



/*
void _onInteractionStart(ScaleStartDetails scaleStartDetails) {
  dev.log('_onInteractionStart focalPoint: ${scaleStartDetails.focalPoint}'
      ', localFocalPoint: ${scaleStartDetails.localFocalPoint}');
}

/// 성능에 문제가 되지 않으면 update 에서 모두 처리
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
  Offset xyOffset = _scaleUpdateDetails.localFocalPoint;
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


  void _onPanUpdate(DragUpdateDetails _dragUpdateDetails) {
    dev.log('_onPanUpdate');

    dev.log('_dragUpdateDetails: $_dragUpdateDetails');
  }

  void _onPanEnd(DragEndDetails _dragEndDetails) {
    dev.log('_onPanEnd');

    dev.log('_dragEndDetails: $_dragEndDetails');
  }
*/