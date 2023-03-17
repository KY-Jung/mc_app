import 'package:flutter/cupertino.dart';

class McImageProvider with ChangeNotifier {
  String _imageId = 'image_id_1234';

  void setImageId(id) {
    _imageId = id;
    notifyListeners();
  }

  String getImageId() => _imageId;
}
