import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image/image.dart' as IMG;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jpeg_encode/jpeg_encode.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

import '../dto/info_shapefile.dart';
import '../dto/info_signfile.dart';

class FileUtil {
  ////////////////////////////////////////////////////////////////////////////////
  // 이미지 읽어들이기 START
  ////////////////////////////////////////////////////////////////////////////////
  // asset/media 모두 사용
  static Future<ui.Image> loadUiImageFromPath(String path) async {
    Image image = Image.file(File(path));

    return changeImageToUiImage(image);
  }

  static Future<ui.Image> changeImageToUiImage(Image image) async {
    //final Image image = Image(image: AssetImage('assets/images/jeju.jpg'));
    Completer<ui.Image> completer = Completer<ui.Image>();
    image.image.resolve(const ImageConfiguration()).addListener(ImageStreamListener((ImageInfo image, bool _) {
      completer.complete(image.image);
    }));
    ui.Image uiImage = await completer.future;

    return uiImage;
  }

  static Future<ui.Image> changeImageToUiImageSize(Image image, double width, double height) async {
    //final Image image = Image(image: AssetImage('assets/images/jeju.jpg'));
    Completer<ui.Image> completer = Completer<ui.Image>();
    image.image
        .resolve(ImageConfiguration(size: Size(width, height))) // <-- size 지정해도 효과없음
        .addListener(ImageStreamListener((ImageInfo image, bool _) {
      completer.complete(image.image);
    }));
    ui.Image uiImage = await completer.future;

    return uiImage;
  }

  // 아래 함수는 asset 에서만 동작함
  // The asset does not exist or has empty data.
  static Future<ui.Image> loadUiImageFromAsset(String imageAssetPath, {int height = 0, int width = 0}) async {
    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    final codec = await ui.instantiateImageCodec(
      assetImageByteData.buffer.asUint8List(),
      targetHeight: (height == 0) ? null : height,
      targetWidth: (width == 0) ? null : width,
    );
    final image = (await codec.getNextFrame()).image;

    return image;
  }

  ////////////////////////////////////////////////////////////////////////////////
  // 이미지 읽어들이기 END
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // 파일, 디렉토리 START
  ////////////////////////////////////////////////////////////////////////////////
  static Future<List<String>> loadFileNameList(String dir) async {
    List<String> fileNameList = [];

    Directory appDir = await getApplicationDocumentsDirectory();
    dev.log('getApplicationDocumentsDirectory: $appDir');
    Directory directory = Directory('${appDir.path}/$dir/');

    bool fExist = await directory.exists();
    if (fExist) {
    } else {
      directory.createSync(recursive: true);
      return fileNameList;
    }

    List<FileSystemEntity> fileSystemEntityList = directory.listSync(recursive: true, followLinks: false);
    for (FileSystemEntity fileSystemEntity in fileSystemEntityList) {
      fileNameList.add(fileSystemEntity.path);
    }

    return fileNameList;
  }

  static Future<File> createFile(String dir, String ext) async {
    Directory appDir = await getApplicationDocumentsDirectory();
    dev.log('getApplicationDocumentsDirectory: $appDir');
    String fileName = '${appDir.path}/$dir/'
        '${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.$ext';
    File newImageFile = File(fileName);
    newImageFile.createSync(recursive: true);

    return newImageFile;
  }

  // 디렉토리 삭제
  // 디렉토리 생성
  // 파일 생성
  static Future<File> initTempDirAndFile(String dir, String ext) async {
    // 이전 파일 지우고 신규 파일명 구하기
    Directory appDir = await getApplicationDocumentsDirectory();
    dev.log('getApplicationDocumentsDirectory: $appDir');
    String newPath = '${appDir.path}/$dir';
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
      dev.log(e.toString());
    }
    String fileName = '${appDir.path}/$dir/'
        '${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.$ext';
    File newImageFile = File(fileName);
    newImageFile.createSync(recursive: true);

    return newImageFile;
  }

  ////////////////////////////////////////////////////////////////////////////////
  // 파일, 디렉토리 END
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // JPG, PNG START
  ////////////////////////////////////////////////////////////////////////////////
  static Future<bool> saveUiImageToJpg(ui.Image newImage, File newImageFile) async {
    // Uint8List 로 변환
    ByteData? rgbByte = await newImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    Uint8List jpgByte = JpegEncoder().compress(rgbByte!.buffer.asUint8List(), newImage.width, newImage.height, 98);
    // byte 저장
    newImageFile.writeAsBytesSync(jpgByte.buffer.asUint8List(), flush: true, mode: FileMode.write);

    return true;
  }

  static Future<bool> saveUiImageToPng(ui.Image newImage, File newImageFile) async {
    ByteData? jpgByte = await newImage.toByteData(format: ui.ImageByteFormat.png);
    // byte 저장
    newImageFile.writeAsBytesSync(jpgByte!.buffer.asUint8List(), flush: true, mode: FileMode.write);

    return true;
  }

  static Future<bool> resizeJpgWithFile(String oldPath, String newPath, int w, int h) async {
    // resize 하여 저장
    final cmd = IMG.Command()
      ..decodeImageFile(oldPath)
      ..copyResize(width: w, height: h)
      ..writeToFile(newPath);
    await cmd.executeThread();

    return true;
  }

  ////////////////////////////////////////////////////////////////////////////////
  // JPG, PNG END
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // Shape START
  ////////////////////////////////////////////////////////////////////////////////
  static Future<List<ShapeFileInfo>> loadShapeFileInfoList() async {
    // 약 1초 소요
    List<String> assetList = await readShapeFileList();

    List<ShapeFileInfo> shapeFileInfoList = [];
    int idx = 0;
    for (String fileName in assetList) {
      try {
        ShapeFileInfo shapeFileInfo = ShapeFileInfo();
        shapeFileInfo.fileName = fileName;
        shapeFileInfo.image = SvgPicture.asset(fileName);
        //dev.log('fileName: $file');

        String xmlString = await rootBundle.loadString(fileName);
        //print('xmlString: ${xmlString}');
        //print('--------------');
        XmlDocument xmlDocument = XmlDocument.parse(xmlString);
        Iterable<XmlElement> xmlElementIterable = xmlDocument.findAllElements('path');
        List<XmlElement> xmlElementist = xmlElementIterable.toList();
        //print('xmlElementist: $xmlElementist');
        for (XmlElement xmlElement in xmlElementist) {
          String? strFill = xmlElement.getAttribute('fill');
          if (strFill == null) {
            //Path path = parseSvgPath(xmlElement.getAttribute('d')!);
            Path path = parseSvgPathData(xmlElement.getAttribute('d')!);
            shapeFileInfo.path = path;
            //print('strFill11: ${xmlElement.getAttribute('d')}');
          } else {
            //print('strFill22: null');
          }
          //print('strFill: ${strFill}');
          //print('============= : ${pathElement.toString()}');
        }

        //print('${pathElement?.value}');
        //print('###########');
        shapeFileInfoList.add(shapeFileInfo);
      } catch (e) {
        dev.log('loadShapeFileInfoList exception $idx [$fileName]: $e');
      }
      idx++;
    }

    return shapeFileInfoList;
  }

  static Future<List<String>> readShapeFileList() async {
    String manifestContent = await rootBundle.loadString('AssetManifest.json');
    Map<String, dynamic> manifestMap = json.decode(manifestContent);
    //print('manifestMap list: $manifestMap');

    List<String> svgList = manifestMap.keys
        .where((String key) => key.contains('shape/'))
        //.where((String key) => key.contains('/ic_baby_'))
        .where((String key) => key.contains('.svg'))
        //.where((String key) => !key.contains('_all'))
        .toList();
    //print('svg list: $svgList');

    return svgList;
  }

  ////////////////////////////////////////////////////////////////////////////////
  // Shape END
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // Sign START
  ////////////////////////////////////////////////////////////////////////////////
  static List<String> extractFileNameAndCntFromSignFileInfoList(List<SignFileInfo> signFileInfoList, String delim2) {
    List<String> fileNameList = [];
    for (SignFileInfo signFileInfo in signFileInfoList) {
      String str = '${signFileInfo.fileName}$delim2${signFileInfo.cnt}';
      fileNameList.add(str);
    }

    return fileNameList;
  }

  static Future<List<SignFileInfo>> loadSignFileInfoList(String signDir) async {
    // 파일 목록 구하기
    List<String> fileNameList = await loadFileNameList(signDir);

    List<SignFileInfo> signFileInfoList = [];
    int idx = 0;
    for (String fileName in fileNameList) {
      try {
        SignFileInfo signFileInfo = SignFileInfo(fileName, Image.file(File(fileName)));
        //signFileInfo.fileName = fileName;
        //signFileInfo.image = Image.file(File(fileName));
        //dev.log('fileName: $file');

        signFileInfoList.add(signFileInfo);
      } catch (e) {
        dev.log('loadSignFileInfoList exception $idx [$fileName]: $e');
      }
      idx++;
    }

    return signFileInfoList;
  }

  /// fileNameList 에 없는 것은 반환하지 않음
  static List<SignFileInfo> reorderSignFileInfoListWithFileNameList(
      List<SignFileInfo> signFileInfoList, List<String> fileNameList, String delim2) {
    List<SignFileInfo> signFileInfoListNew = [];

    //dev.log('shapeFileInfoList: ${shapeFileInfoList.length}, fileNameList: ${fileNameList.length}');
    for (int fileIdx = 0, j = fileNameList.length; fileIdx < j; fileIdx++) {
      List<String> fileNameCntList = fileNameList[fileIdx].split(delim2);
      String fileName = fileNameCntList[0];
      String cnt = fileNameCntList[1];

      for (int infoIdx = 0, m = signFileInfoList.length; infoIdx < m; infoIdx++) {
        SignFileInfo signFileInfo = signFileInfoList[infoIdx];

        if (signFileInfo.fileName == fileName) {
          signFileInfo.cnt = int.parse(cnt);
          signFileInfoListNew.add(signFileInfo);
          break;
        }
      }
    }

    return signFileInfoListNew;
  }

  ////////////////////////////////////////////////////////////////////////////////
  // Sign END
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  // Shape/Sign START
  ////////////////////////////////////////////////////////////////////////////////
  static List<String> extractFileNameFromInfoList(List<dynamic> infoList) {
    List<String> fileNameList = [];
    for (var info in infoList) {
      fileNameList.add(info.fileName);
    }

    return fileNameList;
  }

  static List<String> extractFileNameFromContainerList(List<Container> containerList) {
    List<String> fileNameList = [];
    for (Container container in containerList) {
      String fileName = (container.key as ValueKey).value;
      fileNameList.add(fileName);
    }

    return fileNameList;
  }

  static dynamic findInfoWithFileName(List<dynamic> infoList, {String? fileName, Key? key}) {
    fileName ??= (key as ValueKey).value;
    for (var info in infoList) {
      if (info.fileName == fileName) {
        return info;
      }
    }

    return null;
  }

  // TODO : 주석으로 막기 (popup_shapelist.dar 를 없애야 함)
  static ShapeFileInfo? findShapeFileInfoWithFileName(List<ShapeFileInfo> shapeFileInfoList,
      {String? fileName, Key? key}) {
    fileName ??= (key as ValueKey).value;
    ShapeFileInfo shapeFileInfo;
    for (shapeFileInfo in shapeFileInfoList) {
      if (shapeFileInfo.fileName == fileName) {
        return shapeFileInfo;
      }
    }

    return null;
  }

  /// fileNameList 에 없는 것은 맨 마지막으로 밀려남
  /// infoList 가 유지됨
  static void reorderInfoListWithFileNameList(List<dynamic> infoList, List<String> fileNameList) {
    int newIdx = 0;
    for (int fileIdx = 0, j = fileNameList.length; fileIdx < j; fileIdx++) {
      for (int infoIdx = 0, m = infoList.length; infoIdx < m; infoIdx++) {
        var info = infoList[infoIdx];
        if (info.fileName == fileNameList[fileIdx]) {
          var findInfo = infoList.removeAt(infoIdx);
          infoList.insert(newIdx, findInfo);
          newIdx++;
          break;
        }
      }
    }
  }
////////////////////////////////////////////////////////////////////////////////
// Shape/Sign END
////////////////////////////////////////////////////////////////////////////////
}
