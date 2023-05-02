import 'package:flutter/material.dart';

import '../dto/info_dot.dart';

class SignProvider with ChangeNotifier {

  List<List<DotInfo>> lines = <List<DotInfo>>[];

  ////////////////////////////////////////////////////////////////////////////////
  double _size = 10;
  double get size => _size;
  void changeSize(double size) {
    _size = size;
    //notifyListeners();
  }

  Color _color = Colors.black;
  Color get color => _color;
  void changeColor(Color color) {
    _color = color;
    //notifyListeners();
  }
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  void drawStart(Offset offset) {
    List<DotInfo> oneLine = <DotInfo>[];
    oneLine.add(DotInfo(offset, size, color));
    lines.add(oneLine);
    notifyListeners();
  }
  void drawing(Offset offset, double s) {
    lines.last.add(DotInfo(offset, s, null));
    notifyListeners();
  }
  void init() {
    lines.clear();
    notifyListeners();
  }

  ////////////////////////////////////////////////////////////////////////////////

}
