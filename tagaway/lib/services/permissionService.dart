// IMPORT FLUTTER PACKAGES
import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

Future checkPermission() async {
  final androidInfo = await DeviceInfoPlugin().androidInfo;
  print(androidInfo.version.sdkInt);
  PermissionStatus serviceStatus = Platform.isIOS
      ? await Permission.photos.status
      : androidInfo.version.sdkInt <= 32
          ? await Permission.storage.status
          : await Permission.photos.status;
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
