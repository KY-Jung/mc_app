import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:mc/provider/provider_make.dart';
import 'package:mc/ui/bar_baby.dart';
import 'package:mc/ui/bar_blank.dart';
import 'package:mc/ui/bar_caption.dart';
import 'package:mc/ui/bar_link.dart';
import 'package:mc/ui/bar_parent.dart';
import 'package:mc/ui/bar_sound.dart';
import 'package:provider/provider.dart';

import '../config/color_app.dart';
import '../config/config_app.dart';
import '../config/constant_app.dart';
import '../dto/info_parent.dart';
import '../library/custom_expandable_draggable_widget.dart';
import '../painter/painter_make.dart';
import '../painter/painter_make_parent_resize.dart';
import '../provider/provider_parent.dart';
import '../util/util_bracket.dart';
import '../util/util_info.dart';
import '../util/util_popup.dart';

enum MakePageEnum {
  BLANK,
  PARENT,
  BABY,
  CAPTION,
  SOUND,
  LINK,
}

enum MakePageBringEnum {
  NONE,
  GALLERY,
  CAMERA,
  RESIZE,
}

enum MakeParentResizePointEnum {
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

class MakePage extends StatefulWidget {
  const MakePage({super.key});

  @override
  State<MakePage> createState() => MakePageState();
}

class MakePageState extends State<MakePage> {
  ////////////////////////////////////////////////////////////////////////////////
  // variable

  MakePageEnum _makePageEnum = MakePageEnum.BLANK;

  // InteractiveView size (_afterBuild 에서 구해짐)
  late Size screenSize;
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // object

  late MakeProvider makeProvider;
  late ParentProvider parentProvider;

  final TransformationController _transformationController =
      TransformationController(
          Matrix4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1));

  late TapDownDetails _tapDownDetails; // onDoubleTap 에서 사용

  /// build 이후에 InteractiveViewer 화면 크기를 구할때 사용
  final GlobalKey _screenGlobalKey = GlobalKey();

  /// fab 을 toggle 할때 사용
  late final GlobalObjectKey<CustomExpandableDraggableFabState> _fabGlobalKey =
      GlobalObjectKey<CustomExpandableDraggableFabState>(context);
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# MakePage initState START');
    super.initState();

    ////////////////////////////////////////////////////////////////////////////////
    // 초기화
    if (ParentInfo.path != '') {
      _makePageEnum = MakePageEnum.PARENT;

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

    dev.log('# MakePage initState END');
  }

  // 뒤로가기 클릭하면 호출됨
  @override
  void dispose() {
    dev.log('# MakePage dispose START');
    super.dispose();

    _transformationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# MakePage build START');
    dev.log('build _makeEnum: $_makePageEnum');
    dev.log('build ParentInfo.path: ${ParentInfo.path}');

    ////////////////////////////////////////////////////////////////////////////////
    makeProvider = Provider.of<MakeProvider>(context);
    parentProvider = Provider.of<ParentProvider>(context);
    ////////////////////////////////////////////////////////////////////////////////

    /*
    // _onTapDownAll 에서 toggle 처리를 하므로, 아래 코드 사용하지 않음
    ////////////////////////////////////////////////////////////////////////////////
    // function bar 에서 수신된 경우 처리
    if (!makeProvider.fabOpen) {
      var floatKeyState = _fabGlobalKey.currentState;
      if (floatKeyState != null) {
        if (floatKeyState.isOpen) {
          dev.log('build floatKeyState.isOpen and close');
          // 직접 호출하면 setState() or markNeedsBuild() called during build 에러 발생
          //floatKeyState.toggle();
          WidgetsBinding.instance
              .addPostFrameCallback((_) => floatKeyState.toggle());
        }
      }
    }
    ////////////////////////////////////////////////////////////////////////////////
    */

    return Scaffold(
      appBar: AppBar(
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
                child: const Icon(Icons.delete_forever),
              ),
            ),
          ),
        ],
      ),
      body: Scaffold(
        backgroundColor: Colors.black87,
        body: GestureDetector(
          onTapDown: _onTapDownAll,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand, // 비로소 상하 center 에 오게됨
                  children: <Widget>[
                    if (_makePageEnum != MakePageEnum.BLANK)
                      GestureDetector(
                        onTapDown: _onTapDown,
                        onTapUp: _onTapUp,
                        onDoubleTap: _onDoubleTap,
                        //onPanUpdate: _onPanUpdate,    // onInteractionUpdate 과 중복 문제 발생
                        //onPanEnd: _onPanEnd,
                        child: InteractiveViewer(
                          // build 이후 InteractiveViewer 의 사이즈 구하기
                          key: _screenGlobalKey,
                          //maxScale: (makeProvider.parentResize)
                          maxScale: (_makePageEnum == MakePageEnum.PARENT && parentProvider.parentBarEnum == ParentBarEnum.RESIZE)
                              ? 1.0
                              : AppConfig.MAKE_SCREEN_MAX,
                          //minScale: (makeProvider.parentResize)
                          minScale: (_makePageEnum == MakePageEnum.PARENT && parentProvider.parentBarEnum == ParentBarEnum.RESIZE)
                              ? 1.0
                              : AppConfig.MAKE_SCREEN_MIN,
                          transformationController: _transformationController,
                          panEnabled: true,
                          scaleEnabled: true,
                          constrained: true,
                          //panAxis: PanAxis.aligned,   // 중앙을 기준으로만 확대됨
                          //boundaryMargin: const EdgeInsets.all(20.0),   // 이동시키면 공백이 나타남
                          //onInteractionStart: _onInteractionStart,
                          onInteractionEnd: _onInteractionEnd,
                          onInteractionUpdate: _onInteractionUpdate,
                          //child: Image.asset('assets/images/jeju.jpg'),
                          //child: CustomPaint(
                          //  painter: MyPainter(ParentInfo.image!),
                          //),
                          child: Image.file(File(ParentInfo.path)),
                        ),
                      ),
                    if (_makePageEnum != MakePageEnum.BLANK)
                      IgnorePointer(
                        child: RepaintBoundary(
                          child: CustomPaint(
                            // size 안 정해도 동작함
                            //painter: (makeProvider.parentResize)
                            painter: (_makePageEnum == MakePageEnum.PARENT && parentProvider.parentBarEnum == ParentBarEnum.RESIZE)
                                ? MakeParentResizePainter()
                                : MakePainter(),
                          ),
                        ),
                      ),
                    if (_makePageEnum != MakePageEnum.BLANK)
                      for (int i = 0, j = 2; i < j; i++)
                        Text('$i Text===========\nafdafjkl;j;alfj;ds\njfdalfjs;dalk\nfdalkfj;l'),
                    if (_makePageEnum == MakePageEnum.BLANK)
                      Row(
                        key: _screenGlobalKey,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          ElevatedButton.icon(
                              icon: const Icon(
                                Icons.photo,
                                color: Colors.amber,
                              ),
                              label: Text('GALLERY'.tr()),
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.white),
                              onPressed: () {
                                _bringParentPressed(MakePageBringEnum.GALLERY);
                              }),
                          ElevatedButton.icon(
                              icon: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.lightGreen,
                              ),
                              label: Text('CAMERA'.tr()),
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.white),
                              onPressed: () {
                                _bringParentPressed(MakePageBringEnum.CAMERA);
                              }),
                        ],
                      ),
                  ],
                ),
              ),
              SizedBox(
                height:
                    AppBar().preferredSize.height * AppConfig.FUNCTIONBAR_HEIGHT,
                child: _chooseFunctionBar(_makePageEnum),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonAnimator: NoScalingAnimation(),
      floatingActionButtonLocation: ExpandableFloatLocation(),
      floatingActionButton: (_makePageEnum == MakePageEnum.BLANK)
          ? Container()
          : CustomExpandableDraggableFab(
              key: _fabGlobalKey,
              childrenCount: 5,
              onTab: _onTabFab,
              childrenTransition: ChildrenTransition.fadeTransation,
              initialOpen: false,
              //childrenBoxDecoration: const BoxDecoration(color: Colors.red),
              enableChildrenAnimation: true,
              curveAnimation: Curves.linear,
              reverseAnimation: Curves.linear,
              childrenType: ChildrenType.columnChildren,
              //closeChildrenRotate: false,
              closeChildrenRotate: true,
              childrenAlignment: Alignment.center,
              initialDraggableOffset: Offset(
                  MediaQuery.of(context).size.width / 2 - 56 / 2 - 8, // 8 은 모름
                  MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height *
                          AppConfig.FUNCTIONBAR_HEIGHT -
                      56 -
                      8 - 2),
              distance: 100,
              // Animation distance during open and close.
              children: [
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.aspect_ratio,
                    color: Colors.white60,
                  ),
                  label: Text('PARENT'.tr()),
                  style:
                      TextButton.styleFrom(backgroundColor: AppColors.MAKE_PARENT_FAB_BACKGROUND),
                  onPressed: _fabParent,
                ),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.photo_album,
                    color: Colors.white60,
                  ),
                  label: Text('BABY'.tr()),
                  style: TextButton.styleFrom(backgroundColor: AppColors.MAKE_BABY_FAB_BACKGROUND),
                  onPressed: _fabBaby,
                ),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white60,
                  ),
                  label: Text('CAPTION'.tr()),
                  style:
                      TextButton.styleFrom(backgroundColor: AppColors.MAKE_CAPTION_FAB_BACKGROUND),
                  onPressed: _fabCaption,
                ),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.volume_up_rounded,
                    color: Colors.white60,
                  ),
                  label: Text('SOUND'.tr()),
                  style:
                      TextButton.styleFrom(backgroundColor: AppColors.MAKE_SOUND_FAB_BACKGROUND),
                  onPressed: _fabSound,
                ),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.open_in_browser,
                    color: Colors.white60,
                  ),
                  label: Text('LINK'.tr()),
                  style:
                      TextButton.styleFrom(backgroundColor: AppColors.MAKE_LINK_FAB_BACKGROUND),
                  onPressed: _fabLink,
                ),
              ],
            ),
    );
  }

  /// build 이후에 실행
  void _afterBuild(context) {
    dev.log('# MakePage _afterBuild START');

    ////////////////////////////////////////////////////////////////////////////////
    /// InteractiveViewer 실제 크기를 구해서 ParentInfo wScreen/hScreen 에 저장
    RenderBox renderBox =
        _screenGlobalKey.currentContext!.findRenderObject() as RenderBox;
    screenSize = renderBox.size;
    dev.log('InteractiveViewer size: $screenSize');
    var wScreen = screenSize.width;
    var hScreen = screenSize.height;

    ParentInfo.wScreen = wScreen;
    ParentInfo.hScreen = hScreen;
    ////////////////////////////////////////////////////////////////////////////////

    ///_transformationController. .scale(scaleHalf);
  }

  Widget _chooseFunctionBar(type) {
    switch (type) {
      case MakePageEnum.BLANK:
        return const BlankBar();
      case MakePageEnum.PARENT:
        return const ParentBar();
      case MakePageEnum.BABY:
        return const BabyBar();
      case MakePageEnum.CAPTION:
        return const CaptionBar();
      case MakePageEnum.SOUND:
        return const SoundBar();
      case MakePageEnum.LINK:
        return const LinkBar();
      default:
        return const BlankBar();
    }
  }
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // Event Start //
  ////////////////////////////////////////////////////////////////////////////////
  void _onTapDownAll(TapDownDetails tapDownDetails) async {
    dev.log('# MakePage _onTapDownAll');

    /*
    // fab close 처리 (provider 를 사용해서 닫기)
    if (makeProvider.fabOpen) {
      makeProvider.setFabOpen(false);
    }
    */
    ////////////////////////////////////////////////////////////////////////////////
    // toggle fab
    //_fabGlobalKey.currentState?.toggle();
    var floatKeyState = _fabGlobalKey.currentState;
    if (floatKeyState != null) {
      if (floatKeyState.isOpen) {
        dev.log('_onTapDownAll floatKeyState.isOpen --> close');
        floatKeyState.toggle();
      }
    }
    ////////////////////////////////////////////////////////////////////////////////
  }

  void _bringParentPressed(MakePageBringEnum type) async {
    dev.log('# MakePage _bringParentPressed START');

    XFile? xFile;
    if (type == MakePageBringEnum.CAMERA) {
      xFile = await ImagePicker().pickImage(source: ImageSource.camera);
    } else {
      xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    }
    dev.log('file: ${xFile?.path}');
    if (xFile == null) return; // 취소한 경우

    // TODO : 모래시계 필요

    await InfoUtil.setParentInfo(xFile.path);
    if (type == MakePageBringEnum.CAMERA) {
      ParentInfo.makeBringEnum = MakePageBringEnum.CAMERA;
    } else {
      ParentInfo.makeBringEnum = MakePageBringEnum.GALLERY;
    }

    // TODO : 나머지도 있다면 재조정

    setState(() {
      _makePageEnum = MakePageEnum.PARENT;
    });
    dev.log('# MakePage _bringParentPressed END');
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
    //if (makeProvider.parentResize) {
    if (_makePageEnum == MakePageEnum.PARENT && parentProvider.parentBarEnum == ParentBarEnum.RESIZE) {
      // _onTapDown 이 호출되지 않은 경우, _onTapDown 에서 선택되지 않은 경우
      if (ParentInfo.makeParentSizePointEnum == MakeParentResizePointEnum.NONE) {
        return;
      }

      // blank 검사
      if (!BracketUtil.checkBlankArea(
          xyOffset, ParentInfo.makeParentSizePointEnum)) {
        dev.log('\n\n### checkBlankArea return\n\n');
        return;
      }

      // bracket 간에 침범할 수 없는 영역을 순식간에 넘어갔는지 검사
      if (!BracketUtil.checkBracketCross(
          xyOffset, ParentInfo.makeParentSizePointEnum)) {
        dev.log('\n\n### checkBracketCross return\n\n');
        return;
      }

      // shrink 허용치 검사
      Rect bracketRect = BracketUtil.calcBracketRect(
          xyOffset, ParentInfo.makeParentSizePointEnum);
      dev.log('bracketRect: $bracketRect');
      double minArea = (ParentInfo.wScreen - ParentInfo.xBlank * 2) *
          (ParentInfo.hScreen - ParentInfo.yBlank * 2) *
          AppConfig.SIZE_SHRINK_MIN;
      if (minArea >= (bracketRect.width * bracketRect.height)) {
        dev.log(
            'parentSize exceed ${AppConfig.SIZE_SHRINK_MIN * 100}%: $xyOffset');
        return;
      }

      // sticky
      dev.log('org xyOffset: $xyOffset');
      xyOffset = BracketUtil.stickyBracketOffset(
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
      BracketUtil.updateBracketArea(
          xyOffset, ParentInfo.makeParentSizePointEnum);
    } // end if (makeProvider.parentResize) {
    ////////////////////////////////////////////////////////////////////////////////

    setState(() {});
  }

  // drag 이후에는 onTapUp 호출안됨
  void _onInteractionEnd(ScaleEndDetails scaleEndDetails) {
    dev.log('_onInteractionEnd Velocity: ${scaleEndDetails.velocity}');
    ParentInfo.makeParentSizePointEnum = MakeParentResizePointEnum.NONE;
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

    /*
    ////////////////////////////////////////////////////////////////////////////////
    // toggle 일 경우 return
    var floatKeyState = _fabGlobalKey.currentState;
    if (floatKeyState != null) {
      if (floatKeyState.isOpen) {
        dev.log('_onTapDown floatKeyState.isOpen and return');
        floatKeyState.toggle();
        return;
      }
    }
    ////////////////////////////////////////////////////////////////////////////////
    */

    ////////////////////////////////////////////////////////////////////////////////
    // for debug
    Matrix4 matrix4 = _transformationController.value;
    double scale = matrix4.entry(0, 0);
    double xStart = matrix4.entry(0, 3);
    double yStart = matrix4.entry(1, 3);
    Offset xyOffset = _tapDownDetails.localPosition;
    dev.log(
        '_onTapDown scale: $scale, xyOffset: $xyOffset, xStart: $xStart, yStart: $yStart');
    ParentInfo.printParent();
    //dev.log('_onTapDown wView: ${ParentInfo.wScreen - ParentInfo.xBlank}, '
    //    'wScreen: ${ParentInfo.wScreen}, xBlank: ${ParentInfo.xBlank}, '
    //    'hView: ${ParentInfo.hScreen - ParentInfo.yBlank}, '
    //    'hScreen: ${ParentInfo.hScreen}, yBlank: ${ParentInfo.yBlank}');
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
    //if (makeProvider.parentResize) {
    if (_makePageEnum == MakePageEnum.PARENT && parentProvider.parentBarEnum == ParentBarEnum.RESIZE) {
      dev.log(
          'parentSize leftTopOffset: ${ParentInfo.leftTopOffset}, rightTopOffset: ${ParentInfo.rightTopOffset}, '
          'leftBottomOffset: ${ParentInfo.leftBottomOffset}, rightBottomOffset: ${ParentInfo.rightBottomOffset}');

      ParentInfo.xyOffset = xyOffset; // for test
      MakeParentResizePointEnum makeParentSizeEnum =
          BracketUtil.findBracketArea(xyOffset);
      dev.log('findBracketArea makeParentSizeEnum: $makeParentSizeEnum');
      //if (makeParentSizeEnum != MakeParentSizePointEnum.NONE) {
      //  ParentInfo.makeParentSizePointEnum = makeParentSizeEnum;
      //}
      ParentInfo.makeParentSizePointEnum = makeParentSizeEnum;
    } // if (makeProvider.parentResize) {
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // for debug
    //setState(() {});
    ////////////////////////////////////////////////////////////////////////////////

  }

  // drag 이후에는 호출안됨
  void _onTapUp(TapUpDetails tapUpDetails) async {
    //dev.log('_onTapUp TapUpDetails: ${tapUpDetails.localPosition}');
    ParentInfo.makeParentSizePointEnum = MakeParentResizePointEnum.NONE;
  }

  /// 변경되는 값 : scale, xStart, yStart, xyOffset
  void _onDoubleTap() async {
    //dev.log('_onDoubleTap localPosition: ${_tapDownDetails.localPosition}');
    //dev.log('_transformationController.value: ${_transformationController.value}');

    // for has not been initialized
    if (_tapDownDetails == null) {
      return;
    }

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
    //if (makeProvider.parentResize) {
    if (_makePageEnum == MakePageEnum.PARENT && parentProvider.parentBarEnum == ParentBarEnum.RESIZE) {
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

    ////////////////////////////////////////////////////////////////////////////////
    // toggle 일 경우 return
    var floatKeyState = _fabGlobalKey.currentState;
    if (floatKeyState != null) {
      if (floatKeyState.isOpen) {
        dev.log('_onLongPressDelete floatKeyState.isOpen and return');
        floatKeyState.toggle();
        return;
      }
    }
    ////////////////////////////////////////////////////////////////////////////////

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
          _makePageEnum = MakePageEnum.BLANK;
        });
      }
    });
  }

  // floatKeyState.toggle() 을 사용하면 자동으로 onTab 이 호출됨
  void _onTabFab() {
    /*
    // _onTapDownAll 에서 toggle 처리를 하므로, 아래 코드 사용하지 않음
    ////////////////////////////////////////////////////////////////////////////////
    // toggle 일 경우 return
    var floatKeyState = _fabGlobalKey.currentState;
    if (floatKeyState != null) {
      if (floatKeyState.isOpen) {
        dev.log('_onTabFab open -> close');
        if (makeProvider.fabOpen) {
          makeProvider.setFabOpen(false);
        }
      } else {
        dev.log('_onTabFab close -> open');
        if (!makeProvider.fabOpen) {
          makeProvider.setFabOpen(true);
        }
      }
    }
    ////////////////////////////////////////////////////////////////////////////////
    */
  }

  void _fabParent() {
    dev.log('_fabParent');

    _fabGlobalKey.currentState?.toggle();

    // TODO : Parent 가져오기 실행
    // 이미 Parent 상태여도 가져오기 실행
    // 취소하면 FB 는 이전 것으로 유지

    setState(() {
      _makePageEnum = MakePageEnum.PARENT;
    });
  }

  void _fabBaby() {
    dev.log('_fabBaby');

    _fabGlobalKey.currentState?.toggle();

    // TODO : Baby 가져오기 실행
    // 이미 Baby 상태여도 가져오기 실행
    // 취소하면 FB 는 이전 것으로 유지

    setState(() {
      _makePageEnum = MakePageEnum.BABY;
      //if (makeProvider.parentResize) {
      //  makeProvider.setParentResize(false);
      //}
      //context.read<MakeProvider>().setParentSize(false);
      //InfoUtil.initParentInfoBracket();
    });
  }

  void _fabCaption() {
    dev.log('_fabCaption');

    _fabGlobalKey.currentState?.toggle();

    // TODO : caption 추가, 키보드 올리기
    // FB 는 Caption 으로 변경

    setState(() {
      _makePageEnum = MakePageEnum.CAPTION;
      //if (makeProvider.parentResize) {
      //  makeProvider.setParentResize(false);
      //}
      //context.read<MakeProvider>().setParentSize(false);
      //InfoUtil.initParentInfoBracket();
    });
  }

  void _fabSound() {
    dev.log('_fabSound');

    _fabGlobalKey.currentState?.toggle();

    // TODO : Function bar 만 이동

    setState(() {
      _makePageEnum = MakePageEnum.SOUND;
      //if (makeProvider.parentResize) {
      //  makeProvider.setParentResize(false);
      //}
      //context.read<MakeProvider>().setParentSize(false);
      //InfoUtil.initParentInfoBracket();
    });
  }

  void _fabLink() {
    dev.log('_fabLink');

    _fabGlobalKey.currentState?.toggle();

    // TODO : Function bar 만 이동

    setState(() {
      _makePageEnum = MakePageEnum.LINK;
      //if (makeProvider.parentResize) {
      //  makeProvider.setParentResize(false);
      //}
      //context.read<MakeProvider>().setParentSize(false);
      //InfoUtil.initParentInfoBracket();
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

