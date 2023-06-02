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
    var screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight < 710) {
      return .1;
    } else if (screenHeight > 711 && screenHeight < 800) {
      return .08;
    } else {
      return .07;
    }
  }

  double timeHeaderChildAspectRatio(context) {
    var screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 374) {
      return 1.08;
    } else if (screenWidth <= 375) {
      return 1.025;
    } else if (screenWidth < 390) {
      return 1.015;
    } else if (screenWidth < 410) {
      return .98;
    } else if (screenWidth < 415) {
      return .92;
    } else {
      return .9;
    }
  }

  double gridTagElementMaxWidthCalculator(context) {
    var screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 374) {
      return screenWidth * .28;
    } else if (screenWidth <= 375) {
      return screenWidth * .3;
    } else if (screenWidth < 390) {
      return screenWidth * .32;
    } else if (screenWidth < 410) {
      return screenWidth * .35;
    } else if (screenWidth < 415) {
      return screenWidth * .37;
    } else {
      return screenWidth * .4;
    }
  }

  double gridTagUploadedQueryElementMaxWidthCalculator(context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var numberOfTags = StoreService.instance.get('queryTags');
    if (numberOfTags == '') {
      numberOfTags = 0;
    } else {
      numberOfTags = numberOfTags.length;
    }
    if (screenWidth < 374 && numberOfTags <= 1) {
      return screenWidth * .6;
    } else if (screenWidth < 374 && numberOfTags > 1) {
      return screenWidth * .15;
    } else if (screenWidth <= 375 && numberOfTags <= 1) {
      return screenWidth * .6;
    } else if (screenWidth <= 375 && numberOfTags > 1) {
      return screenWidth * .18;
    } else if (screenWidth < 390 && numberOfTags <= 1) {
      return screenWidth * .65;
    } else if (screenWidth < 390 && numberOfTags > 1) {
      return screenWidth * .18;
    } else if (screenWidth < 410 && numberOfTags <= 1) {
      return screenWidth * .7;
    } else if (screenWidth < 410 && numberOfTags > 1) {
      return screenWidth * .2;
    } else if (screenWidth < 415 && numberOfTags <= 1) {
      return screenWidth * .7;
    } else if (screenWidth < 415 && numberOfTags > 1) {
      return screenWidth * .25;
    } else if (screenWidth >= 415 && numberOfTags <= 1) {
      return screenWidth * .7;
    } else if (screenWidth >= 415 && numberOfTags > 1) {
      return screenWidth * .28;
    } else {
      return 0;
    }
  }

  double thumbnailHeight (context) {
    return (MediaQuery.of(context).size.width / 2).round () - 1;
  }

}
