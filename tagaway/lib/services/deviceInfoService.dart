// IMPORT FLUTTER PACKAGES
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  DeviceInfoService._privateConstructor ();

  static final DeviceInfoService instance =
      DeviceInfoService._privateConstructor ();

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin ();

  Future<String> androidInfo () async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.model;
  }

  Future<String?> iOSInfo () async {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.utsname.machine;
  }
}
