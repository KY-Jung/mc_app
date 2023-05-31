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

class ShapeListPopup extends StatefulWidget {
  const ShapeListPopup({super.key});

  @override
  State<ShapeListPopup> createState() => ShapeListPopupState();
}

class ShapeListPopupState extends State<ShapeListPopup> {
  ////////////////////////////////////////////////////////////////////////////////
  late ParentProvider parentProvider;

  List<Container> shapeContainerList = [];
  List<String> reorderedList = [];    // 이전 파일명 저장
  int selectedIdx = -1;   // 선택한 idx
  String? firstFileName;    // 처음 선택된 파일명

  late double whShape;
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# ShapeListPopup initState START');
    super.initState();

    dev.log('# ShapeListPopup initState END');
  }

  @override
  void dispose() {
    dev.log('# ShapeListPopup dispose START');
    super.dispose();

    shapeContainerList.clear();
    reorderedList.clear();
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# ShapeListPopup build START');

    ////////////////////////////////////////////////////////////////////////////////
    parentProvider = Provider.of<ParentProvider>(context);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // 처음에만 provider 에서 읽어와서 넣음
    // (cancel 한 경우에는 parentProvider.shapeInfoList 도 다시 초기화하는 것이 번거롭기 때문)
    if (shapeContainerList.isEmpty) {
      dev.log('shapeContainerList 생성');

      // list 조정하기 (ReorderableWrap 에서 못하는 기능들)
      whShape = MediaQuery.of(context).size.width / 7;

      selectedIdx = parentProvider.selectedShapeInfoIdx;
      dev.log('selectedIdx: $selectedIdx');
      if (selectedIdx != -1) {
        firstFileName = parentProvider.shapeInfoList[selectedIdx].fileName;
      }

      // 최초 생성
      int idx = 0;
      for (ShapeInfo shapeInfo in parentProvider.shapeInfoList) {
        Container container;
        if (idx == selectedIdx) {
          // 이미 선택된 것
          container = makeShapeContainer(shapeInfo, AppColors.BOXDECO_GREEN100_GREY6_BORDER);
        } else {
          // 나머지 것들
          container = makeShapeContainer(shapeInfo, AppColors.BOXDECO_YELLOW50_BORDER);
        }
        shapeContainerList.add(container);

        idx++;
      }
    }
    ////////////////////////////////////////////////////////////////////////////////

    return AlertDialog(
      title: Text('SHAPE'.tr()),
      content: SizedBox(
        //width: MediaQuery.of(context).size.width * 0.8,
        //height: MediaQuery.of(context).size.height * 0.6,   // 여기서 안하면 길쭉하게 됨
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
                children: shapeContainerList,
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        ElevatedButton(onPressed: () => Navigator.pop(context, 'CANCEL'), child: Text('CANCEL'.tr())),
        ElevatedButton(onPressed: _onPressedOk, child: Text('OK'.tr())),
      ],
    );
  }

  /// shapeInfo 는 fileName, svgPicture 를 구하기 위해 필요
  Container makeShapeContainer(ShapeInfo shapeInfo, BoxDecoration boxDecoration) {
    Container container = Container(
      key: Key(shapeInfo.fileName),
      padding: const EdgeInsets.all(0),
      width: whShape,
      height: whShape,
      child: badges.Badge(
        showBadge: true,
        //showBadge: false,
        ignorePointer: false,
        badgeStyle: badges.BadgeStyle(
          shape: badges.BadgeShape.circle,
          badgeColor: Colors.lightBlue,
          padding: const EdgeInsets.all(2),
          borderRadius: BorderRadius.circular(10),
        ),
        badgeContent: const Text(' X '),
        onTap: () {
          dev.log('badge onTap');
          //setState(() {});
        },
        child: Container(
          decoration: boxDecoration,
          width: whShape,
          height: whShape,
          child: InkWell(   // GestureDetector 는 reorderble widget 에서 사용하고 있으므로 InkWell 을 사용해야 함
            onTap: () {
              dev.log('svg onTap ${shapeInfo.fileName}');
              _onTapShape(shapeInfo.fileName);
            },
            child: shapeInfo.image,
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
    dev.log('# ShapeListPopup _onTapShape START');

    ////////////////////////////////////////////////////////////////////////////////
    // newIdx 구하기
    int newIdx = 0;
    for (Container container in shapeContainerList) {
      if ((container.key as ValueKey).value == fileNameNew) {
        break;
      }
      newIdx++;
    }
    dev.log('newIdx: $newIdx');
    // 동일하면 return
    if (newIdx == selectedIdx) {
      dev.log('_onTapShape same idx and return');
      return;
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // old 원복
    if (selectedIdx != -1) {
      Container containerOld = shapeContainerList[selectedIdx];
      String fileNameOld = (containerOld.key as ValueKey).value;
      ShapeInfo? shapeInfoOld = FileUtil.findShapeInfoWithFileName(parentProvider.shapeInfoList, fileName: fileNameOld);
      if (shapeInfoOld == null) {
        PopupUtil.popupAlertOk(context, 'NOT FOUND _onTapShape shapeInfoOld', fileNameOld);
        return;
      }

      if (fileNameOld == firstFileName) {
        dev.log('firstFileName');
        containerOld = makeShapeContainer(shapeInfoOld, AppColors.BOXDECO_GREEN100_BORDER);
      } else if (reorderedList.contains(fileNameOld)) {
        dev.log('reorderedList contains');
        containerOld = makeShapeContainer(shapeInfoOld, AppColors.BOXDECO_YELLOW50_BLACK2_BORDER);
      } else {
        containerOld = makeShapeContainer(shapeInfoOld, AppColors.BOXDECO_YELLOW50_BORDER);
      }
      shapeContainerList[selectedIdx] = containerOld;
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // new 설정
    ShapeInfo? shapeInfoNew = FileUtil.findShapeInfoWithFileName(parentProvider.shapeInfoList, fileName: fileNameNew);
    if (shapeInfoNew == null) {
      PopupUtil.popupAlertOk(context, 'NOT FOUND _onTapShape shapeInfoNew', fileNameNew);
      return;
    }

    Container containerNew;
    if (fileNameNew == firstFileName) {
      dev.log('firstFileName');
      containerNew = makeShapeContainer(shapeInfoNew, AppColors.BOXDECO_GREEN100_GREY6_BORDER);
    } else {
      containerNew = makeShapeContainer(shapeInfoNew, AppColors.BOXDECO_YELLOW50_GREY6_BORDER);
    }
    shapeContainerList[newIdx] = containerNew;
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    selectedIdx = newIdx;
    setState(() {});
    ////////////////////////////////////////////////////////////////////////////////
  }

  void _onPressedOk() async {
    dev.log('# ShapeListPopup _onPressedOk START');

    ////////////////////////////////////////////////////////////////////////////////
    // 현재 파일명 목록 구하기
    List<String> fileNameList = FileUtil.extractFileNameFromContainerList(shapeContainerList);
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
      //parentProvider.reorderShapeInfoList(fileNameList);
      FileUtil.reorderInfoListWithFileNameList(parentProvider.shapeInfoList, fileNameList);
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    parentProvider.setSelectedShapeInfoIdx(selectedIdx);
    ////////////////////////////////////////////////////////////////////////////////

    if (!mounted) return;
    Navigator.pop(context, 'OK');
  }

  void _onReorder(int oldIdx, int newIdx) {
    dev.log('# ShapeListPopup _onReorder START');
    dev.log('oldIdx: $oldIdx, newIdx: $newIdx');

    ////////////////////////////////////////////////////////////////////////////////
    // 이전에 선택된 것 원복
    Container containerOld = shapeContainerList[selectedIdx];
    String fileNameOld = (containerOld.key as ValueKey).value;
    ShapeInfo? shapeInfoOld = FileUtil.findShapeInfoWithFileName(parentProvider.shapeInfoList, fileName: fileNameOld);
    if (shapeInfoOld == null) {
      PopupUtil.popupAlertOk(context, 'NOT FOUND _onReorder shapeInfoOld', fileNameOld);
      return;
    }

    if (fileNameOld == firstFileName) {
      dev.log('firstFileName');
      containerOld = makeShapeContainer(shapeInfoOld, AppColors.BOXDECO_GREEN100_BORDER);
    } else if (reorderedList.contains(fileNameOld)) {
      dev.log('reorderedIdxList contains');
      containerOld = makeShapeContainer(shapeInfoOld, AppColors.BOXDECO_YELLOW50_BLACK2_BORDER);
    } else {
      containerOld = makeShapeContainer(shapeInfoOld, AppColors.BOXDECO_YELLOW50_BORDER);
    }
    //containerOld = makeShapeContainer(shapeInfoOld, AppColors.BOXDECO_YELLOW50_BLACK2_BORDER);
    shapeContainerList[selectedIdx] = containerOld;
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    // 교체하기
    Container containerNew = shapeContainerList.removeAt(oldIdx);
    String fileNameNew = (containerNew.key as ValueKey).value;
    ShapeInfo? shapeInfoNew = FileUtil.findShapeInfoWithFileName(parentProvider.shapeInfoList, fileName: fileNameNew);
    if (shapeInfoNew == null) {
      PopupUtil.popupAlertOk(context, 'NOT FOUND _onReorder shapeInfoNew', fileNameNew);
      return;
    }
    if (fileNameNew == firstFileName) {
      dev.log('firstFileName');
      containerNew = makeShapeContainer(shapeInfoNew, AppColors.BOXDECO_GREEN100_GREY6_BORDER);
    } else {
      containerNew = makeShapeContainer(shapeInfoNew, AppColors.BOXDECO_YELLOW50_GREY6_BORDER);
    }
    shapeContainerList.insert(newIdx, containerNew);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    selectedIdx = newIdx;
    if (!reorderedList.contains(fileNameNew)) {
      reorderedList.add(fileNameNew);
    }

    setState(() { });
    ////////////////////////////////////////////////////////////////////////////////
  }
  ////////////////////////////////////////////////////////////////////////////////
  // Event END
  ////////////////////////////////////////////////////////////////////////////////

}
