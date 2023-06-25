import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/config_app.dart';
import '../config/enum_app.dart';
import '../painter/painter_makeresize.dart';
import '../util/util_bracket.dart';
import '../util/util_info.dart';

class ResizeBracketWidget extends StatefulWidget {
  //const ResizeBracket({super.key});

  ////////////////////////////////////////////////////////////////////////////////
  // // 전체 좌표
  // Rect rect;
  //
  // // 터치 영역 크기
  // double whTouch;
  //
  // // 핸들 크기
  // double whHandle;
  // Color handleColor;
  //
  // // 최소/최대 크기
  // Size? maxSize;
  // Size? minSize;
  //
  // // 회전 시 sticky 각도
  // // 0 으로 하면 sticky 와 angleGuide 하지 않음
  // double resizeSticky;
  //
  // dynamic notifyAlarm;
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  double wScreen;
  double hScreen;

  int wImage;
  int hImage;

  double inScale;

  double xBlank;
  double yBlank;

  double xStart;
  double yStart;

  double scale;

  Offset leftTopOffset;
  Offset rightTopOffset;
  Offset leftBottomOffset;
  Offset rightBottomOffset;

  dynamic callbackResize;

  ////////////////////////////////////////////////////////////////////////////////

  ResizeBracketWidget({
    super.key,
    // required this.rect,
    // required this.whTouch,
    // required this.whHandle,
    // required this.handleColor,
    // this.maxSize,
    // this.minSize,
    // required this.resizeSticky,
    // this.notifyAlarm,
    required this.wScreen,
    required this.hScreen,
    required this.wImage,
    required this.hImage,
    required this.inScale,
    required this.xBlank,
    required this.yBlank,
    required this.xStart,
    required this.yStart,
    required this.scale,
    required this.leftTopOffset,
    required this.rightTopOffset,
    required this.leftBottomOffset,
    required this.rightBottomOffset,
    required this.callbackResize,
  });

  @override
  State<ResizeBracketWidget> createState() => ResizeBracketWidgetState();
}

class ResizeBracketWidgetState extends State<ResizeBracketWidget> {
  ////////////////////////////////////////////////////////////////////////////////
  bool fMaxMin = false;

  MakeParentResizePointEnum makeParentSizePointEnum =
      MakeParentResizePointEnum.NONE;

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# ResizeBracketWidget initState START');
    super.initState();

    dev.log('# ResizeBracketWidget initState END');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# ResizeBracketWidget build START');

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTap: () {},
      onPanStart: (dragUpdateDetails) {},
      onPanEnd: _onPanEnd,
      onPanUpdate: _onPanUpdate,
      child: CustomPaint(
        // size 안 정해도 동작함
        painter: MakeResizePainter(
            wScreen: widget.wScreen,
            hScreen: widget.hScreen,
            wImage: widget.wImage,
            hImage: widget.hImage,
            inScale: widget.inScale,
            xBlank: widget.xBlank,
            yBlank: widget.yBlank,
            xStart: widget.xStart,
            yStart: widget.yStart,
            scale: widget.scale,
            leftTopOffset: widget.leftTopOffset,
            rightTopOffset: widget.rightTopOffset,
            leftBottomOffset: widget.leftBottomOffset,
            rightBottomOffset: widget.rightBottomOffset),
      ),
    );

    ////////////////////////////////////////////////////////////////////////////////
  }

  ////////////////////////////////////////////////////////////////////////////////
  // Event START
  ////////////////////////////////////////////////////////////////////////////////

  void _onTapDown(TapDownDetails tapDownDetails) async {
    dev.log('# ResizeBracketWidget _onTapDown');
    // local x/y from image, global x/y from phone screen
    //dev.log('_onTapDown localPosition: ${details.localPosition}');

    ////////////////////////////////////////////////////////////////////////////////
    Offset xyOffset = tapDownDetails.localPosition;
    dev.log(' xyOffset: $xyOffset');

    makeParentSizePointEnum = BracketUtil.findBracketArea(
        xyOffset,
        widget.leftTopOffset,
        widget.rightTopOffset,
        widget.leftBottomOffset,
        widget.rightBottomOffset,
        (widget.wScreen * AppConfig.SIZE_BRACKET_LENGTH));
    ////////////////////////////////////////////////////////////////////////////////
  }

  void _onTapUp(TapUpDetails tapUpDetails) {
    //dev.log('# ResizeBracketWidget _onTapUp TapUpDetails: ${tapUpDetails.localPosition}');
    makeParentSizePointEnum = MakeParentResizePointEnum.NONE;
  }

  void _onPanEnd(dragEndDetails) {
    widget.callbackResize(widget.leftTopOffset, widget.rightTopOffset,
        widget.leftBottomOffset, widget.rightBottomOffset);
  }

  void _onPanUpdate(dragUpdateDetails) {
    ////////////////////////////////////////////////////////////////////////////////
    Offset xyOffset = dragUpdateDetails.localPosition;
    dev.log('# ResizeBracketWidget _onPanUpdate xyOffset: $xyOffset');
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // _onTapDown 이 호출되지 않은 경우, _onTapDown 에서 선택되지 않은 경우
    if (makeParentSizePointEnum == MakeParentResizePointEnum.NONE) {
      return;
    }

    // blank 검사
    if (!BracketUtil.checkBlankArea(xyOffset, makeParentSizePointEnum,
        widget.wScreen, widget.hScreen, widget.xBlank, widget.yBlank)) {
      dev.log('\n\n### checkBlankArea return\n\n');
      return;
    }

    // bracket 간에 침범할 수 없는 영역을 순식간에 넘어갔는지 검사
    if (!BracketUtil.checkBracketCross(
        xyOffset,
        makeParentSizePointEnum,
        widget.leftTopOffset,
        widget.rightTopOffset,
        widget.leftBottomOffset,
        widget.rightBottomOffset)) {
      dev.log('\n\n### checkBracketCross return\n\n');
      return;
    }

    // shrink 허용치 검사
    Rect bracketRect = BracketUtil.calcBracketRect(
        xyOffset,
        makeParentSizePointEnum,
        widget.leftTopOffset,
        widget.rightTopOffset,
        widget.leftBottomOffset,
        widget.rightBottomOffset);
    dev.log('bracketRect: $bracketRect');
    double minArea = (widget.wScreen - widget.xBlank * 2) *
        (widget.hScreen - widget.yBlank * 2) *
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
        widget.wScreen,
        widget.xBlank,
        widget.hScreen,
        widget.yBlank,
        AppConfig.SIZE_GRID_RATIO,
        AppConfig.SIZE_GRID_RATIO,
        AppConfig.SIZE_STICKY_RATIO,
        makeParentSizePointEnum);
    dev.log('new xyOffset: $xyOffset');

    ////////////////////////////////////////////////////////////////////////////////
    // parentProvider.xStart = xStart;
    // parentProvider.yStart = yStart;
    // parentProvider.xyOffset = xyOffset; // for test
    ////////////////////////////////////////////////////////////////////////////////

    // parentProvider 의 Offset 수정 --> paint 에서 사용
    List<Offset> offsetList = BracketUtil.updateBracketArea(
        xyOffset,
        makeParentSizePointEnum,
        widget.leftTopOffset,
        widget.rightTopOffset,
        widget.leftBottomOffset,
        widget.rightBottomOffset);
    widget.leftTopOffset = offsetList[0];
    widget.rightTopOffset = offsetList[1];
    widget.leftBottomOffset = offsetList[2];
    widget.rightBottomOffset = offsetList[3];
    ////////////////////////////////////////////////////////////////////////////////

    setState(() {});
  }
////////////////////////////////////////////////////////////////////////////////
// Event END
////////////////////////////////////////////////////////////////////////////////
}
