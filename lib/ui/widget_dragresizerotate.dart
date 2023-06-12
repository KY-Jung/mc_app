import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:flutter/material.dart';

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
  // 본체 테두리
  Color childColor;
  // 본체 크기
  double wChild;
  double hChild;

  // 터치 영역 크기
  double whTouch;

  // 핸들 크기
  double whHandle;
  Color handleColor;

  // child 의 drag 가 끝난 경우
  dynamic childOnTapDown;
  dynamic childOnTap;
  dynamic childOnDragEnd;
  dynamic touchOnTapDown;
  dynamic touchOnTap;
  dynamic touchOnPanUpdate;
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  Offset sumOffset;
  ////////////////////////////////////////////////////////////////////////////////

  DragResizeRotateWidget(
      this.left,
      this.top,
      this.width,
      this.height,
      this.angle,
      this.child,
      this.childColor,
      this.wChild,
      this.hChild,
      this.whTouch,
      this.whHandle,
      this.handleColor,
      this.sumOffset,
      this.childOnTapDown,
      this.childOnTap,
      this.childOnDragEnd,
      this.touchOnTapDown,
      this.touchOnTap,
      this.touchOnPanUpdate,
      {super.key});

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
                              color: Colors.transparent,
                              border: Border.all(color: widget.childColor, width: 2)),
                          child: FittedBox(
                            fit: BoxFit.cover,
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
                  onDragEnd: (draggableDetails) {
                    widget.childOnDragEnd(draggableDetails);
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
                            color: Colors.transparent,
                            border: Border.all(color: widget.childColor, width: 2)),
                        child: FittedBox(
                            fit: BoxFit.cover,
                            child: widget.child),
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
                        (widget.wChild + widget.whTouch * 2 - widget.whHandle * 2) / 2,
                        (widget.hChild + widget.whTouch * 2 - widget.whHandle * 2) / 2);
                    Offset diffOffset = baseOffset - centerOffset;
                    Offset newOffset = diffOffset + dragUpdateDetails.localPosition - widget.sumOffset;
                    Offset oldOffset = diffOffset +
                        (dragUpdateDetails.localPosition - dragUpdateDetails.delta) -
                        widget.sumOffset;
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
                    double wDiff = math.sqrt(
                        math.pow(wSquare, 2) / (math.pow(wSquare, 2) + math.pow(hSquare, 2))) *
                        diffDistance;
                    double hDiff = hSquare / wSquare * wDiff; // 늘리면 양수, 줄이면 음수
                    //dev.log('wDiff: $wDiff, hDiff: $hDiff');

                    // 이동한 결과를 저장했다가 보정해 주어야 함
                    widget.sumOffset = Offset(widget.sumOffset.dx - wDiff, widget.sumOffset.dy - hDiff); // 2/2 위치별 수정

                    // resize
                    //parentProvider.whSign = parentProvider.whSign + wDiff * 2; // 양쪽이므로 *2
                    widget.wChild = widget.wChild + wDiff * 2; // 양쪽이므로 *2
                    widget.hChild = widget.hChild + hDiff * 2; // 양쪽이므로 *2
                    // center 이동
                    //signProvider.parentSignOffset = Offset(signProvider.parentSignOffset!.dx - wDiff,
                    //    signProvider.parentSignOffset!.dy - hDiff);

                    widget.touchOnPanUpdate(widget.angle, widget.wChild, widget.hChild, wDiff, hDiff, widget.sumOffset);
                    //setState(() {});
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
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
                    Offset centerOffset = Offset(
                        (widget.wChild + widget.whTouch * 2 - widget.whHandle * 2) / 2,
                        (widget.hChild + widget.whTouch * 2 - widget.whHandle * 2) / 2);
                    Offset diffOffset = baseOffset - centerOffset;
                    Offset newOffset = diffOffset + dragUpdateDetails.localPosition - widget.sumOffset;
                    Offset oldOffset = diffOffset +
                        (dragUpdateDetails.localPosition - dragUpdateDetails.delta) -
                        widget.sumOffset;
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
                    double wDiff = math.sqrt(
                        math.pow(wSquare, 2) / (math.pow(wSquare, 2) + math.pow(hSquare, 2))) *
                        diffDistance;
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
                    //setState(() {});
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
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
                    Offset centerOffset = Offset(
                        (widget.wChild + widget.whTouch * 2 - widget.whHandle * 2) / 2,
                        (widget.hChild + widget.whTouch * 2 - widget.whHandle * 2) / 2);
                    Offset diffOffset = baseOffset - centerOffset;
                    Offset newOffset = diffOffset + dragUpdateDetails.localPosition - widget.sumOffset;
                    Offset oldOffset = diffOffset +
                        (dragUpdateDetails.localPosition - dragUpdateDetails.delta) -
                        widget.sumOffset;
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
                    double wDiff = math.sqrt(
                        math.pow(wSquare, 2) / (math.pow(wSquare, 2) + math.pow(hSquare, 2))) *
                        diffDistance;
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
                    //setState(() {});
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    width: widget.whTouch,
                    height: widget.whTouch,
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
                    Offset centerOffset = Offset(
                        (widget.wChild + widget.whTouch * 2 - widget.whHandle * 2) / 2,
                        (widget.hChild + widget.whTouch * 2 - widget.whHandle * 2) / 2);
                    Offset diffOffset = baseOffset - centerOffset;
                    Offset newOffset = diffOffset + dragUpdateDetails.localPosition - widget.sumOffset;
                    Offset oldOffset = diffOffset +
                        (dragUpdateDetails.localPosition - dragUpdateDetails.delta) -
                        widget.sumOffset;
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
                    double wDiff = math.sqrt(
                        math.pow(wSquare, 2) / (math.pow(wSquare, 2) + math.pow(hSquare, 2))) *
                        diffDistance;
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
                    //setState(() {});
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
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

}
