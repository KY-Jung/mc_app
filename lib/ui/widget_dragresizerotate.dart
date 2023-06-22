import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../util/util_info.dart';

class DragResizeRotateWidget extends StatefulWidget {
  //const DragResizeRotateWidget({super.key});

  ////////////////////////////////////////////////////////////////////////////////
  // 전체 좌표
  double left;
  double top;
  double width;
  double height;

  // 전체 각도 (radian)
  double angle;

  // 본체
  Widget child;

  // 배경색
  Color childBackground;

  // 본체 테두리
  Color childBorderColor;

  // 본체 크기
  double wChild;
  double hChild;

  // 터치 영역 크기
  double whTouch;

  // 핸들 크기
  double whHandle;
  Color handleColor;

  // 최소/최대 크기
  Size maxSize;
  Size minSize;
  double angleSticky;

  // resize 오차 보정
  Offset sizeSumOffset;
  // max/min 오차 보정
  Offset overSumOffset;
  // angle 오차 보정
  double angleSum;

  // child 의 drag 가 끝난 경우
  dynamic childOnTapDown;
  dynamic childOnTap;
  dynamic childOnDragUpdate;
  dynamic childOnDragEnd;
  dynamic touchOnTapDown;
  dynamic touchOnTap;
  dynamic touchOnPanUpdate;
  dynamic touchOnPanEnd;
  dynamic deleteOnTap;
  dynamic notifyAngle;
  dynamic notifyAlarm;
  ////////////////////////////////////////////////////////////////////////////////

  DragResizeRotateWidget({
    super.key,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.angle,
    required this.childBackground,
    required this.childBorderColor,
    required this.wChild,
    required this.hChild,
    required this.whTouch,
    required this.whHandle,
    required this.handleColor,
    required this.maxSize,
    required this.minSize,
    required this.angleSticky,
    required this.sizeSumOffset,
    required this.overSumOffset,
    required this.angleSum,
    this.childOnTapDown,
    this.childOnTap,
    this.childOnDragUpdate,
    this.childOnDragEnd,
    this.touchOnTapDown,
    this.touchOnTap,
    this.touchOnPanUpdate,
    this.touchOnPanEnd,
    this.deleteOnTap,
    this.notifyAngle,
    this.notifyAlarm,
    required this.child,
  });

  @override
  State<DragResizeRotateWidget> createState() => DragResizeRotateWidgetState();

////////////////////////////////////////////////////////////////////////////////
// TODO : handle/touch hide, max border color 초기화
////////////////////////////////////////////////////////////////////////////////
}

class DragResizeRotateWidgetState extends State<DragResizeRotateWidget> {
  ////////////////////////////////////////////////////////////////////////////////
  bool fMaxMin = false;
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# DragResizeRotateWidgetState initState START');
    super.initState();

    dev.log('# DragResizeRotateWidgetState initState END');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# DragResizeRotateWidgetState build START');

    return Positioned(
      left: widget.left,
      top: widget.top,
      width: widget.width,
      height: widget.height,
      child: Transform.rotate(
        angle: widget.angle,
        child: Container(
          //color: Colors.green[100],
          color: Colors.transparent,
          child: Stack(
            children: <Widget>[
              Positioned(
                left: widget.whTouch - widget.whHandle,
                top: widget.whTouch - widget.whHandle,
                width: widget.wChild,
                height: widget.hChild,
                child: Draggable(
                  feedback: SizedBox(
                    width: widget.wChild, // 웬지 drag 중에는 Pogistioned 크기가 적용되지 않음
                    height: widget.hChild,
                    child: Transform.rotate(
                      angle: widget.angle,
                      child: Container(
                          decoration: BoxDecoration(
                              color: widget.childBackground,
                              border: Border.all(
                                  color: widget.childBorderColor, width: 2)),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: widget.child,
                          )),
                    ),
                  ),
                  childWhenDragging: SizedBox(
                    width: widget.wChild,
                    height: widget.hChild,
                    child: Opacity(
                      opacity: 0.4,
                      child: widget.child,
                    ),
                  ),
                  onDragUpdate: (dragUpdateDetails) {
                    // onDragEnd 에서 모두 처리

                    /// globalPostion 과 localPosition 값이 동일한 버그 발견
                    /// widget 의 좌표가 아니라 포인터의 좌표를 반환하는 문제로 인해 사용안함
                    widget.childOnDragUpdate(dragUpdateDetails);
                  },
                  onDragEnd: (draggableDetails) {
                    // only global position
                    widget.childOnDragEnd(draggableDetails, widget.wChild,
                        widget.hChild, widget.angle);
                  },
                  child: GestureDetector(
                    onTapDown: (tapDownDetails) {
                      dev.log('childOnTapDownn');
                      widget.childOnTapDown(tapDownDetails);
                    },
                    onTap: () {
                      dev.log('childOnTap');
                      widget.childOnTap();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: widget.childBackground,
                          border: Border.all(
                              color: fMaxMin
                                  ? Colors.deepOrangeAccent
                                  : widget.childBorderColor,
                              width: 2)),
                      child:
                          FittedBox(fit: BoxFit.contain, child: widget.child),
                    ),
                  ),
                ),
              ),
              Positioned(
                // topleft handle
                left: widget.whTouch - widget.whHandle * 1.5,
                top: widget.whTouch - widget.whHandle * 1.5,
                width: widget.whHandle,
                height: widget.whHandle,
                child: Container(
                  color: widget.handleColor,
                  width: widget.whHandle,
                  height: widget.whHandle,
                ),
              ),
              Positioned(
                // topright handle
                left: widget.wChild + widget.whTouch - widget.whHandle * 1.5,
                top: widget.whTouch - widget.whHandle * 1.5,
                width: widget.whHandle,
                height: widget.whHandle,
                child: Container(
                  color: widget.handleColor,
                  width: widget.whHandle,
                  height: widget.whHandle,
                ),
              ),
              Positioned(
                // tbottomleft handle
                left: widget.whTouch - widget.whHandle * 1.5,
                top: widget.hChild + widget.whTouch - widget.whHandle * 1.5,
                width: widget.whHandle,
                height: widget.whHandle,
                child: Container(
                  color: widget.handleColor,
                  width: widget.whHandle,
                  height: widget.whHandle,
                ),
              ),
              Positioned(
                // bottomright handle
                left: widget.wChild + widget.whTouch - widget.whHandle * 1.5,
                top: widget.hChild + widget.whTouch - widget.whHandle * 1.5,
                width: widget.whHandle,
                height: widget.whHandle,
                child: Container(
                  color: widget.handleColor,
                  width: widget.whHandle,
                  height: widget.whHandle,
                ),
              ),
              Positioned(
                left: widget.whTouch +
                    (widget.wChild - widget.whHandle * 2) * 0.5 -
                    widget.whHandle * 1.5 * 0.5,
                top: widget.whTouch - widget.whHandle * 1.5 * 2,
                width: widget.whHandle * 1.5,
                height: widget.whHandle * 1.5,
                child: GestureDetector(
                  onTap: () {
                    dev.log('delete touch onTap');
                    widget.deleteOnTap();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.childBorderColor,
                      shape: BoxShape.circle,
                    ),
                    width: widget.whHandle,
                    height: widget.whHandle,
                    //child: SvgPicture.asset('assets/svg/close_black_24dp.svg', fit: BoxFit.cover),
                    child: const Icon(Icons.delete_forever),
                  ),
                ),
              ),
              Positioned(
                // bottomright touch
                left: widget.wChild + widget.whTouch - widget.whHandle * 2,
                top: widget.hChild + widget.whTouch - widget.whHandle * 2,
                width: widget.whTouch,
                height: widget.whTouch,
                child: GestureDetector(
                  onTapDown: (tapDownDetails) {
                    dev.log('bottomright touch onTapDown');
                    widget.touchOnTapDown(tapDownDetails);
                  },
                  onTap: () {
                    dev.log('bottomright touch onTap');
                    widget.touchOnTap();
                  },
                  onPanStart: (dragUpdateDetails) {
                    // 시작할때 하므로, makepage 에서는 초기화 하지 않음
                    widget.sizeSumOffset = const Offset(0, 0);
                    widget.overSumOffset = const Offset(0, 0);
                    widget.angleSum = 0;
                  },
                  onPanEnd: (dragEndDetails) {
                    fMaxMin = false;
                    widget.touchOnPanEnd();
                  },
                  onPanUpdate: (dragUpdateDetails) {
                    handleOnPanUpdate(dragUpdateDetails, Alignment.bottomRight);
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      //color: Colors.lightGreenAccent,
                      shape: BoxShape.circle,
                    ),
                    width: widget.whTouch,
                    height: widget.whTouch,
                  ),
                ),
              ),
              Positioned(
                // bottomleft touch
                left: 0,
                top: widget.hChild + widget.whTouch - widget.whHandle * 2,
                width: widget.whTouch,
                height: widget.whTouch,
                child: GestureDetector(
                  onTapDown: (tapDownDetails) {
                    dev.log('bottomleft touch onTapDown');
                    widget.touchOnTapDown(tapDownDetails);
                  },
                  onTap: () {
                    dev.log('bottomleft touch onTap');
                    widget.touchOnTap();
                  },
                  onPanStart: (dragUpdateDetails) {
                    // 시작할때 하므로, makepage 에서는 초기화 하지 않음
                    widget.sizeSumOffset = const Offset(0, 0);
                    widget.overSumOffset = const Offset(0, 0);
                    widget.angleSum = 0;
                  },
                  onPanEnd: (dragEndDetails) {
                    fMaxMin = false;
                    widget.touchOnPanEnd();
                  },
                  onPanUpdate: (dragUpdateDetails) {
                    handleOnPanUpdate(dragUpdateDetails, Alignment.bottomLeft);
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      //color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    width: widget.whTouch,
                    height: widget.whTouch,
                  ),
                ),
              ),
              Positioned(
                // topright touch
                left: widget.wChild + widget.whTouch - widget.whHandle * 2,
                top: 0,
                width: widget.whTouch,
                height: widget.whTouch,
                child: GestureDetector(
                  onTapDown: (tapDownDetails) {
                    dev.log('topright touch onTapDown');
                    widget.touchOnTapDown(tapDownDetails);
                  },
                  onTap: () {
                    dev.log('topright touch onTap');
                    widget.touchOnTap();
                  },
                  onPanStart: (dragUpdateDetails) {
                    // 시작할때 하므로, makepage 에서는 초기화 하지 않음
                    widget.sizeSumOffset = const Offset(0, 0);
                    widget.overSumOffset = const Offset(0, 0);
                    widget.angleSum = 0;
                  },
                  onPanEnd: (dragEndDetails) {
                    fMaxMin = false;
                    widget.touchOnPanEnd();
                  },
                  onPanUpdate: (dragUpdateDetails) {
                    handleOnPanUpdate(dragUpdateDetails, Alignment.topRight);
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      //color: Colors.yellow,
                      shape: BoxShape.circle,
                    ),
                    width: widget.whTouch,
                    height: widget.whTouch,
                  ),
                ),
              ),
              Positioned(
                // topleft touch
                left: 0,
                top: 0,
                width: widget.whTouch,
                height: widget.whTouch,
                child: GestureDetector(
                  onTapDown: (tapDownDetails) {
                    dev.log('topleft touch onTapDown');
                    widget.touchOnTapDown(tapDownDetails);
                  },
                  onTap: () {
                    dev.log('topleft touch onTap');
                    widget.touchOnTap();
                  },
                  onPanStart: (dragUpdateDetails) {
                    // 시작할때 하므로, makepage 에서는 초기화 하지 않음
                    widget.sizeSumOffset = const Offset(0, 0);
                    widget.overSumOffset = const Offset(0, 0);
                    widget.angleSum = 0;
                  },
                  onPanEnd: (dragEndDetails) {
                    fMaxMin = false;
                    widget.touchOnPanEnd();
                  },
                  onPanUpdate: (dragUpdateDetails) {
                    /*
                    //dev.log(
                    //    '------${DateTime.now()} globalPosition: ${dragUpdateDetails.globalPosition}, '
                    //    'localPosition: ${dragUpdateDetails.localPosition},delta: ${dragUpdateDetails.delta}');

                    ////////////////////////////////////////////////////////////////////////////////
                    // 중심점으로 offset 계산

                    Offset baseOffset = const Offset(
                        0, // 1/2 위치별 수정
                        0);
                    Offset centerOffset = Offset((widget.wChild + widget.whTouch * 2 - widget.whHandle * 2) / 2,
                        (widget.hChild + widget.whTouch * 2 - widget.whHandle * 2) / 2);
                    Offset diffOffset = baseOffset - centerOffset;
                    Offset newOffset = diffOffset + dragUpdateDetails.localPosition - widget.moveSumOffset;
                    Offset oldOffset =
                        diffOffset + (dragUpdateDetails.localPosition - dragUpdateDetails.delta) - widget.moveSumOffset;
                    //dev.log('baseOffset: $baseOffset, centerOffset: $centerOffset, diffOffset: $diffOffset');
                    //dev.log('oldOffset: $oldOffset, newOffset: $newOffset');
                    // 회전
                    widget.angle = widget.angle + (newOffset.direction - oldOffset.direction);
                    //dev.log('signRadian: $signRadian');
                    ////////////////////////////////////////////////////////////////////////////////

                    ////////////////////////////////////////////////////////////////////////////////
                    // line distance

                    double diffDistance = newOffset.distance - oldOffset.distance;
                    // 직사각형인 경우
                    double wSquare = widget.wChild;
                    double hSquare = widget.hChild;
                    //double wDiff = diffDistance / math.sqrt(2);   // 정사각형인 경우
                    double wDiff =
                        math.sqrt(math.pow(wSquare, 2) / (math.pow(wSquare, 2) + math.pow(hSquare, 2))) * diffDistance;
                    double hDiff = hSquare / wSquare * wDiff; // 늘리면 양수, 줄이면 음수
                    //dev.log('wDiff: $wDiff, hDiff: $hDiff');
                    ////////////////////////////////////////////////////////////////////////////////

                    ////////////////////////////////////////////////////////////////////////////////
                    // 최대/최소

                    //dev.log('---${DateTime.now()} wDiff: $wDiff, hDiff: $hDiff');
                    // 비율을 사용하므로 w/h 하나만 해도 됨
                    if ((widget.wChild + widget.overSumOffset.dx + wDiff * 2) > widget.maxSize.width) {
                      // double diffFit = 0.5 * (widget.maxSize.width - widget.wChild - widget.overSumOffset.dx);
                      // dev.log('max wDiff: $wDiff, diffFit: $diffFit');
                      widget.overSumOffset = Offset(widget.overSumOffset.dx + wDiff, widget.overSumOffset.dy);
                      wDiff = 0;
                    } else if ((widget.wChild + widget.overSumOffset.dx + wDiff * 2) < widget.minSize.width) {
                      // double diffFit = 0.5 * (widget.minSize.width - widget.wChild - widget.overSumOffset.dx);
                      // dev.log('min wDiff: $wDiff, diffFit: $diffFit');
                      widget.overSumOffset = Offset(widget.overSumOffset.dx + wDiff, widget.overSumOffset.dy);
                      wDiff = 0;
                    } else {
                      //dev.log('wDiff minus: ${widget.overSumOffset}');
                      wDiff = widget.overSumOffset.dx + wDiff;
                      widget.overSumOffset = Offset(0, widget.overSumOffset.dy);
                    }
                    if ((widget.hChild + widget.overSumOffset.dy + hDiff * 2) > widget.maxSize.height) {
                      // double diffFit = 0.5 * (widget.maxSize.height - widget.hChild - widget.overSumOffset.dy);
                      // dev.log('max hDiff: $hDiff, diffFit: $diffFit');
                      widget.overSumOffset = Offset(widget.overSumOffset.dx, widget.overSumOffset.dy + hDiff);
                      hDiff = 0;
                    } else if ((widget.hChild + widget.overSumOffset.dy + hDiff * 2) < widget.minSize.height) {
                      // double diffFit = 0.5 * (widget.minSize.height - widget.hChild - widget.overSumOffset.dy);
                      // dev.log('min hDiff: $hDiff, diffFit: $diffFit');
                      widget.overSumOffset = Offset(widget.overSumOffset.dx, widget.overSumOffset.dy + hDiff);
                      hDiff = 0;
                    } else {
                      //dev.log('hDiff minus: ${widget.overSumOffset}');
                      hDiff = widget.overSumOffset.dy + hDiff;
                      widget.overSumOffset = Offset(widget.overSumOffset.dx, 0);
                    }
                    ////////////////////////////////////////////////////////////////////////////////

                    ////////////////////////////////////////////////////////////////////////////////
                    // 반영

                    // 크기가 변경되므로, 포인터가 이동한 결과를 저장했다가 보정해 주어야 함
                    widget.moveSumOffset = Offset(widget.moveSumOffset.dx - wDiff, widget.moveSumOffset.dy - hDiff); // 2/2 위치별 수정

                    // resize
                    //parentProvider.whSign = parentProvider.whSign + wDiff * 2; // 양쪽이므로 *2
                    widget.wChild = widget.wChild + wDiff * 2; // 양쪽이므로 *2
                    widget.hChild = widget.hChild + hDiff * 2; // 양쪽이므로 *2
                    // center 이동
                    //signProvider.parentSignOffset = Offset(signProvider.parentSignOffset!.dx - wDiff,
                    //    signProvider.parentSignOffset!.dy - hDiff);

                    widget.touchOnPanUpdate(widget.angle, widget.wChild, widget.hChild, wDiff, hDiff, widget.moveSumOffset, widget.overSumOffset);
                    ////////////////////////////////////////////////////////////////////////////////
                    */
                    handleOnPanUpdate(dragUpdateDetails, Alignment.topLeft);
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      //color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    width: widget.whTouch,
                    height: widget.whTouch,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    ////////////////////////////////////////////////////////////////////////////////
  }

  void handleOnPanUpdate(dragUpdateDetails, position) {
    //dev.log(
    //    '------${DateTime.now()} globalPosition: ${dragUpdateDetails.globalPosition}, '
    //    'localPosition: ${dragUpdateDetails.localPosition},delta: ${dragUpdateDetails.delta}');

    ////////////////////////////////////////////////////////////////////////////////
    double baseOffsetXPosition = 0;
    double baseOffsetYPosition = 0;
    switch (position) {
      case Alignment.topLeft:
        baseOffsetXPosition = 0;
        baseOffsetYPosition = 0;
        break;
      case Alignment.topRight:
        baseOffsetXPosition =
            (widget.wChild + widget.whTouch - widget.whHandle * 2);
        baseOffsetYPosition = 0;
        break;
      case Alignment.bottomLeft:
        baseOffsetXPosition = 0;
        baseOffsetYPosition =
            (widget.hChild + widget.whTouch - widget.whHandle * 2);
        break;
      case Alignment.bottomRight:
        baseOffsetXPosition =
            (widget.wChild + widget.whTouch - widget.whHandle * 2);
        baseOffsetYPosition =
            (widget.hChild + widget.whTouch - widget.whHandle * 2);
        break;
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // 중심점으로 offset 계산

    Offset baseOffset = Offset(
        baseOffsetXPosition, // 1/2 위치별 수정
        baseOffsetYPosition);
    Offset centerOffset = Offset(
        (widget.wChild + widget.whTouch * 2 - widget.whHandle * 2) / 2,
        (widget.hChild + widget.whTouch * 2 - widget.whHandle * 2) / 2);
    Offset diffOffset = baseOffset - centerOffset;
    Offset newOffset =
        diffOffset + dragUpdateDetails.localPosition - widget.sizeSumOffset;
    Offset oldOffset = diffOffset +
        (dragUpdateDetails.localPosition - dragUpdateDetails.delta) -
        widget.sizeSumOffset;
    //dev.log('baseOffset: $baseOffset, centerOffset: $centerOffset, diffOffset: $diffOffset');
    //dev.log('oldOffset: $oldOffset, newOffset: $newOffset');
    // 회전
    widget.angle = widget.angle + (newOffset.direction - oldOffset.direction);
    dev.log('widget.angle: ${widget.angle}');
    //dev.log('newOffset.direction: ${newOffset.direction}');
    //dev.log('oldOffset.direction: ${oldOffset.direction}');
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // angle 조정

    //double degree = InfoUtil.radianToDegree(widget.angle);
    double degreeNew = InfoUtil.radianToDegree2(widget.angle);
    //dev.log('--- degree: $degree');
    // double degreeNew = 0;
    // if (degree < 0) {
    //   degreeNew = 360 - degree.abs();
    // } else {
    //   degreeNew = degree;
    // }
    //dev.log('degreeNew: $degreeNew');
    //dev.log('angleSum: ${widget.angleSum}');
    degreeNew -= widget.angleSum;
    widget.angleSum = 0;
    degreeNew = degreeNew % 360;
    dev.log('degreeNew: $degreeNew');

    if (degreeNew < widget.angleSticky) {
      widget.angleSum = 0 - degreeNew;
      degreeNew = 0;
      //Vibration.vibrate();
      dev.log('~~~0 degreeNew: $degreeNew, angleSum: ${widget.angleSum}');
    } else if (degreeNew > (360 - widget.angleSticky)) {
      widget.angleSum = 360 - degreeNew;
      degreeNew = 0;
      //Vibration.vibrate();
      dev.log('~~~360 degreeNew: $degreeNew, angleSum: ${widget.angleSum}');
    } else if (degreeNew > (45 - widget.angleSticky) &&
        degreeNew < (45 + widget.angleSticky)) {
      widget.angleSum = 45 - degreeNew;
      degreeNew = 45;
      //Vibration.vibrate();
      dev.log('~~~45 degreeNew: $degreeNew, angleSum: ${widget.angleSum}');
    } else if (degreeNew > (90 - widget.angleSticky) &&
        degreeNew < (90 + widget.angleSticky)) {
      widget.angleSum = 90 - degreeNew;
      degreeNew = 90;
      //Vibration.vibrate();
      dev.log('~~~90 degreeNew: $degreeNew, angleSum: ${widget.angleSum}');
    } else if (degreeNew > (135 - widget.angleSticky) &&
        degreeNew < (135 + widget.angleSticky)) {
      widget.angleSum = 135 - degreeNew;
      degreeNew = 135;
      //Vibration.vibrate();
      dev.log('~~~135 degreeNew: $degreeNew, angleSum: ${widget.angleSum}');
    } else if (degreeNew > (180 - widget.angleSticky) &&
        degreeNew < (180 + widget.angleSticky)) {
      widget.angleSum = 180 - degreeNew;
      degreeNew = 180;
      //Vibration.vibrate();
      dev.log('~~~180 degreeNew: $degreeNew, angleSum: ${widget.angleSum}');
    } else if (degreeNew > (225 - widget.angleSticky) &&
        degreeNew < (225 + widget.angleSticky)) {
      widget.angleSum = 225 - degreeNew;
      degreeNew = 225;
      //Vibration.vibrate();
      dev.log('~~~225 degreeNew: $degreeNew, angleSum: ${widget.angleSum}');
    } else if (degreeNew > (270 - widget.angleSticky) &&
        degreeNew < (270 + widget.angleSticky)) {
      widget.angleSum = 270 - degreeNew;
      degreeNew = 270;
      //Vibration.vibrate();
      dev.log('~~~270 degreeNew: $degreeNew, angleSum: ${widget.angleSum}');
    } else if (degreeNew > (315 - widget.angleSticky) &&
        degreeNew < (315 + widget.angleSticky)) {
      widget.angleSum = 315 - degreeNew;
      degreeNew = 315;
      //Vibration.vibrate();
      dev.log('~~~315 degreeNew: $degreeNew, angleSum: ${widget.angleSum}');
    }
    widget.angle = InfoUtil.degreeToRadian(degreeNew);
    //double angle4 = InfoUtil.degreeToRadian(degreeNew);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // angle guide
    Offset? angleGuideOffset;
    if (degreeNew % 45 == 0) {
      angleGuideOffset = Offset(widget.left + widget.width * 0.5, widget.top + widget.height * 0.5);
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // line distance

    double diffDistance = newOffset.distance - oldOffset.distance;
    // 직사각형인 경우
    double wSquare = widget.wChild;
    double hSquare = widget.hChild;
    //double wDiff = diffDistance / math.sqrt(2);   // 정사각형인 경우
    double wDiff = math.sqrt(math.pow(wSquare, 2) /
            (math.pow(wSquare, 2) + math.pow(hSquare, 2))) *
        diffDistance;
    double hDiff = hSquare / wSquare * wDiff; // 늘리면 양수, 줄이면 음수
    //dev.log('wDiff: $wDiff, hDiff: $hDiff');
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // 최대/최소

    //dev.log('---${DateTime.now()} wDiff: $wDiff, hDiff: $hDiff');
    //dev.log('widget.wChild: ${widget.wChild}, widget.overSumOffset.dx: ${widget.overSumOffset.dx}');
    //dev.log('widget.maxSize.width: ${widget.maxSize.width}');
    // 비율을 사용하므로 w/h 하나만 해도 됨
    if ((widget.wChild + widget.overSumOffset.dx + wDiff * 2) >
        widget.maxSize.width) {
      //double wFit = 0.5 * (widget.maxSize.width - widget.wChild - widget.overSumOffset.dx);
      //dev.log('max wDiff: $wDiff, wFit: $wFit');
      widget.overSumOffset =
          Offset(widget.overSumOffset.dx + wDiff, widget.overSumOffset.dy);
      wDiff = 0;
      fMaxMin = true;
    } else if ((widget.wChild + widget.overSumOffset.dx + wDiff * 2) <
        widget.minSize.width) {
      // double wFit = 0.5 * (widget.minSize.width - widget.wChild - widget.overSumOffset.dx);
      // dev.log('min wDiff: $wDiff, wFit: $wFit');
      widget.overSumOffset =
          Offset(widget.overSumOffset.dx + wDiff, widget.overSumOffset.dy);
      wDiff = 0;
      fMaxMin = true;
    } else {
      //dev.log('wDiff minus: ${widget.overSumOffset}');
      wDiff = widget.overSumOffset.dx + wDiff;
      widget.overSumOffset = Offset(0, widget.overSumOffset.dy);
      fMaxMin = false;
    }
    if ((widget.hChild + widget.overSumOffset.dy + hDiff * 2) >
        widget.maxSize.height) {
      //double hFit = 0.5 * (widget.maxSize.height - widget.hChild - widget.overSumOffset.dy);
      //dev.log('max hDiff: $hDiff, hFit: $hFit');
      widget.overSumOffset =
          Offset(widget.overSumOffset.dx, widget.overSumOffset.dy + hDiff);
      hDiff = 0;
      fMaxMin = true;
    } else if ((widget.hChild + widget.overSumOffset.dy + hDiff * 2) <
        widget.minSize.height) {
      // double hFit = 0.5 * (widget.minSize.height - widget.hChild - widget.overSumOffset.dy);
      // dev.log('min hDiff: $hDiff, hFit: $hFit');
      widget.overSumOffset =
          Offset(widget.overSumOffset.dx, widget.overSumOffset.dy + hDiff);
      hDiff = 0;
      fMaxMin = true;
    } else {
      //dev.log('hDiff minus: ${widget.overSumOffset}');
      hDiff = widget.overSumOffset.dy + hDiff;
      widget.overSumOffset = Offset(widget.overSumOffset.dx, 0);
      fMaxMin = false;
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    double sizeSumOffsetXPosition = 0;
    double sizeSumOffsetYPosition = 0;
    switch (position) {
      case Alignment.topLeft:
        sizeSumOffsetXPosition = widget.sizeSumOffset.dx - wDiff;
        sizeSumOffsetYPosition = widget.sizeSumOffset.dy - hDiff;
        break;
      case Alignment.topRight:
        sizeSumOffsetXPosition = widget.sizeSumOffset.dx + wDiff;
        sizeSumOffsetYPosition = widget.sizeSumOffset.dy - hDiff;
        break;
      case Alignment.bottomLeft:
        sizeSumOffsetXPosition = widget.sizeSumOffset.dx - wDiff;
        sizeSumOffsetYPosition = widget.sizeSumOffset.dy + hDiff;
        break;
      case Alignment.bottomRight:
        sizeSumOffsetXPosition = widget.sizeSumOffset.dx + wDiff;
        sizeSumOffsetYPosition = widget.sizeSumOffset.dy + hDiff;
        break;
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // 반영

    // 크기가 변경되므로, 포인터가 이동한 결과를 저장했다가 보정해 주어야 함
    //widget.moveSumOffset = Offset(widget.moveSumOffset.dx - wDiff, widget.moveSumOffset.dy - hDiff); // 2/2 위치별 수정
    widget.sizeSumOffset =
        Offset(sizeSumOffsetXPosition, sizeSumOffsetYPosition); // 2/2 위치별 수정

    // resize
    //parentProvider.whSign = parentProvider.whSign + wDiff * 2; // 양쪽이므로 *2
    widget.wChild = widget.wChild + wDiff * 2; // 양쪽이므로 *2
    widget.hChild = widget.hChild + hDiff * 2; // 양쪽이므로 *2
    // center 이동
    //signProvider.parentSignOffset = Offset(signProvider.parentSignOffset!.dx - wDiff,
    //    signProvider.parentSignOffset!.dy - hDiff);

    //widget.touchOnPanUpdate(widget.angle, widget.wChild, widget.hChild, wDiff, hDiff, widget.sizeSumOffset, widget.overSumOffset);
    widget.touchOnPanUpdate(widget.angle, widget.wChild, widget.hChild, wDiff,
        hDiff, widget.sizeSumOffset, widget.overSumOffset, widget.angleSum, angleGuideOffset);
    ////////////////////////////////////////////////////////////////////////////////

  }
}
