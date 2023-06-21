import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
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
  final TextEditingController searchTagController = TextEditingController();
  final PageController controller = PageController();
  dynamic usertags = [];
  String currentlyTagging = '';
  bool swiped = false;
  dynamic startTaggingModal = '';
  List<String> pivIdsToDelete = [];
  bool deleting = false;

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
    searchTagController.dispose();
    controller.dispose();
    cancelListener();
  }

  bool searchTag(String query) {
    StoreService.instance.set('tagFilterLocal', query);
    return true;
  }

  void deleteAssets() async {
    PhotoManager.editor.deleteWithIds(pivIdsToDelete);
    // https://pub.dev/packages/photo_manager#delete-entities
    //After the deletion, you can call the refreshPathProperties method to refresh the corresponding AssetPathEntity in order to get latest fields.
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return PageView.builder(
      reverse: true,
      controller: controller,
      itemCount: 5,
      pageSnapping: true,
      itemBuilder: (BuildContext context, int index) {
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
                      backgroundColor: deleting ? kAltoRed : kAltoBlue,
                      label: const Text('Done', style: kSelectAllButton),
                      icon: const Icon(Icons.done),
                    ))),
            Visibility(
                visible: currentlyTagging == '',
                child: const StartTaggingButton(
                  buttonKey: Key('start tagging'),
                  buttonText: 'Start Tagging',
                )),
            Visibility(
                visible: currentlyTagging == '',
                child: DeleteButton(
                  onPressed: () {
                    //  enter DELETE MODE
                  },
                )),
            Visibility(
                visible: currentlyTagging == '',
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox.expand(
                      child:
                          NotificationListener<DraggableScrollableNotification>(
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
                        initialChildSize: 0,
                        minChildSize: 0,
                        // initialChildSize: currentScrollableSize,
                        // minChildSize: initialScrollableSize,
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
                                padding:
                                    const EdgeInsets.only(left: 12, right: 12),
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
                                          padding: EdgeInsets.only(
                                              top: 8.0, bottom: 8),
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
                                          padding: EdgeInsets.only(
                                              top: 8.0, bottom: 8),
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
                                                  vertical: 10.0,
                                                  horizontal: 20.0),
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
                                      physics:
                                          const NeverScrollableScrollPhysics(),
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
                                  StoreService.instance
                                      .set('swipedLocal', true);
                                  StoreService.instance
                                      .set('startTaggingModal', false);
                                }))
                      ],
                    ),
                  ),
                ))),
            Visibility(
                visible: !deleting,
                // THIS HAS TO CHANGE, IT HAS TO BE ON RED 'DONE' BUTTON TAP
                child: Center(
                  child: Container(
                    height: 225,
                    width: 225,
                    decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        border: Border.all(color: Colors.white, width: .5)),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 15.0, right: 15, left: 15),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 20.0),
                            child: Text(
                              'Delete from your phone?',
                              textAlign: TextAlign.center,
                              style: kDeleteModalTitle,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: Text(
                              'This action cannot be undone. This will permanently delete these photos and videos from your device.',
                              textAlign: TextAlign.center,
                              style: kGridBottomRowText,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 20.0),
                            child: Text(
                              'Are you sure?',
                              textAlign: TextAlign.center,
                              style: kGridBottomRowText,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 15.0),
                            child: Text(
                              'Delete',
                              textAlign: TextAlign.center,
                              style: kDeleteModalTitle,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 0.0),
                            child: Text(
                              'Cancel',
                              textAlign: TextAlign.center,
                              style: kGridTagListElement,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
          ],
        );
      },
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
    loadLocalPivs();
  }

  loadLocalPivs() async {
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
    final localPivs = await recentAlbum.getAssetListRange(
      start: 0, // start at index 0
      end: 1000000, // end at a very big index (to get all the assets)
    );
    StoreService.instance.set('countLocal', localPivs.length);

    for (var piv in localPivs) {
      StoreService.instance
          .set('pivDate:' + piv.id, piv.createDateTime.millisecondsSinceEpoch);
    }
    TagService.instance.getLocalTimeHeader();

    // Update the state and notify UI
    setState(() {
      itemList = localPivs;
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
                    return LocalGridItem(itemList[index]);
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
          child: const SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20),
              child: Column(
                children: [
                  Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: LinearProgressIndicator(
                        value: .5,
                        color: kAltoBlue,
                        backgroundColor: Colors.white,
                      )),
                  Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '1000 left',
                              style: kLookingAtText,
                            ),
                          ),
                        ],
                      )),
                  Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text('This Month',
                              textAlign: TextAlign.center,
                              style: kLeftAndRightPhoneGridTitle,
                              key: Key('left-title')),
                        ),
                        Expanded(
                            child: Text('This Week',
                                style: kCenterPhoneGridTitle,
                                textAlign: TextAlign.center,
                                key: Key('center-title'))),
                        Expanded(
                            child: Text('Today',
                                textAlign: TextAlign.center,
                                style: kLeftAndRightPhoneGridTitle,
                                key: Key('right-title'))),
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
