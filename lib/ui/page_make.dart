import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:mc/provider/provider_make.dart';
import 'package:mc/ui/bar_baby.dart';
import 'package:mc/ui/bar_blank.dart';
import 'package:mc/ui/bar_caption.dart';
import 'package:mc/ui/bar_link.dart';
import 'package:mc/ui/bar_parent.dart';
import 'package:mc/ui/bar_sound.dart';
import 'package:mc/ui/widget_dragresizerotate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/color_app.dart';
import '../config/config_app.dart';
import '../config/constant_app.dart';
import '../config/enum_app.dart';
import '../library/custom_expandable_draggable_widget.dart';
import '../painter/painter_make.dart';
import '../painter/painter_make_parent_resize.dart';
import '../provider/provider_parent.dart';
import '../provider/provider_sign.dart';
import '../util/util_bracket.dart';
import '../util/util_info.dart';
import '../util/util_popup.dart';

class MakePage extends StatefulWidget {
  const MakePage({super.key});

  @override
  State<MakePage> createState() => MakePageState();
}

class MakePageState extends State<MakePage> {
  ////////////////////////////////////////////////////////////////////////////////
  // variable

  //MakePageEnum _makePageEnum = MakePageEnum.PARENT;
  bool first = true;

  late double childHandleWh;
  late double childTouchWh;

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // sign
  double signRadian = 0;

  // resize
  Offset sumOffset = const Offset(0, 0);

  // 최대 크기를 벗어난 경우에 사용
  Offset overSumOffset = const Offset(0, 0);

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // object

  late MakeProvider makeProvider;
  late ParentProvider parentProvider;
  late SignProvider signProvider;

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

/*
    // parentProvider 가 아직 초기화되지 않는 문제 발생
    // MakeTab 으로 다시 옮김
    ////////////////////////////////////////////////////////////////////////////////
    // 초기화
    if (parentProvider.path != '') {
      _makePageEnum = MakePageEnum.PARENT;

      dev.log('initState recall _setparentProvider');
      InfoUtil.setParenProvider(parentProvider.path, parentProvider).then((_) => {});

      // TODO : 나머지도 있다면 초기화
    }
    ////////////////////////////////////////////////////////////////////////////////
*/

    ////////////////////////////////////////////////////////////////////////////////
    /// build 이후 실행
    /// InteractiveViewer 실제 크기를 구해서 ParentProvider wScreen/hScreen 에 저장
    /// --> didChangeDependencies 에서 직접 구하는 것으로 수정
    //WidgetsBinding.instance.addPostFrameCallback((_) => _afterBuild(context));
    ////////////////////////////////////////////////////////////////////////////////

    dev.log('# MakePage initState END');
  }

  // initState --> didChangeDependencies --> build
  @override
  void didChangeDependencies() {
    dev.log('# MakePage didChangeDependencies START');
    super.didChangeDependencies();
  }

  // 뒤로가기 클릭하면 호출됨
  @override
  void dispose() {
    dev.log('# MakePage dispose START');
    super.dispose();

    //signProvider.parentSignOffset = null;

    _transformationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# MakePage build START');

    ////////////////////////////////////////////////////////////////////////////////
    makeProvider = Provider.of<MakeProvider>(context);
    parentProvider = Provider.of<ParentProvider>(context);
    signProvider = Provider.of<SignProvider>(context);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // initState 에서 MediaQuery 를 호출하면 에러 발생
    if (first) {
      dev.log('first start');

      // parent 의 나머지 설정
      parentProvider.hTopBlank =
          MediaQuery.of(context).padding.top + AppBar().preferredSize.height;
      parentProvider.hBottomBlank =
          AppBar().preferredSize.height * AppConfig.FUNCTIONBAR_HEIGHT;
      var wScreen = MediaQuery.of(context).size.width;
      var hScreen = MediaQuery.of(context).size.height -
          parentProvider.hTopBlank -
          parentProvider.hBottomBlank;
      parentProvider.initParenProviderWithScreen(wScreen, hScreen);
      parentProvider.whSign =
          (parentProvider.wScreen + parentProvider.hScreen) *
              0.5 *
              AppConfig.SIGN_WH_RATIO;

      dev.log('MediaQuery.of(context).size: ${MediaQuery.of(context).size}');
      dev.log(
          'MediaQuery.of(context).padding.top: ${MediaQuery.of(context).padding.top}');
      dev.log(
          'AppBar().preferredSize.height: ${AppBar().preferredSize.height}');
      dev.log('parentProvider.wScreen: ${parentProvider.wScreen}');
      dev.log('parentProvider.hScreen: ${parentProvider.hScreen}');
      dev.log('hTopBlank: ${parentProvider.hTopBlank}');
      dev.log('hBottomBlank: ${parentProvider.hBottomBlank}');
      dev.log('whSign: ${parentProvider.whSign}');

      first = false;
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    childTouchWh = (parentProvider.wScreen + parentProvider.hScreen) *
        0.6 *
        AppConfig.WIDGET_TOUCH_WH;
    childHandleWh = (parentProvider.wScreen + parentProvider.hScreen) *
        0.5 *
        AppConfig.WIDGET_HANDLE_WH;

    dev.log(
        'whSign: ${parentProvider.whSign}, widgetTouchWh: $childTouchWh, widgetHandleWh: $childHandleWh');
    ////////////////////////////////////////////////////////////////////////////////

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
              onTap: () {},
              child: Ink(
                child: const Icon(Icons.delete_forever),
              ),
            ),
          ),
          GestureDetector(
            onTapDown: _onTapDownAll,
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell(
                onTap: _onTapDelete,
                onLongPress: _onLongPressDelete,
                child: Ink(
                  child: const Icon(Icons.delete_forever),
                ),
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
                    GestureDetector(
                      onTapDown: _onTapDown,
                      onTapUp: _onTapUp,
                      onDoubleTap: _onDoubleTap,
                      //onPanUpdate: _onPanUpdate,    // onInteractionUpdate 과 중복 문제 발생
                      //onPanEnd: _onPanEnd,
                      child: InteractiveViewer(
                        // build 이후 InteractiveViewer 의 사이즈 구하기
                        key: _screenGlobalKey,
                        maxScale:
                            (makeProvider.makeFabEnum == MakeFabEnum.PARENT &&
                                    parentProvider.parentBarEnum ==
                                        ParentBarEnum.RESIZE)
                                ? 1.0
                                : AppConfig.MAKE_SCREEN_MAX,
                        minScale:
                            (makeProvider.makeFabEnum == MakeFabEnum.PARENT &&
                                    parentProvider.parentBarEnum ==
                                        ParentBarEnum.RESIZE)
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
                        child: Image.file(File(parentProvider.path!)),
                      ),
                    ),
                    IgnorePointer(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          // size 안 정해도 동작함
                          //painter: (makeProvider.parentResize)
                          painter:
                              (makeProvider.makeFabEnum == MakeFabEnum.PARENT &&
                                      parentProvider.parentBarEnum ==
                                          ParentBarEnum.RESIZE)
                                  ? MakeParentResizePainter(
                                      parentProvider.wScreen,
                                      parentProvider.hScreen,
                                      parentProvider.wImage,
                                      parentProvider.hImage,
                                      parentProvider.inScale,
                                      parentProvider.xBlank,
                                      parentProvider.yBlank,
                                      parentProvider.xStart,
                                      parentProvider.yStart,
                                      parentProvider.scale,
                                      parentProvider.leftTopOffset,
                                      parentProvider.rightTopOffset,
                                      parentProvider.leftBottomOffset,
                                      parentProvider.rightBottomOffset)
                                  : MakePainter(
                                      parentProvider.wScreen,
                                      parentProvider.hScreen,
                                      parentProvider.wImage,
                                      parentProvider.hImage,
                                      parentProvider.inScale,
                                      parentProvider.xBlank,
                                      parentProvider.yBlank,
                                      parentProvider.xStart,
                                      parentProvider.yStart,
                                      parentProvider.scale),
                        ),
                      ),
                    ),
                    /*
                    if (signProvider.parentSignFileInfoIdx != -1)
                      Positioned(
                        left: signProvider.parentSignOffset!.dx - childTouchWh + childHandleWh,
                        top: signProvider.parentSignOffset!.dy - childTouchWh + childHandleWh,
                        width: parentProvider.whSign + childTouchWh * 2 - childHandleWh * 2,
                        height: parentProvider.whSign + childTouchWh * 2 - childHandleWh * 2,
                        child: Transform.rotate(
                          angle: signRadian,
                          child: Container(
                            //color: Colors.green[100],
                            color: Colors.transparent,
                            child: Stack(
                              children: <Widget>[
                                Positioned(
                                  left: childTouchWh - childHandleWh,
                                  top: childTouchWh - childHandleWh,
                                  width: parentProvider.whSign,
                                  height: parentProvider.whSign,
                                  child: Draggable(
                                    feedback: SizedBox(
                                      width: parentProvider.whSign, // 웬지 drag 중에는 Pogistioned 크기가 적용되지 않음
                                      height: parentProvider.whSign,
                                      child: Transform.rotate(
                                        angle: signRadian,
                                        child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                border: Border.all(color: Colors.white38, width: 2)),
                                            child: FittedBox(
                                              fit: BoxFit.fill,
                                              child: signProvider
                                                  .signFileInfoList[signProvider.parentSignFileInfoIdx].image,
                                            )),
                                      ),
                                    ),
                                    childWhenDragging: SizedBox(
                                      width: parentProvider.whSign,
                                      height: parentProvider.whSign,
                                      child: Opacity(
                                        opacity: 0.4,
                                        child: signProvider.signFileInfoList[signProvider.parentSignFileInfoIdx].image,
                                      ),
                                    ),
                                    onDragEnd: (details) {
                                      dev.log('onDragEnd offset: ${details.offset}');
                                      signProvider.parentSignOffset =
                                          Offset(details.offset.dx, details.offset.dy - parentProvider.hTopBlank);
                                      dev.log('onDragEnd signOffset: ${signProvider.parentSignOffset}');
                                      setState(() {});

                                      SharedPreferences.getInstance().then((prefs) {
                                        prefs.setDouble(AppConstant.PREFS_PARENTSIGNOFFSET_X, details.offset.dx);
                                        prefs.setDouble(AppConstant.PREFS_PARENTSIGNOFFSET_Y,
                                            details.offset.dy - parentProvider.hTopBlank);
                                      });
                                    },
                                    child: GestureDetector(
                                      onTapDown: (tapDownDetails) {
                                        dev.log('sign onTapDown');
                                      },
                                      onTap: () {
                                        dev.log('sign onTap');
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              border: Border.all(color: Colors.white38, width: 2)),
                                          child: FittedBox(
                                              fit: BoxFit.fill,
                                              child: signProvider.signFileInfoList[signProvider.parentSignFileInfoIdx].image)),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  // lefttop handle
                                  left: childTouchWh - childHandleWh * 1.5,
                                  top: childTouchWh - childHandleWh * 1.5,
                                  width: childHandleWh,
                                  height: childHandleWh,
                                  child: Container(
                                    color: Colors.white60,
                                    width: childHandleWh,
                                    height: childHandleWh,
                                  ),
                                ),
                                Positioned(
                                  // righttop handle
                                  left: parentProvider.whSign + childTouchWh - childHandleWh * 1.5,
                                  top: childTouchWh - childHandleWh * 1.5,
                                  width: childHandleWh,
                                  height: childHandleWh,
                                  child: Container(
                                    color: Colors.white60,
                                    width: childHandleWh,
                                    height: childHandleWh,
                                  ),
                                ),
                                Positioned(
                                  // leftbottom handle
                                  left: childTouchWh - childHandleWh * 1.5,
                                  top: parentProvider.whSign + childTouchWh - childHandleWh * 1.5,
                                  width: childHandleWh,
                                  height: childHandleWh,
                                  child: Container(
                                    color: Colors.white60,
                                    width: childHandleWh,
                                    height: childHandleWh,
                                  ),
                                ),
                                Positioned(
                                  // rightbottom handle
                                  left: parentProvider.whSign + childTouchWh - childHandleWh * 1.5,
                                  top: parentProvider.whSign + childTouchWh - childHandleWh * 1.5,
                                  width: childHandleWh,
                                  height: childHandleWh,
                                  child: Container(
                                    color: Colors.white60,
                                    width: childHandleWh,
                                    height: childHandleWh,
                                  ),
                                ),
                                Positioned(
                                  // lefttop touch
                                  left: 0,
                                  top: 0,
                                  width: childTouchWh,
                                  height: childTouchWh,
                                  child: GestureDetector(
                                    onTapDown: (tapDownDetails) {
                                      dev.log('lefttop touch');
                                    },
                                    onPanStart: (dragUpdateDetails) {
                                      sumOffset = const Offset(0, 0);
                                    },
                                    onPanUpdate: (dragUpdateDetails) {
                                      //dev.log(
                                      //    '------${DateTime.now()} globalPosition: ${dragUpdateDetails.globalPosition}, '
                                      //    'localPosition: ${dragUpdateDetails.localPosition},delta: ${dragUpdateDetails.delta}');

                                      // 중심점으로 offset 계산
                                      Offset baseOffset = const Offset(
                                          0, // 1/2 위치별 수정
                                          0);
                                      Offset centerOffset = Offset(
                                          (parentProvider.whSign + childTouchWh * 2 - childHandleWh * 2) / 2,
                                          (parentProvider.whSign + childTouchWh * 2 - childHandleWh * 2) / 2);
                                      Offset diffOffset = baseOffset - centerOffset;
                                      Offset newOffset = diffOffset + dragUpdateDetails.localPosition - sumOffset;
                                      Offset oldOffset = diffOffset +
                                          (dragUpdateDetails.localPosition - dragUpdateDetails.delta) -
                                          sumOffset;
                                      //dev.log('baseOffset: $baseOffset, centerOffset: $centerOffset, diffOffset: $diffOffset');
                                      //dev.log('oldOffset: $oldOffset, newOffset: $newOffset');
                                      // 회전
                                      signRadian = signRadian + (newOffset.direction - oldOffset.direction);
                                      //dev.log('signRadian: $signRadian');

                                      // line distance
                                      double diffDistance = newOffset.distance - oldOffset.distance;
                                      // 직사각형인 경우
                                      double wSquare = parentProvider.whSign;
                                      double hSquare = parentProvider.whSign;
                                      //double wDiff = diffDistance / math.sqrt(2);   // 정사각형인 경우
                                      double wDiff = math.sqrt(
                                              math.pow(wSquare, 2) / (math.pow(wSquare, 2) + math.pow(hSquare, 2))) *
                                          diffDistance;
                                      double hDiff = hSquare / wSquare * wDiff; // 늘리면 양수, 줄이면 음수
                                      //dev.log('wDiff: $wDiff, hDiff: $hDiff');

                                      // 이동한 결과를 저장했다가 보정해 주어야 함
                                      sumOffset = Offset(sumOffset.dx - wDiff, sumOffset.dy - hDiff); // 2/2 위치별 수정

                                      // resize
                                      parentProvider.whSign = parentProvider.whSign + wDiff * 2; // 양쪽이므로 *2
                                      // center 이동
                                      signProvider.parentSignOffset = Offset(signProvider.parentSignOffset!.dx - wDiff,
                                          signProvider.parentSignOffset!.dy - hDiff);

                                      setState(() {});
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      width: childTouchWh,
                                      height: childTouchWh,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  // righttop touch
                                  left: parentProvider.whSign + childTouchWh - childHandleWh * 2,
                                  top: 0,
                                  width: childTouchWh,
                                  height: childTouchWh,
                                  child: GestureDetector(
                                    onTapDown: (tapDownDetails) {
                                      dev.log('righttop touch');
                                    },
                                    onPanStart: (dragUpdateDetails) {
                                      sumOffset = const Offset(0, 0);
                                    },
                                    onPanUpdate: (dragUpdateDetails) {
                                      //dev.log(
                                      //    '------${DateTime.now()} globalPosition: ${dragUpdateDetails.globalPosition}, '
                                      //    'localPosition: ${dragUpdateDetails.localPosition},delta: ${dragUpdateDetails.delta}');

                                      // 중심점으로 offset 계산
                                      Offset baseOffset = Offset(
                                          (parentProvider.whSign + childTouchWh - childHandleWh * 2), // 1/2 위치별 수정
                                          0);
                                      Offset centerOffset = Offset(
                                          (parentProvider.whSign + childTouchWh * 2 - childHandleWh * 2) / 2,
                                          (parentProvider.whSign + childTouchWh * 2 - childHandleWh * 2) / 2);
                                      Offset diffOffset = baseOffset - centerOffset;
                                      Offset newOffset = diffOffset + dragUpdateDetails.localPosition - sumOffset;
                                      Offset oldOffset = diffOffset +
                                          (dragUpdateDetails.localPosition - dragUpdateDetails.delta) -
                                          sumOffset;
                                      //dev.log('baseOffset: $baseOffset, centerOffset: $centerOffset, diffOffset: $diffOffset');
                                      //dev.log('oldOffset: $oldOffset, newOffset: $newOffset');
                                      // 회전
                                      signRadian = signRadian + (newOffset.direction - oldOffset.direction);
                                      //dev.log('signRadian: $signRadian');

                                      // line distance
                                      double diffDistance = newOffset.distance - oldOffset.distance;
                                      // 직사각형인 경우
                                      double wSquare = parentProvider.whSign;
                                      double hSquare = parentProvider.whSign;
                                      //double wDiff = diffDistance / math.sqrt(2);   // 정사각형인 경우
                                      double wDiff = math.sqrt(
                                              math.pow(wSquare, 2) / (math.pow(wSquare, 2) + math.pow(hSquare, 2))) *
                                          diffDistance;
                                      double hDiff = hSquare / wSquare * wDiff; // 늘리면 양수, 줄이면 음수
                                      //dev.log('wDiff: $wDiff, hDiff: $hDiff');

                                      // 이동한 결과를 저장했다가 보정해 주어야 함
                                      sumOffset = Offset(sumOffset.dx + wDiff, sumOffset.dy - hDiff); // 2/2 위치별 수정

                                      // resize
                                      parentProvider.whSign = parentProvider.whSign + wDiff * 2; // 양쪽이므로 *2
                                      // center 이동
                                      signProvider.parentSignOffset = Offset(signProvider.parentSignOffset!.dx - wDiff,
                                          signProvider.parentSignOffset!.dy - hDiff);

                                      setState(() {});
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      width: childTouchWh,
                                      height: childTouchWh,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  // leftbottom touch
                                  left: 0,
                                  top: parentProvider.whSign + childTouchWh - childHandleWh * 2,
                                  width: childTouchWh,
                                  height: childTouchWh,
                                  child: GestureDetector(
                                    onTapDown: (tapDownDetails) {
                                      dev.log('leftbottom touch');
                                    },
                                    onPanStart: (dragUpdateDetails) {
                                      sumOffset = const Offset(0, 0);
                                    },
                                    onPanUpdate: (dragUpdateDetails) {
                                      //dev.log(
                                      //    '------${DateTime.now()} globalPosition: ${dragUpdateDetails.globalPosition}, '
                                      //    'localPosition: ${dragUpdateDetails.localPosition},delta: ${dragUpdateDetails.delta}');

                                      // 중심점으로 offset 계산
                                      Offset baseOffset = Offset(
                                          0, // 1/2 위치별 수정
                                          (parentProvider.whSign + childTouchWh - childHandleWh * 2));
                                      Offset centerOffset = Offset(
                                          (parentProvider.whSign + childTouchWh * 2 - childHandleWh * 2) / 2,
                                          (parentProvider.whSign + childTouchWh * 2 - childHandleWh * 2) / 2);
                                      Offset diffOffset = baseOffset - centerOffset;
                                      Offset newOffset = diffOffset + dragUpdateDetails.localPosition - sumOffset;
                                      Offset oldOffset = diffOffset +
                                          (dragUpdateDetails.localPosition - dragUpdateDetails.delta) -
                                          sumOffset;
                                      //dev.log('baseOffset: $baseOffset, centerOffset: $centerOffset, diffOffset: $diffOffset');
                                      //dev.log('oldOffset: $oldOffset, newOffset: $newOffset');
                                      // 회전
                                      signRadian = signRadian + (newOffset.direction - oldOffset.direction);
                                      //dev.log('signRadian: $signRadian');

                                      // line distance
                                      double diffDistance = newOffset.distance - oldOffset.distance;
                                      // 직사각형인 경우
                                      double wSquare = parentProvider.whSign;
                                      double hSquare = parentProvider.whSign;
                                      //double wDiff = diffDistance / math.sqrt(2);   // 정사각형인 경우
                                      double wDiff = math.sqrt(
                                              math.pow(wSquare, 2) / (math.pow(wSquare, 2) + math.pow(hSquare, 2))) *
                                          diffDistance;
                                      double hDiff = hSquare / wSquare * wDiff; // 늘리면 양수, 줄이면 음수
                                      //dev.log('wDiff: $wDiff, hDiff: $hDiff');

                                      // 이동한 결과를 저장했다가 보정해 주어야 함
                                      sumOffset = Offset(sumOffset.dx - wDiff, sumOffset.dy + hDiff); // 2/2 위치별 수정

                                      // resize
                                      parentProvider.whSign = parentProvider.whSign + wDiff * 2; // 양쪽이므로 *2
                                      // center 이동
                                      signProvider.parentSignOffset = Offset(signProvider.parentSignOffset!.dx - wDiff,
                                          signProvider.parentSignOffset!.dy - hDiff);

                                      setState(() {});
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      width: childTouchWh,
                                      height: childTouchWh,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  // rightbottom touch
                                  left: parentProvider.whSign + childTouchWh - childHandleWh * 2,
                                  top: parentProvider.whSign + childTouchWh - childHandleWh * 2,
                                  width: childTouchWh,
                                  height: childTouchWh,
                                  child: GestureDetector(
                                    onTapDown: (tapDownDetails) {
                                      dev.log('rightbottom touch');
                                    },
                                    onPanStart: (dragUpdateDetails) {
                                      sumOffset = const Offset(0, 0);
                                    },
                                    onPanUpdate: (dragUpdateDetails) {
                                      //dev.log(
                                      //    '------${DateTime.now()} globalPosition: ${dragUpdateDetails.globalPosition}, '
                                      //    'localPosition: ${dragUpdateDetails.localPosition},delta: ${dragUpdateDetails.delta}');

                                      // 중심점으로 offset 계산
                                      Offset baseOffset = Offset(
                                          (parentProvider.whSign + childTouchWh - childHandleWh * 2), // 1/2 위치별 수정
                                          (parentProvider.whSign + childTouchWh - childHandleWh * 2));
                                      Offset centerOffset = Offset(
                                          (parentProvider.whSign + childTouchWh * 2 - childHandleWh * 2) / 2,
                                          (parentProvider.whSign + childTouchWh * 2 - childHandleWh * 2) / 2);
                                      Offset diffOffset = baseOffset - centerOffset;
                                      Offset newOffset = diffOffset + dragUpdateDetails.localPosition - sumOffset;
                                      Offset oldOffset = diffOffset +
                                          (dragUpdateDetails.localPosition - dragUpdateDetails.delta) -
                                          sumOffset;
                                      //dev.log('baseOffset: $baseOffset, centerOffset: $centerOffset, diffOffset: $diffOffset');
                                      //dev.log('oldOffset: $oldOffset, newOffset: $newOffset');
                                      // 회전
                                      signRadian = signRadian + (newOffset.direction - oldOffset.direction);
                                      //dev.log('signRadian: $signRadian');

                                      // line distance
                                      double diffDistance = newOffset.distance - oldOffset.distance;
                                      // 직사각형인 경우
                                      double wSquare = parentProvider.whSign;
                                      double hSquare = parentProvider.whSign;
                                      //double wDiff = diffDistance / math.sqrt(2);   // 정사각형인 경우
                                      double wDiff = math.sqrt(
                                              math.pow(wSquare, 2) / (math.pow(wSquare, 2) + math.pow(hSquare, 2))) *
                                          diffDistance;
                                      double hDiff = hSquare / wSquare * wDiff; // 늘리면 양수, 줄이면 음수
                                      //dev.log('wDiff: $wDiff, hDiff: $hDiff');

                                      // 이동한 결과를 저장했다가 보정해 주어야 함
                                      sumOffset = Offset(sumOffset.dx + wDiff, sumOffset.dy + hDiff); // 2/2 위치별 수정

                                      // resize
                                      parentProvider.whSign = parentProvider.whSign + wDiff * 2; // 양쪽이므로 *2
                                      // center 이동
                                      signProvider.parentSignOffset = Offset(signProvider.parentSignOffset!.dx - wDiff,
                                          signProvider.parentSignOffset!.dy - hDiff);

                                      setState(() {});
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      width: childTouchWh,
                                      height: childTouchWh,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      */
                    if (signProvider.parentSignFileInfoIdx != -1)
                      DragResizeRotateWidget(
                        left: signProvider.parentSignOffset!.dx -
                            childTouchWh +
                            childHandleWh,
                        top: signProvider.parentSignOffset!.dy -
                            childTouchWh +
                            childHandleWh,
                        width: parentProvider.whSign +
                            childTouchWh * 2 -
                            childHandleWh * 2,
                        height: parentProvider.whSign +
                            childTouchWh * 2 -
                            childHandleWh * 2,
                        angle: signRadian,
                        childBackground: Colors.transparent,
                        childBorderColor: Colors.white38,
                        wChild: parentProvider.whSign,
                        hChild: parentProvider.whSign,
                        whTouch: childTouchWh,
                        whHandle: childHandleWh,
                        handleColor: Colors.white60,
                        sumOffset: sumOffset,
                        overSumOffset: overSumOffset,
                        minSize: Size(
                            (parentProvider.wScreen + parentProvider.hScreen) *
                                0.5 *
                                AppConfig.SIGN_WH_MIN,
                            (parentProvider.wScreen + parentProvider.hScreen) *
                                0.5 *
                                AppConfig.SIGN_WH_MIN),
                        maxSize: Size(
                            (parentProvider.wScreen + parentProvider.hScreen) *
                                0.5 *
                                AppConfig.SIGN_WH_MAX,
                            (parentProvider.wScreen + parentProvider.hScreen) *
                                0.5 *
                                AppConfig.SIGN_WH_MAX),
                        childOnTapDown: childOnTapDown,
                        childOnTap: childOnTap,
                        childOnDragUpdate: childOnDragUpdate,
                        childOnDragEnd: childOnDragEnd,
                        touchOnTapDown: touchOnTapDown,
                        touchOnTap: touchOnTap,
                        touchOnPanUpdate: touchOnPanUpdate,
                        touchOnPanEnd: touchOnPanEnd,
                        deleteOnTap: deleteOnTap,
                        child: signProvider
                            .signFileInfoList[
                                signProvider.parentSignFileInfoIdx]
                            .image,
                      ),
                    /*
                    if (signProvider.parentSignFileInfoIdx != -1)
                      // delete icon
                      Positioned(
                        // delete icon
                        left: signProvider.parentSignOffset!.dx + parentProvider.whSign * 0.5 - childHandleWh * 1.5 * 0.5,
                        top: signProvider.parentSignOffset!.dy - childHandleWh * 3,
                        width: childHandleWh * 1.5,
                        height: childHandleWh * 1.5,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white60,
                            shape: BoxShape.circle,
                          ),
                          width: childHandleWh,
                          height: childHandleWh,
                        ),
                      ),
                    */
                  ],
                ),
              ),
              SizedBox(
                height: AppBar().preferredSize.height *
                    AppConfig.FUNCTIONBAR_HEIGHT,
                child: _chooseFunctionBar(makeProvider.makeFabEnum),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonAnimator: NoScalingAnimation(),
      floatingActionButtonLocation: ExpandableFloatLocation(),
      floatingActionButton: CustomExpandableDraggableFab(
        key: _fabGlobalKey,
        childrenCount: 5,
        onTab: _onTapFab,
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
                AppBar().preferredSize.height * AppConfig.FUNCTIONBAR_HEIGHT -
                56 -
                8 -
                2),
        distance: 100,
        // Animation distance during open and close.
        children: [
          ElevatedButton.icon(
            icon: const Icon(
              Icons.aspect_ratio,
              color: Colors.white60,
            ),
            label: Text('PARENT'.tr()),
            style: TextButton.styleFrom(
                backgroundColor: AppColors.MAKE_PARENT_FAB_BACKGROUND),
            onPressed: _fabParent,
          ),
          ElevatedButton.icon(
            icon: const Icon(
              Icons.photo_album,
              color: Colors.white60,
            ),
            label: Text('BABY'.tr()),
            style: TextButton.styleFrom(
                backgroundColor: AppColors.MAKE_BABY_FAB_BACKGROUND),
            onPressed: _fabBaby,
          ),
          ElevatedButton.icon(
            icon: const Icon(
              Icons.edit,
              color: Colors.white60,
            ),
            label: Text('CAPTION'.tr()),
            style: TextButton.styleFrom(
                backgroundColor: AppColors.MAKE_CAPTION_FAB_BACKGROUND),
            onPressed: _fabCaption,
          ),
          ElevatedButton.icon(
            icon: const Icon(
              Icons.volume_up_rounded,
              color: Colors.white60,
            ),
            label: Text('SOUND'.tr()),
            style: TextButton.styleFrom(
                backgroundColor: AppColors.MAKE_SOUND_FAB_BACKGROUND),
            onPressed: _fabSound,
          ),
          ElevatedButton.icon(
            icon: const Icon(
              Icons.open_in_browser,
              color: Colors.white60,
            ),
            label: Text('LINK'.tr()),
            style: TextButton.styleFrom(
                backgroundColor: AppColors.MAKE_LINK_FAB_BACKGROUND),
            onPressed: _fabLink,
          ),
        ],
      ),
    );
  }

  Widget _chooseFunctionBar(type) {
    switch (type) {
      case MakeFabEnum.PARENT:
        return const ParentBar();
      case MakeFabEnum.BABY:
        return const BabyBar();
      case MakeFabEnum.CAPTION:
        return const CaptionBar();
      case MakeFabEnum.SOUND:
        return const SoundBar();
      case MakeFabEnum.LINK:
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
    if (makeProvider.makeFabEnum == MakeFabEnum.PARENT &&
        parentProvider.parentBarEnum == ParentBarEnum.RESIZE) {
      // _onTapDown 이 호출되지 않은 경우, _onTapDown 에서 선택되지 않은 경우
      if (parentProvider.makeParentSizePointEnum ==
          MakeParentResizePointEnum.NONE) {
        return;
      }

      // blank 검사
      if (!BracketUtil.checkBlankArea(
          xyOffset, parentProvider.makeParentSizePointEnum, parentProvider)) {
        dev.log('\n\n### checkBlankArea return\n\n');
        return;
      }

      // bracket 간에 침범할 수 없는 영역을 순식간에 넘어갔는지 검사
      if (!BracketUtil.checkBracketCross(
          xyOffset, parentProvider.makeParentSizePointEnum, parentProvider)) {
        dev.log('\n\n### checkBracketCross return\n\n');
        return;
      }

      // shrink 허용치 검사
      Rect bracketRect = BracketUtil.calcBracketRect(
          xyOffset, parentProvider.makeParentSizePointEnum, parentProvider);
      dev.log('bracketRect: $bracketRect');
      double minArea = (parentProvider.wScreen - parentProvider.xBlank * 2) *
          (parentProvider.hScreen - parentProvider.yBlank * 2) *
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
          parentProvider.wScreen,
          parentProvider.xBlank,
          parentProvider.hScreen,
          parentProvider.yBlank,
          AppConfig.SIZE_GRID_RATIO,
          AppConfig.SIZE_GRID_RATIO,
          AppConfig.SIZE_STICKY_RATIO,
          parentProvider.makeParentSizePointEnum);
      dev.log('new xyOffset: $xyOffset');

      ////////////////////////////////////////////////////////////////////////////////
      parentProvider.xStart = xStart;
      parentProvider.yStart = yStart;
      parentProvider.xyOffset = xyOffset; // for test
      ////////////////////////////////////////////////////////////////////////////////

      // parentProvider 의 Offset 수정 --> paint 에서 사용
      BracketUtil.updateBracketArea(
          xyOffset, parentProvider.makeParentSizePointEnum, parentProvider);
    } // end if (makeProvider.parentResize) {
    ////////////////////////////////////////////////////////////////////////////////

    setState(() {});
  }

  // drag 이후에는 onTapUp 호출안됨
  void _onInteractionEnd(ScaleEndDetails scaleEndDetails) {
    dev.log('_onInteractionEnd Velocity: ${scaleEndDetails.velocity}');
    parentProvider.makeParentSizePointEnum = MakeParentResizePointEnum.NONE;
  }

  /// 변경되는 값 : xyOffset
  /// 보정되는 값 : _transformationController.value 의 xStart, yStart
  void _onTapDown(TapDownDetails tapDownDetails) async {
    // local x/y from image, global x/y from phone screen
    //dev.log('_onTapDown localPosition: ${details.localPosition}');
    dev.log(
        '_onTapDown _transformationController.value: ${_transformationController.value}');
    parentProvider.printParent();

    // for test
    dev.log('-45 * math.pi / 180: ${-45 * math.pi / 180}');
    dev.log('180 * math.pi / 180: ${180 * math.pi / 180}');
    dev.log('-180 * math.pi / 180: ${-180 * math.pi / 180}');
    dev.log('360 * math.pi / 180: ${360 * math.pi / 180}');
    dev.log('-360 * math.pi / 180: ${-360 * math.pi / 180}');

    // onDoubleTap 에서 사용
    _tapDownDetails = tapDownDetails;

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

    ////////////////////////////////////////////////////////////////////////////////
    // size 상태인 경우 bracket 이 선택되었는지 검사
    //if (makeProvider.parentResize) {
    if (makeProvider.makeFabEnum == MakeFabEnum.PARENT &&
        parentProvider.parentBarEnum == ParentBarEnum.RESIZE) {
      dev.log(
          'parentSize leftTopOffset: ${parentProvider.leftTopOffset}, rightTopOffset: ${parentProvider.rightTopOffset}, '
          'leftBottomOffset: ${parentProvider.leftBottomOffset}, rightBottomOffset: ${parentProvider.rightBottomOffset}');

      parentProvider.xyOffset = xyOffset; // for test
      MakeParentResizePointEnum makeParentSizeEnum =
          BracketUtil.findBracketArea(xyOffset, parentProvider);
      dev.log('findBracketArea makeParentSizeEnum: $makeParentSizeEnum');
      //if (makeParentSizeEnum != MakeParentSizePointEnum.NONE) {
      //  parentProvider.makeParentSizePointEnum = makeParentSizeEnum;
      //}
      parentProvider.makeParentSizePointEnum = makeParentSizeEnum;
    } // if (makeProvider.parentResize) {
    ////////////////////////////////////////////////////////////////////////////////
  }

  // drag 이후에는 호출안됨
  void _onTapUp(TapUpDetails tapUpDetails) async {
    //dev.log('_onTapUp TapUpDetails: ${tapUpDetails.localPosition}');
    parentProvider.makeParentSizePointEnum = MakeParentResizePointEnum.NONE;
  }

  /// 변경되는 값 : scale, xStart, yStart, xyOffset
  void _onDoubleTap() async {
    //dev.log('_onDoubleTap localPosition: ${_tapDownDetails.localPosition}');
    //dev.log('_transformationController.value: ${_transformationController.value}');

    // for has not been initialized
    //if (_tapDownDetails == null) {
    //  return;
    //}

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
    if (makeProvider.makeFabEnum == MakeFabEnum.PARENT &&
        parentProvider.parentBarEnum == ParentBarEnum.RESIZE) {
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

  void _onTapDelete() {
    dev.log('_onTapDelete');

    // TODO : 한개씩 지우기

    // for test
    signProvider.parentSignFileInfoIdx = -1;
    parentProvider.whSign = (parentProvider.wScreen + parentProvider.hScreen) *
        0.5 *
        AppConfig.SIGN_WH_RATIO;
    //signProvider.parentSignOffset = null;
    signRadian = 0;

    setState(() {});
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

        //parentProvider.path = '';
        parentProvider.clearParentProvider(); // path, init 같이 처리
        Navigator.pop(context, 'CANCEL');
      }
    });
  }

  // floatKeyState.toggle() 을 사용하면 자동으로 onTab 이  호출됨
  void _onTapFab() {
    dev.log('_onTapFab');
  }

  void _fabParent() {
    dev.log('_fabParent');

    _fabGlobalKey.currentState?.toggle();

    // TODO : Parent 가져오기 실행
    // 이미 Parent 상태여도 가져오기 실행
    // 취소하면 FB 는 이전 것으로 유지

    makeProvider.setMakeFabEnum(MakeFabEnum.PARENT);
  }

  void _fabBaby() {
    dev.log('_fabBaby');

    _fabGlobalKey.currentState?.toggle();

    // TODO : Baby 가져오기 실행
    // 이미 Baby 상태여도 가져오기 실행
    // 취소하면 FB 는 이전 것으로 유지

    makeProvider.setMakeFabEnum(MakeFabEnum.BABY);
  }

  void _fabCaption() {
    dev.log('_fabCaption');

    _fabGlobalKey.currentState?.toggle();

    // TODO : caption 추가, 키보드 올리기
    // FB 는 Caption 으로 변경

    makeProvider.setMakeFabEnum(MakeFabEnum.CAPTION);
  }

  void _fabSound() {
    dev.log('_fabSound');

    _fabGlobalKey.currentState?.toggle();

    // TODO : Function bar 만 이동

    makeProvider.setMakeFabEnum(MakeFabEnum.SOUND);
  }

  void _fabLink() {
    dev.log('_fabLink');

    _fabGlobalKey.currentState?.toggle();

    // TODO : Function bar 만 이동

    makeProvider.setMakeFabEnum(MakeFabEnum.LINK);
  }

  ////////////////////////////////////////////////////////////////////////////////
  // Event END //
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // child callback START
  ////////////////////////////////////////////////////////////////////////////////
  void childOnTapDown(tapDownDetails) {}

  void childOnTap() {}

  /// WARNING
  /// globalPostion 과 localPosition 값이 동일한 버그 발견
  /// widget 의 좌표가 아니라 포인터의 좌표를 반환하는 문제로 인해 사용안함
  void childOnDragUpdate(dragUpdateDetails) {
    /*
    dev.log('# childOnDragUpdate dragUpdateDetails: $dragUpdateDetails');

    Offset globalOffset = dragUpdateDetails.globalPosition;
    dev.log('childOnDragUpdate globalOffset: $globalOffset');
    dev.log('childOnDragUpdate localPosition: ${dragUpdateDetails.localPosition}');
    Rect validRect = parentProvider.calcValidRect();
    dev.log('childOnDragUpdate validRect: $validRect');

    if (globalOffset.dy < validRect.top) {
      signProvider.parentSignOffset =
          Offset(globalOffset.dx, validRect.top);
      dev.log('childOnDragEnd childOnDragUpdate: ${signProvider.parentSignOffset}');
      setState(() {});
      return;
    }
    */
  }

  void childOnDragEnd(draggableDetails, wChild, hChild, angle) {
    dev.log('childOnDragEnd offset: ${draggableDetails.offset}');

    // global position
    Offset dragOffset = draggableDetails.offset;
    // global position
    // wScreen/hScreen, htopBlank/hBottomBlank, xBlank/yBlank 까지 계산한 값
    Rect validRect = parentProvider.calcValidRect();
    dev.log('childOnDragEnd validRect: $validRect');

    double xNew = dragOffset.dx;
    double yNew = dragOffset.dy - parentProvider.hTopBlank;

    // 회전한 경우를 감안하여 보정
    Size rotateSize = InfoUtil.calcRotateSize(wChild, hChild, angle);
    double wChildDiff = (rotateSize.width - wChild) * 0.5;
    double hChildDiff = (rotateSize.height - hChild) * 0.5;

    if (dragOffset.dy - hChildDiff < validRect.top) {
      dev.log('(dragOffset.dy - hChildDiff < validRect.top)');
      yNew = validRect.top - parentProvider.hTopBlank + hChildDiff;
    }
    if (dragOffset.dx - wChildDiff < validRect.left) {
      dev.log('(dragOffset.dx - wChildDiff < validRect.left)');
      xNew = validRect.left + wChildDiff;
    }
    if (dragOffset.dx + wChild + wChildDiff > validRect.right) {
      dev.log('(dragOffset.dy + parentProvider.wChild > validRect.right)');
      xNew = validRect.right - wChild - wChildDiff;
    }
    if (dragOffset.dy + hChild + hChildDiff > validRect.bottom) {
      dev.log('(dragOffset.dy + parentProvider.hChild > validRect.bottom)');
      yNew = validRect.bottom - parentProvider.hTopBlank - hChild - hChildDiff;
    }

    signProvider.parentSignOffset = Offset(xNew, yNew);
    dev.log('childOnDragEnd signOffset: ${signProvider.parentSignOffset}');
    setState(() {});

    SharedPreferences.getInstance().then((prefs) {
      prefs.setDouble(
          AppConstant.PREFS_PARENTSIGNOFFSET_X, draggableDetails.offset.dx);
      prefs.setDouble(AppConstant.PREFS_PARENTSIGNOFFSET_Y,
          draggableDetails.offset.dy - parentProvider.hTopBlank);
    });
  }

  void touchOnTapDown(tapDownDetails) {}

  void touchOnTap() {}

  void touchOnPanUpdate(double angle, double wChild, double hChild,
      double wDiff, double hDiff, Offset sumOffset, Offset overSumOffset) {
    signRadian = angle;

    parentProvider.whSign = wChild;
    parentProvider.whSign = hChild;

    signProvider.parentSignOffset = Offset(
        signProvider.parentSignOffset!.dx - wDiff,
        signProvider.parentSignOffset!.dy - hDiff);

    this.sumOffset = sumOffset;
    this.overSumOffset = overSumOffset;

    setState(() {});
  }

  void touchOnPanEnd() {
    setState(() {});
  }

  void deleteOnTap() {}
////////////////////////////////////////////////////////////////////////////////
// child callback END
////////////////////////////////////////////////////////////////////////////////
}
