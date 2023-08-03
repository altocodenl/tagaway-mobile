import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const ENV = 'dev';
// const ENV = 'prod';

const version = '1.1.0';

const kAltoURL = 'https://altocode.nl/' + (ENV == 'dev' ? 'dev' : '');
const kTagawayURL = 'https://tagaway.nl/' + (ENV == 'dev' ? 'dev/' : '');
const kAltoPicAppURL = kTagawayURL + 'app';
const kTagawayThumbSURL = kTagawayURL + 'app/thumb/S/';
const kTagawayThumbMURL = kTagawayURL + 'app/thumb/M/';
const kTagawayVideoURL = kTagawayURL + 'app/piv/';
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
    fontSize: 25,
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

const kBlueAltocodeSubtitle = TextStyle(
  fontFamily: 'Montserrat',
  fontWeight: FontWeight.bold,
  fontSize: 20,
  color: kAltoBlue,
);

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

const kCenterPhoneGridTitle = TextStyle(
  fontFamily: 'Montserrat',
  fontWeight: FontWeight.bold,
  fontSize: 16,
  color: kAltoBlue,
);

const kDeleteModalTitle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: kAltoRed,
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

const kLeftAndRightPhoneGridTitle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: kGreyLight,
);

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

const kGridDeleteElement = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: kAltoRed,
);

const kGridTagListElementBlue = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: kAltoBlue,
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

const kTaglineText = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 12,
  color: kGreyDarker,
);

const kTaglineTextBold = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 12,
  fontWeight: FontWeight.bold,
  color: kGreyDarker,
);

Color tagColor(String tag) {
  var acc = 0;
  tag.split('').forEach((v) {
    acc += v.codeUnitAt(0);
  });
  return tagColors[acc % tagColors.length];
}

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
