import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tagaway/services/sizeService.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/services/tools.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/localGridItemView.dart';

class LocalView extends StatefulWidget {
  static const String id = 'local';

  const LocalView({Key? key}) : super(key: key);

  @override
  State<LocalView> createState() => _LocalViewState();
}

class _LocalViewState extends State<LocalView> {
  final PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    StoreService.instance.set('localPage', 0);
    pageController.addListener(() {
      var maxPage = StoreService.instance.get('localPagesLength');
      if (maxPage == '') maxPage = 0;
      if (pageController.page! >= maxPage)
        pageController.jumpToPage(maxPage - 1);
      StoreService.instance.set('localPage', pageController.page!.round());
    });
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return PageView.builder(
      reverse: true,
      controller: pageController,
      // We do not want the grid to be redrawn every time that the amount of local pages changes.
      // Therefore, we set it to a very high number and we restrict scrolling past the limit on the listener on the pageController.
      itemCount: 1000,
      pageSnapping: true,
      itemBuilder: (BuildContext context, int index) {
        return Stack(
          children: [
            Grid(localPagesIndex: index),
            TopRow(localPagesIndex: index),
            const DoneButton(view: 'Local'),
            const AddMoreTagsButton(view: 'Local'),
            const StartButton(buttonText: 'Start', view: 'Local'),
            const SelectAllButton(view: 'Local'),
            const DeleteButton(view: 'Local'),
            const TagButton(view: 'Local'),
            const TagPivsScrollableList(view: 'Local'),
            const DeleteModal(view: 'Local'),
            const RenameTagModal(view: 'Local'),
            const DeleteTagModal(view: 'Local'),
            PhoneAchievementsView(localPagesIndex: index)
          ],
        );
      },
    );
  }
}

class Grid extends StatefulWidget {
  const Grid({
    Key? key,
    required this.localPagesIndex,
  }) : super(key: key);

  final dynamic localPagesIndex;

  @override
  State<Grid> createState() => _GridState();
}

class _GridState extends State<Grid> {
  dynamic cancelListener;
  dynamic page = '';

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance
        .listen(['localPage:' + widget.localPagesIndex.toString()], (v1) {
      // If the list of ids in page['pivs'] is unchanged, we don't update the state to avoid redrawing the grid and experiencing a flicker.
      if (page != '') {
        var existingIds = page['pivs'].map((asset) => asset.id).toList();
        var newIds = v1['pivs'].map((asset) => asset.id).toList();
        if (const DeepCollectionEquality().equals(existingIds, newIds)) return;
      }
      setState(() {
        page = v1;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
  }

  @override
  Widget build(BuildContext context) {
    if (page == '')
      return Center(
        child: Container(
            color: Colors.grey[50],
            child: const CircularProgressIndicator(
              color: kAltoBlue,
            )),
      );
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, top: 180),
      child: page['pivs'].length == 0
          ? const Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: FaIcon(
                    kFlagIcon,
                    color: kAltoBlue,
                    size: 20,
                  ),
                ),
                FaIcon(
                  kMountainIcon,
                  color: kAltoBlue,
                  size: 40,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'You\'re all done!',
                    style: kPlainTextBold,
                  ),
                ),
              ],
            ))
          : SizedBox.expand(
              child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: GridView.builder(
                      reverse: true,
                      shrinkWrap: true,
                      cacheExtent: 50,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                      ),
                      itemCount: page['pivs'].length,
                      itemBuilder: (BuildContext context, index) {
                        return LocalGridItem(
                            page['pivs'][index], page['pivs'], 'local', 0);
                      })),
            ),
    );
  }
}

class TopRow extends StatefulWidget {
  const TopRow({
    Key? key,
    required this.localPagesIndex,
  }) : super(key: key);

  final dynamic localPagesIndex;

  @override
  State<TopRow> createState() => _TopRowState();
}

class _TopRowState extends State<TopRow> {
  dynamic cancelListener;

  dynamic currentlyTagging = '';
  dynamic prev = '';
  dynamic page = '';
  dynamic next = '';
  dynamic displayMode;

  @override
  void initState() {
    PhotoManager.requestPermissionExtend();
    super.initState();
    cancelListener = StoreService.instance.listen([
      'currentlyTaggingLocal',
      'localPage:' + (widget.localPagesIndex - 1).toString(),
      'localPage:' + widget.localPagesIndex.toString(),
      'localPage:' + (widget.localPagesIndex + 1).toString(),
      'displayMode'
    ], (v1, v3, v4, v5, DisplayMode) {
      setState(() {
        currentlyTagging = v1;
        prev = v3;
        page = v4;
        next = v5;
        displayMode = DisplayMode;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
  }

  @override
  Widget build(BuildContext context) {
    if (page == '') return Container();
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20, top: 10),
              child: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width:
                                SizeService.instance.screenWidth(context) * .7,
                            child: LinearProgressIndicator(
                              value: page['total'] == 0
                                  ? 1
                                  : max(
                                      (page['total'] - page['left']) /
                                          page['total'],
                                      0.1),
                              color: kAltoOrganized,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: SizeService.instance.screenWidth(context) <=
                                    375
                                ? SizeService.instance.screenWidth(context) *
                                    .11
                                : SizeService.instance.screenWidth(context) *
                                    .13,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 1),
                            child: PhoneViewSettings(),
                          )
                        ],
                      )),
                  Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              page['left'].toString() +
                                  (displayMode['cameraOnly']
                                      ? ' camera pivs'
                                      : '') +
                                  ' left',
                              style: kLookingAtText,
                            ),
                          ),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(next != '' ? next['title'] : '',
                              textAlign: TextAlign.center,
                              style: kLeftAndRightPhoneGridTitle,
                              key: Key('left-title' + now().toString())),
                        ),
                        Expanded(
                            child: Text(page['title'],
                                style: kCenterPhoneGridTitle,
                                textAlign: TextAlign.center,
                                key: Key('center-title' + now().toString()))),
                        Expanded(
                            child: Text(prev != '' ? prev['title'] : '',
                                textAlign: TextAlign.center,
                                style: kLeftAndRightPhoneGridTitle,
                                key: Key('right-title' + now().toString()))),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        currentlyTagging != ''
            ? Container(
                height: 60,
                width: double.infinity,
                decoration: const BoxDecoration(
                  border:
                      Border(top: BorderSide(width: 1, color: kGreyLighter)),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: Row(children: (() {
                    List<Widget> output = [];
                    output.add(const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Text(
                        'Now tagging with',
                        style: kLookingAtText,
                      ),
                    ));
                    currentlyTagging.forEach((tag) {
                      output.add(GridTagElement(
                          view: 'local',
                          gridTagElementIcon: tagIcon(tag),
                          iconColor: tagIconColor(tag),
                          gridTagName: tagTitle(tag)));
                    });

                    return output;
                  })()),
                ),
              )
            : Container()
      ],
    );
  }
}

class PhoneAchievementsView extends StatefulWidget {
  const PhoneAchievementsView({Key? key, required this.localPagesIndex})
      : super(key: key);

  final dynamic localPagesIndex;

  @override
  State<PhoneAchievementsView> createState() => _PhoneAchievementsViewState();
}

class _PhoneAchievementsViewState extends State<PhoneAchievementsView> {
  dynamic cancelListener;
  var currentPage;
  var rows = [];

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance.listen(
        ['localPage:' + widget.localPagesIndex.toString()], (LocalPage) {
      setState(() {
        currentPage = LocalPage;
        (() async {
          rows = await TagService.instance.getLocalAchievements(currentPage);
        })();
      });
    });

    // We add a timeout when we initialize the widget because `computeLocalPages` might not be done by the time we render this widget, and we need it to be done in order to render this widget correctly
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        currentPage = StoreService.instance
            .get('localPage:' + widget.localPagesIndex.toString());
        (() async {
          rows = await TagService.instance.getLocalAchievements(currentPage);
        })();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
  }

  @override
  Widget build(BuildContext context) {
    // No page loaded yet, or there are no pivs at all on the page, or there are pivs left to organize
    if (currentPage == '' ||
        currentPage['total'] == 0 ||
        currentPage['pivs'].length > 0) return Container();
    if (rows.length == 0) return Container();
    return Align(
      alignment: SizeService.instance.screenHeight(context) < 710
          ? const Alignment(0, 1)
          : SizeService.instance.screenHeight(context) > 860
              ? const Alignment(0, .5)
              : const Alignment(0, .7),
      child: Container(
        padding: const EdgeInsets.only(top: 20),
        width: SizeService.instance.screenWidth(context) * .85,
        height: SizeService.instance.screenHeight(context) < 710
            ? SizeService.instance.screenHeight(context) * .72
            : SizeService.instance.screenHeight(context) > 870
                ? SizeService.instance.screenHeight(context) * .55
                : SizeService.instance.screenHeight(context) > 711 &&
                        SizeService.instance.screenHeight(context) < 800
                    ? SizeService.instance.screenHeight(context) * .68
                    : SizeService.instance.screenHeight(context) * .62,
        decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            border: Border.all(color: kGreyLight, width: .5)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: SizeService.instance.screenHeight(context) < 710
                  ? const EdgeInsets.only(bottom: 10)
                  : const EdgeInsets.only(bottom: 20),
              child: const Text(
                'Congrats! You\'re done!',
                style: kCenterPhoneGridTitle,
              ),
            ),
            Column(
                children: rows.map((row) {
              if (row[0] == 'Total' || row[0] == 'All time organized')
                return Container();
              return GestureDetector(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 12.0),
                        child: FaIcon(
                          kTagIcon,
                          size: 20,
                          color: tagColor(row[0]),
                        ),
                      ),
                      Expanded(
                          child: Text(
                        row[0],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: TextStyle(
                          fontFamily: 'Montserrat-Regular',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kGreyDarker,
                        ),
                      )),
                      Text(
                        row[1].toString(),
                        style: kPhoneViewAchievementsNumber,
                      ),
                    ],
                  ),
                ),
              );
            }).toList()),
            Padding(
              padding:
                  EdgeInsets.only(top: 10.0, bottom: 20, left: 20, right: 20),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 12.0),
                    child: FaIcon(kCheckIcon, color: kAltoOrganized, size: 20),
                  ),
                  Expanded(
                      child: Text(
                    'Total',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontFamily: 'Montserrat-Regular',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kGreyDarker,
                    ),
                  )),
                  Text(
                    rows[rows.length - 2][1].toString(),
                    style: kPhoneViewAchievementsNumber,
                  ),
                ],
              ),
            ),
            Padding(
              padding: SizeService.instance.screenHeight(context) < 710
                  ? const EdgeInsets.only(
                      top: 10, bottom: 20, left: 20, right: 20)
                  : const EdgeInsets.only(
                      top: 10, bottom: 40, left: 20, right: 20),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 12.0),
                    child: FaIcon(kCircleCheckIcon,
                        color: kAltoOrganized, size: 20),
                  ),
                  Expanded(
                      child: Text(
                    'All time organized',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontFamily: 'Montserrat-Regular',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kGreyDarker,
                    ),
                  )),
                  Text(
                    rows[rows.length - 1][1].toString(),
                    style: kPhoneViewAchievementsNumber,
                  ),
                ],
              ),
            ),
            FloatingActionButton.extended(
              key: const Key('keepOnGoing'),
              onPressed: () {},
              extendedPadding: const EdgeInsets.only(left: 20, right: 20),
              heroTag: null,
              backgroundColor: kAltoBlue,
              elevation: 20,
              label: const Text('Keep Going!', style: kStartButton),
            )
          ],
        ),
      ),
    );
  }
}

class PhoneViewSettings extends StatefulWidget {
  const PhoneViewSettings({Key? key}) : super(key: key);

  @override
  State<PhoneViewSettings> createState() => _PhoneViewSettingsState();
}

class _PhoneViewSettingsState extends State<PhoneViewSettings> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return Container(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  color: Colors.white,
                  height: 250,
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: const [
                      Icon(
                        kMinusIcon,
                        color: kGreyDarker,
                        size: 30,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Settings',
                              style: kPlainTextBoldDarkest,
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Hide organized pivs',
                                    style: kPlainTextBold,
                                  ),
                                ),
                                Expanded(child: ShowOrganizedPivsSwitch()),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Show only camera pivs',
                                    style: kPlainTextBold,
                                  ),
                                ),
                                Expanded(child: ShowCameraPivs()),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ));
            });
      },
      child: const Center(
        child: FaIcon(
          kGearIcon,
          color: kGrey,
          size: 25,
        ),
      ),
    );
  }
}

class ShowOrganizedPivsSwitch extends StatefulWidget {
  const ShowOrganizedPivsSwitch({super.key});

  @override
  State<ShowOrganizedPivsSwitch> createState() => _ShowOrganizedPivsSwitch();
}

class _ShowOrganizedPivsSwitch extends State<ShowOrganizedPivsSwitch> {
  dynamic cancelListener;
  dynamic displayMode;

  @override
  void initState() {
    super.initState();
    cancelListener =
        StoreService.instance.listen(['displayMode'], (DisplayMode) {
      setState(() {
        displayMode = DisplayMode;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Transform.scale(
          scale: SizeService.instance.screenWidth(context) < 380 ? 1.2 : 1.5,
          child: Switch(
            activeTrackColor: kAltoBlue,
            activeColor: Colors.white,
            inactiveTrackColor: kGreyLight,
            value: displayMode['showOrganized'],
            onChanged: (bool value) {
              StoreService.instance.set('displayMode', {
                'showOrganized': value ? true : false,
                'cameraOnly': displayMode['cameraOnly']
              });
            },
          ),
        ),
      ],
    );
  }
}

class ShowCameraPivs extends StatefulWidget {
  const ShowCameraPivs({Key? key}) : super(key: key);

  @override
  State<ShowCameraPivs> createState() => _ShowCameraPivsState();
}

class _ShowCameraPivsState extends State<ShowCameraPivs> {
  dynamic cancelListener;
  dynamic displayMode;

  @override
  void initState() {
    super.initState();
    cancelListener =
        StoreService.instance.listen(['displayMode'], (DisplayMode) {
      setState(() {
        displayMode = DisplayMode;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Transform.scale(
          scale: SizeService.instance.screenWidth(context) < 380 ? 1.2 : 1.5,
          child: Switch(
            activeTrackColor: kAltoBlue,
            activeColor: Colors.white,
            inactiveTrackColor: kGreyLight,
            value: displayMode['cameraOnly'],
            onChanged: (bool value) {
              StoreService.instance.set('displayMode', {
                'showOrganized': displayMode['showOrganized'],
                'cameraOnly': value ? true : false
              });
            },
          ),
        ),
      ],
    );
  }
}
