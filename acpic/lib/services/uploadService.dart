// IMPORT FLUTTER PACKAGES
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:core';
import 'dart:async';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:isolate';
//IMPORT SCREENS
import 'package:acpic/screens/grid.dart';
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/material_elements.dart';

class UploadService {
  UploadService._privateConstructor();
  static final UploadService instance = UploadService._privateConstructor();
  List<String> pathList = [];
  List<String> lastModifiedList = [];
  List<int> lengthList = [];
  List<String> bytesToStringList = [];

  Future<String> uploadStart(
      String op, String csrf, List tags, String cookie, int total) async {
    try {
      final response = await http.post(
        Uri.parse('https://altocode.nl/picdev/upload'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'cookie': cookie
        },
        body: jsonEncode(<String, dynamic>{
          'op': op,
          'csrf': csrf,
          'tags': tags,
          'total': total
        }),
      );
      if (response.statusCode == 200) {
        return response.body.substring(6, response.body.indexOf('}'));
      } else {
        print(response.statusCode);
        print(response.body);
        return 'error';
      }
    } on SocketException catch (_) {
      return 'offline';
    }
  }

  Future<int> uploadEnd(String op, String csrf, int id, String cookie) async {
    try {
      final response = await http.post(
        Uri.parse('https://altocode.nl/picdev/upload'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'cookie': cookie
        },
        body: jsonEncode(<String, dynamic>{'op': op, 'csrf': csrf, 'id': id}),
      );
      if (response.statusCode == 200) {
        // print(response.body);
        // print(response.headers);
        print('uploadEnd done');
        return response.statusCode;
      } else {
        print(response.statusCode);
        print(response.body);
        print(response.headers);
        return response.statusCode;
      }
    } on SocketException catch (_) {
      return 0;
    }
  }

  Future<int> uploadError(
      String csrf, Object error, int id, String cookie) async {
    try {
      final response = await http.post(
        Uri.parse('https://altocode.nl/picdev/upload'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'cookie': cookie
        },
        body: jsonEncode(<String, dynamic>{
          'op': 'error',
          'csrf': csrf,
          'id': id,
          'error': error
        }),
      );
      if (response.statusCode == 200) {
        print(response.body);
        print(response.headers);
        print('uploadError done');
        return response.statusCode;
      } else {
        print(response.statusCode);
        print(response.body);
        print(response.headers);
        return response.statusCode;
      }
    } on SocketException catch (_) {
      return 0;
    }
  }

  Timer onlineChecker;

  uploadOnlineChecker(BuildContext context, int id, String csrf, String cookie,
      List tags, List<AssetEntity> list) {
    onlineChecker = Timer.periodic(Duration(seconds: 3), (timer) {
      uploadRetry(context, id, csrf, cookie, tags, list);
    });
  }

  uploadRetry(BuildContext context, int id, String csrf, String cookie,
      List tags, List<AssetEntity> list) async {
    try {
      final result = await InternetAddress.lookup('altocode.nl');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        uploadMain(context, id, csrf, cookie, tags, list);
        print('connected');
        onlineChecker.cancel();
        Provider.of<ProviderController>(context, listen: false)
            .uploadingPausePlay(false);
      }
    } on SocketException catch (_) {
      print('not connected');
    }
  }

  uiReset(BuildContext context) {
    Provider.of<ProviderController>(context, listen: false)
        .selectAllTapped(false);
    Provider.of<ProviderController>(context, listen: false).redraw();
    Provider.of<ProviderController>(context, listen: false)
        .selectionInProcess(false);
    Provider.of<ProviderController>(context, listen: false)
        .showUploadingProcess(false);
    Provider.of<ProviderController>(context, listen: false)
        .uploadProgressFunction(0);
  }

  uiCancelReset(BuildContext context) {
    Provider.of<ProviderController>(context, listen: false)
        .showUploadingProcess(false);
    Provider.of<ProviderController>(context, listen: false)
        .selectionInProcess(true);
    Provider.of<ProviderController>(context, listen: false)
        .uploadProgressFunction(0);
  }

  uploadMain(BuildContext context, int id, String csrf, String cookie,
      List tags, List<AssetEntity> list) {
    uploadOne() async {
      if (list.isEmpty) {
        uploadEnd('complete', csrf, id, cookie);
        uiReset(context);
        print('Made it to the end');
        return false;
      }
      if (list.last.width == 00 && list.last.height == 00) {
        uploadEnd('cancel', csrf, id, cookie);
        list.clear();
        return false;
      }
      var asset = list[0];
      print(asset.type);
      var piv = asset.file;
      list.removeAt(0);
      Provider.of<ProviderController>(context, listen: false)
          .uploadProgressFunction(
              Provider.of<ProviderController>(context, listen: false)
                      .selectedItems
                      .length -
                  list.length);
      File image = await piv;
      var uri = Uri.parse('https://altocode.nl/picdev/piv');
      var request = http.MultipartRequest('POST', uri);
      try {
        request.headers['cookie'] = cookie;
        request.fields['id'] = id.toString();
        request.fields['csrf'] = csrf;
        request.fields['tags'] = tags.toString();
        request.fields['lastModified'] =
            asset.modifiedDateTime.millisecondsSinceEpoch.abs().toString();
        request.files.add(await http.MultipartFile.fromPath('piv', image.path));
        var response = await request.send();
        final respStr = await response.stream.bytesToString();
        print(respStr);
        print(
            'DEBUG response ' + response.statusCode.toString() + ' ' + respStr);
        if (response.statusCode == 409 && respStr == '{"error":"capacity"}') {
          uploadError(csrf, {'code': response.statusCode, 'error': respStr}, id,
              cookie);
          uiReset(context);
          SnackBarGlobal.buildSnackBar(
              context, 'You\'ve run out of space.', 'red');
          return false;
        } else if (response.statusCode >= 500) {
          uploadError(csrf, {'code': response.statusCode, 'error': respStr}, id,
              cookie);
          uiReset(context);
          SnackBarGlobal.buildSnackBar(
              context, 'Something is wrong on our side. Sorry.', 'red');
          return false;
        }
      } on SocketException catch (_) {
        print('Socket Exception');
        Provider.of<ProviderController>(context, listen: false)
            .uploadingPausePlay(true);
        SnackBarGlobal.buildSnackBar(
            context, 'You\'re offline. Upload paused.', 'red');
        list.insert(0, asset);
        uploadOnlineChecker(context, id, csrf, cookie, tags, list);
        return false;
      } on Exception {
        print('Exception');
        Provider.of<ProviderController>(context, listen: false)
            .uploadingPausePlay(true);
        SnackBarGlobal.buildSnackBar(
            context, 'You\'re offline. Upload paused.', 'red');
        list.insert(0, asset);
        uploadOnlineChecker(context, id, csrf, cookie, tags, list);
        return false;
      }
      if (Platform.isIOS) {
        image.delete();
        PhotoManager.clearFileCache();
      } else {
        PhotoManager.clearFileCache();
      }
      return true;
    }

    Future.doWhile(uploadOne);
  }

  Future uploadDataForIsolate(
      BuildContext context, List<AssetEntity> list) async {
    // dataOfOne() async {
    //   if (list.isEmpty) {
    //     print('Done going through list');
    //     Provider.of<ProviderController>(context, listen: false)
    //         .dataForIsolateDoneLoading(true);
    //     return false;
    //   }
    var asset = list[0];
    var piv = asset.file;
    File image = await piv;
    String path = image.path;
    String lastModified =
        asset.modifiedDateTime.millisecondsSinceEpoch.abs().toString();
    int length = await image.length();
    var stream = new http.ByteStream(image.openRead());
    var streamToBytes = await stream.toBytes();
    String imageBytesToString = String.fromCharCodes(streamToBytes);
    pathList.insert(0, path);
    lastModifiedList.insert(0, lastModified);
    lengthList.insert(0, length);
    bytesToStringList.insert(0, imageBytesToString);
    list.removeAt(0);
    if (Platform.isIOS) {
      image.delete();
      PhotoManager.clearFileCache();
    } else {
      PhotoManager.clearFileCache();
    }
    //   return true;
    // }
    //
    // Future.doWhile(dataOfOne);
  }
}
