
import 'package:flutter/material.dart';

import '../config/enum_app.dart';
import '../dto/info_baby.dart';
import '../dto/info_caption.dart';
import '../dto/info_link.dart';
import '../dto/info_parent.dart';
import '../dto/info_sound.dart';

class MakeProvider with ChangeNotifier {

  ////////////////////////////////////////////////////////////////////////////////
  // MakeFab START
  ////////////////////////////////////////////////////////////////////////////////
  MakeFabEnum makeFabEnum = MakeFabEnum.PARENT;
  void setMakeFabEnum(var value) {
    makeFabEnum = value;
    notifyListeners();
  }
  ////////////////////////////////////////////////////////////////////////////////
  // MakeFab END
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
    return 'MakeProvider{_parentInfo: $_parentInfo, _babyInfo: $_babyInfo, '
        '_captionInfo: $_captionInfo, _soundInfo: $_soundInfo, _linkInfo: $_linkInfo}';
  }
  ////////////////////////////////////////////////////////////////////////////////

}
