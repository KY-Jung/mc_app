import 'package:flutter/cupertino.dart';

import '../dto/info_baby.dart';
import '../dto/info_caption.dart';
import '../dto/info_link.dart';
import '../dto/info_parent.dart';
import '../dto/info_sound.dart';
import '../ui/bar_parent.dart';

class MakeProvider with ChangeNotifier {

  /*
  ////////////////////////////////////////////////////////////////////////////////
  /// 설정 : ParentBar 에서 버튼 누를때, loadPreferences 할때
  /// 해제 : ParentBar 에서 버튼 누를때,
  ///       MakePage 에서 fab 를 눌러서 교체될때 (일일이 찾아서 처리해야 함)
  ///       ParentBar 에서 dispose 할때는 에러 발생해서 안됨
  bool _parentResize = false;
  bool get parentResize => _parentResize;
  void setParentResize(bool value) {
    _parentResize = value;
    notifyListeners();
  }
  void setParentResizeWithNoNotify(bool value) {
    _parentResize = value;
  }
  ////////////////////////////////////////////////////////////////////////////////
  */

  /*
  ////////////////////////////////////////////////////////////////////////////////
  // prefs 에 저장될 필요없음 (2023.05.18, KY.Jung)
  var _parentBarEnum = ParentBarEnum.FRAME;
  get parentBarEnum => _parentBarEnum;
  void setParentBarEnum(var value) {
    _parentBarEnum = value;
    notifyListeners();
  }
  //void setParentBarEnumWithNoNotify(var value) {
  //  _parentBarEnum = value;
  //}
  ////////////////////////////////////////////////////////////////////////////////
  */


  ////////////////////////////////////////////////////////////////////////////////
  /*
  bool _fabOpen = false;
  bool get fabOpen => _fabOpen;
  void setFabOpen(bool value) {
    _fabOpen = value;
    //notifyListeners();
  }
  */
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  ParentInfo? _parentInfo;
  BabyInfo? _babyInfo;
  CaptionInfo? _captionInfo;
  SoundInfo? _soundInfo;
  LinkInfo? _linkInfo;

  ParentInfo? get parentInfo => _parentInfo;
  set parentInfo(ParentInfo? value) {
    _parentInfo = value;
    notifyListeners();
  }

  BabyInfo? get babyInfo => _babyInfo;
  set babyInfo(BabyInfo? value) {
    _babyInfo = value;
    notifyListeners();
  }

  CaptionInfo? get captionInfo => _captionInfo;
  set captionInfo(CaptionInfo? value) {
    _captionInfo = value;
    notifyListeners();
  }

  SoundInfo? get soundInfo => _soundInfo;
  set soundInfo(SoundInfo? value) {
    _soundInfo = value;
    notifyListeners();
  }

  LinkInfo? get linkInfo => _linkInfo;
  set linkInfo(LinkInfo? value) {
    _linkInfo = value;
    notifyListeners();
  }
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  @override
  String toString() {
    return 'MakeProvider{_parentInfo: $_parentInfo, _babyInfo: $_babyInfo, _captionInfo: $_captionInfo, _soundInfo: $_soundInfo, _linkInfo: $_linkInfo}';
  }
  ////////////////////////////////////////////////////////////////////////////////

}
