import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MakeParentEnum { FRAME, SIZE, SIGN }

class ParentWidget extends StatefulWidget {
  const ParentWidget({super.key});

  @override
  State<ParentWidget> createState() => _ParentWidget();
}

class _ParentWidget extends State<ParentWidget> {
  ////////////////////////////////////////////////////////////////////////////////
  List<bool> toggleSelectList = [true, false, false];
  MakeParentEnum makeParentEnum = MakeParentEnum.FRAME;

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

    // ######################################################################## //
    // TODO : 임시 사용, 초기 화면 지정
    makeParentEnum = MakeParentEnum.SIZE;
    toggleSelectList = [false, true, false];

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(
          'MakeParentEnum', EnumToString.convertToString(makeParentEnum));
    });
    // ######################################################################## //

    dev.log('# ParentWidget initState END');
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# ParentWidget build START');

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
          if (makeParentEnum == MakeParentEnum.FRAME)
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  OutlinedButton(
                    child: Text('FRAME'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          if (makeParentEnum == MakeParentEnum.SIZE)
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  OutlinedButton(
                    child: Text('plus 1'),
                    onPressed: () {},
                  ),
                  OutlinedButton(
                    child: Text('plus 2'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          if (makeParentEnum == MakeParentEnum.SIGN)
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  OutlinedButton(
                    child: Text('SIGN'),
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
  Future _initPreferences() async {
    dev.log('# ParentWidget _initPreferences START');

    SharedPreferences prefs = await SharedPreferences.getInstance();

    //prefs.setString('MakeParentEnum', EnumToString.convertToString(makeParentEnum));
    //prefs.setString('MakeParentEnum', EnumToString.convertToString(makeParentEnum));
    //prefs.setString('MakeParentEnum', EnumToString.convertToString(makeParentEnum));
  }

  /// frame, size, sign 선택 + 세부 항목
  Future _loadPreferences() async {
    dev.log('# ParentWidget _checkPreferences START');

    SharedPreferences prefs = await SharedPreferences.getInstance();

    var retPrefs = prefs.getString('MakeParentEnum');
    if (retPrefs == null) {
      // 처음인 경우
      makeParentEnum = MakeParentEnum.FRAME;
      prefs.setString(
          'MakeParentEnum', EnumToString.convertToString(makeParentEnum));
    } else {
      var retEnum = EnumToString.fromString(MakeParentEnum.values, retPrefs);
      if (retEnum == null) {
        // 에러 상황 (enum 에 없는 값이 저장된 경우)
        makeParentEnum = MakeParentEnum.FRAME;
        prefs.setString(
            'MakeParentEnum', EnumToString.convertToString(makeParentEnum));
      } else {
        makeParentEnum = retEnum;
      }
    }
    dev.log('makeParentEnum: $makeParentEnum');
  }

  ////////////////////////////////////////////////////////////////////////////////

  void _toggleButtonsSelect(idx) {
    toggleSelectList = [false, false, false];
    switch (idx) {
      case 0:
        makeParentEnum = MakeParentEnum.FRAME;
        toggleSelectList[0] = true;
        break;
      case 1:
        makeParentEnum = MakeParentEnum.SIZE;
        toggleSelectList[1] = true;
        break;
      case 2:
        makeParentEnum = MakeParentEnum.SIGN;
        toggleSelectList[2] = true;
        break;
    }
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(
          'MakeParentEnum', EnumToString.convertToString(makeParentEnum));
    });

    // TODO : impl
    switch (makeParentEnum) {
      case MakeParentEnum.FRAME:
        break;
      case MakeParentEnum.SIZE:
        break;
      case MakeParentEnum.SIGN:
        break;
    }

    setState(() {});
  }
}
