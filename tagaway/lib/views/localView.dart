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
import 'package:visibility_detector/visibility_detector.dart';

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
  final TextEditingController searchTagController = TextEditingController();

  dynamic usertags = [];
  String currentlyTagging = '';
  bool swiped = false;
  dynamic startTaggingModal = '';

  // When clicking on one of the buttons of this widget, we want the ScrollableDraggableSheet to be opened. Unfortunately, the methods provided in the controller for it (`animate` and `jumpTo`) change the scroll position of the sheet, but not its height.
  // For this reason, we need to set the `currentScrollableSize` directly. This is not a clean solution, and it lacks an animation. But it's the best we've come up with so far.
  // For more info, refer to https://github.com/flutter/flutter/issues/45009
  double initialScrollableSize =
      StoreService.instance.get('initialScrollableSize');
  double currentScrollableSize =
      StoreService.instance.get('initialScrollableSize');

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance.listen([
      'usertags',
      'currentlyTaggingLocal',
      'swipedLocal',
      'tagFilterLocal',
      'startTaggingModal'
    ], (v1, v2, v3, v4, v5) {
      var currentView = StoreService.instance.get('currentIndex');
      // Invoke the service only if uploaded is not the current view
      if (v2 != '' && currentView != 2)
        TagService.instance.getTaggedPivs(v2, 'local');
      setState(() {
        if (v1 != '') {
          var filter = v4;
          usertags = v1
              .where(
                  (tag) => RegExp(filter, caseSensitive: false).hasMatch(tag))
              .toList();
          if (filter != '' && !usertags.contains(filter))
            usertags.insert(0, filter + ' (new tag)');
        }
        if (currentView != 2) {
          currentlyTagging = v2;
          if (v3 != '') swiped = v3;
          if (swiped == false) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
          if (swiped == false && currentScrollableSize > initialScrollableSize)
            currentScrollableSize = initialScrollableSize;
          if (swiped == true && currentScrollableSize < 0.77)
            currentScrollableSize = 0.77;
          startTaggingModal = v5;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
  }

  bool searchTag(String query) {
    StoreService.instance.set('tagFilterLocal', query);
    return true;
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
                    key: Key(currentScrollableSize.toString()),
                    snap: true,
                    initialChildSize: currentScrollableSize,
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
                                  child: GestureDetector(
                                    onTap: () {
                                      StoreService.instance
                                          .set('swipedLocal', true);
                                      StoreService.instance
                                          .set('startTaggingModal', false);
                                    },
                                    child: const Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: FaIcon(
                                          FontAwesomeIcons.anglesUp,
                                          color: kGrey,
                                          size: 16,
                                        ),
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
                                  child: GestureDetector(
                                    onTap: () {
                                      StoreService.instance
                                          .set('swipedLocal', false);
                                    },
                                    child: const Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: FaIcon(
                                          FontAwesomeIcons.anglesDown,
                                          color: kGrey,
                                          size: 16,
                                        ),
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
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: SizedBox(
                                  height: 50,
                                  child: TextField(
                                    controller: searchTagController,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 20.0),
                                      fillColor: kGreyLightest,
                                      hintText: 'Create or search a tag',
                                      hintMaxLines: 1,
                                      hintStyle: kPlainTextBold,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: kGreyDarker)),
                                      prefixIcon: const Padding(
                                        padding: EdgeInsets.only(
                                            right: 12, left: 12, top: 15),
                                        child: FaIcon(
                                          kSearchIcon,
                                          size: 16,
                                          color: kGreyDarker,
                                        ),
                                      ),
                                    ),
                                    onChanged: searchTag,
                                  ),
                                ),
                              ),
                              ListView.builder(
                                  itemCount: usertags.length,
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    var tag = usertags[index];
                                    var actualTag = tag;
                                    if (index == 0 &&
                                        RegExp(' \\(new tag\\)\$')
                                            .hasMatch(tag)) {
                                      actualTag = tag.replaceFirst(
                                          RegExp(' \\(new tag\\)\$'), '');
                                    }
                                    return TagListElement(
                                      tagColor: tagColor(actualTag),
                                      tagName: tag,
                                      onTap: () {
                                        // We need to wrap this in another function, otherwise it gets executed on view draw. Madness.
                                        return () {
                                          StoreService.instance.set(
                                              'currentlyTaggingLocal',
                                              actualTag);
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
              child: GridView.builder(
                  reverse: true,
                  shrinkWrap: true,
                  cacheExtent: 50,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 1,
                    crossAxisSpacing: 1,
                  ),
                  itemCount: itemList.length,
                  itemBuilder: (BuildContext context, index) {
                    return VisibilityDetector(
                        key: Key('local-' + index.toString()),
                        onVisibilityChanged: (VisibilityInfo info) {
                          TagService.instance.toggleTimeHeaderVisibility(
                              'local',
                              itemList[index],
                              info.visibleFraction > 0.2);
                        },
                        child: LocalGridItem(itemList[index]));
                  })),
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
    StoreService.instance.set('localTimeHeaderController', pageController);
    StoreService.instance.set('localTimeHeaderPage', 0);
    cancelListener = StoreService.instance.listen(
        ['currentlyTaggingLocal', 'taggedPivCountLocal', 'localTimeHeader'],
        (v1, v2, v3) {
      setState(() {
        currentlyTagging = v1;
        taggedPivCount = v2;
        timeHeader = v3 == '' ? [] : v3;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
    pageController.dispose();
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
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: const Icon(
                          kTrashCanIcon,
                          color: Colors.transparent,
                          semanticLabel: 'Search',
                          size: 25,
                        ),
                      ),
                      const Expanded(
                        child: Align(
                            alignment: Alignment(0.6, .9), child: LocalYear()),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            disabledBackgroundColor: Colors.white,
                            disabledForegroundColor: Colors.white,
                            elevation: 0,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            surfaceTintColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                          child: Row(
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(right: 8.0, bottom: 2),
                                child: Text(
                                  'Search',
                                  style: TextStyle(color: Colors.transparent),
                                ),
                              ),
                              Icon(
                                kSearchIcon,
                                color: Colors.transparent,
                                size: 15,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: SizedBox(
                        height: 64,
                        child: PageView.builder(
                            itemCount: timeHeader.length,
                            reverse: true,
                            scrollDirection: Axis.horizontal,
                            controller: pageController,
                            onPageChanged: (int index) {
                              StoreService.instance
                                  .set('localTimeHeaderPage', index);
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
                                            whiteOrAltoBlueDashIcon: month[3]
                                                ? kAltoBlue
                                                : Colors.white,
                                            onTap: () {
                                              // TODO: add method to jump to proper piv
                                              /*
                                              if (month[2] != 'white')
                                                return debug(
                                                    ['TODO JUMP TO', month[4]]);
                                                */
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
