import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tagaway/services/sizeService.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/localGridItemView.dart';

class LocalYear extends StatefulWidget {
  const LocalYear({Key? key}) : super(key: key);

  @override
  State<LocalYear> createState() => _LocalYearState();
}

class _LocalYearState extends State<LocalYear> {
  dynamic cancelListener;
  dynamic year = '';

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance.listen([
      'localYear',
    ], (v1) {
      setState(() => year = v1);
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
  }

  @override
  Widget build(BuildContext context) {
    return Text(year.toString(),
        textAlign: TextAlign.center, style: kLocalYear);
  }
}

class LocalView extends StatefulWidget {
  static const String id = 'local';

  const LocalView({Key? key}) : super(key: key);

  @override
  State<LocalView> createState() => _LocalViewState();
}

class _LocalViewState extends State<LocalView> {
  dynamic cancelListener;
  final TextEditingController newTagName = TextEditingController();

  dynamic usertags = [];
  String currentlyTagging = '';
  bool swiped = false;
  dynamic newTag = '';
  dynamic startTaggingModal = '';

  // When clicking on one of the buttons of this widget, we want the ScrollableDraggableSheet to be opened. Unfortunately, the methods provided in the controller for it (`animate` and `jumpTo`) change the scroll position of the sheet, but not its height.
  // For this reason, we need to set the `initialChildSize` directly. This is not a clean solution, and it lacks an animation. But it's the best we've come up with so far.
  // For more info, refer to https://github.com/flutter/flutter/issues/45009
  double initialScrollableSize = StoreService.instance.get ('initialScrollableSize');
  double initialChildSize = StoreService.instance.get ('initialScrollableSize');

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance.listen([
      'usertags',
      'currentlyTaggingLocal',
      'swipedLocal',
      'newTagLocal',
      'startTaggingModal'
    ], (v1, v2, v3, v4, v5) {
      var currentView = StoreService.instance.get('currentIndex');
      // Invoke the service only if uploaded is not the current view
      if (v2 != '' && currentView != 2)
        TagService.instance.getTaggedPivs(v2, 'local');
      setState(() {
        if (v1 != '') usertags = v1;
        if (currentView != 2) {
          currentlyTagging = v2;
          if (v3 != '') swiped = v3;
          newTag = v4;
          startTaggingModal = v5;
          if (swiped == false && initialChildSize > initialScrollableSize)
            initialChildSize = initialScrollableSize;
          if (swiped == true && initialChildSize < 0.77)
            initialChildSize = 0.77;
        }
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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Stack(
      children: [
        const Grid(),
        const TopRow(),
        Visibility(
            visible: currentlyTagging != '',
            child: Align(
                alignment: const Alignment(0.8, .9),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    StoreService.instance.set('swipedLocal', false);
                    StoreService.instance.set('currentlyTaggingLocal', '');
                    // We update the tag list in case we just created a new one.
                    TagService.instance.getTags();
                  },
                  backgroundColor: kAltoBlue,
                  label: const Text('Done', style: kSelectAllButton),
                  icon: const Icon(Icons.done),
                ))),
        Visibility(
            visible: currentlyTagging == '',
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox.expand(
                  child: NotificationListener<DraggableScrollableNotification>(
                onNotification: (state) {
                  if (state.extent < (initialScrollableSize + 0.0001))
                    StoreService.instance.set('swipedLocal', false);
                  if (state.extent > (0.77 - 0.0001))
                    StoreService.instance.set('swipedLocal', true);
                  StoreService.instance.set('startTaggingModal', false);
                  return true;
                },
                child: DraggableScrollableSheet(
                    snap: true,
                    initialChildSize: initialChildSize,
                    minChildSize: initialScrollableSize,
                    maxChildSize: 0.77,
                    builder: (BuildContext context,
                        ScrollController scrollController) {
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
                              Visibility(
                                  visible: !swiped,
                                  child: const Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: FaIcon(
                                        FontAwesomeIcons.anglesUp,
                                        color: kGrey,
                                        size: 16,
                                      ),
                                    ),
                                  )),
                              Visibility(
                                  visible: !swiped,
                                  child: const Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(top: 8.0, bottom: 8),
                                      child: Text(
                                        'Swipe to start tagging',
                                        style: kPlainTextBold,
                                      ),
                                    ),
                                  )),
                              Visibility(
                                  visible: swiped,
                                  child: const Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: FaIcon(
                                        FontAwesomeIcons.anglesDown,
                                        color: kGrey,
                                        size: 16,
                                      ),
                                    ),
                                  )),
                              Visibility(
                                  visible: swiped,
                                  child: const Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(top: 8.0, bottom: 8),
                                      child: Text(
                                        'Tag your pics and videos',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: kAltoBlue),
                                      ),
                                    ),
                                  )),
                              Visibility(
                                  visible: swiped,
                                  child: const Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(top: 8.0, bottom: 8),
                                      child: Text(
                                        'Choose a tag and select the pics & videos you want!',
                                        textAlign: TextAlign.center,
                                        style: kPlainTextBold,
                                      ),
                                    ),
                                  )),
                              ListView.builder(
                                  itemCount: usertags.length,
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    var tag = usertags[index];
                                    return TagListElement(
                                      tagColor: tagColor(tag),
                                      tagName: tag,
                                      onTap: () {
                                        // We need to wrap this in another function, otherwise it gets executed on view draw. Madness.
                                        return () {
                                          StoreService.instance.set(
                                              'currentlyTaggingLocal', tag);
                                        };
                                      },
                                    );
                                  })
                            ],
                          ),
                        ),
                      );
                    }),
              )),
            )),
        Visibility(
            visible: newTag != '',
            child: Container(
              height: double.infinity,
              width: double.infinity,
              color: kAltoBlue.withOpacity(.8),
            )),
        Visibility(
            visible: newTag != '',
            child: Center(
                child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text(
                        'Create a new tag',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: kAltoBlue),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 12, right: 12, top: 20),
                      child: TextField(
                        controller: newTagName,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        enableSuggestions: true,
                        decoration: const InputDecoration(
                          hintText: 'Insert the name of your new tag here…',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              StoreService.instance.set('newTagLocal', '');
                              newTagName.clear();
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(right: 30.0),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: kAltoBlue),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              var text = newTagName.text;
                              if (text == '') return;
                              StoreService.instance.set('newTagLocal', '');
                              StoreService.instance
                                  .set('currentlyTaggingLocal', text);
                              newTagName.clear();
                            },
                            child: const Text(
                              'Create',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: kAltoBlue),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ))),
        Visibility(
            visible: newTag == '' && swiped == true && currentlyTagging == '',
            child: Align(
              alignment: const Alignment(0, .9),
              child: FloatingActionButton.extended(
                onPressed: () {
                  // We store `newTag` to `true` simply to enable visibility of the new tag modal
                  StoreService.instance.set('newTagLocal', true);
                },
                backgroundColor: kAltoBlue,
                label: const Text('Create tag', style: kSelectAllButton),
              ),
            )),
        Visibility(
            visible: startTaggingModal == true,
            child: Center(
                child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: kAltoBlue,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                          top: 20.0, right: 15, left: 15, bottom: 10),
                      child: Text(
                        'Your pics will backup as you tag them',
                        textAlign: TextAlign.center,
                        style: kWhiteSubtitle,
                      ),
                    ),
                    Center(
                        child: WhiteRoundedButton(
                            title: 'Start tagging',
                            onPressed: () {
                              StoreService.instance.set('swipedLocal', true);
                              StoreService.instance
                                  .set('startTaggingModal', false);
                            }))
                  ],
                ),
              ),
            )))
      ],
    );
  }
}

class Grid extends StatefulWidget {
  const Grid({Key? key}) : super(key: key);

  @override
  State<Grid> createState() => _GridState();
}

class _GridState extends State<Grid> {
  List<AssetEntity> itemList = [];
  bool loadedPivs = false;

  @override
  void initState() {
    super.initState();
    fetchAssets();
  }

  fetchAssets() async {
    FilterOptionGroup makeOption() {
      // final option = FilterOption();
      return FilterOptionGroup()
        ..addOrderOption(
            const OrderOption(type: OrderOptionType.createDate, asc: false));
    }

    final option = makeOption();
    // Set onlyAll to true, to fetch only the 'Recent' album
    // which contains all the photos/videos in the storage
    final albums = await PhotoManager.getAssetPathList(
        onlyAll: true, filterOption: option);
    final recentAlbum = albums.first;

    // Now that we got the album, fetch all the assets it contains
    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0, // start at index 0
      end: 1000000, // end at a very big index (to get all the assets)
    );

    for (var asset in recentAssets) {
      StoreService.instance.set(
          'pivDate:' + asset.id, asset.createDateTime.millisecondsSinceEpoch);
    }
    TagService.instance.getLocalTimeHeader();

    // Update the state and notify UI
    setState(() {
      itemList = recentAssets;
      loadedPivs = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: loadedPivs,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0, top: 180),
        child: SizedBox.expand(
          child: Directionality(
              textDirection: TextDirection.rtl,
              child: NotificationListener<ScrollMetricsNotification>(
                  onNotification: (state) {
                    var pivHeight = (MediaQuery.of(context).size.width - 1) / 2;
                    var pivRowIndex =
                        max(0, (state.metrics.pixels / pivHeight).floor() * 2);
                    if (!itemList.isEmpty) {
                      // TODO: highlight the proper month
                      // debug(['HIGHLIGHTED PIV INDEX', itemList[pivRowIndex]]);
                    }
                    return true;
                  },
                  child: GridView.builder(
                      reverse: true,
                      shrinkWrap: true,
                      cacheExtent: 50,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                      ),
                      itemCount: itemList.length,
                      itemBuilder: (BuildContext context, index) {
                        return LocalGridItem(itemList[index]);
                      }))),
        ),
      ),
      replacement: Center(
        child: Container(
            color: Colors.grey[50],
            child: const CircularProgressIndicator(
              color: kAltoBlue,
            )),
      ),
    );
  }
}

class TopRow extends StatefulWidget {
  const TopRow({Key? key}) : super(key: key);

  @override
  State<TopRow> createState() => _TopRowState();
}

class _TopRowState extends State<TopRow> {
  dynamic cancelListener;

  String currentlyTagging = '';
  dynamic taggedPivCount = '';
  dynamic timeHeader = [];

  final PageController pageController = PageController();

  @override
  void initState() {
    PhotoManager.requestPermissionExtend();
    super.initState();
    cancelListener = StoreService.instance.listen(
        ['currentlyTaggingLocal', 'taggedPivCountLocal', 'localTimeHeader'],
        (v1, v2, v3) {
      setState(() {
        currentlyTagging = v1;
        taggedPivCount = v2;
        timeHeader = v3 == '' ? [] : v3;
        if (timeHeader.length > 0)
          StoreService.instance
              .set('localYear', timeHeader.last[0][0].toString());
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
                      GestureDetector(
                        onTap: () {},
                        child: const Icon(
                          kTrashCanIcon,
                          color: kGreyDarker,
                          size: 25,
                        ),
                      ),
                      const Expanded(
                        child: Align(
                            alignment: Alignment(0.29, .9), child: LocalYear()),
                      ),
                      const Icon(
                        kSearchIcon,
                        color: Colors.white,
                        size: 25,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Icon(
                          kSlidersIcon,
                          color: Colors.white,
                          size: 25,
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: SizedBox(
                        height: 80,
                        child: PageView.builder(
                            itemCount: timeHeader.length,
                            reverse: true,
                            scrollDirection: Axis.horizontal,
                            controller: pageController,
                            onPageChanged: (int index) {
                              StoreService.instance.set(
                                  'localYear',
                                  timeHeader[timeHeader.length - index - 1][0]
                                          [0]
                                      .toString());
                            },
                            itemBuilder:
                                (BuildContext context, int semesterIndex) {
                              return GridView.count(
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 1,
                                  crossAxisSpacing: 0,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  childAspectRatio: SizeService.instance
                                      .timeHeaderChildAspectRatio(context),
                                  children: (() {
                                    List<Widget> output = [];
                                    if (timeHeader.isEmpty)
                                      output.add(Container());
                                    else
                                      timeHeader[timeHeader.length -
                                              semesterIndex -
                                              1]
                                          .forEach((month) {
                                        output.add(GridMonthElement(
                                            roundedIcon: month[2] == 'green'
                                                ? kCircleCheckIcon
                                                : (month[2] == 'gray'
                                                    ? kSolidCircleIcon
                                                    : kEmptyCircle),
                                            roundedIconColor:
                                                month[2] == 'green'
                                                    ? kAltoOrganized
                                                    : kGreyDarker,
                                            month: month[1],
                                            // TODO: selected
                                            whiteOrAltoBlueDashIcon:
                                                Colors.white,
                                            //whiteOrAltoBlueDashIcon: kAltoBlue,
                                            onTap: () {
                                              // TODO: add method to jump to proper piv
                                              if (month[2] != 'white')
                                                return debug(
                                                    ['TODO JUMP TO', month[3]]);
                                            }));
                                      });
                                    return output;
                                  })());
                            })))
              ],
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
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Text(
                          'Now tagging with',
                          style: kLookingAtText,
                        ),
                      ),
                      GridTagElement(
                        gridTagElementIcon: kTagIcon,
                        iconColor: tagColor(currentlyTagging),
                        gridTagName: currentlyTagging,
                      ),
                      Expanded(
                        child: Text(
                          taggedPivCount.toString(),
                          textAlign: TextAlign.right,
                          style: kOrganizedAmountOfPivs,
                        ),
                      )
                    ],
                  ),
                ),
              )
            : Container()
      ],
    );
  }
}
