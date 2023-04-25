import 'package:flutter/material.dart';
import 'package:tagaway/services/storeService.dart';

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

  double gridTagElementMaxWidthCalculator(context) {
    var screenWidth = MediaQuery.of(context).size.width;
    print(screenWidth);
    if (screenWidth < 374) {
      return screenWidth * .28;
    } else if (screenWidth <= 375) {
      print('.3');
      return screenWidth * .3;
    } else if (screenWidth > 376 && screenWidth < 390) {
      print('.32');
      return screenWidth * .32;
    } else if (screenWidth >= 390 && screenWidth < 410) {
      print('.35');
      return screenWidth * .35;
    } else if (screenWidth >= 410 && screenWidth < 415) {
      print('.37');
      return screenWidth * .37;
    } else {
      print('.4');
      return screenWidth * .4;
    }
  }

  double gridTagUploadedQueryElementMaxWidthCalculator(context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var numberOfTags = StoreService.instance.get('queryTags');
    if (numberOfTags == null || numberOfTags == '') {
      numberOfTags = 0;
    } else {
      numberOfTags = numberOfTags.length;
    }
    print(screenWidth);
    if (screenWidth < 374 && numberOfTags <= 1) {
      print('.6');
      return screenWidth * .6;
    } else if (screenWidth < 374 && numberOfTags > 1) {
      print('.15');
      return screenWidth * .15;
    } else if (screenWidth <= 375 && numberOfTags <= 1) {
      print('.6');
      return screenWidth * .6;
    } else if (screenWidth <= 375 && numberOfTags > 1) {
      print('.18');
      return screenWidth * .18;
    } else if (screenWidth > 376 && screenWidth < 390 && numberOfTags <= 1) {
      print('.65');
      return screenWidth * .65;
    } else if (screenWidth > 376 && screenWidth < 390 && numberOfTags > 1) {
      print('.18');
      return screenWidth * .18;
    } else if (screenWidth >= 390 && screenWidth < 410 && numberOfTags <= 1) {
      print('.7');
      return screenWidth * .7;
    } else if (screenWidth >= 390 && screenWidth < 410 && numberOfTags > 1) {
      print('.2');
      return screenWidth * .2;
    } else if (screenWidth >= 410 && screenWidth < 415 && numberOfTags <= 1) {
      print('.7');
      return screenWidth * .7;
    } else if (screenWidth >= 410 && screenWidth < 415 && numberOfTags > 1) {
      print('.25');
      return screenWidth * .25;
    } else if (screenWidth > 415 && numberOfTags <= 1) {
      print('.7');
      return screenWidth * .7;
    } else if (screenWidth > 415 && numberOfTags > 1) {
      print('.28');
      return screenWidth * .28;
    } else {
      print('.5');
      return screenWidth * .5;
    }
  }
}
