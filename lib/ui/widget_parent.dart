import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dto/info_parent.dart';
import '../provider/provider_make.dart';

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
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
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
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    child: Text('FRAME parentSize: ${makeProvider.parentSize}'),
                    onPressed: () {},
                  ),
                  ElevatedButton(
                    child: Text('FRAME parentResize: ${makeProvider.parentResize}'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          if (_makeParentEnum == MakeParentEnum.SIZE)
            (makeProvider.parentResize)
                ? Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(
                          child: Text('parentSize: ${makeProvider.parentSize}'),
                          onPressed: () {},
                        ),
                        ElevatedButton(
                          child: Text('parentResize: ${makeProvider.parentResize}'),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        OutlinedButton(
                          child: Text('parentSize: ${makeProvider.parentSize}'),
                          onPressed: () {},
                        ),
                        OutlinedButton(
                          child: Text('parentResize: ${makeProvider.parentResize}'),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
          if (_makeParentEnum == MakeParentEnum.SIGN)
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  OutlinedButton(
                    child: Text('SIGN parentSize: ${makeProvider.parentSize}'),
                    onPressed: () {},
                  ),
                  OutlinedButton(
                    child: Text('SIGN parentResize: ${makeProvider.parentResize}'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
        ],
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
        break;
      case MakeParentEnum.SIZE:
        dev.log('case MakeParentEnum.SIZE');
        toggleSelectList[1] = true;
        if (!mounted) return;
        context.read<MakeProvider>().setParentSize(true);
        break;
      case MakeParentEnum.SIGN:
        dev.log('case MakeParentEnum.SIGN');
        toggleSelectList[2] = true;
        if (!mounted) return;
        context.read<MakeProvider>().setParentSize(false);
        break;
    }

    //ParentInfo.xyOffset = const Offset(0, 0);
  }

  ////////////////////////////////////////////////////////////////////////////////

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
        break;
      case MakeParentEnum.SIZE:
        dev.log('case MakeParentEnum.SIZE');
        context.read<MakeProvider>().setParentSize(true);
        break;
      case MakeParentEnum.SIGN:
        context.read<MakeProvider>().setParentSize(false);
        break;
    }

    //ParentInfo.xyOffset = const Offset(0, 0);

    setState(() {});
  }

  /// end 는 dispose, 저장 버튼을 누른 경우
  void startResize(bool ir) {
    //isResize = ir;
    setState(() {
    });
  }

}
