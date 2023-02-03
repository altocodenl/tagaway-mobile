import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagaway/ui_elements/constants.dart';

class SnackBarGlobal {
  SnackBarGlobal._();

  static buildSnackBar(
      BuildContext context, String message, String backgroundColorSnackBar) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: kSnackBarText,
        ),
        backgroundColor: Color(backgroundColorSnackBar == 'green'
            ? 0xFF04E762
            : backgroundColorSnackBar == 'red'
                ? 0xFFD33E43
                : 0xFFffff00),
        //  var colors = {green: '#04E762', red: '#D33E43', yellow: '#ffff00'};
      ),
    );
  }
}

class SixSecondSnackBar {
  SixSecondSnackBar._();

  static buildSnackBar(
      BuildContext context, String message, String backgroundColorSnackBar) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: kSnackBarText,
        ),
        backgroundColor: Color(backgroundColorSnackBar == 'green'
            ? 0xFF04E762
            : backgroundColorSnackBar == 'red'
                ? 0xFFD33E43
                : 0xFFffff00),
        //  var colors = {green: '#04E762', red: '#D33E43', yellow: '#ffff00'};
      ),
    );
  }
}

class WhiteSnackBar {
  WhiteSnackBar._();

  static buildSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.left,
          style: kWhiteSnackBarText,
        ),
        backgroundColor: Colors.white,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.only(bottom: 50),
        padding: const EdgeInsets.all(20),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}

class RoundedButton extends StatelessWidget {
  const RoundedButton(
      {Key? key,
      required this.title,
      required this.colour,
      required this.onPressed})
      : super(key: key);

  final Color colour;
  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(title, style: kButtonText),
        style: ElevatedButton.styleFrom(
            backgroundColor: colour,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            minimumSize: const Size(200, 42)),
      ),
    );
  }
}

class HomeCard extends StatelessWidget {
  const HomeCard({
    Key? key,
    required this.color,
    required this.title,
  }) : super(key: key);

  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Container(
        height: 140,
        width: 1000,
        padding: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 20),
          child: Text(
            title,
            style: kHomeTagBoxText,
          ),
        ),
      ),
    );
  }
}

class TagListElement extends StatelessWidget {
  const TagListElement({
    Key? key,
    required this.tagColor,
    required this.tagName,
    required this.onTap,
  }) : super(key: key);

  final Color tagColor;
  final String tagName;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap(),
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Container(
          height: 70,
          width: 1000,
          decoration: const BoxDecoration(
              color: kGreyLighter,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: FaIcon(
                    FontAwesomeIcons.tag,
                    color: tagColor,
                  ),
                ),
                Text(
                  tagName,
                  style: kTagListElementText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditTagListElement extends StatelessWidget {
  const EditTagListElement({
    Key? key,
    required this.tagColor,
    required this.tagName,
    required this.onTapOnRedCircle,
    required this.onTagElementVerticalDragDown,
  }) : super(key: key);

  final Color tagColor;
  final String tagName;
  final Function onTapOnRedCircle;
  final Function onTagElementVerticalDragDown;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTapOnRedCircle(),
            child: Container(
              child: const Icon(
                FontAwesomeIcons.circleMinus,
                color: kAltoRed,
              ),
              color: Colors.transparent,
              margin: const EdgeInsets.only(left: 10, right: 12),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onVerticalDragDown: onTagElementVerticalDragDown(),
              child: Container(
                height: 70,
                decoration: const BoxDecoration(
                    color: kGreyLighter,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: FaIcon(
                          FontAwesomeIcons.tag,
                          color: tagColor,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          tagName,
                          style: kTagListElementText,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 12, right: 12.0),
                        child: FaIcon(
                          FontAwesomeIcons.bars,
                          color: kGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserMenuElementTransparent extends StatelessWidget {
  const UserMenuElementTransparent({
    Key? key,
    required this.textOnElement,
  }) : super(key: key);

  final String textOnElement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 20, top: 5),
      child: Container(
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Center(
            child: Text(
          textOnElement,
          style: kPlainTextBold,
        )),
      ),
    );
  }
}

class UserMenuElementLightGrey extends StatelessWidget {
  const UserMenuElementLightGrey({
    Key? key,
    required this.onTap,
    required this.textOnElement,
  }) : super(key: key);

  final Function onTap;
  final String textOnElement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 20, top: 5),
      child: GestureDetector(
        onTap: onTap(),
        child: Container(
          height: 50,
          decoration: const BoxDecoration(
            color: kGreyLight,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Center(
              child: Text(
            textOnElement,
            style: kPlainText,
          )),
        ),
      ),
    );
  }
}

class UserMenuElementDarkGrey extends StatelessWidget {
  const UserMenuElementDarkGrey({
    Key? key,
    required this.onTap,
    required this.textOnElement,
  }) : super(key: key);

  final Function onTap;
  final String textOnElement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 20, top: 5),
      child: GestureDetector(
        onTap: onTap(),
        child: Container(
          height: 50,
          decoration: const BoxDecoration(
            color: kGreyDarker,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Center(
              child: Text(textOnElement,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    color: Colors.white,
                  ))),
        ),
      ),
    );
  }
}

class GridMonthElement extends StatelessWidget {
  const GridMonthElement({
    Key? key,
    required this.roundedIcon,
    required this.roundedIconColor,
    required this.month,
    required this.whiteOrAltoBlueDashIcon,
  }) : super(key: key);

  final IconData roundedIcon;
  final Color roundedIconColor;
  final String month;
  final Color whiteOrAltoBlueDashIcon;

  // FontAwesomeIcons.solidCircleCheck
  // FontAwesomeIcons.solidCircle
  // FontAwesomeIcons.circle

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 40.0),
      child: Column(
        children: [
          FaIcon(
            roundedIcon,
            color: roundedIconColor,
            size: 16,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(month, style: kHorizontalMonth),
          ),
          FaIcon(
            FontAwesomeIcons.minus,
            color: whiteOrAltoBlueDashIcon,
          ),
        ],
      ),
    );
  }
}
