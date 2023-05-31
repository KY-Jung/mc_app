import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';
import 'package:flutter_reorderable_grid_view/entities/order_update_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:image/image.dart' as IMG;

import 'package:easy_localization/easy_localization.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jpeg_encode/jpeg_encode.dart';
import 'package:mc/config/constant_app.dart';
import 'package:mc/dto/info_shape.dart';
import 'package:mc/ui/page_make.dart';
import 'package:mc/util/util_popup.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;
import 'package:svg_path_parser/svg_path_parser.dart';

import '../config/color_app.dart';
import '../config/config_app.dart';
import '../dto/info_parent.dart';
import '../painter/clipper_sign.dart';
import '../painter/painter_make_parent_sign.dart';
import '../provider/provider_make.dart';
import '../provider/provider_parent.dart';
import '../util/util_file.dart';
import '../util/util_info.dart';

class ReorderListPopup extends StatefulWidget {
  //const ReorderListPopup({super.key});
  ReorderListPopup(
      {Key? key,
      required this.selectedIdx,
      required this.infoList,
      required this.whShape,
      required this.title,
      required this.badge,
      required this.delete,
      required this.heightRatio})
      : super(key: key);

  ////////////////////////////////////////////////////////////////////////////////
  List<dynamic> infoList;
  int selectedIdx; // 선택한 idx
  final double whShape;
  String title;
  bool badge;
  bool delete;
  double heightRatio;

  List<Container> reorderContainerList = [];
  List<String> reorderList = []; // 이전 파일명 저장
  String? firstFileName; // 처음 선택된 파일명
  ////////////////////////////////////////////////////////////////////////////////

  @override
  State<ReorderListPopup> createState() => ReorderListPopupState();
}

class ReorderListPopupState extends State<ReorderListPopup> {
  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# ReorderListPopup initState START');
    super.initState();

    dev.log('# ReorderListPopup initState END');
  }

  @override
  void dispose() {
    dev.log('# ReorderListPopup dispose START');
    super.dispose();

    widget.reorderContainerList.clear();
    widget.reorderList.clear();
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# ReorderListPopup build START');

    ////////////////////////////////////////////////////////////////////////////////
    // 처음에만 provider 에서 읽어와서 넣음
    // (cancel 한 경우에는 parentProvider.shapeInfoList 도 다시 초기화하는 것이 번거롭기 때문)
    if (widget.reorderContainerList.isEmpty) {
      dev.log('reorderContainerList 생성');

      dev.log('selectedIdx: ${widget.selectedIdx}');
      if (widget.selectedIdx != -1) {
        widget.firstFileName = widget.infoList[widget.selectedIdx].fileName;
      }

      // 최초 생성
      int idx = 0;
      for (var info in widget.infoList) {
        Container container;
        if (idx == widget.selectedIdx) {
          // 이미 선택된 것
          container = makeContainer(info, AppColors.BOXDECO_GREEN100_GREY6_BORDER);
        } else {
          // 나머지 것들
          container = makeContainer(info, AppColors.BOXDECO_YELLOW50_BORDER);
        }
        widget.reorderContainerList.add(container);

        idx++;
      }
    }
    ////////////////////////////////////////////////////////////////////////////////

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        //width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * widget.heightRatio, // 여기서 안하면 길쭉하게 됨
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('LONGCLICK_FOR_REORDERING'.tr()),
            const SizedBox(height: 10),
            Expanded(
              child: ReorderableWrap(
                enableReorder: true,
                needsLongPressDraggable: true,
                minMainAxisCount: 4,
                maxMainAxisCount: 6,
                spacing: 4.0,
                runSpacing: 4.0,
                padding: const EdgeInsets.all(8),
                onReorder: _onReorder,
                onNoReorder: (int index) {
                  //this callback is optional
                  debugPrint('${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
                },
                onReorderStarted: (int index) {
                  //this callback is optional
                  debugPrint('${DateTime.now().toString().substring(5, 22)} reorder started: index:$index');
                },
                children: widget.reorderContainerList,
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        (widget.delete) ? ElevatedButton(onPressed: _onPressedDelete, child: Text('DELETE'.tr())) : const SizedBox(),
        ElevatedButton(onPressed: () => Navigator.pop(context, 'CANCEL'), child: Text('CANCEL'.tr())),
        ElevatedButton(onPressed: _onPressedOk, child: Text('OK'.tr())),
      ],
    );
  }

  /// shapeInfo 는 fileName, svgPicture 를 구하기 위해 필요
  Container makeContainer(var info, BoxDecoration boxDecoration) {
    Container container = Container(
      key: Key(info.fileName),
      padding: const EdgeInsets.all(0),
      width: widget.whShape,
      height: widget.whShape,
      child: badges.Badge(
        showBadge: (widget.badge) ? true : false,
        ignorePointer: false,
        badgeStyle: badges.BadgeStyle(
          shape: badges.BadgeShape.circle,
          badgeColor: Colors.lightBlue,
          padding: const EdgeInsets.all(2),
          borderRadius: BorderRadius.circular(10),
        ),
        //badgeContent: const Text(' X '),
        badgeContent: (widget.badge) ? Text(' ${info.cnt} ') : const Text(''),
        onTap: () {
          dev.log('badge onTap');
        },
        child: Container(
          decoration: boxDecoration,
          width: widget.whShape,
          height: widget.whShape,
          child: InkWell(
            // GestureDetector 는 reorderble widget 에서 사용하고 있으므로 InkWell 을 사용해야 함
            onTap: () {
              dev.log('svg onTap ${info.fileName}');
              _onTapShape(info.fileName);
            },
            child: info.image,
          ),
        ),
      ),
    );
    return container;
  }

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // Event Start
  ////////////////////////////////////////////////////////////////////////////////
  // 동일한 idx 를 클릭해도 다시 호출되는 문제 있음
  void _onTapShape(String fileNameNew) {
    dev.log('# ReorderListPopup _onTapShape START');

    ////////////////////////////////////////////////////////////////////////////////
    // newIdx 구하기
    int newIdx = 0;
    for (Container container in widget.reorderContainerList) {
      if ((container.key as ValueKey).value == fileNameNew) {
        break;
      }
      newIdx++;
    }
    dev.log('newIdx: $newIdx');
    // 동일하면 return
    if (newIdx == widget.selectedIdx) {
      dev.log('_onTapShape same idx and return');
      return;
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // old 원복
    if (widget.selectedIdx != -1) {
      Container containerOld = widget.reorderContainerList[widget.selectedIdx];
      String fileNameOld = (containerOld.key as ValueKey).value;
      var infoOld = FileUtil.findInfoWithFileName(widget.infoList, fileName: fileNameOld);
      if (infoOld == null) {
        PopupUtil.popupAlertOk(context, 'NOT FOUND _onTapShape infoOld', fileNameOld);
        return;
      }

      if (fileNameOld == widget.firstFileName) {
        dev.log('firstFileName');
        containerOld = makeContainer(infoOld, AppColors.BOXDECO_GREEN100_BORDER);
      } else if (widget.reorderList.contains(fileNameOld)) {
        dev.log('reorderedList contains');
        containerOld = makeContainer(infoOld, AppColors.BOXDECO_YELLOW50_BLACK2_BORDER);
      } else {
        containerOld = makeContainer(infoOld, AppColors.BOXDECO_YELLOW50_BORDER);
      }
      widget.reorderContainerList[widget.selectedIdx] = containerOld;
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // new 설정
    var infoNew = FileUtil.findInfoWithFileName(widget.infoList, fileName: fileNameNew);
    if (infoNew == null) {
      PopupUtil.popupAlertOk(context, 'NOT FOUND _onTapShape infoNew', fileNameNew);
      return;
    }

    Container containerNew;
    if (fileNameNew == widget.firstFileName) {
      dev.log('firstFileName');
      containerNew = makeContainer(infoNew, AppColors.BOXDECO_GREEN100_GREY6_BORDER);
    } else {
      containerNew = makeContainer(infoNew, AppColors.BOXDECO_YELLOW50_GREY6_BORDER);
    }
    widget.reorderContainerList[newIdx] = containerNew;
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    widget.selectedIdx = newIdx;
    setState(() {});
    ////////////////////////////////////////////////////////////////////////////////
  }

  void _onPressedOk() async {
    dev.log('# ReorderListPopup _onPressedOk START');

    /*
    ////////////////////////////////////////////////////////////////////////////////
    // 현재 파일명 목록 구하기
    List<String> fileNameList = FileUtil.extractFileNameFromShapeContainerList(widget.reorderContainerList);
    String fileNameStr = fileNameList.join(AppConstant.PREFS_DELIM);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // prefs 의 파일명 목록 구하기
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? prefsShapeInfoList = prefs.getString(AppConstant.PREFS_SHAPEINFOLIST);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // 같지 않으면 prefs 저장 + reordering
    if (fileNameStr != prefsShapeInfoList) {
      // save prefs
      dev.log('save prefs');
      await prefs.setString(AppConstant.PREFS_SHAPEINFOLIST, fileNameStr);

      // reordering
      dev.log('reordering');
      //dev.log('fileNameList: $fileNameList');
      FileUtil.reorderInfoListWithFileNameList(widget.infoList, fileNameList);
    }
    ////////////////////////////////////////////////////////////////////////////////
    */
    // 팝업에서는 목록만 수정하고, mbs 에서 목록을 가지고 다시 prefs 저장
    //if (widget.selectedIdx != -1) {
    List<String> fileNameList = FileUtil.extractFileNameFromContainerList(widget.reorderContainerList);
    FileUtil.reorderInfoListWithFileNameList(widget.infoList, fileNameList);
    //}

    if (!mounted) return;
    Navigator.pop(context, widget.selectedIdx);
  }

  void _onReorder(int oldIdx, int newIdx) {
    dev.log('# ReorderListPopup _onReorder START');
    dev.log('oldIdx: $oldIdx, newIdx: $newIdx');

    ////////////////////////////////////////////////////////////////////////////////
    // 이전에 선택된 것 원복
    if (widget.selectedIdx != -1) {
      Container containerOld = widget.reorderContainerList[widget.selectedIdx];
      String fileNameOld = (containerOld.key as ValueKey).value;
      var infoOld = FileUtil.findInfoWithFileName(widget.infoList, fileName: fileNameOld);
      if (infoOld == null) {
        PopupUtil.popupAlertOk(context, 'NOT FOUND _onReorder infoOld', fileNameOld);
        return;
      }

      if (fileNameOld == widget.firstFileName) {
        dev.log('firstFileName');
        containerOld = makeContainer(infoOld, AppColors.BOXDECO_GREEN100_BORDER);
      } else if (widget.reorderList.contains(fileNameOld)) {
        dev.log('reorderedIdxList contains');
        containerOld = makeContainer(infoOld, AppColors.BOXDECO_YELLOW50_BLACK2_BORDER);
      } else {
        containerOld = makeContainer(infoOld, AppColors.BOXDECO_YELLOW50_BORDER);
      }
      //containerOld = makeShapeContainer(infoOld, AppColors.BOXDECO_YELLOW50_BLACK2_BORDER);
      widget.reorderContainerList[widget.selectedIdx] = containerOld;
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // 교체하기
    Container containerNew = widget.reorderContainerList.removeAt(oldIdx);
    String fileNameNew = (containerNew.key as ValueKey).value;
    var infoNew = FileUtil.findInfoWithFileName(widget.infoList, fileName: fileNameNew);
    if (infoNew == null) {
      PopupUtil.popupAlertOk(context, 'NOT FOUND _onReorder infoNew', fileNameNew);
      return;
    }
    if (fileNameNew == widget.firstFileName) {
      dev.log('firstFileName');
      containerNew = makeContainer(infoNew, AppColors.BOXDECO_GREEN100_GREY6_BORDER);
    } else {
      containerNew = makeContainer(infoNew, AppColors.BOXDECO_YELLOW50_GREY6_BORDER);
    }
    widget.reorderContainerList.insert(newIdx, containerNew);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    widget.selectedIdx = newIdx;
    if (!widget.reorderList.contains(fileNameNew)) {
      widget.reorderList.add(fileNameNew);
    }

    setState(() {});
    ////////////////////////////////////////////////////////////////////////////////
  }

  void _onPressedDelete() async {
    dev.log('# ReorderListPopup _onPressedDelete START');

    if (widget.selectedIdx == -1) {
      dev.log('widget.selectedIdx == -1, return');
      return;
    }

    widget.reorderContainerList.removeAt(widget.selectedIdx);
    widget.infoList.removeAt(widget.selectedIdx);
    widget.selectedIdx = -1;
    dev.log('widget.reorderContainerList: ${widget.reorderContainerList}');
    setState(() {});
  }
////////////////////////////////////////////////////////////////////////////////
// Event END
////////////////////////////////////////////////////////////////////////////////
}
