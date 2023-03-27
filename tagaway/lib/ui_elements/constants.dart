import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:tagaway/services/storeService.dart';

const kAltoURL = 'https://altocode.nl/dev';
const kAltoPicAppURL = kAltoURL + '/pic/app';
const kTagawayThumbSURL = kAltoURL + '/pic/app/thumb/S/';
const kTagawayThumbMURL = kAltoURL + '/pic/app/thumb/M/';
const kTagawayVideoURL = kAltoURL + '/pic/app/piv/';
const kTagawayHomeURL = kAltoURL + '/pic';
const kAltoBlue = Color(0xFF5b6eff);
const kAltoGreen = Color(0xFF04E762);
const kAltoOrganized = Color(0xFF00992b);
const kAltoRed = Color(0xFFD33E43);
const kAltoYellow = Color(0xFFffff00);
const kAltoRemove = Color(0xFFFC201F);
const kGreyLightest = Color(0xFFfbfbfb);
const kGreyLighter = Color(0xFFf2f2f2);
const kGreyLight = Color(0xFFdedede);
const kGrey = Color(0xFF8b8b8b);
const kGreyDarker = Color(0xFF484848);
const kGreyDarkest = Color(0xFF333333);
const kTagColor1 = Color(0xFFec5bff);
const kTagColor2 = Color(0xFFff5b6e);
const kTagColor3 = Color(0xFF5bffec);
const kTagColor4 = Color(0xFF4aff95);
const kTagColor5 = Color(0xFFffec5b);
const kTagColor6 = Color(0xFF80762e);
const kSelectedTag = Color(0xFFc1d4ff);

// FontAwesomeIcons.circleCheck
const kTagIcon = FontAwesomeIcons.tag;
const kEmptyCircle = FontAwesomeIcons.circle;
const kSolidCircleIcon = FontAwesomeIcons.solidCircle;
const kCircleCheckIcon = FontAwesomeIcons.solidCircleCheck;
const kClockIcon = FontAwesomeIcons.clock;
const kLocationDotIcon = FontAwesomeIcons.locationDot;
const kLocationPinIcon = FontAwesomeIcons.locationPin;
const kSearchIcon = FontAwesomeIcons.magnifyingGlass;
const kSlidersIcon = FontAwesomeIcons.sliders;
const kCameraIcon = FontAwesomeIcons.camera;
const kEllipsisIcon = FontAwesomeIcons.ellipsis;
const kMinusIcon = FontAwesomeIcons.minus;
const kBoxArchiveIcon = FontAwesomeIcons.boxArchive;
const kShareArrownUpIcon = FontAwesomeIcons.arrowUpFromBracket;
const kTrashCanIcon = FontAwesomeIcons.trashCan;
const kVideoIcon = FontAwesomeIcons.video;
const kAlert = FontAwesomeIcons.triangleExclamation;
const kEmailValidation = FontAwesomeIcons.envelopeCircleCheck;

const tagColors = [
  kTagColor1,
  kTagColor2,
  kTagColor3,
  kTagColor4,
  kTagColor5,
  kTagColor6
];

const kAcpicSplash = TextStyle(
  fontFamily: 'Montserrat',
  fontWeight: FontWeight.bold,
  fontSize: 50,
  color: kAltoBlue,
);

const kAcpicMain = TextStyle(
  fontFamily: 'Montserrat',
  fontWeight: FontWeight.bold,
  fontSize: 30,
  color: kAltoBlue,
);

const kLocalYear = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.bold,
    fontSize: 30,
    color: kGrey);

const kBigTitle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 25,
  color: kGreyDarker,
);

const kDarkBackgroundBigTitle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 25,
  color: kGreyLightest,
);

const kBigTitleOffline = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 25,
  color: kAltoBlue,
);

const kSubtitle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 20,
  color: kGreyDarker,
);

const kWhiteSubtitle = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: Colors.white);

const kPlainText = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 16,
  color: kGreyDarker,
);

const kPlainTextBold = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: kGreyDarker,
);

const kPlainHypertext = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14,
  color: kGreyDarker,
  decoration: TextDecoration.underline,
);

const kButtonText = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const kWhiteButtonText = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: kAltoBlue,
);

const kGridBottomRowText = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 12,
  fontWeight: FontWeight.bold,
  color: kGreyDarkest,
);

const kBottomNavigationText = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 12,
  fontWeight: FontWeight.bold,
);

const kSelectAllButton = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14,
  fontWeight: FontWeight.bold,
);

const kGoToWebButton = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: kAltoBlue);

const kLogOutButton = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: kAltoRed);

const kSnackBarText = TextStyle(
  fontWeight: FontWeight.bold,
  fontFamily: 'Montserrat',
  fontSize: 16,
  color: kGreyDarkest,
);

const kWhiteSnackBarText = TextStyle(
  fontWeight: FontWeight.bold,
  fontFamily: 'Montserrat',
  fontSize: 16,
  height: 1.5,
  color: kAltoBlue,
);

const kHomeEmptyText = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 22,
  color: kGreyDarker,
);

const kSubPageAppBarTitle = TextStyle(
  fontFamily: 'Montserrat',
  fontWeight: FontWeight.bold,
  fontSize: 25,
  color: kGreyDarker,
);

const kHomeTagBoxText = TextStyle(
  fontFamily: 'Montserrat',
  fontWeight: FontWeight.bold,
  fontSize: 25,
  color: kGreyDarkest,
);

const kTagListElementText = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 20,
  fontWeight: FontWeight.bold,
  color: kGreyDarker,
);

const kGridTagListElement = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: kGreyDarker,
);

const kDoneEditText = TextStyle(
  fontFamily: 'Montserrat',
  fontWeight: FontWeight.bold,
  fontSize: 20,
  color: kAltoBlue,
);

const kHorizontalMonth = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: kGreyDarker,
);

const kLookingAtText = TextStyle(
  fontFamily: 'Montserrat',
  fontWeight: FontWeight.bold,
  fontSize: 14,
  color: kGreyDarker,
);

const kOrganizedAmountOfPivs = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: kAltoOrganized,
);

const kUploadedAmountOfPivs = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: kGreyDarker,
);

int now() {
  return DateTime.now().millisecondsSinceEpoch;
}

int nowms = now();

void debug(List params) {
  String acc = 'DEBUG (' + (now() - nowms).toString() + 'ms)';
  params.forEach((v) => acc += ' ' + v.toString());
  print(acc);
}

Color tagColor(String tag) {
  var acc = 0;
  tag.split('').forEach((v) {
    acc += v.codeUnitAt(0);
  });
  return tagColors[acc % tagColors.length];
}

bool showLogs = false;

Future<dynamic> ajax(String method, String path, [dynamic body]) async {
  // We use getBeforeLoad in case we make an ajax call before the store service is initialized.
  String cookie = await StoreService.instance.getBeforeLoad('cookie');
  int start = now();
  if (showLogs)
    debug([
      'AJAX REQ:' + start.toString(),
      method.toUpperCase(),
      '/' + path,
      body
    ]);
  var response;
  try {
    if (method == 'get')
      response = await http.get(Uri.parse(kAltoPicAppURL + '/' + path),
          headers: {'cookie': cookie});
    else {
      if (path != 'auth/login' && path != 'auth/signup' && path != 'auth/recover')
        body['csrf'] = await StoreService.instance.get('csrf');
      response = await http.post(Uri.parse(kAltoPicAppURL + '/' + path),
          headers: {
            'Content-Type':
                method == 'post' ? 'application/json; charset=UTF-8' : '',
            'cookie': cookie
          },
          body: jsonEncode(body));
    }
    if (showLogs)
      debug([
        'AJAX RES:' + start.toString(),
        method,
        '/' + path,
        (now() - start).toString() + 'ms',
        response.statusCode,
        response.headers,
        jsonDecode(response.body == '' ? '{}' : response.body)
      ]);

    // If we get a 403, it should be because the cookie is invalid. We delete it locally.
    if (response.statusCode == 403) {
      await StoreService.instance.remove ('cookie', 'disk');
      await StoreService.instance.remove ('csrf', 'disk');
    }

    return {
      'code': response.statusCode,
      'headers': response.headers,
      'body': jsonDecode(response.body == '' ? '{}' : response.body)
    };
  } on SocketException catch (_) {
    return {'code': 0};
  }
}

Future<dynamic> ajaxMulti(String path, dynamic fields, dynamic filePath) async {
  var request =
      http.MultipartRequest('post', Uri.parse(kAltoPicAppURL + '/' + path));
  request.headers['cookie'] = await StoreService.instance.get('cookie');
  request.fields['csrf'] = await StoreService.instance.get('csrf');
  fields.forEach((k, v) => request.fields[k] = v.toString());
  request.files.add(await http.MultipartFile.fromPath('piv', filePath));
  int start = now();
  if (showLogs)
    debug([
      'AJAX MULTI REQ:' + start.toString(),
      'POST',
      '/' + path,
      fields,
      filePath
    ]);
  var response;
  try {
    var response = await request.send();
    String rbody = await response.stream.bytesToString();
    if (showLogs)
      debug([
        'AJAX MULTI RES:' + start.toString(),
        'POST',
        '/' + path,
        (now() - start).toString() + 'ms',
        response.statusCode,
        response.headers,
        jsonDecode(rbody == '' ? '{}' : rbody)
      ]);
    return {
      'code': response.statusCode,
      'headers': response.headers,
      'body': jsonDecode(rbody == '' ? '{}' : rbody)
    };
  } on SocketException catch (_) {
    return {'code': 0};
  }
}
