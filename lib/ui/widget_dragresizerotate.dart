import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
  Size minSize;
  Size maxSize;

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

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // widget 의 크기가 변경되는 것을 보정하는 값
  Offset sumOffset;

  // 최대 크기를 벗어난 경우에 사용
  Offset overSumOffset;
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
    required this.sumOffset,
    required this.overSumOffset,
    required this.minSize,
    required this.maxSize,
    this.childOnTapDown,
    this.childOnTap,
    this.childOnDragUpdate,
    this.childOnDragEnd,
    this.touchOnTapDown,
    this.touchOnTap,
    this.touchOnPanUpdate,
    this.touchOnPanEnd,
    this.deleteOnTap,
    required this.child,
  });

  @override
  State<DragResizeRotateWidget> createState() => DragResizeRotateWidgetState();
}

class DragResizeRotateWidgetState extends State<DragResizeRotateWidget> {
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
                              color: widget.childBackground, border: Border.all(color: widget.childBorderColor, width: 2)),
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
                    widget.childOnDragEnd(draggableDetails, widget.wChild, widget.hChild, widget.angle);
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
                          color: widget.childBackground, border: Border.all(color: widget.childBorderColor, width: 2)),
                      child: FittedBox(fit: BoxFit.contain, child: widget.child),
                    ),
                  ),
                ),
              ),
              Positioned(
                // lefttop handle
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
                // righttop handle
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
                // leftbottom handle
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
                // rightbottom handle
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
                left: widget.whTouch + (widget.wChild - widget.whHandle * 2) * 0.5 - widget.whHandle * 1.5 * 0.5,
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
                // rightbottom touch
                left: widget.wChild + widget.whTouch - widget.whHandle * 2,
                top: widget.hChild + widget.whTouch - widget.whHandle * 2,
                width: widget.whTouch,
                height: widget.whTouch,
                child: GestureDetector(
                  onTapDown: (tapDownDetails) {
                    dev.log('rightbottom touch onTapDown');
                    widget.touchOnTapDown(tapDownDetails);
                  },
                  onTap: () {
                    dev.log('rightbottom touch onTap');
                    widget.touchOnTap();
                  },
                  onPanStart: (dragUpdateDetails) {
                    widget.sumOffset = const Offset(0, 0);
                  },
                  onPanUpdate: (dragUpdateDetails) {
                    //dev.log(
                    //    '------${DateTime.now()} globalPosition: ${dragUpdateDetails.globalPosition}, '
                    //    'localPosition: ${dragUpdateDetails.localPosition},delta: ${dragUpdateDetails.delta}');

                    // 중심점으로 offset 계산
                    Offset baseOffset = Offset(
                        (widget.wChild + widget.whTouch - widget.whHandle * 2), // 1/2 위치별 수정
                        (widget.hChild + widget.whTouch - widget.whHandle * 2));
                    Offset centerOffset = Offset((widget.wChild + widget.whTouch * 2 - widget.whHandle * 2) / 2,
                        (widget.hChild + widget.whTouch * 2 - widget.whHandle * 2) / 2);
                    Offset diffOffset = baseOffset - centerOffset;
                    Offset newOffset = diffOffset + dragUpdateDetails.localPosition - widget.sumOffset;
                    Offset oldOffset =
                        diffOffset + (dragUpdateDetails.localPosition - dragUpdateDetails.delta) - widget.sumOffset;
                    //dev.log('baseOffset: $baseOffset, centerOffset: $centerOffset, diffOffset: $diffOffset');
                    //dev.log('oldOffset: $oldOffset, newOffset: $newOffset');
                    // 회전
                    widget.angle = widget.angle + (newOffset.direction - oldOffset.direction);
                    //dev.log('signRadian: ${widget.angle}');

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

                    // 이동한 결과를 저장했다가 보정해 주어야 함
                    widget.sumOffset = Offset(widget.sumOffset.dx + wDiff, widget.sumOffset.dy + hDiff); // 2/2 위치별 수정

                    // resize
                    //parentProvider.whSign = parentProvider.whSign + wDiff * 2; // 양쪽이므로 *2
                    widget.wChild = widget.wChild + wDiff * 2; // 양쪽이므로 *2
                    widget.hChild = widget.hChild + hDiff * 2; // 양쪽이므로 *2
                    // center 이동
                    //signProvider.parentSignOffset = Offset(signProvider.parentSignOffset!.dx - wDiff,
                    //    signProvider.parentSignOffset!.dy - hDiff);

                    widget.touchOnPanUpdate(widget.angle, widget.wChild, widget.hChild, wDiff, hDiff, widget.sumOffset);
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
                // leftbottom touch
                left: 0,
                top: widget.hChild + widget.whTouch - widget.whHandle * 2,
                width: widget.whTouch,
                height: widget.whTouch,
                child: GestureDetector(
                  onTapDown: (tapDownDetails) {
                    dev.log('leftbottom touch onTapDown');
                    widget.touchOnTapDown(tapDownDetails);
                  },
                  onTap: () {
                    dev.log('leftbottom touch onTap');
                    widget.touchOnTap();
                  },
                  onPanStart: (dragUpdateDetails) {
                    widget.sumOffset = const Offset(0, 0);
                  },
                  onPanUpdate: (dragUpdateDetails) {
                    //dev.log(
                    //    '------${DateTime.now()} globalPosition: ${dragUpdateDetails.globalPosition}, '
                    //    'localPosition: ${dragUpdateDetails.localPosition},delta: ${dragUpdateDetails.delta}');

                    // 중심점으로 offset 계산
                    Offset baseOffset = Offset(
                        0, // 1/2 위치별 수정
                        (widget.hChild + widget.whTouch - widget.whHandle * 2));
                    Offset centerOffset = Offset((widget.wChild + widget.whTouch * 2 - widget.whHandle * 2) / 2,
                        (widget.hChild + widget.whTouch * 2 - widget.whHandle * 2) / 2);
                    Offset diffOffset = baseOffset - centerOffset;
                    Offset newOffset = diffOffset + dragUpdateDetails.localPosition - widget.sumOffset;
                    Offset oldOffset =
                        diffOffset + (dragUpdateDetails.localPosition - dragUpdateDetails.delta) - widget.sumOffset;
                    //dev.log('baseOffset: $baseOffset, centerOffset: $centerOffset, diffOffset: $diffOffset');
                    //dev.log('oldOffset: $oldOffset, newOffset: $newOffset');
                    // 회전
                    widget.angle = widget.angle + (newOffset.direction - oldOffset.direction);
                    //dev.log('signRadian: $signRadian');

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

                    // 이동한 결과를 저장했다가 보정해 주어야 함
                    widget.sumOffset = Offset(widget.sumOffset.dx - wDiff, widget.sumOffset.dy + hDiff); // 2/2 위치별 수정

                    // resize
                    //parentProvider.whSign = parentProvider.whSign + wDiff * 2; // 양쪽이므로 *2
                    widget.wChild = widget.wChild + wDiff * 2; // 양쪽이므로 *2
                    widget.hChild = widget.hChild + hDiff * 2; // 양쪽이므로 *2
                    // center 이동
                    //signProvider.parentSignOffset = Offset(signProvider.parentSignOffset!.dx - wDiff,
                    //    signProvider.parentSignOffset!.dy - hDiff);

                    widget.touchOnPanUpdate(widget.angle, widget.wChild, widget.hChild, wDiff, hDiff, widget.sumOffset);
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
                // righttop touch
                left: widget.wChild + widget.whTouch - widget.whHandle * 2,
                top: 0,
                width: widget.whTouch,
                height: widget.whTouch,
                child: GestureDetector(
                  onTapDown: (tapDownDetails) {
                    dev.log('righttop touch onTapDown');
                    widget.touchOnTapDown(tapDownDetails);
                  },
                  onTap: () {
                    dev.log('righttop touch onTap');
                    widget.touchOnTap();
                  },
                  onPanStart: (dragUpdateDetails) {
                    widget.sumOffset = const Offset(0, 0);
                  },
                  onPanUpdate: (dragUpdateDetails) {
                    //dev.log(
                    //    '------${DateTime.now()} globalPosition: ${dragUpdateDetails.globalPosition}, '
                    //    'localPosition: ${dragUpdateDetails.localPosition},delta: ${dragUpdateDetails.delta}');

                    // 중심점으로 offset 계산
                    Offset baseOffset = Offset(
                        (widget.wChild + widget.whTouch - widget.whHandle * 2), // 1/2 위치별 수정
                        0);
                    Offset centerOffset = Offset((widget.wChild + widget.whTouch * 2 - widget.whHandle * 2) / 2,
                        (widget.hChild + widget.whTouch * 2 - widget.whHandle * 2) / 2);
                    Offset diffOffset = baseOffset - centerOffset;
                    Offset newOffset = diffOffset + dragUpdateDetails.localPosition - widget.sumOffset;
                    Offset oldOffset =
                        diffOffset + (dragUpdateDetails.localPosition - dragUpdateDetails.delta) - widget.sumOffset;
                    //dev.log('baseOffset: $baseOffset, centerOffset: $centerOffset, diffOffset: $diffOffset');
                    //dev.log('oldOffset: $oldOffset, newOffset: $newOffset');
                    // 회전
                    widget.angle = widget.angle + (newOffset.direction - oldOffset.direction);
                    //dev.log('signRadian: ${widget.angle}');

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

                    // 이동한 결과를 저장했다가 보정해 주어야 함
                    widget.sumOffset = Offset(widget.sumOffset.dx + wDiff, widget.sumOffset.dy - hDiff); // 2/2 위치별 수정

                    // resize
                    //parentProvider.whSign = parentProvider.whSign + wDiff * 2; // 양쪽이므로 *2
                    widget.wChild = widget.wChild + wDiff * 2; // 양쪽이므로 *2
                    widget.hChild = widget.hChild + hDiff * 2; // 양쪽이므로 *2
                    // center 이동
                    //signProvider.parentSignOffset = Offset(signProvider.parentSignOffset!.dx - wDiff,
                    //    signProvider.parentSignOffset!.dy - hDiff);

                    widget.touchOnPanUpdate(widget.angle, widget.wChild, widget.hChild, wDiff, hDiff, widget.sumOffset);
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
                // lefttop touch
                left: 0,
                top: 0,
                width: widget.whTouch,
                height: widget.whTouch,
                child: GestureDetector(
                  onTapDown: (tapDownDetails) {
                    dev.log('lefttop touch onTapDown');
                    widget.touchOnTapDown(tapDownDetails);
                  },
                  onTap: () {
                    dev.log('lefttop touch onTap');
                    widget.touchOnTap();
                  },
                  onPanStart: (dragUpdateDetails) {
                    widget.sumOffset = const Offset(0, 0);
                    widget.overSumOffset = const Offset(0, 0);
                  },
                  onPanEnd: (dragEndDetails) {
                    //widget.sumOffset = const Offset(0, 0);
                    //widget.overSumOffset = const Offset(0, 0);
                    widget.touchOnPanEnd();
                  },
                  onPanUpdate: (dragUpdateDetails) {
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
                    Offset newOffset = diffOffset + dragUpdateDetails.localPosition - widget.sumOffset;
                    Offset oldOffset =
                        diffOffset + (dragUpdateDetails.localPosition - dragUpdateDetails.delta) - widget.sumOffset;
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
                    /*
                    if (wDiff > 0 && (widget.wChild + wDiff * 2) > widget.maxSize.width) {
                      dev.log('maxSize wDiff plus');
                      wDiff = 0;
                    }
                    if (wDiff < 0 && (widget.wChild + wDiff * 2) < widget.minSize.width) {
                      dev.log('minSize wDiff minus');
                      wDiff = 0;
                    }
                    if (hDiff > 0 && (widget.wChild + hDiff * 2) > widget.maxSize.width) {
                      dev.log('maxSize hDiff plus');
                      hDiff = 0;
                    }
                    if (hDiff < 0 && (widget.wChild + hDiff * 2) < widget.minSize.width) {
                      dev.log('minSize hDiff minus');
                      hDiff = 0;
                    }
                    */
                    dev.log('wDiff: $wDiff, hDiff: $hDiff');
                    // 비융을 사용하므로 w/h 하나만 해도 됨

                    /*
                    if (wDiff > 0) {
                      if ((widget.wChild + widget.overSumOffset.dx + wDiff * 2) > widget.maxSize.width) {
                        dev.log('maxSize wDiff plus');
                        widget.overSumOffset = Offset(widget.overSumOffset.dx + wDiff, widget.overSumOffset.dy);
                        wDiff = 0;
                      }
                    } else {
                      if ((widget.wChild + widget.overSumOffset.dx + wDiff * 2) > widget.maxSize.width) {
                        dev.log('minSize wDiff minus');
                        widget.overSumOffset = Offset(widget.overSumOffset.dx + wDiff, widget.overSumOffset.dy);
                        wDiff = 0;
                      } else {
                        //if ((widget.overSumOffset.dx > 0) && (widget.overSumOffset.dx + wDiff) < 0) {
                        if ((widget.overSumOffset.dx > 0)) {
                          wDiff = widget.overSumOffset.dx + wDiff;
                          widget.overSumOffset = Offset(0, widget.overSumOffset.dy);
                        }
                      }
                    }
                    if (hDiff > 0) {
                      if ((widget.hChild + widget.overSumOffset.dy + hDiff * 2) > widget.maxSize.height) {
                        dev.log('maxSize hDiff plus');
                        widget.overSumOffset = Offset(widget.overSumOffset.dx, widget.overSumOffset.dy + hDiff);
                        hDiff = 0;
                      }
                    } else {
                      if ((widget.hChild + widget.overSumOffset.dy + hDiff * 2) > widget.maxSize.height) {
                        dev.log('minSize hDiff minus: ${widget.overSumOffset}');
                        widget.overSumOffset = Offset(widget.overSumOffset.dx, widget.overSumOffset.dy + hDiff);
                        hDiff = 0;
                      } else {
                        //if ((widget.overSumOffset.dy > 0) && (widget.overSumOffset.dy + hDiff) < 0) {
                        if ((widget.overSumOffset.dy > 0)) {
                          hDiff = widget.overSumOffset.dy + hDiff;
                          widget.overSumOffset = Offset(widget.overSumOffset.dx, 0);
                        }
                      }
                    }
                     */
                    if ((widget.wChild + widget.overSumOffset.dx + wDiff * 2) > widget.maxSize.width ||
                        (widget.wChild + widget.overSumOffset.dx + wDiff * 2) < widget.minSize.width) {
                      dev.log('minSize wDiff minus: ${widget.overSumOffset}');
                      widget.overSumOffset = Offset(widget.overSumOffset.dx + wDiff, widget.overSumOffset.dy);
                      wDiff = 0;
                    } else {
                      //if ((widget.overSumOffset.dy > 0) && (widget.overSumOffset.dy + hDiff) < 0) {
                      if ((widget.overSumOffset.dx != 0)) {
                        wDiff = widget.overSumOffset.dx + wDiff;
                        widget.overSumOffset = Offset(0, widget.overSumOffset.dy);
                      }
                    }
                    if ((widget.hChild + widget.overSumOffset.dy + hDiff * 2) > widget.maxSize.width ||
                        (widget.hChild + widget.overSumOffset.dy + hDiff * 2) < widget.minSize.width) {
                      dev.log('minSize hDiff minus: ${widget.overSumOffset}');
                      widget.overSumOffset = Offset(widget.overSumOffset.dx, widget.overSumOffset.dy + hDiff);
                      hDiff = 0;
                    } else {
                      //if ((widget.overSumOffset.dy > 0) && (widget.overSumOffset.dy + hDiff) < 0) {
                      if ((widget.overSumOffset.dy != 0)) {
                        hDiff = widget.overSumOffset.dy + hDiff;
                        widget.overSumOffset = Offset(widget.overSumOffset.dx, 0);
                      }
                    }
                    //dev.log('widget.hChild: ${widget.hChild}');
                    //dev.log('widget.overSumOffset.dy: ${widget.overSumOffset.dy}');
                    //dev.log('hDiff: $hDiff');
                    //dev.log('(widget.hChild + widget.overSumOffset.dy + hDiff * 2): ${(widget.hChild + widget.overSumOffset.dy + hDiff * 2)}');
                    //dev.log('widget.maxSize.height: ${widget.maxSize.height}');
                    ////////////////////////////////////////////////////////////////////////////////

                    ////////////////////////////////////////////////////////////////////////////////
                    // 이동한 결과를 저장했다가 보정해 주어야 함
                    widget.sumOffset = Offset(widget.sumOffset.dx - wDiff, widget.sumOffset.dy - hDiff); // 2/2 위치별 수정

                    // resize
                    //parentProvider.whSign = parentProvider.whSign + wDiff * 2; // 양쪽이므로 *2
                    widget.wChild = widget.wChild + wDiff * 2; // 양쪽이므로 *2
                    widget.hChild = widget.hChild + hDiff * 2; // 양쪽이므로 *2
                    // center 이동
                    //signProvider.parentSignOffset = Offset(signProvider.parentSignOffset!.dx - wDiff,
                    //    signProvider.parentSignOffset!.dy - hDiff);

                    widget.touchOnPanUpdate(widget.angle, widget.wChild, widget.hChild, wDiff, hDiff, widget.sumOffset, widget.overSumOffset);
                    ////////////////////////////////////////////////////////////////////////////////

                    /*
                    // for test
                    widget.wChild = 200;
                    widget.hChild = 100;
                    widget.angle = 30 / 180 * math.pi;
                    double xR = widget.wChild * 0.5 * math.cos(widget.angle) + widget.wChild * 0.5 * math.sin(widget.angle);
                    double yR = widget.wChild * 0.5 * math.sin(widget.angle) + widget.wChild * 0.5 * math.cos(widget.angle);
                    dev.log('xR: $xR, yR: $yR');
                    dev.log('widget.wChild: ${widget.wChild}, widget.angle: ${widget.angle}');
                    widget.touchOnPanUpdate(widget.angle, widget.wChild, widget.hChild, 0.0, 0.0, widget.sumOffset);


                    double angle_1 = 30 / 180 * math.pi;
                    double x_1 = math.sin(angle_1) * 100;
                    double x_2 = math.cos(angle_1) * 100;
                    dev.log('x_1: $x_1, x_2: $x_2');
                    double angle_2 = 60 / 180 * math.pi;
                    double y_1 = math.sin(angle_2) * 200;
                    double y_2 = math.cos(angle_2) * 200;
                    dev.log('y_1: $y_1, y_2: $y_2');
                    dev.log('------------------------------------');
                    */
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

  void handleOnPanUpdate(dragUpdateDetails) {

  }

}
