// IMPORT FLUTTER PACKAGES
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// IMPORT UI ELEMENTS
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';

class UploadedView extends StatefulWidget {
  const UploadedView({Key? key}) : super(key: key);

  @override
  State<UploadedView> createState() => _UploadedViewState();
}

class _UploadedViewState extends State<UploadedView> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const TopRow(),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox.expand(
            child: DraggableScrollableSheet(
                snap: true,
                initialChildSize: .07,
                minChildSize: .07,
                maxChildSize: .77,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    child: Container(
                      color: Colors.white,
                      child: ListView(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        controller: scrollController,
                        children: [
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: FaIcon(
                                FontAwesomeIcons.anglesUp,
                                color: kGrey,
                                size: 16,
                              ),
                            ),
                          ),
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 8.0, bottom: 8),
                              child: Text(
                                'Swipe to start tagging',
                                style: kPlainTextBold,
                              ),
                            ),
                          ),
                          // const Center(
                          //   child: Padding(
                          //     padding: EdgeInsets.only(top: 8.0),
                          //     child: FaIcon(
                          //       FontAwesomeIcons.anglesDown,
                          //       color: kGrey,
                          //       size: 16,
                          //     ),
                          //   ),
                          // ),
                          // const Center(
                          //   child: Padding(
                          //     padding: EdgeInsets.only(top: 8.0, bottom: 8),
                          //     child: Text(
                          //       'Tag your pics and videos',
                          //       style: TextStyle(
                          //           fontFamily: 'Montserrat',
                          //           fontWeight: FontWeight.bold,
                          //           fontSize: 20,
                          //           color: kAltoBlue),
                          //     ),
                          //   ),
                          // ),
                          // const Center(
                          //   child: Padding(
                          //     padding: EdgeInsets.only(top: 8.0, bottom: 8),
                          //     child: Text(
                          //       'Choose a tag and select the pics & videos you want!',
                          //       textAlign: TextAlign.center,
                          //       style: kPlainTextBold,
                          //     ),
                          //   ),
                          // ),
                          TagListElement(
                            tagColor: kTagColor1,
                            tagName: 'Vacations',
                            onTap: () {},
                          ),
                          TagListElement(
                            tagColor: kTagColor2,
                            tagName: 'Vacations',
                            onTap: () {},
                          ),
                          TagListElement(
                            tagColor: kTagColor3,
                            tagName: 'Vacations',
                            onTap: () {},
                          ),
                          TagListElement(
                            tagColor: kTagColor4,
                            tagName: 'Vacations',
                            onTap: () {},
                          ),
                          TagListElement(
                            tagColor: kTagColor5,
                            tagName: 'Vacations',
                            onTap: () {},
                          ),
                          TagListElement(
                            tagColor: kTagColor6,
                            tagName: 'Vacations',
                            onTap: () {},
                          ),
                          TagListElement(
                            tagColor: kTagColor1,
                            tagName: 'Vacations',
                            onTap: () {},
                          ),
                          TagListElement(
                            tagColor: kTagColor2,
                            tagName: 'Vacations',
                            onTap: () {},
                          ),
                          TagListElement(
                            tagColor: kTagColor3,
                            tagName: 'Vacations',
                            onTap: () {},
                          ),
                          TagListElement(
                            tagColor: kTagColor4,
                            tagName: 'Vacations',
                            onTap: () {},
                          ),
                          TagListElement(
                            tagColor: kTagColor5,
                            tagName: 'Vacations',
                            onTap: () {},
                          ),
                          TagListElement(
                            tagColor: kTagColor6,
                            tagName: 'Vacations',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ),
      ],
    );
  }
}

class TopRow extends StatefulWidget {
  const TopRow({Key? key}) : super(key: key);

  @override
  State<TopRow> createState() => _TopRowState();
}

class _TopRowState extends State<TopRow> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Align(
                          alignment: Alignment(0.29, .9),
                          child: Text(
                            '2022',
                            textAlign: TextAlign.center,
                            style: kLocalYear,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Icon(
                          kSearchIcon,
                          color: kGreyDarker,
                          size: 25,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: GestureDetector(
                          onTap: () {},
                          child: Transform.rotate(
                            angle: 90 * -math.pi / 180.0,
                            child: const Icon(
                              kSlidersIcon,
                              color: kGreyDarker,
                              size: 25,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: SizedBox(
                    height: 80,
                    child: ListView(
                      reverse: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 1,
                          crossAxisSpacing: 0,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          childAspectRatio: 1.11,
                          children: const [
                            GridMonthElement(
                              roundedIcon: kSolidCircleIcon,
                              roundedIconColor: kGreyDarker,
                              month: 'Jul',
                              whiteOrAltoBlueDashIcon: Colors.white,
                            ),
                            GridMonthElement(
                              roundedIcon: kCircleCheckIcon,
                              roundedIconColor: kAltoOrganized,
                              month: 'Aug',
                              whiteOrAltoBlueDashIcon: Colors.white,
                            ),
                            GridMonthElement(
                              roundedIcon: kEmptyCircle,
                              roundedIconColor: kGreyDarker,
                              month: 'Sep',
                              whiteOrAltoBlueDashIcon: Colors.white,
                            ),
                            GridMonthElement(
                              roundedIcon: kCircleCheckIcon,
                              roundedIconColor: kAltoOrganized,
                              month: 'Oct',
                              whiteOrAltoBlueDashIcon: Colors.white,
                            ),
                            GridMonthElement(
                              roundedIcon: kSolidCircleIcon,
                              roundedIconColor: kGreyDarker,
                              month: 'Nov',
                              whiteOrAltoBlueDashIcon: Colors.white,
                            ),
                            GridMonthElement(
                              roundedIcon: FontAwesomeIcons.solidCircleCheck,
                              roundedIconColor: kAltoOrganized,
                              month: 'Dec',
                              whiteOrAltoBlueDashIcon: kAltoBlue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Container(
          height: 60,
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(width: 1, color: kGreyLighter)),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Row(
              children: const [
                // Padding(
                //   padding: EdgeInsets.only(right: 8.0),
                //   child: Text(
                //     'You’re looking at',
                //     style: kLookingAtText,
                //   ),
                // ),
                // GridTagElement(
                //     gridTagElementIcon: kCameraIcon,
                //     iconColor: kGreyDarker,
                //     gridTagName: 'Everything'),
                GridTagElement(
                    gridTagElementIcon: kClockIcon,
                    iconColor: kGreyDarker,
                    gridTagName: '2020'),
                GridTagElement(
                    gridTagElementIcon: kClockIcon,
                    iconColor: kGreyDarker,
                    gridTagName: 'May'),

                GridTagElement(
                    gridTagElementIcon: kLocationDotIcon,
                    iconColor: kGreyDarker,
                    gridTagName: 'AR'),
                GridSeeMoreElement(),
                Expanded(
                  child: Text(
                    '4,444',
                    textAlign: TextAlign.right,
                    style: kUploadedAmountOfPivs,
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}