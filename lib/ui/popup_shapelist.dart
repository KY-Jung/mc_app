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
      whShape = MediaQuery
          .of(context)
          .size
          .width / 7;
      for (ShapeInfo shapeInfo in parentProvider.shapeInfoList) {
        SvgPicture svgPicture = shapeInfo.svgPicture;
        Container container = Container(
          key: Key(shapeInfo.fileName),
          padding: const EdgeInsets.all(0),
          width: whShape,
          height: whShape,
          child: badges.Badge(
            showBadge: true,
            ignorePointer: false,
            badgeStyle: badges.BadgeStyle(
              shape: badges.BadgeShape.square,
              badgeColor: Colors.lightBlue,
              padding: const EdgeInsets.all(2),
              borderRadius: BorderRadius.circular(10),
            ),
            badgeContent: const Text(' X '),
            onTap: () {
              dev.log('onTap');
              setState(() {});
            },
            child: Container(
              decoration: AppColors.BOXDECO_YELLOW50_BORDER,
              width: whShape,
              height: whShape,
              child: svgPicture,
            ),
          ),
        );
        shapeContainerList.add(container);
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
            const SizedBox(
              height: 10,
            ),

            Expanded(
              child: ReorderableWrap(
                  enableReorder: true,
                  //needsLongPressDraggable: true,
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

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // Event Start
  ////////////////////////////////////////////////////////////////////////////////
  void _onPressedOk() async {
    dev.log('# ShapeListPopup _onPressedOk START');

    // 현재 파일명 목록 구하기
    List<String> fileNameList = FileUtil.extractFileNameFromShapeContainerList(shapeContainerList);
    String fileNameStr = fileNameList.join(AppConstant.PREFS_DELIM);

    // prefs 의 파일명 목록 구하기
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? prefsShapeInfoList = prefs.getString(AppConstant.PREFS_SHAPEINFOLIST);

    // 같지 않으면 저장 + reordering
    if (fileNameStr != prefsShapeInfoList) {
      // save prefs
      dev.log('save prefs');
      await prefs.setString(AppConstant.PREFS_SHAPEINFOLIST, fileNameStr);

      // reordering
      dev.log('reordering');
      //dev.log('fileNameList: $fileNameList');
      FileUtil.reorderingShapeInfoListWithFileNameList(parentProvider.shapeInfoList, fileNameList);
    }

    if (!mounted) return;
    Navigator.pop(context, 'OK');
  }

  void _onReorder(int oldIndex, int newIndex) {
    dev.log('# ShapeListPopup _onReorder START');
    dev.log('oldIndex: $oldIndex, newIndex: $newIndex');

    // 교체하기
    Container container = shapeContainerList.removeAt(oldIndex);
    shapeContainerList.insert(newIndex, container);

    // 색깔 바꾸기
    Container oldContainer = shapeContainerList[newIndex];
    //dev.log('oldContainer.key.toString(): ${oldContainer.key.toString()}');
    ShapeInfo? shapeInfo = FileUtil.findShapeInfoWithFileName(parentProvider.shapeInfoList, key: oldContainer.key);
    //dev.log('findShapeInfo: $shapeInfo');
    Container newContainer = Container(
      key: oldContainer.key,
      padding: const EdgeInsets.all(0),
      width: whShape,
      height: whShape,
      child: badges.Badge(
        showBadge: true,
        ignorePointer: false,
        badgeStyle: badges.BadgeStyle(
          shape: badges.BadgeShape.square,
          badgeColor: Colors.lightBlue,
          padding: const EdgeInsets.all(2),
          borderRadius: BorderRadius.circular(10),
        ),
        badgeContent: const Text(' X '),
        onTap: () {
          dev.log('onTap');
          setState(() {});
        },
        child: Container(
            decoration: AppColors.BOXDECO_GREEN100_BORDER,
            width: whShape,
            height: whShape,
            child: shapeInfo?.svgPicture,   // badge 안의 것을 바꿀 방법이 없어서 부득이 정부 다시 생성 (2023.05.19, KY.Jung)
        ),
      ),
    );

    // 화면 갱신해야만 함
    setState(() {
      // 바꾼 색으로 다시 넣기
      shapeContainerList[newIndex] = newContainer;
    });
  }
  ////////////////////////////////////////////////////////////////////////////////
  // Event END
  ////////////////////////////////////////////////////////////////////////////////

}
