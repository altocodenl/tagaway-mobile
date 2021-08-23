// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

Future<String> checkPermission(BuildContext context) async {
  final serviceStatus = Platform.isIOS
      ? await Permission.photos.status
      : await Permission.storage.status;
  if (serviceStatus == PermissionStatus.granted) {
    print('granted');
    return 'granted';
  } else if (serviceStatus == PermissionStatus.denied) {
    print('denied');
    return 'denied';
  } else if (serviceStatus == PermissionStatus.limited) {
    print('limited');
    return 'limited';
  } else if (serviceStatus == PermissionStatus.restricted) {
    print('restricted');
    return 'restricted';
  } else if (serviceStatus == PermissionStatus.permanentlyDenied) {
    print('permanently denied');
    return 'permanent';
  }
}

class PermissionLevelFlag {
  final String permissionLevel;
  PermissionLevelFlag({this.permissionLevel});
}
