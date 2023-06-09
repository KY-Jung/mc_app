import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mc/config/constant_app.dart';
import 'package:mc/util/util_popup.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

import '../config/color_app.dart';
import '../config/config_app.dart';
import '../config/enum_app.dart';
import '../provider/provider_make.dart';
import '../provider/provider_parent.dart';
import '../provider/provider_sign.dart';
import '../util/util_file.dart';
import 'mbs_sign.dart';

enum ParentBarEnum { FRAME, RESIZE, SIGN }

class ParentBar extends StatefulWidget {
  const ParentBar({super.key});

  @override
  State<ParentBar> createState() => ParentBarState();
}

class ParentBarState extends State<ParentBar> {
  ////////////////////////////////////////////////////////////////////////////////
  List<bool> toggleSelectList = [false, false, false];

  late MakeProvider makeProvider;
  late ParentProvider parentProvider;
  late SignProvider signProvider;

  late double hBarDetail;
  late double whPreSign;
  late double wScreen;

  /// signlist 에서 OK 한 경우 선택된 shape 로 위치이동하기 위해 사용
  late ScrollController _preSignController;

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# ParentBar initState START');
    super.initState();

    // resize 하다가 다른 bar 로 갔다가 다시 돌아온 경우 처리
    //InfoUtil.initParentProviderBracket(parentProvider);

    ////////////////////////////////////////////////////////////////////////////////
    /// build 이후 실행
    /// SharedPreferences.getInstance() 는 initState/build 에서는 await 효과 없으므로
    /// build 이후에 다시 실행하는 것으로 수정함

    //WidgetsBinding.instance
    //    .addPostFrameCallback((_) => _loadPreferences(context));
    ////////////////////////////////////////////////////////////////////////////////

    dev.log('# ParentBar initState END');
  }

  @override
  void dispose() {
    dev.log('# ParentBar dispose START');
    super.dispose();

    parentProvider.clearParentBracket();

    _preSignController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# ParentBar build START');

    ////////////////////////////////////////////////////////////////////////////////
    makeProvider = Provider.of<MakeProvider>(context);
    parentProvider = Provider.of<ParentProvider>(context);
    signProvider = Provider.of<SignProvider>(context);
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    switch (parentProvider.parentBarEnum) {
      case ParentBarEnum.FRAME:
        dev.log('case ParentBarEnum.FRAME');
        toggleSelectList[0] = true;
        break;
      case ParentBarEnum.RESIZE:
        dev.log('case ParentBarEnum.RESIZE');
        toggleSelectList[1] = true;
        break;
      case ParentBarEnum.SIGN:
        dev.log('case ParentBarEnum.SIGN');
        toggleSelectList[2] = true;
        break;
    }
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    hBarDetail = AppBar().preferredSize.height *
        AppConfig.FUNCTIONBAR_HEIGHT *
        AppConfig.MAKE_FUNCTIONBAR_2 /
        (AppConfig.MAKE_FUNCTIONBAR_1 + AppConfig.MAKE_FUNCTIONBAR_2);
    whPreSign = hBarDetail - 20 * 2;

    wScreen = MediaQuery.of(context).size.width;
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    double listWidth = wScreen - (whPreSign + 10 * 2) * 2;
    double cntPreSign = listWidth / (whPreSign + 10);
    dev.log('cntPreSign: $cntPreSign');

    _preSignController = ScrollController(
        initialScrollOffset:
            signProvider.selectedSignFileInfoIdx * (whPreSign + 10) - (whPreSign) * cntPreSign * 0.5 - 10 * 0.5);
    ////////////////////////////////////////////////////////////////////////////////

    return Scaffold(
      //backgroundColor: Colors.yellow,
      backgroundColor: AppColors.MAKE_PARENT_FB_BACKGROUND,
      body: Column(
        children: <Widget>[
          Expanded(
            flex: AppConfig.MAKE_FUNCTIONBAR_1,
            child: ToggleButtons(
              color: Colors.grey,
              selectedColor: Colors.black,
              fillColor: Colors.white,
              //disabledColor: Colors.white10,
              renderBorder: true,
              borderRadius: BorderRadius.circular(10),
              borderWidth: 2,
              borderColor: Colors.white60,
              selectedBorderColor: Colors.white70,
              isSelected: toggleSelectList,
              //constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width * 0.25),
              onPressed: _toggleButtonsSelect,
              children: [
                Container(
                    //height: 40,
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06),
                    child: Text(
                      'FRAME'.tr(),
                    )),
                Container(
                  //height: 40,
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06),
                  child: Text(
                    'SIZE'.tr(),
                  ),
                ),
                Container(
                  //height: 40,
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06),
                  child: Text(
                    'SIGN'.tr(),
                  ),
                ),
              ],
            ),
          ),
          if (parentProvider.parentBarEnum == ParentBarEnum.FRAME)
            Expanded(
              flex: AppConfig.MAKE_FUNCTIONBAR_2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    child: Text('FRAME parentSize1'),
                    onPressed: () {},
                  ),
                  ElevatedButton(
                    child: Text('FRAME parentSize2'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          if (parentProvider.parentBarEnum == ParentBarEnum.RESIZE)
            Expanded(
              flex: AppConfig.MAKE_FUNCTIONBAR_2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _onPressedSizeInit,
                    child: Text('SIZE_INIT'.tr()),
                  ),
                  ElevatedButton(
                    onPressed: _onPressedSizeSave,
                    child: Text('SIZE_SAVE'.tr()),
                  ),
                ],
              ),
            ),
          if (parentProvider.parentBarEnum == ParentBarEnum.SIGN)
            Expanded(
              flex: AppConfig.MAKE_FUNCTIONBAR_2,
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  InkWell(
                    onTap: _onTapNone,
                    child: Container(
                      width: whPreSign,
                      height: whPreSign,
                      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      alignment: Alignment.center,
                      decoration: (signProvider.parentSignFileInfoIdx == -1)
                          ? BoxDecoration(color: Colors.grey, border: Border.all(color: Colors.black))
                          : BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: Text('NONE'.tr()),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.yellow[50],
                      //margin: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                      margin: const EdgeInsets.fromLTRB(0, 15, 10, 15),
                      child: ListView.separated(
                        controller: _preSignController,
                        //padding: const EdgeInsets.all(10),
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: signProvider.signFileInfoList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Row(
                            children: [
                              InkWell(
                                onTap: () => _onTapPreSign(index),
                                child: SizedBox(
                                  width: whPreSign,
                                  height: whPreSign,
                                  child: badges.Badge(
                                    badgeContent: Text('${signProvider.signFileInfoList[index].cnt}'),
                                    badgeStyle: badges.BadgeStyle(
                                      badgeColor: AppColors.BLUE_LIGHT,
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: whPreSign,
                                      height: whPreSign,
                                      decoration: (signProvider.parentSignFileInfoIdx == index)
                                          ? BoxDecoration(
                                              color: Colors.grey[200], border: Border.all(color: Colors.black, width: 2))
                                          : const BoxDecoration(),
                                      child: signProvider.signFileInfoList[index].image,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 10,
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) => const Divider(),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _onTapSignNew,
                    child: Container(
                      width: whPreSign,
                      height: whPreSign,
                      margin: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                      alignment: Alignment.center,
                      color: Colors.black12,
                      child: const Icon(
                        Icons.miscellaneous_services,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////////
  // Event Start //
  ////////////////////////////////////////////////////////////////////////////////
  void _toggleButtonsSelect(idx) {
    dev.log('# ParentBar _toggleButtonsSelect START');
    dev.log('case idx: $idx');

    toggleSelectList = [false, false, false];
    switch (idx) {
      case 0:
        parentProvider.setParentBarEnum(ParentBarEnum.FRAME);
        toggleSelectList[0] = true;
        break;
      case 1:
        parentProvider.setParentBarEnum(ParentBarEnum.RESIZE);
        toggleSelectList[1] = true;

        //InfoUtil.initParentProviderBracket(parentProvider);   // ParentBar dispose 로 변경
        break;
      case 2:
        parentProvider.setParentBarEnum(ParentBarEnum.SIGN);
        toggleSelectList[2] = true;
        break;
    }
  }

  void _onPressedSizeInit() {
    dev.log('# ParentBar _onPressedSizeInit START');

    parentProvider.leftTopOffset = Offset(parentProvider.leftTopOffset.dx + 10, parentProvider.leftTopOffset.dy + 10);
    parentProvider.rightTopOffset =
        Offset(parentProvider.rightTopOffset.dx - 10, parentProvider.rightTopOffset.dy + 10);
    parentProvider.leftBottomOffset =
        Offset(parentProvider.leftBottomOffset.dx + 10, parentProvider.leftBottomOffset.dy - 10);
    parentProvider.rightBottomOffset =
        Offset(parentProvider.rightBottomOffset.dx - 10, parentProvider.rightBottomOffset.dy - 10);
    parentProvider.setParentBarEnum(ParentBarEnum.RESIZE); // for refresh

    Timer(const Duration(milliseconds: AppConfig.SIZE_INIT_INTERVAL), () {
      dev.log('# ParentBar _onPressedSizeInit Timer');
      parentProvider.clearParentBracket();

      // 한번 더 refresh 해야 함
      parentProvider.setParentBarEnum(ParentBarEnum.RESIZE); // for refresh
    });
  }

  void _onPressedSizeSave() async {
    dev.log('# ParentBar _onPressedSizeSave START');

    ////////////////////////////////////////////////////////////////////////////////
    bool leftTop = (parentProvider.leftTopOffset.dx.toInt() == parentProvider.xBlank.toInt() &&
        parentProvider.leftTopOffset.dy.toInt() == parentProvider.yBlank.toInt());
    bool rightTop =
        (parentProvider.rightTopOffset.dx.toInt() == (parentProvider.wScreen - parentProvider.xBlank).toInt() &&
            parentProvider.rightTopOffset.dy.toInt() == parentProvider.yBlank.toInt());
    bool leftBottom = (parentProvider.leftBottomOffset.dx.toInt() == parentProvider.xBlank.toInt() &&
        parentProvider.leftBottomOffset.dy.toInt() == (parentProvider.hScreen - parentProvider.yBlank).toInt());
    bool rightBottom =
        (parentProvider.rightBottomOffset.dx.toInt() == (parentProvider.wScreen - parentProvider.xBlank).toInt() &&
            parentProvider.rightBottomOffset.dy.toInt() == (parentProvider.hScreen - parentProvider.yBlank).toInt());

    // 변경된 것이 없으면 return
    if (leftTop && rightTop && leftBottom && rightBottom) {
      dev.log('_onPressedSizeSave SIZE_NO_CHANGE');
      PopupUtil.toastMsgShort('SIZE_NO_CHANGE'.tr());
      return;
    }
    ////////////////////////////////////////////////////////////////////////////////

    dev.log('_onPressedSizeSave SIZE_CHANGE');

    ////////////////////////////////////////////////////////////////////////////////
    // 새로 저장

    // 선택한 영역 구하기
    Offset leftTopOffset = parentProvider.leftTopOffset;
    Offset rightTopOffset = parentProvider.rightTopOffset;
    //Offset leftBottomOffset = parentProvider.leftBottomOffset;
    Offset rightBottomOffset = parentProvider.rightBottomOffset;
    double xBlank = parentProvider.xBlank;
    double yBlank = parentProvider.yBlank;
    double inScale = parentProvider.inScale;
    Rect srcRect = Offset((leftTopOffset.dx - xBlank) / inScale, (leftTopOffset.dy - yBlank) / inScale) &
        Size((rightTopOffset.dx - leftTopOffset.dx) / inScale, (rightBottomOffset.dy - rightTopOffset.dy) / inScale);
    dev.log('srcRect: $srcRect');

    // 저장할 영역 구하기
    Rect dstRect = const Offset(0, 0) & Size(srcRect.width, srcRect.height);

    // 그리기
    ui.Image uiImage = await FileUtil.loadUiImageFromPath(parentProvider.path!);
    ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder, dstRect);
    canvas.drawImageRect(uiImage, srcRect, dstRect, Paint());
    uiImage.dispose();

    // 새로 uiImage 생성
    ui.Image newImage =
        await pictureRecorder.endRecording().toImage(srcRect.width.toInt(), srcRect.height.toInt()); // 여기서 scaling 안됨

    // 화면에 보여주기
    Widget imageWidget = RawImage(
      image: newImage,
    );
    double wPopup = parentProvider.wScreen * 0.8;
    double hPopup = parentProvider.hScreen * 0.4;
    if (!mounted) return;
    PopupUtil.popupImageOkCancel(context, 'CONFIRM'.tr(), 'SIZE_SAVE_CONFIRM'.tr(), imageWidget, wPopup, hPopup)
        .then((ret) async {
      dev.log('popupImageOkCancel: $ret');

      // example
      if (ret == null) {
        // 팝업 바깥 영역을 클릭한 경우
        newImage.dispose();
        return;
      }
      if (ret == AppConstant.OK) {
        ////////////////////////////////////////////////////////////////////////////////
        File newImageFile = await FileUtil.initTempDirAndFile(AppConstant.PARENT_RESIZE_DIR, 'jpg');
        dev.log('newImageFile.path: ${newImageFile.path}');
        await FileUtil.saveUiImageToJpg(newImage, newImageFile);
        dev.log('writeAsBytesSync end');
        ////////////////////////////////////////////////////////////////////////////////

        ////////////////////////////////////////////////////////////////////////////////
        // 화면 갱신
        parentProvider.clearParentProvider();
        //parentProvider.path = newImageFile.path;
        //await parentProvider.initParenProvider(newImageFile.path);
        await parentProvider.initParenProviderWithPath(newImageFile.path);
        parentProvider.initParenProviderWithScreen(parentProvider.wScreen, parentProvider.hScreen);
        parentProvider.makeBringEnum = MakePageBringEnum.RESIZE;
        ////////////////////////////////////////////////////////////////////////////////

        dev.log('# ParentBar _onPressedSizeSave end');
        setState(() {});
      } else {
        newImage.dispose();
      }
    });
  }

  void _onTapSignNew() async {
    dev.log('# ParentBar _onTabSignNew START');

    if (!mounted) return;

    showModalBottomSheet(
        context: context,
        // 없으면 overflowed 에러 발생
        // A RenderFlex overflowed by 11 pixels on the bottom.
        isScrollControlled: true,
        enableDrag: false, // sign 하기 위해 아래로 드래그할대 close 막기
        //barrierDismissible: true, // 바깥 영역 터치시 창닫기
        builder: (BuildContext context) {
          return const SignMbs();
        }).then((ret) {
      dev.log('_onTapSignNew idx: $ret');
      if (ret == null || ret == 'CANCEL') {
      } else {
        // 위치 조정
        if (ret != -1) {
          double listWidth = wScreen - (whPreSign + 10 * 2) * 2;
          double cntPreSign = listWidth / (whPreSign + 10);
          dev.log('cntPreSign: $cntPreSign');

          _preSignController.animateTo(
            ret * (whPreSign + 10) - (whPreSign) * cntPreSign * 0.5 - 10 * 0.5,
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
          );
        }
      }
    });
  }

  void _onTapNone() {
    dev.log('# ParentBar _onTapNone START');
    _onTapPreSign(-1);
  }

  void _onTapPreSign(int idx) {
    dev.log('# ParentBar _onTapPreSign START index: $idx');

    if (idx == signProvider.parentSignFileInfoIdx) {
      return;
    }

    // 최초 위치
    // local position
    if (signProvider.parentSignOffset == null) {
      double xSign = parentProvider.wScreen -
          parentProvider.xBlank -
          parentProvider.whSign -
          parentProvider.whSign * AppConfig.SIGN_PADDING_FIRST;
      double ySign = MediaQuery.of(context).size.height -
          parentProvider.hBottomBlank -
          parentProvider.yBlank -
          parentProvider.whSign -
          parentProvider.whSign * AppConfig.SIGN_PADDING_FIRST -
          parentProvider.hTopBlank;
      signProvider.parentSignOffset = Offset(xSign, ySign);
    }
    dev.log('signProvider.parentSignOffset: $signProvider.parentSignOffset');

    // for test
    //signProvider.parentSignOffset = Offset(200, 200);

    signProvider.setParentSignFileInfoIdx(idx, notify: true);
  }
////////////////////////////////////////////////////////////////////////////////
// Event Start //
////////////////////////////////////////////////////////////////////////////////
}
