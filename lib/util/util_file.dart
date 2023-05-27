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
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:xml/xml.dart';

import '../config/constant_app.dart';
import '../dto/info_parent.dart';
import '../dto/info_shape.dart';

class FileUtil {

  ////////////////////////////////////////////////////////////////////////////////
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
      print(e);
    }
    String fileName = '${appDir.path}/$dir/'
        '${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.$ext';
    File newImageFile = File(fileName);
    newImageFile.createSync(recursive: true);

    return newImageFile;
  }
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
  static Future<bool> saveUiImageToJpg(ui.Image newImage, File newImageFile) async {

    // Uint8List 로 변환
    ByteData? rgbByte = await newImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    Uint8List jpgByte = JpegEncoder().compress(
        rgbByte!.buffer.asUint8List(), newImage.width, newImage.height, 98);
    // byte 저장
    newImageFile.writeAsBytesSync(jpgByte.buffer.asUint8List(),
        flush: true, mode: FileMode.write);

    return true;
  }
  static Future<bool> saveUiImageToPng(ui.Image newImage, File newImageFile) async {

    ByteData? jpgByte = await newImage.toByteData(format: ui.ImageByteFormat.png);
    // byte 저장
    newImageFile.writeAsBytesSync(jpgByte!.buffer.asUint8List(),
        flush: true, mode: FileMode.write);

    return true;
  }
  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////
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

  ////////////////////////////////////////////////////////////////////////////////
  //static List<String>? SHAPE_LIST = null;
  static Future<List<String>> readShapeFileList() async {
    String manifestContent = await rootBundle.loadString('AssetManifest.json');
    Map<String, dynamic> manifestMap = json.decode(manifestContent);

    List<String> svgList = manifestMap.keys
        .where((String key) => key.contains('svg/'))
        //.where((String key) => key.contains('/ic_baby_'))
        .where((String key) => key.contains('.svg'))
        //.where((String key) => !key.contains('_all'))
        .toList();
    //print('svg list: $svgList');

    return svgList;
  }
  /*
  static Future<List<ShapeInfo>> loadShapeInfoList() async {
    // 약 1초 소요
    List<String> assetList = await readShapeFileList();

    List<ShapeInfo> shapeInfoList = [];
    int cnt = 0;
    for (String file in assetList) {
      try {
        ShapeInfo shapeInfo = ShapeInfo();
        shapeInfo.fileName = file;
        shapeInfo.svgPicture = SvgPicture.asset(file);
        //dev.log('fileName: $file');

        String xmlString = await rootBundle.loadString(file);
        //print('xmlString: ${xmlString}');
        //print('--------------');
        XmlDocument xmlDocument = XmlDocument.parse(xmlString);
        Iterable<XmlElement> xmlElementIterable = xmlDocument.findAllElements('path');
        List<XmlElement> xmlElementist = xmlElementIterable.toList();
        //print('xmlElementist: $xmlElementist');
        for (XmlElement xmlElement in xmlElementist) {
          String? strFill = xmlElement.getAttribute('fill');
          if (strFill == null) {
            Path path = parseSvgPath(xmlElement.getAttribute('d')!);
            shapeInfo.path = path;
            //print('strFill11: ${xmlElement.getAttribute('d')}');
          } else {
            //print('strFill22: null');
          }
          //print('strFill: ${strFill}');
          //print('============= : ${pathElement.toString()}');
        }

        //print('${pathElement?.value}');
        //print('###########');
        shapeInfoList.add(shapeInfo);
      } catch (e) {
        dev.log('loadShapeInfoList exception $cnt [$file]: $e');
      }
      cnt++;
    }

    return shapeInfoList;
  }
  */
  static Future<List<ShapeInfo>> loadShapeInfoList() async {
    // 약 1초 소요
    List<String> assetList = await readShapeFileList();

    List<ShapeInfo> shapeInfoList = [];
    int cnt = 0;
    for (String file in assetList) {
      try {
        ShapeInfo shapeInfo = ShapeInfo();
        shapeInfo.fileName = file;
        shapeInfo.svgPicture = SvgPicture.asset(file);
        //dev.log('fileName: $file');

        String xmlString = await rootBundle.loadString(file);
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
            shapeInfo.path = path;
            //print('strFill11: ${xmlElement.getAttribute('d')}');
          } else {
            //print('strFill22: null');
          }
          //print('strFill: ${strFill}');
          //print('============= : ${pathElement.toString()}');
        }

        //print('${pathElement?.value}');
        //print('###########');
        shapeInfoList.add(shapeInfo);
      } catch (e) {
        dev.log('loadShapeInfoList exception $cnt [$file]: $e');
      }
      cnt++;
    }

    return shapeInfoList;
  }
  static List<String> extractFileNameFromShapeInfoList(List<ShapeInfo> shapeInfoList) {
    List<String> fileNameList = [];
    for (ShapeInfo shapeInfo in shapeInfoList) {
      fileNameList.add(shapeInfo.fileName);
    }

    return fileNameList;
  }
  static List<String> extractFileNameFromShapeContainerList(List<Container> shapeContainerList) {
    List<String> fileNameList = [];
    for (Container container in shapeContainerList) {
      String fileName = (container.key as ValueKey).value;
      fileNameList.add(fileName);
    }

    return fileNameList;
  }
  static ShapeInfo? findShapeInfoWithFileName(List<ShapeInfo> shapeInfoList, {String? fileName, Key? key}) {
    fileName ??= (key as ValueKey).value;
    ShapeInfo shapeInfo;
    for (shapeInfo in shapeInfoList) {
      if (shapeInfo.fileName == fileName) {
        return shapeInfo;
      }
    }

    return null;
  }
  /*
  static void reorderingShapeInfoListWithFileNameList(List<ShapeInfo> shapeInfoList, List<String> fileNameList) {
    //dev.log('shapeInfoList: ${shapeInfoList.length}, fileNameList: ${fileNameList.length}');
    int listIdx = 0;
    int findIdx = 0;
    for (String fileName in fileNameList) {
      findIdx = listIdx;
      for (int i = findIdx, j = shapeInfoList.length; i < j; i++) {
      //for (ShapeInfo shapeInfo in shapeInfoList) {
        ShapeInfo shapeInfo = shapeInfoList[i];
        if (shapeInfo.fileName == fileName) {
          if (findIdx == listIdx) {
            listIdx++;
            break;
          }
          ShapeInfo findShapeInfo = shapeInfoList.removeAt(findIdx);
          shapeInfoList.insert(listIdx, findShapeInfo);
          listIdx++;
          break;
        }
        findIdx++;
      }
    }
  }
  */
  // shapeInfoList 의 순서를 조정
  /*
  static void reorderingShapeInfoListWithFileNameList(List<ShapeInfo> shapeInfoList, List<String> fileNameList) {
    //dev.log('shapeInfoList: ${shapeInfoList.length}, fileNameList: ${fileNameList.length}');
    for (int fileIdx = 0, j = fileNameList.length; fileIdx < j; fileIdx++) {
      for (int infoIdx = fileIdx, m = shapeInfoList.length; infoIdx < m; infoIdx++) {

        ShapeInfo shapeInfo = shapeInfoList[infoIdx];
        if (shapeInfo.fileName == fileNameList[fileIdx]) {
          if (fileIdx == infoIdx) {
            break;
          }
          ShapeInfo findShapeInfo = shapeInfoList.removeAt(infoIdx);
          shapeInfoList.insert(fileIdx, findShapeInfo);
          break;
        }
      }
    }
    // fileNameList 에 없는 것 지우기
    shapeInfoList.removeRange(fileNameList.length, shapeInfoList.length);
  }
  */
  static void reorderShapeInfoListWithFileNameList(List<ShapeInfo> shapeInfoList, List<String> fileNameList) {
    //dev.log('shapeInfoList: ${shapeInfoList.length}, fileNameList: ${fileNameList.length}');
    int newIdx = 0;
    for (int fileIdx = 0, j = fileNameList.length; fileIdx < j; fileIdx++) {
      for (int infoIdx = newIdx, m = shapeInfoList.length; infoIdx < m; infoIdx++) {

        ShapeInfo shapeInfo = shapeInfoList[infoIdx];
        if (shapeInfo.fileName == fileNameList[fileIdx]) {
          ShapeInfo findShapeInfo = shapeInfoList.removeAt(infoIdx);
          shapeInfoList.insert(newIdx, findShapeInfo);
          newIdx++;
          break;
        }
      }
    }
  }
  ////////////////////////////////////////////////////////////////////////////////

}

