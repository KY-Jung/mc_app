import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:jpeg_encode/jpeg_encode.dart';
import 'package:mc/config/constant_app.dart';
import 'package:mc/ui/screen_make.dart';
import 'package:mc/util/util_popup.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/config_app.dart';
import '../dto/info_parent.dart';
import '../provider/provider_make.dart';
import '../util/util_info.dart';

enum MakeParentEnum { FRAME, SIZE, SIGN }

class ParentWidget extends StatefulWidget {
  const ParentWidget({super.key});

  //final void Function(bool isSize) callbackParentSizeInitScreen;
  //const ParentWidget({required this.callbackParentSizeInitScreen, super.key});
  //const ParentWidget({ Key? key, required this.callbackParentSizeInitScreen, }) : super(key: key);

  @override
  State<ParentWidget> createState() => ParentWidgetState();
}

class ParentWidgetState extends State<ParentWidget> {
  ////////////////////////////////////////////////////////////////////////////////
  List<bool> toggleSelectList = [true, false, false];

  MakeParentEnum _makeParentEnum = MakeParentEnum.FRAME;

  //bool isResize = false;
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# ParentWidget initState START');
    super.initState();

    ////////////////////////////////////////////////////////////////////////////////
    /// 기본값으로 변경해야할 항목들 처리
    _initPreferences();

    /// frame, size, sign 선택 + 세부 항목
    _loadPreferences();
    ////////////////////////////////////////////////////////////////////////////////

    /*
    // ######################################################################## //
    // TODO : 임시 사용, 초기 화면 지정
    makeParentEnum = MakeParentEnum.SIZE;
    toggleSelectList = [false, true, false];

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(
          'MakeParentEnum', EnumToString.convertToString(makeParentEnum));
    });
    // ######################################################################## //
    */

    dev.log('# ParentWidget initState END');
  }

  @override
  void dispose() {
    dev.log('# ParentWidget dispose START');
    super.dispose();

    // 마지막 상태 저장
    // 맨 나중에 호출되어서 아래코드 효과없음
    //ParentInfo.isSize = false;
    // 아래 코드는 에러 유발
    //widget.callbackParentSizeInitScreen();

    //isResize = false;
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# ParentWidget build START');

    MakeProvider makeProvider = Provider.of<MakeProvider>(context);

    return Scaffold(
      //backgroundColor: Colors.yellow,
      backgroundColor: Colors.black87,
      body: GestureDetector(
        onTapDown: _onTapDownAll,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
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
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.06),
                      child: Text(
                        'FRAME'.tr(),
                      )),
                  Container(
                    //height: 40,
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.06),
                    child: Text(
                      'SIZE'.tr(),
                    ),
                  ),
                  Container(
                    //height: 40,
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.06),
                    child: Text(
                      'SIGN'.tr(),
                    ),
                  ),
                ],
              ),
            ),
            if (_makeParentEnum == MakeParentEnum.FRAME)
              Expanded(
                flex: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      child:
                          Text('FRAME parentSize: ${makeProvider.parentSize}'),
                      onPressed: () {},
                    ),
                    ElevatedButton(
                      child:
                          Text('FRAME parentSize: ${makeProvider.parentSize}'),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            if (_makeParentEnum == MakeParentEnum.SIZE)
              Expanded(
                flex: 5,
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
            if (_makeParentEnum == MakeParentEnum.SIGN)
              Expanded(
                flex: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    OutlinedButton(
                      child:
                          Text('SIGN parentSize: ${makeProvider.parentSize}'),
                      onPressed: () {},
                    ),
                    OutlinedButton(
                      child:
                          Text('SIGN parentSize: ${makeProvider.parentSize}'),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////////
  /// 초기화가 필요한 항목들 처리
  /// 1. Frame 선택, 목록에서 없음 선택
  /// 2. Size 에서 화면과 버튼 초기화
  /// 3. Sign 에서 선택 초기화 안함
  void _initPreferences() async {
    dev.log('# ParentWidget _initPreferences START');

    //SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.setString('MakeParentEnum', EnumToString.convertToString(makeParentEnum));
  }

  /// frame, size, sign 선택 + 세부 항목
  void _loadPreferences() async {
    dev.log('# ParentWidget _loadPreferences START');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var retPrefs = prefs.getString('MakeParentEnum');
    if (retPrefs == null) {
      // 처음인 경우
      _makeParentEnum = MakeParentEnum.FRAME;
      prefs.setString(
          'MakeParentEnum', EnumToString.convertToString(_makeParentEnum));
    } else {
      var retEnum = EnumToString.fromString(MakeParentEnum.values, retPrefs);
      if (retEnum == null) {
        // 에러 상황 (enum 에 없는 값이 저장된 경우)
        _makeParentEnum = MakeParentEnum.FRAME;
        prefs.setString(
            'MakeParentEnum', EnumToString.convertToString(_makeParentEnum));
      } else {
        _makeParentEnum = retEnum;
      }
    }
    dev.log('_makeParentEnum: $_makeParentEnum');

    toggleSelectList = [false, false, false];
    switch (_makeParentEnum) {
      case MakeParentEnum.FRAME:
        dev.log('case MakeParentEnum.FRAME');
        toggleSelectList[0] = true;
        if (!mounted) return;
        context.read<MakeProvider>().setParentSize(false);
        //makeProviderWatch.setParentSize(false);
        break;
      case MakeParentEnum.SIZE:
        dev.log('case MakeParentEnum.SIZE');
        toggleSelectList[1] = true;
        if (!mounted) return;
        context.read<MakeProvider>().setParentSize(true);
        //makeProviderWatch.setParentSize(true);
        break;
      case MakeParentEnum.SIGN:
        dev.log('case MakeParentEnum.SIGN');
        toggleSelectList[2] = true;
        if (!mounted) return;
        context.read<MakeProvider>().setParentSize(false);
        //makeProviderWatch.setParentSize(false);
        break;
    }

    //ParentInfo.xyOffset = const Offset(0, 0);
  }

  ////////////////////////////////////////////////////////////////////////////////
  // fab close 처리
  // 기존 이벤트는 그대로 처리
  void _onTapDownAll(TapDownDetails tapDownDetails) async {
    dev.log('_onTapDownAll');

    // fab close 처리 (provider 를 사용해서 닫기)
    MakeProvider makeProvider = Provider.of<MakeProvider>(context, listen: false);
    makeProvider.setFabOpen(false);
  }

  void _toggleButtonsSelect(idx) {
    dev.log('# ParentWidget _toggleButtonsSelect START');
    toggleSelectList = [false, false, false];
    switch (idx) {
      case 0:
        //if (makeParentEnum == MakeParentEnum.FRAME)  return;
        _makeParentEnum = MakeParentEnum.FRAME;
        toggleSelectList[0] = true;
        break;
      case 1:
        //if (makeParentEnum == MakeParentEnum.SIZE)  return;
        _makeParentEnum = MakeParentEnum.SIZE;
        toggleSelectList[1] = true;
        break;
      case 2:
        //if (makeParentEnum == MakeParentEnum.SIGN)  return;
        _makeParentEnum = MakeParentEnum.SIGN;
        toggleSelectList[2] = true;
        break;
    }
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(
          'MakeParentEnum', EnumToString.convertToString(_makeParentEnum));
    });

    // TODO : impl
    switch (_makeParentEnum) {
      case MakeParentEnum.FRAME:
        context.read<MakeProvider>().setParentSize(false);
        //makeProviderWatch.setParentSize(false);
        break;
      case MakeParentEnum.SIZE:
        dev.log('case MakeParentEnum.SIZE');
        context.read<MakeProvider>().setParentSize(true);
        //makeProviderWatch.setParentSize(true);
        break;
      case MakeParentEnum.SIGN:
        context.read<MakeProvider>().setParentSize(false);
        //makeProviderWatch.setParentSize(false);
        break;
    }

    //ParentInfo.xyOffset = const Offset(0, 0);

    setState(() {});
  }

  void _onPressedSizeInit() {
    dev.log('# ParentWidget _onPressedSizeInit START');
    ParentInfo.leftTopOffset = Offset(
        ParentInfo.leftTopOffset.dx + 10, ParentInfo.leftTopOffset.dy + 10);
    ParentInfo.rightTopOffset = Offset(
        ParentInfo.rightTopOffset.dx - 10, ParentInfo.rightTopOffset.dy + 10);
    ParentInfo.leftBottomOffset = Offset(ParentInfo.leftBottomOffset.dx + 10,
        ParentInfo.leftBottomOffset.dy - 10);
    ParentInfo.rightBottomOffset = Offset(ParentInfo.rightBottomOffset.dx - 10,
        ParentInfo.rightBottomOffset.dy - 10);
    context.read<MakeProvider>().setParentSize(true);
    //makeProviderWatch.setParentSize(true);

    Timer(const Duration(milliseconds: AppConfig.SIZE_INIT_INTERVAL), () {
      dev.log('# ParentWidget _onPressedSizeInit Timer');
      ParentInfo.leftTopOffset = Offset(ParentInfo.xBlank, ParentInfo.yBlank);
      ParentInfo.rightTopOffset =
          Offset(ParentInfo.wScreen - ParentInfo.xBlank, ParentInfo.yBlank);
      ParentInfo.leftBottomOffset =
          Offset(ParentInfo.xBlank, ParentInfo.hScreen - ParentInfo.yBlank);
      ParentInfo.rightBottomOffset = Offset(
          ParentInfo.wScreen - ParentInfo.xBlank,
          ParentInfo.hScreen - ParentInfo.yBlank);
      context.read<MakeProvider>().setParentSize(true);
      //makeProviderWatch.setParentSize(true);
    });

    //InfoUtil.setParentInfo(ParentInfo.path);
  }

  void _onPressedSizeSave() async {
    dev.log('# ParentWidget _onPressedSizeSave START');

    ////////////////////////////////////////////////////////////////////////////////
    bool leftTop =
        (ParentInfo.leftTopOffset.dx.toInt() == ParentInfo.xBlank.toInt() &&
            ParentInfo.leftTopOffset.dy.toInt() == ParentInfo.yBlank.toInt());
    bool rightTop = (ParentInfo.rightTopOffset.dx.toInt() ==
            (ParentInfo.wScreen - ParentInfo.xBlank).toInt() &&
        ParentInfo.rightTopOffset.dy.toInt() == ParentInfo.yBlank.toInt());
    bool leftBottom =
        (ParentInfo.leftBottomOffset.dx.toInt() == ParentInfo.xBlank.toInt() &&
            ParentInfo.leftBottomOffset.dy.toInt() ==
                (ParentInfo.hScreen - ParentInfo.yBlank).toInt());
    bool rightBottom = (ParentInfo.rightBottomOffset.dx.toInt() ==
            (ParentInfo.wScreen - ParentInfo.xBlank).toInt() &&
        ParentInfo.rightBottomOffset.dy.toInt() ==
            (ParentInfo.hScreen - ParentInfo.yBlank).toInt());

    if (leftTop && rightTop && leftBottom && rightBottom) {
      dev.log('_onPressedSizeSave SIZE_NOCHANGE');
      PopupUtil.toastMsgShort('SIZE_NOCHANGE'.tr());
      return;
    }
    ////////////////////////////////////////////////////////////////////////////////

    dev.log('_onPressedSizeSave SIZE_CHANGE');

    ////////////////////////////////////////////////////////////////////////////////
    // 새로 저장
    //ParentInfo.printParent();

    // 선택한 영역 구하기
    Offset leftTopOffset = ParentInfo.leftTopOffset;
    Offset rightTopOffset = ParentInfo.rightTopOffset;
    //Offset leftBottomOffset = ParentInfo.leftBottomOffset;
    Offset rightBottomOffset = ParentInfo.rightBottomOffset;
    double xBlank = ParentInfo.xBlank;
    double yBlank = ParentInfo.yBlank;
    double inScale = ParentInfo.inScale;
    Rect srcRect = Offset((leftTopOffset.dx - xBlank) / inScale,
            (leftTopOffset.dy - yBlank) / inScale) &
        Size((rightTopOffset.dx - leftTopOffset.dx) / inScale,
            (rightBottomOffset.dy - rightTopOffset.dy) / inScale);
    dev.log('srcRect: $srcRect');

    // 저장할 영역 구하기
    Rect dstRect = const Offset(0, 0) & Size(srcRect.width, srcRect.height);

    // 그리기
    ui.Image uiImage = await InfoUtil.loadUiImage(ParentInfo.path);
    PictureRecorder pictureRecorder = PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder, dstRect);
    canvas.drawImageRect(uiImage, srcRect, dstRect, Paint());
    ui.Image newImage = await pictureRecorder
        .endRecording()
        .toImage(srcRect.width.toInt(), srcRect.height.toInt());

    //Image image = Image.file(File(ParentInfo.path));
    Widget imageWidget = RawImage(
      image: newImage,
    );
    //if (!mounted) return;
    double wPopup = ParentInfo.wScreen * 0.8;
    double hPopup = ParentInfo.hScreen * 0.4;
    if (!mounted) return;
    PopupUtil.popupImageOkCancel(context, 'CONFIRM'.tr(),
            'SIZE_SAVE_CONFIRM'.tr(), imageWidget, wPopup, hPopup)
        .then((ret) async {
      dev.log('popupImageOkCancel: $ret');

      // example
      if (ret == null) {
        // 팝업 바깥 영역을 클릭한 경우
        return;
      }
      if (ret == AppConstant.OK) {
        // jpgByte 로 변환
        var rgbByte =
            await newImage.toByteData(format: ui.ImageByteFormat.rawRgba);
        var jpgByte = JpegEncoder().compress(
            rgbByte!.buffer.asUint8List(), newImage.width, newImage.height, 90);

        // byte 저장
        Directory appDir = await getApplicationDocumentsDirectory();
        dev.log('getApplicationDocumentsDirectory: $appDir');
        String newPath = '${appDir.path}/${AppConstant.PARENT_RESIZE_DIR}';
        dev.log('newPath: $newPath');
        File newPathFile = File(newPath);
        bool f = await newPathFile.exists(); // 항상 false --> ?
        try {
          if (f) {
            dev.log('newPathFile.exists: true');
            newPathFile.deleteSync(recursive: true);
          }
          newPathFile.deleteSync(recursive: true);
        } catch (e) {
          print(e);
        }

        // new 파일 생성
        String fileName = '${appDir.path}/${AppConstant.PARENT_RESIZE_DIR}/'
            '${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.jpg';
        File newImageFile = File(fileName);
        newImageFile.createSync(recursive: true);

        // byte 저장
        newImageFile.writeAsBytesSync(jpgByte.buffer.asUint8List(),
            flush: true, mode: FileMode.write);
        dev.log('writeAsBytesSync end');
        ////////////////////////////////////////////////////////////////////////////////

        ////////////////////////////////////////////////////////////////////////////////
        // 화면 갱신
        await InfoUtil.setParentInfo(fileName);
        ParentInfo.makeBringEnum = MakeBringEnum.RESIZE;
        ////////////////////////////////////////////////////////////////////////////////

        if (!mounted) return;
        context.read<MakeProvider>().setParentSize(false);
        context.read<MakeProvider>().setParentSize(true);
        //makeProviderWatch.setParentSize(true);
        dev.log('# ParentWidget _onPressedSizeSave end');
        setState(() {});
      }
    });
  }
}
