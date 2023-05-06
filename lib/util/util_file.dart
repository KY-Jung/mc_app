import 'dart:developer' as dev;
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:image/image.dart' as IMG;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jpeg_encode/jpeg_encode.dart';
import 'package:path_provider/path_provider.dart';

import '../config/constant_app.dart';
import '../dto/info_parent.dart';

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

}

