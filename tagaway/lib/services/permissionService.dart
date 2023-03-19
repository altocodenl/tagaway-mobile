// IMPORT FLUTTER PACKAGES
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future checkPermission() async {
  final serviceStatus = Platform.isIOS
      ? await Permission.photos.status
      : await Permission.storage.status;
  if (serviceStatus == PermissionStatus.granted) {
    return 'granted';
  } else if (serviceStatus == PermissionStatus.denied) {
    return 'denied';
  } else if (serviceStatus == PermissionStatus.limited) {
    return 'limited';
  } else if (serviceStatus == PermissionStatus.restricted) {
    return 'restricted';
  } else if (serviceStatus == PermissionStatus.permanentlyDenied) {
    return 'permanent';
  }
}

class PermissionLevelFlag {
  final String permissionLevel;

  PermissionLevelFlag({required this.permissionLevel});
}
