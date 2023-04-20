import 'package:flutter/cupertino.dart';

import '../dto/info_baby.dart';
import '../dto/info_caption.dart';
import '../dto/info_link.dart';
import '../dto/info_parent.dart';
import '../dto/info_sound.dart';

class MakeProvider with ChangeNotifier {
  ////////////////////////////////////////////////////////////////////////////////
  /// 설정 : ParentWidget 에서 버튼 누를때, loadPreferences 할때
  /// 해제 : ParentWidget 에서 버튼 누를때,
  ///       MakeScreen 에서 fab 를 눌러서 교체될때 (일일이 찾아서 처리해야 함)
  ///       ParentWidget 에서 dispose 할때는 에러 발생해서 안됨
  bool _parentSize = false;
  bool get parentSize => _parentSize;
  void setParentSize(bool value) {
    _parentSize = value;
    notifyListeners();
  }

  bool _fabOpen = false;
  bool get fabOpen => _fabOpen;
  void setFabOpen(bool value) {
    _fabOpen = value;
    notifyListeners();
  }
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  ParentInfo? _parentInfo;
  BabyInfo? _babyInfo;
  CaptionInfo? _captionInfo;
  SoundInfo? _soundInfo;
  LinkInfo? _linkInfo;

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
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

  @override
  String toString() {
    return 'MakeProvider{_parentInfo: $_parentInfo, _babyInfo: $_babyInfo, _captionInfo: $_captionInfo, _soundInfo: $_soundInfo, _linkInfo: $_linkInfo}';
  }

////////////////////////////////////////////////////////////////////////////////
}
