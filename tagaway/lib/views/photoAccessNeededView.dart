// IMPORT FLUTTER PACKAGES
import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';

class PhotoAccessNeededView extends StatefulWidget {
  static const String id = 'photoAccessNeeded';

  const PhotoAccessNeededView({Key? key}) : super(key: key);

  @override
  _PhotoAccessNeededViewState createState() => _PhotoAccessNeededViewState();
}

class _PhotoAccessNeededViewState extends State<PhotoAccessNeededView> {
  late String brand;
  late String androidVersion;
  RegExp regExpAndroid6 = RegExp(r"6.*");
  RegExp regExpAndroid7 = RegExp(r"7.*");
  RegExp regExpAndroid8 = RegExp(r"8.*");
  RegExp regExpAndroid9 = RegExp(r"9.*");
  RegExp regExpAndroid10 = RegExp(r"10.*");
  RegExp regExpAndroid11 = RegExp(r"11.*");
  RegExp regExpAndroid12 = RegExp(r"12.*");

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  androidPlatformChecker() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    setState(() {
      brand = androidInfo.brand;
      androidVersion = androidInfo.version.release;
    });
  }

  @override
  void initState() {
    androidVersion = '1';
    if (Platform.isAndroid) {
      androidPlatformChecker();
    }
    super.initState();
  }

  String androidSettingsStep1() {
    if (Platform.isAndroid) {
      if (regExpAndroid9.hasMatch(androidVersion) ||
          regExpAndroid8.hasMatch(androidVersion) ||
          regExpAndroid7.hasMatch(androidVersion) ||
          regExpAndroid6.hasMatch(androidVersion)) {
        return ' Then ';
      } else {
        return ' Then tap on ';
      }
    } else {
      return '';
    }
  }

  String androidSettingsStep2() {
    if (Platform.isAndroid) {
      if (regExpAndroid12.hasMatch(androidVersion)) {
        return 'Files and media. \n\n';
      } else if (regExpAndroid11.hasMatch(androidVersion) &&
          brand != 'samsung') {
        return 'Files and media. \n\n';
      } else if (regExpAndroid11.hasMatch(androidVersion) &&
          brand == 'samsung') {
        return 'Storage. \n\n';
      } else if (regExpAndroid10.hasMatch(androidVersion)) {
        return 'Storage. \n\n';
      } else if (regExpAndroid9.hasMatch(androidVersion) ||
          regExpAndroid8.hasMatch(androidVersion) ||
          regExpAndroid7.hasMatch(androidVersion) ||
          regExpAndroid6.hasMatch(androidVersion)) {
        return 'slide right on the Storage slider. \n\n';
      } else {
        return 'Files and media. \n\n';
      }
    } else {
      return '';
    }
  }

  String androidSettingsPreStep3() {
    if (Platform.isAndroid) {
      if (regExpAndroid9.hasMatch(androidVersion) ||
          regExpAndroid8.hasMatch(androidVersion) ||
          regExpAndroid7.hasMatch(androidVersion) ||
          regExpAndroid6.hasMatch(androidVersion)) {
        return '';
      } else {
        return ' Change tagaway\'s access from ';
      }
    } else {
      return '';
    }
  }

  String androidSettingsDeny() {
    if (regExpAndroid12.hasMatch(androidVersion) ||
        regExpAndroid11.hasMatch(androidVersion) ||
        regExpAndroid10.hasMatch(androidVersion)) {
      return 'Deny';
    } else {
      return '';
    }
  }

  String settingsTo() {
    if (Platform.isAndroid) {
      if (regExpAndroid12.hasMatch(androidVersion) ||
          regExpAndroid11.hasMatch(androidVersion) ||
          regExpAndroid10.hasMatch(androidVersion)) {
        return ' to';
      } else {
        return '';
      }
    } else {
      return ' to';
    }
  }

  String androidSettingsStep3() {
    if (Platform.isAndroid) {
      if (regExpAndroid11.hasMatch(androidVersion) ||
          regExpAndroid12.hasMatch(androidVersion)) {
        return ' Allow access to media only.';
      } else if (regExpAndroid10.hasMatch(androidVersion)) {
        return ' Allow.';
      } else {
        return '';
      }
    } else {
      return ' All Photos.';
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // IMPLEMENT LifeCycleManager()

    // final flag =
    //     ModalRoute.of(context)!.settings.arguments as PermissionLevelFlag;
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Image.asset(
                  'images/tag blue with white - 400x400.png',
                  scale: 4,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'tagaway needs access to your photos.',
                  textAlign: TextAlign.center,
                  style: kBigTitle,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'We need access to your photos and videos in order to upload them to your account.',
                  textAlign: TextAlign.center,
                  style: kPlainText,
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: kPlainText,
                      children: <TextSpan>[
                        TextSpan(
                            text: Platform.isIOS
                                ? 'Tap on the button below to change tagaway\'s access from '
                                : 'Tap on the button below and go to '),
                        TextSpan(
                            text: Platform.isAndroid ? 'Permissions.' : '',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                          text: androidSettingsStep1(),
                        ),
                        TextSpan(
                            text: androidSettingsStep2(),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                          text: androidSettingsPreStep3(),
                        ),
                        TextSpan(
                            text:
                                Platform.isIOS ? 'None' : androidSettingsDeny(),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                          text: settingsTo(),
                        ),
                        TextSpan(
                            text: androidSettingsStep3(),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )),
              RoundedButton(
                title: 'Change settings',
                colour: kAltoBlue,
                onPressed: () {
                  openAppSettings();
                },
              ),
              const Padding(padding: EdgeInsets.all(0)),
            ],
          ),
        ),
      )),
    );
  }
}
