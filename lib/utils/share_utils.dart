import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

final String scrawlImagePath = '/screen_shot_scraw.png';

Future<File> getScreenShotFile() async {
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = '${tempDir.path}$scrawlImagePath';
  File image = File(tempPath);
  bool isExist = await image.exists();
  return isExist ? image : null;
}

Future<String> getScreenShotFilePath() async {
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = '${tempDir.path}$scrawlImagePath';
  File image = File(tempPath);
  bool isExist = await image.exists();
  return isExist ? tempPath : null;
}

Future saveScreenShot2SDCard(RenderRepaintBoundary boundary,
    {Function success, Function fail}) async {
  // check storage permission.
  if (await Permission.storage.request().isGranted) {
    capturePng2List(boundary).then((uint8List) async {
      if (uint8List == null || uint8List.length == 0) {
        if (fail != null) fail();
        return;
      }
      Directory tempDir = await getExternalStorageDirectory();
      _saveImage(uint8List, Directory('${tempDir.path}/flutter_ui'),
          '/screen_shot_scraw_${DateTime.now()}.png',
          success: success, fail: fail);
    });
  } else {
    if (fail != null) fail();
    return;
  }
}

void saveScreenShot(RenderRepaintBoundary boundary,
    {Function success, Function fail}) {
  capturePng2List(boundary).then((uint8List) async {
    if (uint8List == null || uint8List.length == 0) {
      if (fail != null) fail();
      return;
    }
    Directory tempDir = await getTemporaryDirectory();
    _saveImage(uint8List, tempDir, scrawlImagePath,
        success: success, fail: fail);
  });
}

void _saveImage(Uint8List uint8List, Directory dir, String fileName,
    {Function success, Function fail}) async {
  bool isDirExist = await Directory(dir.path).exists();
  if (!isDirExist) Directory(dir.path).create();
  String tempPath = '${dir.path}$fileName';
  File image = File(tempPath);
  bool isExist = await image.exists();
  if (isExist) await image.delete();
  File(tempPath).writeAsBytes(uint8List).then((_) {
    if (success != null) success();
  });
}

Future<Uint8List> capturePng2List(RenderRepaintBoundary boundary) async {
  ui.Image image =
      await boundary.toImage(pixelRatio: ui.window.devicePixelRatio);
  ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  Uint8List pngBytes = byteData.buffer.asUint8List();
  return pngBytes;
}
