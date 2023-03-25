import 'dart:developer' as dev;
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../config/config_app.dart';
import '../dto/info_parent.dart';
import '../util/util_image.dart';

class MakeScreen extends StatefulWidget {
  const MakeScreen({super.key});

  @override
  State<MakeScreen> createState() => _MakeScreen();
}

class _MakeScreen extends State<MakeScreen> {
  ////////////////////////////////////////////////////////////////////////////////
  // variable
  /// true 이면 gallery/camera 버튼 표시
  bool isEmpty = true;

  late double wScreen;
  late double hScreen;

  late double xStart;
  late double yStart;
  late double xBlank;
  late double yBlank;

  /// 최초 InteractiveViewer 에 맞추어진 scale
  late double inScreenRatio;

  /// scale 된 Parent scale
  late double parentScale;

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // object
  //Matrix4 matrix4 = Matrix4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
  final TransformationController _transformationController =
      TransformationController(
          Matrix4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1));

  late TapDownDetails _doubleTapDetails;

  /// InteractiveViewer 화면 크기를 구할때 사용
  final GlobalKey _containerKey = GlobalKey();

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    dev.log('# MakeScreen initState START');
    super.initState();

    ////////////////////////////////////////////////////////////////////////////////
    /// build 이후 실행
    WidgetsBinding.instance.addPostFrameCallback((_) => _initScreen(context));
    ////////////////////////////////////////////////////////////////////////////////

    dev.log('# MakeScreen initState END');
  }

  @override
  void dispose() {
    dev.log('# MakeScreen dispose START');
    super.dispose();

    _transformationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dev.log('# MakeScreen build START');

    dev.log('isEmpty: $isEmpty');
    ////////////////////////////////////////////////////////////////////////////////
    // for test
    //Image image = const Image(image: AssetImage('assets/images/jeju.jpg'));
    //ParentInfo.image = image;
    //isEmpty = false;
    ////////////////////////////////////////////////////////////////////////////////

    return Scaffold(
      //backgroundColor: Colors.black87,  <-- 효과 없음
      appBar: AppBar(
        //backgroundColor: Colors.black,
        title: Text('MAKE_NEW'.tr()),

        actions: [
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(10),
            //padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              onTap: _onTabDelete,
              onLongPress: _onLongPressDelete,
              child: Ink(
                child: const Icon(Icons.delete),
              ),
            ),
          ),
        ],
      ),

      body: Scaffold(
        backgroundColor: Colors.black87,
        body: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand, // 비로소 상하 center 에 오게됨
          children: <Widget>[
            if (!isEmpty)
              InteractiveViewer(
                key: _containerKey,
                // for build 이후에 _initScreen 에서 InteractiveViewer 의 사이즈 구하기
                maxScale: AppConfig.MAKE_SCREEN_MAX,
                minScale: AppConfig.MAKE_SCREEN_MIN,
                transformationController: _transformationController,
                panEnabled: true,
                scaleEnabled: true,
                constrained: true,
                //panAxis: PanAxis.aligned,   // 중앙을 기준으로만 확대됨
                //boundaryMargin: const EdgeInsets.all(20.0),   // 이동시키면 공백이 나타남
                onInteractionStart: _onInteractionStart,
                onInteractionEnd: _onInteractionEnd,
                onInteractionUpdate: _onInteractionUpdate,
                //child: Image.asset("assets/images/jeju.jpg"),
                child: ParentInfo.image as Widget,
              ),
            if (!isEmpty)
              CustomPaint(
                // size 안 정해도 동작함
                //size: Size(MediaQuery.of(context).size.width,
                //    MediaQuery.of(context).size.height),
                painter: MyPainter(),
              ),
            if (isEmpty)
              Row(
                key: _containerKey,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton.icon(
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.lightGreen,
                    ),
                    label: Text("CAMERA".tr()),
                    style: TextButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: _cameraPressed,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(
                      Icons.photo,
                      color: Colors.amber,
                    ),
                    label: Text("GALLERY".tr()),
                    style: TextButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: _galleryPressed,
                  ),
                ],
              ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        child: const Text('close', style: TextStyle(fontSize: 24)),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  /// build 이후에 실행
  void _initScreen(context) async {
    dev.log('# MakeScreen _initScreen START');

    ////////////////////////////////////////////////////////////////////////////////
    /// InteractiveViewer 화면 크기
    RenderBox renderBox =
        _containerKey.currentContext!.findRenderObject() as RenderBox;
    Size screenSize = renderBox.size;
    dev.log('screenSize: $screenSize');
    wScreen = screenSize.width;
    hScreen = screenSize.height;
    ////////////////////////////////////////////////////////////////////////////////

  }

  void _cameraPressed() async {
    dev.log('# MakeScreen _cameraPressed START');

    // 끝나면 자동으로 build 호출
    // 취소하면 null 반환
    XFile? xFile = await ImagePicker().pickImage(source: ImageSource.camera);
    dev.log('file: ${xFile?.path}');
    if (xFile == null) return;

    _setParentInfo(File(xFile.path));

    setState(() {
      // setState() 추가.
      isEmpty = false;
    });
    dev.log('# MakeScreen _cameraPressed END');
  }

  void _galleryPressed() async {
    dev.log('# MakeScreen _galleryPressed START');

    // 끝나면 자동으로 build 호출
    // 취소하면 null 반환
    XFile? xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    dev.log('file: ${xFile?.path}');
    if (xFile == null) return;

    _setParentInfo(File(xFile.path));

    setState(() {
      // setState() 추가.
      isEmpty = false;
    });
    dev.log('# MakeScreen _galleryPressed END');
  }

  void _onInteractionStart(ScaleStartDetails scaleStartDetails) {
    print('_onInteractionStart focalPoint: ${scaleStartDetails.focalPoint}'
        ', localFocalPoint: ${scaleStartDetails.localFocalPoint}');
  }

  void _onInteractionEnd(ScaleEndDetails scaleEndDetails) {
    print('_onInteractionEnd velocity: ${scaleEndDetails.velocity}');
    dev.log(
        ' _transformationController.value: ${_transformationController.value}');
    dev.log(' Matrix4.identity(): ${Matrix4.identity()}');
  }

  void _onInteractionUpdate(ScaleUpdateDetails scaleUpdateDetails) {
    print('_onInteractionUpdate focalPoint: ${scaleUpdateDetails.focalPoint}'
        ', localFocalPoint: ${scaleUpdateDetails.localFocalPoint}'
        ', focalPointDelta: ${scaleUpdateDetails.focalPointDelta}'
        ', scale: ${scaleUpdateDetails.scale}'
        ', horizontalScale: ${scaleUpdateDetails.horizontalScale}'
        ', verticalScale: ${scaleUpdateDetails.verticalScale}'
        ', rotation: ${scaleUpdateDetails.rotation}');
  }

  void _tapDown(TapDownDetails details) {
    dev.log('# MakeScreen _tapDown START');
    // local x/y from image, global x/y from container
    dev.log('localPosition: ${details.localPosition}'
        ', globalPosition: ${details.globalPosition}');
  }

  void _doubleTapDown(TapDownDetails details) {
    dev.log('# MakeScreen _doubleTapDown START');
    dev.log('TapDownDetails: $details');
    _doubleTapDetails = details;
  }

  void _doubleTap() {
    dev.log('# MakeScreen _doubleTap START');
    dev.log(
        ' _transformationController.value: ${_transformationController.value}');
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails.localPosition;
      // For a 3x zoom
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
      // Fox a 2x zoom
      // ..translate(-position.dx, -position.dy)
      // ..scale(2.0);
    }
  }

  void _onTabDelete() {
    dev.log('delete onTap');
  }

  void _onLongPressDelete() {
    dev.log('delete onLongPressed');
  }
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  void _setParentInfo(path) async {

    ////////////////////////////////////////////////////////////////////////////////
    Image image = Image.file(path);
    ParentInfo.image = image;
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    /// Parent 이미지 크기 구하기
    Size imageSize = await ImageUtil.getImageSize(ParentInfo.image);
    dev.log('getImageSize: $imageSize');
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    /// Parent 이미지가 InteractiveViewer 에 맞추어진 ratio 구하기
    inScreenRatio = ImageUtil.calcFitRatioIn(
        wScreen, hScreen, imageSize.width, imageSize.height);
    dev.log('inScreenRatio: $inScreenRatio');
    ////////////////////////////////////////////////////////////////////////////////

  }
  ////////////////////////////////////////////////////////////////////////////////
}

////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // wScreen, hScreen 과 동일
    dev.log('# MyPainter paint START');

    Paint paint = Paint()
      ..color = Colors.deepPurpleAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    Offset p1 = Offset(0.0, 0.0);
    Offset p2 = Offset(size.width * 0.5, size.height * 0.5);

    canvas.drawLine(p1, p2, paint); // 선을 그림.
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
