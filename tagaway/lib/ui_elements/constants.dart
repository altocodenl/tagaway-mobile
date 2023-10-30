import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const ENV = 'dev';
// const ENV = 'prod';

const version = '2.1.0';

const kAltoURL = 'https://altocode.nl/' + (ENV == 'dev' ? 'dev' : '');
const kTagawayURL = 'https://tagaway.nl/' + (ENV == 'dev' ? 'dev/' : '');
const kAltoPicAppURL = kTagawayURL + 'app';
const kTagawayThumbSURL = kTagawayURL + 'app/thumb/S/';
const kTagawayThumbMURL = kTagawayURL + 'app/thumb/M/';
const kTagawayVideoURL = kTagawayURL + 'app/piv/';
const kAltoURLDomain = 'altocode.nl';
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
// const kTagColor1 = Color(0xFFec5bff);
// const kTagColor2 = Color(0xFFff5b6e);
// const kTagColor3 = Color(0xFF5bffec);
// const kTagColor4 = Color(0xFF4aff95);
// const kTagColor5 = Color(0xFFffec5b);
// const kTagColor6 = Color(0xFF80762e);
// const kTagColor7 = Color(0xFFec755b);
// const kTagColor8 = Color(0xFF7b5bff);
// const kTagColor9 = Color(0xFF5b7bff);
// const kTagColor10 = Color(0xFF5bff7b);
// const kTagColor11 = Color(0xFFff5b7b);
// const kTagColor12 = Color(0xFFff7b5b);
const kSelectedTag = Color(0xFFc1d4ff);
const kTagColor1 = Color(0xFFec5bff);
const kTagColor2 = Color(0xFFfcc5c2);
const kTagColor3 = Color(0xFF7e6361);
const kTagColor4 = Color(0xFFff5b6e);
const kTagColor5 = Color(0xFF5bffec);
const kTagColor6 = Color(0xFF4aff95);
const kTagColor7 = Color(0xFF954aff);
const kTagColor8 = Color(0xFFffec5b);
const kTagColor9 = Color(0xFFc61bd6);
const kTagColor10 = Color(0xFFe38deb);
const kTagColor11 = Color(0xFFf1c6f5);
const kTagColor12 = Color(0xFFd841c7);

const kTagIcon = FontAwesomeIcons.tag;
const kTagsIcon = FontAwesomeIcons.tags;
const kUserTagIcon = FontAwesomeIcons.userTag;
const kEmptyCircle = FontAwesomeIcons.circle;
const kSolidCircleIcon = FontAwesomeIcons.solidCircle;
const kCircleCheckIcon = FontAwesomeIcons.solidCircleCheck;
const kSolidCircleLeft = FontAwesomeIcons.solidCircleLeft;
const kSolidCircleRight = FontAwesomeIcons.solidCircleRight;
const kClockIcon = FontAwesomeIcons.clock;
const kLocationDotIcon = FontAwesomeIcons.locationDot;
const kLocationPinIcon = FontAwesomeIcons.locationPin;
const kSearchIcon = FontAwesomeIcons.magnifyingGlass;
const kSlidersIcon = FontAwesomeIcons.sliders;
const kCameraIcon = FontAwesomeIcons.camera;
const kEllipsisIcon = FontAwesomeIcons.ellipsis;
const kEllipsisVerticalIcon = FontAwesomeIcons.ellipsisVertical;
const kMinusIcon = FontAwesomeIcons.minus;
const kBoxArchiveIcon = FontAwesomeIcons.boxArchive;
const kShareArrownUpIcon = FontAwesomeIcons.arrowUpFromBracket;
const kTrashCanIcon = FontAwesomeIcons.trashCan;
const kVideoIcon = FontAwesomeIcons.video;
const kAlert = FontAwesomeIcons.triangleExclamation;
const kEmailValidation = FontAwesomeIcons.envelopeCircleCheck;
const kPinIcon = FontAwesomeIcons.thumbtack;
const kArrowLeft = FontAwesomeIcons.arrowLeftLong;
const kCloudArrowUp = FontAwesomeIcons.cloudArrowUp;
const kPenToSquareSolidIcon = FontAwesomeIcons.solidPenToSquare;
const kHouseIcon = FontAwesomeIcons.house;
const kMobileScreenIcon = FontAwesomeIcons.mobileScreenButton;
const kEyeIcon = FontAwesomeIcons.eye;
const kSlashedEyeIcon = FontAwesomeIcons.eyeSlash;
const kMountainIcon = FontAwesomeIcons.mountain;
const kFlagIcon = FontAwesomeIcons.solidFontAwesome;
const kEndOfJourneyIcon = FontAwesomeIcons.roadCircleXmark;
const kStartOfJourneyIcon = FontAwesomeIcons.roadCircleCheck;
const kArrowRightLong = FontAwesomeIcons.arrowRightLong;
const kArrowLeftLong = FontAwesomeIcons.arrowLeftLong;
const kHomeIcon = FontAwesomeIcons.house;
const kMobilePhoneIcon = FontAwesomeIcons.mobileScreenButton;
const kBroomIcon = FontAwesomeIcons.broom;
const kPlusIcon = FontAwesomeIcons.plus;
const kGearIcon = FontAwesomeIcons.gear;
const kShareUsersIcon = FontAwesomeIcons.userGroup;
const kPersonDiggingIcon = FontAwesomeIcons.personDigging;
const kSelectAll = FontAwesomeIcons.checkDouble;

const tagColors = [
  kTagColor1,
  kTagColor2,
  kTagColor3,
  kTagColor4,
  kTagColor5,
  kTagColor6,
  kTagColor7,
  kTagColor8,
  kTagColor9,
  kTagColor10,
  kTagColor11,
  kTagColor12,
];

const kAcpicSplash = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontWeight: FontWeight.bold,
  fontSize: 50,
  color: kAltoBlue,
);

const kAcpicMain = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontWeight: FontWeight.bold,
  fontSize: 30,
  color: kAltoBlue,
);

const kLocalYear = TextStyle(
    fontFamily: 'Montserrat-Regular',
    fontWeight: FontWeight.bold,
    fontSize: 25,
    color: kGrey);

const kBigTitle = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 25,
  color: kGreyDarker,
);

const kDarkBackgroundBigTitle = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 25,
  color: kGreyLightest,
);

const kBigTitleOffline = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 25,
  color: kAltoBlue,
);

const kSubtitle = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 20,
  color: kGreyDarker,
);

const kQuerySelectorSubtitles = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontWeight: FontWeight.bold,
  fontSize: 20,
  color: kGreyDarker,
);

const kWhiteSubtitle = TextStyle(
    fontFamily: 'Montserrat-Regular',
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: Colors.white);

const kBlueAltocodeSubtitle = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontWeight: FontWeight.bold,
  fontSize: 20,
  color: kAltoBlue,
);

const kDeleteModalTitle = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontWeight: FontWeight.bold,
  fontSize: 20,
  color: kAltoRed,
);

const kPlainText = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 16,
  color: kGreyDarker,
);

const kPlainTextBold = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: kGreyDarker,
);

const kPlainTextBoldDarkest = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: kGreyDarker,
);

const kCenterPhoneGridTitle = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontWeight: FontWeight.bold,
  fontSize: 18,
  color: kAltoBlue,
);

const kPlainHypertext = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14,
  color: kGreyDarker,
  decoration: TextDecoration.underline,
);

const kButtonText = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const kWhiteButtonText = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: kAltoBlue,
);

const kSelectAllButton = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 14,
  fontWeight: FontWeight.bold,
);

const kStartButton = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 16,
  // fontWeight: FontWeight.bold,
);

const kGoToWebButton = TextStyle(
    fontFamily: 'Montserrat-Regular',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: kAltoBlue);

const kLogOutButton = TextStyle(
    fontFamily: 'Montserrat-Regular',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: kAltoRed);

const kLeftAndRightPhoneGridTitle = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: kGreyLight,
);

const kSnackBarText = TextStyle(
  fontWeight: FontWeight.bold,
  fontFamily: 'Montserrat-Regular',
  fontSize: 16,
  color: kGreyDarkest,
);

const kWhiteSnackBarText = TextStyle(
  fontWeight: FontWeight.bold,
  fontFamily: 'Montserrat-Regular',
  fontSize: 16,
  height: 1.5,
  color: kAltoBlue,
);

const kHomeEmptyText = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 22,
  color: kGreyDarker,
);

const kSubPageAppBarTitle = TextStyle(
  fontFamily: 'Montserrat-Regular',
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
  fontFamily: 'Montserrat-Regular',
  fontSize: 20,
  fontWeight: FontWeight.bold,
  color: kGreyDarker,
);

const kHomeStackedTagText = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 20,
  color: kGreyDarkest,
);

const kGridTagListElement = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: kGreyDarker,
);

const kGridDeleteElement = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: kAltoRed,
);

const kGridTagListElementBlue = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: kAltoBlue,
);

const kDoneEditText = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontWeight: FontWeight.bold,
  fontSize: 20,
  color: kAltoBlue,
);

const kHorizontalMonth = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 16,
  // fontWeight: FontWeight.bold,
  color: kGreyDarker,
);

const kLookingAtText = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontWeight: FontWeight.bold,
  fontSize: 14,
  color: kGreyDarker,
);

const kOrganizedAmountOfPivs = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: kAltoOrganized,
);

const kUploadedAmountOfPivs = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: kGreyDarker,
);

const kGridBottomRowText = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 12,
  fontWeight: FontWeight.bold,
  color: kGreyDarkest,
);

const kBottomNavigationText = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 12,
  fontWeight: FontWeight.bold,
);

const kTaglineText = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 12,
  color: kGreyDarker,
);

const kTaglineTextBold = TextStyle(
  fontFamily: 'Montserrat-Regular',
  fontSize: 12,
  fontWeight: FontWeight.bold,
  color: kGreyDarker,
);

const shortMonthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];

const longMonthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

Color tagColor(String tag) {
  var acc = 0;
  tag.split('').forEach((v) {
    acc += v.codeUnitAt(0);
  });
  return tagColors[acc % tagColors.length];
}

String tagType(tag) {
  if (tag == 'u::') return 'untagged';
  if (tag == 't::') return 'toOrganize';
  if (tag == 'o::') return 'organized';
  if (RegExp('^d::[0-9]').hasMatch(tag)) return 'year';
  if (RegExp('^d::M').hasMatch(tag)) return 'month';
  if (RegExp('^g::').hasMatch(tag)) {
    if (RegExp('^g::[A-Z]{2}').hasMatch(tag))
      return 'country';
    else
      return 'city';
  }
  return 'usertag';
}

String tagTitle(tag) {
  var type = tagType(tag);
  if (type == 'untagged') return 'Untagged';
  if (type == 'toOrganize') return 'To Organize';
  if (type == 'organized') return 'Organized';
  if (type == 'year' || type == 'country' || type == 'city')
    return tag.substring(3);
  if (type == 'month') return shortMonthNames[int.parse(tag.substring(4)) - 1];
  return tag;
}

tagIcon(tag) {
  var type = tagType(tag);
  if (type == 'untagged') return kTagIcon;
  if (type == 'toOrganize') return kBoxArchiveIcon;
  if (type == 'organized') return kCircleCheckIcon;
  if (type == 'year' || type == 'month') return kClockIcon;
  if (type == 'country') return kLocationDotIcon;
  if (type == 'city') return kLocationPinIcon;
  return kTagIcon;
}

Color tagIconColor(tag) {
  var type = tagType(tag);
  if (type == 'untagged' || type == 'toOrganize') return kGrey;
  if (type == 'organized') return kAltoOrganized;
  if (type == 'year' || type == 'month') return kGreyDarker;
  if (type == 'country' || type == 'city') return kGreyDarker;
  return tagColor(tag);
}

String shorten(tag) {
  return tag.length < 15 ? tag : tag.substring(0, 15) + '...';
}
