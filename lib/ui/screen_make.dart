import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mc/provider/provider_make.dart';
import 'package:mc/ui/widget_baby.dart';
import 'package:mc/ui/widget_blank.dart';
import 'package:mc/ui/widget_caption.dart';
import 'package:mc/ui/widget_link.dart';
import 'package:mc/ui/widget_parent.dart';
import 'package:mc/ui/widget_sound.dart';
import 'package:provider/provider.dart';

import '../config/config_app.dart';
import '../config/constant_app.dart';
import '../dto/info_parent.dart';
import '../util/util_info.dart';
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

enum MakeParentSizePointEnum {
  NONE,
  LEFTTOP,
  RIGHTTOP,
  LEFTBOTTOM,
  RIGHTBOTTOM,
  LEFTTOPH,
  LEFTTOPV,
  RIGHTTOPH,
  RIGHTTOPV,
  LEFTBOTTOMH,
  LEFTBOTTOMV,
  RIGHTBOTTOMH,
  RIGHTBOTTOMV,
}

class MakeScreen extends StatefulWidget {
  const MakeScreen({super.key});

  @override
  State<MakeScreen> createState() => MakeScreenState();
}

class MakeScreenState extends State<MakeScreen> {
  ////////////////////////////////////////////////////////////////////////////////
  // variable

  MakeEnum _makeEnum = MakeEnum.BLANK;

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // object

  final TransformationController _transformationController =
      TransformationController(
          Matrix4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1));

  late TapDownDetails _tapDownDetails; // onDoubleTap 에서 사용

  /// build 이후에 InteractiveViewer 화면 크기를 구할때 사용
  final GlobalKey _screenGlobalKey = GlobalKey();

  /// fab 을 toggle 할때 사용
  late final GlobalObjectKey<ExpandableFabState> _fabGlobalKey =
      GlobalObjectKey<ExpandableFabState>(context);

  // provider 방식으로 교체
  //ParentWidget _parentWidget = ParentWidget(callbackParentSizeInitScreen: _callbackParentSizeInitScreen);
  //final GlobalKey<ParentWidgetState> _globalKeyParentWidget = GlobalKey();
  //late ParentWidget _parentWidget;
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# MakeScreen initState START');
    super.initState();

    ////////////////////////////////////////////////////////////////////////////////
    //_parentWidget = ParentWidget(key: _globalKeyParentWidget, callbackParentSizeInitScreen: _callbackParentSizeInitScreen);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // 초기화
    if (ParentInfo.path != '') {
      _makeEnum = MakeEnum.PARENT;

      dev.log('initState recall _setParentInfo');
      InfoUtil.setParentInfo(ParentInfo.path).then((_) => {});

      // TODO : 나머지도 있다면 초기화
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    /// build 이후 실행
    /// InteractiveViewer 실제 크기를 구해서 ParentInfo wScreen/hScreen 에 저장
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

    dev.log('build _makeEnum: $_makeEnum');
    dev.log('AppBar().preferredSize.height: ${AppBar().preferredSize.height}');

    MakeProvider makeProvider =
        Provider.of<MakeProvider>(context, listen: false);
    dev.log('parentSize: ${makeProvider.parentSize}');

    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.black,
        title: Text('MAKE_NEW'.tr()),

        actions: [
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(10),
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
                      onTapUp: _onTapUp,
                      onDoubleTap: _onDoubleTap,
                      //onPanUpdate: _onPanUpdate,    // onInteractionUpdate 과 중복 문제 발생
                      //onPanEnd: _onPanEnd,
                      child: InteractiveViewer(
                        // build 이후 InteractiveViewer 의 사이즈 구하기
                        key: _screenGlobalKey,
                        maxScale: (context.read<MakeProvider>().parentSize)
                            ? 1.0
                            : AppConfig.MAKE_SCREEN_MAX,
                        minScale: (context.read<MakeProvider>().parentSize)
                            ? 1.0
                            : AppConfig.MAKE_SCREEN_MIN,
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
                          painter: (context.watch<MakeProvider>().parentSize)
                              ? MakeParentSizePainter()
                              : MakePainter(),
                        ),
                      ),
                    ),
                  if (_makeEnum == MakeEnum.BLANK)
                    Row(
                      key: _screenGlobalKey,
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
                  if (_makeEnum != MakeEnum.BLANK)
                    Padding(
                      padding:
                          EdgeInsets.all((AppBar().preferredSize.height * 0.8)),
                      child: ExpandableFab(
                        key: _fabGlobalKey,
                        duration: const Duration(milliseconds: 300),
                        distance: 60.0,
                        type: ExpandableFabType.up,
                        fanAngle: 90,
                        child: const Icon(Icons.library_add),
                        collapsedFabSize: ExpandableFabSize.small,
                        //foregroundColor: Colors.amber,
                        //backgroundColor: Colors.green,
                        closeButtonStyle: const ExpandableFabCloseButtonStyle(
                          child: Icon(Icons.close),
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.black26,
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
                    ),
                ],
              ),
            ),
            SizedBox(
              height: AppBar().preferredSize.height * 1.6,
              child: _chooseFunctionBar(_makeEnum),
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
    dev.log('# MakeScreen _afterBuild START');

    ////////////////////////////////////////////////////////////////////////////////
    /// InteractiveViewer 실제 크기를 구해서 ParentInfo wScreen/hScreen 에 저장
    RenderBox renderBox =
        _screenGlobalKey.currentContext!.findRenderObject() as RenderBox;
    Size screenSize = renderBox.size;
    dev.log('InteractiveViewer size: $screenSize');
    var wScreen = screenSize.width;
    var hScreen = screenSize.height;

    ParentInfo.wScreen = wScreen;
    ParentInfo.hScreen = hScreen;
    ////////////////////////////////////////////////////////////////////////////////
  }

  Widget _chooseFunctionBar(type) {
    switch (type) {
      case MakeEnum.BLANK:
        return const BlankWidget();
      case MakeEnum.PARENT:
        //return ParentWidget(callbackParentSizeInitScreen: _callbackParentSizeInitScreen);
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
    dev.log('# MakeScreen _bringParentPressed START');

    XFile? xFile;
    if (type == MakeBringEnum.CAMERA) {
      xFile = await ImagePicker().pickImage(source: ImageSource.camera);
    } else {
      xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    }
    dev.log('file: ${xFile?.path}');
    if (xFile == null) return; // 취소한 경우

    // TODO : 모래시계 필요

    await InfoUtil.setParentInfo(xFile.path);

    // TODO : 나머지도 있다면 재조정

    setState(() {
      _makeEnum = MakeEnum.PARENT;
    });
    dev.log('# MakeScreen _bringParentPressed END');
  }

  /// 변경되는 값 : xStart, yStart, xyOffset
  void _onInteractionUpdate(ScaleUpdateDetails scaleUpdateDetails) async {
    ////////////////////////////////////////////////////////////////////////////////
    // for debug
    Matrix4 matrix4 = _transformationController.value;
    double scale = matrix4.entry(0, 0);
    double xStart = matrix4.entry(0, 3);
    double yStart = matrix4.entry(1, 3);
    Offset xyOffset = scaleUpdateDetails.localFocalPoint;
    dev.log(
        '_onInteractionUpdate scale: $scale, xyOffset: $xyOffset, xStart: $xStart, yStart: $yStart');
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

    // TODO : 확대된 경우 blank 처리하기

    ////////////////////////////////////////////////////////////////////////////////
    // resize 상태 라면
    if (context.read<MakeProvider>().parentSize) {
      // _onTapDown 이 호출되지 않은 경우
      if (ParentInfo.makeParentSizePointEnum == MakeParentSizePointEnum.NONE) {
        return;
      }

      // blank 검사
      if (!InfoUtil.checkBlankArea(
          xyOffset, ParentInfo.makeParentSizePointEnum)) {
        dev.log('\n\n### checkBlankArea return\n\n');
        return;
      }

      // bracket 간에 침범할 수 없는 영역을 순식간에 넘어갔는지 검사
      if (!InfoUtil.checkBracketCrossArea(
          xyOffset, ParentInfo.makeParentSizePointEnum)) {
        dev.log('\n\n### checkBracketCrossArea return\n\n');
        return;
      }

      // shrink 허용치 검사
      Rect bracketRect =
          InfoUtil.calcRect(xyOffset, ParentInfo.makeParentSizePointEnum);
      dev.log('bracketRect: $bracketRect');
      double minArea = (ParentInfo.wScreen - ParentInfo.xBlank) *
          (ParentInfo.hScreen - ParentInfo.yBlank) *
          AppConfig.SIZE_SHRINK_MIN;
      if (minArea >= (bracketRect.width * bracketRect.height)) {
        dev.log(
            'parentSize exceed ${AppConfig.SIZE_SHRINK_MIN * 100}%: $xyOffset');
        return;
      }

      // sticky
      dev.log('org xyOffset: $xyOffset');
      xyOffset = InfoUtil.stickyOffset(
          xyOffset,
          ParentInfo.wScreen,
          ParentInfo.xBlank,
          ParentInfo.hScreen,
          ParentInfo.yBlank,
          AppConfig.SIZE_GRID_RATIO,
          AppConfig.SIZE_GRID_RATIO,
          AppConfig.SIZE_STICKY_RATIO,
          ParentInfo.makeParentSizePointEnum);
      dev.log('new xyOffset: $xyOffset');

      ////////////////////////////////////////////////////////////////////////////////
      ParentInfo.xStart = xStart;
      ParentInfo.yStart = yStart;
      ParentInfo.xyOffset = xyOffset; // for test
      ////////////////////////////////////////////////////////////////////////////////

      // ParentInfo 의 Offset 수정 --> paint 에서 사용
      InfoUtil.updateBracketArea(xyOffset, ParentInfo.makeParentSizePointEnum);
    }
    ////////////////////////////////////////////////////////////////////////////////

    setState(() {});
  }

  /// 변경되는 값 : xyOffset
  /// 보정되는 값 : _transformationController.value 의 xStart, yStart
  void _onTapDown(TapDownDetails tapDownDetails) async {
    // local x/y from image, global x/y from phone screen
    //dev.log('_onTapDown localPosition: ${details.localPosition}');
    dev.log(
        '_onTapDown _transformationController.value: ${_transformationController.value}');

    // onDoubleTap 에서 사용
    _tapDownDetails = tapDownDetails;

    ////////////////////////////////////////////////////////////////////////////////
    // toggle 일 경우 return
    var floatKeyState = _fabGlobalKey.currentState;
    if (floatKeyState != null) {
      if (floatKeyState.isOpen) {
        floatKeyState.toggle();
        return;
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
    dev.log('_onTapDown wView: ${ParentInfo.wScreen - ParentInfo.xBlank}, '
        'wScreen: ${ParentInfo.wScreen}, xBlank: ${ParentInfo.xBlank}, '
        'hView: ${ParentInfo.hScreen - ParentInfo.yBlank}, '
        'hScreen: ${ParentInfo.hScreen}, yBlank: ${ParentInfo.yBlank}');
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

    ////////////////////////////////////////////////////////////////////////////////
    // size 상태인 경우 bracket 이 선택되었는지 검사
    if (context.read<MakeProvider>().parentSize) {
      dev.log(
          'parentSize leftTopOffset: ${ParentInfo.leftTopOffset}, rightTopOffset: ${ParentInfo.rightTopOffset}, '
          'leftBottomOffset: ${ParentInfo.leftBottomOffset}, rightBottomOffset: ${ParentInfo.rightBottomOffset}');

      ParentInfo.xyOffset = xyOffset; // for test
      MakeParentSizePointEnum makeParentSizeEnum =
          InfoUtil.findBracketArea(xyOffset);
      dev.log('findBracketArea makeParentSizeEnum: $makeParentSizeEnum');
      if (makeParentSizeEnum != MakeParentSizePointEnum.NONE) {
        ParentInfo.makeParentSizePointEnum = makeParentSizeEnum;
      }
    }
    ////////////////////////////////////////////////////////////////////////////////
  }

  // drag 이후에는 호출안됨
  void _onTapUp(TapUpDetails tapUpDetails) async {
    //dev.log('_onTapUp TapUpDetails: ${tapUpDetails.localPosition}');
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
    // return 하는 경우
    if (context.read<MakeProvider>().parentSize) {
      dev.log('_onDoubleTap parentSize return');
      return;
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

    setState(() {});
  }

  void _onTabDelete() {
    dev.log('_onTabDelete');

    // TODO : 한개씩 지우기
  }

  void _onLongPressDelete() {
    dev.log('_onLongPressDelete');

    PopupUtil.popupAlertOkCancel(context, 'INFO'.tr(), 'INIT_MAKE'.tr())
        .then((ret) {
      dev.log('popupAlertOkCancel: $ret');

      // example
      if (ret == null) {
        // 팝업 바깥 영역을 클릭한 경우
        return;
      }
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

    _fabGlobalKey.currentState?.toggle();

    // TODO : Parent 가져오기 실행
    // 이미 Parent 상태여도 가져오기 실행
    // 취소하면 FB 는 이전 것으로 유지

    setState(() {
      _makeEnum = MakeEnum.PARENT;
    });
  }

  void _fabBaby() {
    dev.log('_fabBaby');

    _fabGlobalKey.currentState?.toggle();

    // TODO : Baby 가져오기 실행
    // 이미 Baby 상태여도 가져오기 실행
    // 취소하면 FB 는 이전 것으로 유지

    setState(() {
      _makeEnum = MakeEnum.BABY;
      context.read<MakeProvider>().setParentSize(false);
    });
  }

  void _fabCaption() {
    dev.log('_fabCaption');

    _fabGlobalKey.currentState?.toggle();

    // TODO : caption 추가, 키보드 올리기
    // FB 는 Caption 으로 변경

    setState(() {
      _makeEnum = MakeEnum.CAPTION;
      context.read<MakeProvider>().setParentSize(false);
    });
  }

  void _fabSound() {
    dev.log('_fabSound');

    _fabGlobalKey.currentState?.toggle();

    // TODO : Function bar 만 이동

    setState(() {
      _makeEnum = MakeEnum.SOUND;
      context.read<MakeProvider>().setParentSize(false);
    });
  }

  void _fabLink() {
    dev.log('_fabLink');

    _fabGlobalKey.currentState?.toggle();

    // TODO : Function bar 만 이동

    setState(() {
      _makeEnum = MakeEnum.LINK;
      context.read<MakeProvider>().setParentSize(false);
    });
  }

////////////////////////////////////////////////////////////////////////////////
// Event END //
////////////////////////////////////////////////////////////////////////////////

/*
  ////////////////////////////////////////////////////////////////////////////////
  // callback START //
  ////////////////////////////////////////////////////////////////////////////////
  void _callbackParentSizeInitScreen(bool isSize) {
    dev.log('# MakeScreen _callbackParentSizeInitScreen');

    this.isSize = isSize;

    // restore
    _transformationController.value = Matrix4.identity();

    setState(() {});
  }
  ////////////////////////////////////////////////////////////////////////////////
  // callback END //
  ////////////////////////////////////////////////////////////////////////////////
*/
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

  late Offset leftTopOffset;
  late Offset rightTopOffset;
  late Offset leftBottomOffset;
  late Offset rightBottomOffset;

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

    leftTopOffset = ParentInfo.leftTopOffset;
    rightTopOffset = ParentInfo.rightTopOffset;
    leftBottomOffset = ParentInfo.leftBottomOffset;
    rightBottomOffset = ParentInfo.rightBottomOffset;
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

  late Offset leftTopOffset;
  late Offset rightTopOffset;
  late Offset leftBottomOffset;
  late Offset rightBottomOffset;

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
    double bracketWidth = AppConfig.SIZE_BRACKET_WIDTH;
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // grid
    Paint gridPaint = Paint()
      ..color = Colors.white30
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;
    Offset startOffset = Offset(xBlank, yBlank);
    Offset endOffset = Offset(ParentInfo.wScreen - xBlank, yBlank);
    for (int i = 0, j = 9; i < j; i++) {
      startOffset = Offset(
          startOffset.dx,
          startOffset.dy +
              ParentInfo.hImage *
                  ParentInfo.inScale *
                  AppConfig.SIZE_GRID_RATIO);
      endOffset = Offset(
          endOffset.dx,
          endOffset.dy +
              ParentInfo.hImage *
                  ParentInfo.inScale *
                  AppConfig.SIZE_GRID_RATIO);
      canvas.drawLine(startOffset, endOffset, gridPaint);
    }
    startOffset = Offset(xBlank, yBlank);
    endOffset = Offset(xBlank, ParentInfo.hScreen - yBlank);
    for (int i = 0, j = 9; i < j; i++) {
      startOffset = Offset(
          startOffset.dx +
              ParentInfo.wImage *
                  ParentInfo.inScale *
                  AppConfig.SIZE_GRID_RATIO,
          startOffset.dy);
      endOffset = Offset(
          endOffset.dx +
              ParentInfo.wImage *
                  ParentInfo.inScale *
                  AppConfig.SIZE_GRID_RATIO,
          endOffset.dy);
      canvas.drawLine(startOffset, endOffset, gridPaint);
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // bracket
    Paint bracketPaint = Paint()
      ..color = Colors.white60
      ..strokeCap = StrokeCap.round
      ..strokeWidth = bracketWidth;
    // 최소치 검사
    double minArea = (ParentInfo.wScreen - ParentInfo.xBlank) *
        (ParentInfo.hScreen - ParentInfo.yBlank) *
        AppConfig.SIZE_SHRINK_MIN;
    double updateArea =
        (ParentInfo.rightTopOffset.dx - ParentInfo.leftTopOffset.dx) *
            (ParentInfo.rightBottomOffset.dy - ParentInfo.rightTopOffset.dy);
    if (minArea >= updateArea * 0.9) {
      // 정확히 하면 catch 안됨
      bracketPaint.color = Colors.yellowAccent;
    }
    Offset leftTop =
        //Offset(xBlank + bracketWidth / 2, yBlank + bracketWidth / 2);
        Offset(leftTopOffset.dx + bracketWidth / 2,
            leftTopOffset.dy + bracketWidth / 2);
    Offset leftTopH = Offset(leftTop.dx + ParentInfo.wScreen / 6, leftTop.dy);
    Offset leftTopV = Offset(leftTop.dx, leftTop.dy + ParentInfo.wScreen / 6);
    canvas.drawLine(leftTop, leftTopH, bracketPaint);
    canvas.drawLine(leftTop, leftTopV, bracketPaint);

    Offset rightTop =
        //Offset(ParentInfo.wScreen - xBlank - bracketWidth / 2, yBlank + bracketWidth / 2);
        Offset(rightTopOffset.dx - bracketWidth / 2,
            rightTopOffset.dy + bracketWidth / 2);
    Offset rightTopH =
        Offset(rightTop.dx - ParentInfo.wScreen / 6, rightTop.dy);
    Offset rightTopV =
        Offset(rightTop.dx, rightTop.dy + ParentInfo.wScreen / 6);
    canvas.drawLine(rightTop, rightTopH, bracketPaint);
    canvas.drawLine(rightTop, rightTopV, bracketPaint);

    Offset leftBottom =
        //Offset(xBlank + bracketWidth / 2, ParentInfo.hScreen - yBlank - bracketWidth / 2);
        Offset(leftBottomOffset.dx + bracketWidth / 2,
            leftBottomOffset.dy - bracketWidth / 2);
    Offset leftBottomH =
        Offset(leftBottom.dx + ParentInfo.wScreen / 6, leftBottom.dy);
    Offset leftBottomV =
        Offset(leftBottom.dx, leftBottom.dy - ParentInfo.wScreen / 6);
    canvas.drawLine(leftBottom, leftBottomH, bracketPaint);
    canvas.drawLine(leftBottom, leftBottomV, bracketPaint);

    Offset rightBottom =
        //Offset(ParentInfo.wScreen - xBlank - bracketWidth / 2, ParentInfo.hScreen - yBlank - bracketWidth / 2);
        Offset(rightBottomOffset.dx - bracketWidth / 2,
            rightBottomOffset.dy - bracketWidth / 2);
    Offset rightBottomH =
        Offset(rightBottom.dx - ParentInfo.wScreen / 6, rightBottom.dy);
    Offset rightBottomV =
        Offset(rightBottom.dx, rightBottom.dy - ParentInfo.wScreen / 6);
    canvas.drawLine(rightBottom, rightBottomH, bracketPaint);
    canvas.drawLine(rightBottom, rightBottomV, bracketPaint);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // unselected
    Paint unselectedPaint = Paint()
      ..color = Colors.black54
      //..color = Colors.yellow
      ..strokeWidth = 1;
    Rect leftRect = Offset(xBlank, yBlank) &
        Size(leftTopOffset.dx - xBlank, hScreen - yBlank * 2);
    canvas.drawRect(leftRect, unselectedPaint);
    Rect rightRect = Offset(rightTopOffset.dx, yBlank) &
        Size(wScreen - xBlank * 2 - rightTopOffset.dx, hScreen - yBlank * 2);
    canvas.drawRect(rightRect, unselectedPaint);
    Rect topRect = Offset(leftTopOffset.dx, yBlank) &
        Size(rightTopOffset.dx - leftTopOffset.dx, leftTopOffset.dy - yBlank);
    canvas.drawRect(topRect, unselectedPaint);
    Rect bottomRect = Offset(leftBottomOffset.dx, leftBottomOffset.dy) &
        Size(rightBottomOffset.dx - leftBottomOffset.dx,
            hScreen - yBlank - rightBottomOffset.dy);
    canvas.drawRect(bottomRect, unselectedPaint);
    ////////////////////////////////////////////////////////////////////////////////

    /*
    ////////////////////////////////////////////////////////////////////////////////
    // for test
    Paint testPaint = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;
    InfoUtil.findBracketCorner(Offset(-10000, -10000), canvas: canvas, paint: testPaint);
    ////////////////////////////////////////////////////////////////////////////////
    */
  }

  /// 그려야할 정보를 모두 검사해서 틀린 것이 있으면 다시 그리기
  @override
  bool shouldRepaint(MakeParentSizePainter oldDelegate) {
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

    leftTopOffset = ParentInfo.leftTopOffset;
    rightTopOffset = ParentInfo.rightTopOffset;
    leftBottomOffset = ParentInfo.leftBottomOffset;
    rightBottomOffset = ParentInfo.rightBottomOffset;
  }
////////////////////////////////////////////////////////////////////////////////
}
