import 'package:flutter/material.dart';

class SizeService {
  SizeService._privateConstructor();
  static final SizeService instance = SizeService._privateConstructor();

  double screenHeight(context) {
    return MediaQuery.of(context).size.height;
  }

  double screenWidth(context) {
    return MediaQuery.of(context).size.width;
  }

  double draggableScrollableSheetInitialChildSize(context) {
    if (screenHeight(context) < 710) {
      return .1;
    } else if (screenHeight(context) > 711 && screenHeight(context) < 800) {
      return .08;
    } else {
      return .07;
    }
  }

  double timeHeaderChildAspectRatio(context) {
    if (screenWidth(context) < 374) {
      return 1.3;
    } else if (screenWidth(context) <= 375) {
      print(1.26);
      return 1.26;
    } else if (screenWidth(context) > 376 && screenWidth(context) < 390) {
      return 1.23;
    } else if (screenWidth(context) >= 390 && screenWidth(context) < 410) {
      return 1.2;
    } else if (screenWidth(context) >= 410 && screenWidth(context) < 415) {
      return 1.15;
    } else {
      return 1.11;
    }
  }
}
