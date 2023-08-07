import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagaway/services/tools.dart';
import 'package:tagaway/services/sizeService.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/uploadedGridItemView.dart';
import 'package:visibility_detector/visibility_detector.dart';

class YearUploaded extends StatefulWidget {
  const YearUploaded({Key? key}) : super(key: key);

  @override
  State<YearUploaded> createState() => _YearUploadedState();
}

class _YearUploadedState extends State<YearUploaded> {
  dynamic cancelListener;
  dynamic year = '';

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance.listen([
      'yearUploaded',
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

class UploadedView extends StatefulWidget {
  static const String id = 'uploaded';

  const UploadedView({Key? key}) : super(key: key);

  @override
  State<UploadedView> createState() => _UploadedViewState();
}

class _UploadedViewState extends State<UploadedView> {
  dynamic cancelListener;
  final TextEditingController searchTagController = TextEditingController();
  final TextEditingController renameTagController = TextEditingController();

  dynamic usertags = [];
  String currentlyTagging = '';
  bool swiped = false;
  bool currentlyDeleting = false;
  bool currentlyDeletingModal = false;
  String renameTagUploaded = '';
  String deleteTagUploaded = '';

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
      'currentlyTaggingUploaded',
      'swipedUploaded',
      'tagFilterUploaded',
      'renameTagUploaded',
      'deleteTagUploaded',
      'currentlyDeletingUploaded',
      'currentlyDeletingModalUploaded'
    ], (v1, v2, v3, v4, v5, v6, v7, v8) {
      var currentView = StoreService.instance.get('currentIndex');
      // If on this view and just finished tagging, refresh the query
      if (currentView == 2 && v2 == '' && currentlyTagging != '')
        TagService.instance.queryPivs(StoreService.instance.get('queryTags'));
      // Invoke the service only if local is not the current view
      if (v2 != '' && currentView != 1)
        TagService.instance.getTaggedPivs(v2, 'uploaded');
      setState(() {
        if (v1 != '') {
          var filter = v4;
          var lastNTags = StoreService.instance.get('lastNTags');
          if (lastNTags == '') lastNTags = [];
          usertags = List.from(lastNTags)
            ..addAll(v1.where((tag) => !lastNTags.contains(tag)));
          usertags = usertags
              .where(
                  (tag) => RegExp(filter, caseSensitive: false).hasMatch(tag))
              .toList();
          if (filter != '' && !usertags.contains(filter))
            usertags.insert(0, filter + ' (new tag)');
        }
        if (currentView != 1) {
          currentlyTagging = v2;
          if (v3 != '') swiped = v3;
          if (swiped == false) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
          if (swiped == false && currentScrollableSize > initialScrollableSize)
            currentScrollableSize = initialScrollableSize;
          if (swiped == true && currentScrollableSize < 0.77)
            currentScrollableSize = 0.77;
        }
        renameTagUploaded = v5;
        if (renameTagUploaded != '')
          renameTagController.text = renameTagUploaded;
        deleteTagUploaded = v6;
        currentlyDeleting = v7 != '';
        currentlyDeletingModal = v8 != '';
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
    searchTagController.dispose();
    renameTagController.dispose();
  }

  bool searchTag(String query) {
    StoreService.instance.set('tagFilterUploaded', query);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const UploadGrid(),
        const TopRow(),
        Visibility(
            visible: currentlyTagging != '' || currentlyDeleting,
            child: Align(
                alignment: const Alignment(0.8, .9),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    if (currentlyTagging != '') {
                      StoreService.instance.set('swipedUploaded', false);
                      StoreService.instance.set('currentlyTaggingUploaded', '');
                      StoreService.instance.set('tagFilterUploaded', '');
                      searchTagController.clear();
                      // We update the tag list in case we just created a new one.
                      TagService.instance.getTags();
                    } else {
                      if (StoreService.instance
                              .get('currentlyDeletingPivsUploaded') !=
                          '') {
                        StoreService.instance
                            .set('currentlyDeletingModalUploaded', true);
                      } else {
                        StoreService.instance
                            .remove('currentlyDeletingUploaded');
                      }
                    }
                  },
                  backgroundColor: currentlyDeleting ? kAltoRed : kAltoBlue,
                  label: const Text('Done', style: kSelectAllButton),
                  icon: const Icon(Icons.done),
                ))),
        Visibility(
            visible: currentlyTagging == '' && !currentlyDeleting,
            child: StartTaggingButton(
                buttonKey: Key('uploaded-start-tagging'),
                buttonText: 'Add More Tags',
                onPressed: () {
                  StoreService.instance.set('swipedUploaded', true);
                  StoreService.instance.set('startTaggingModal', false);
                })),
        Visibility(
            visible: currentlyTagging == '',
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox.expand(
                child: NotificationListener<DraggableScrollableNotification>(
                    onNotification: (state) {
                      if (state.extent < (initialScrollableSize + 0.0001))
                        StoreService.instance.set('swipedUploaded', false);
                      if (state.extent > (0.77 - 0.0001))
                        StoreService.instance.set('swipedUploaded', true);
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
                                padding:
                                    const EdgeInsets.only(left: 12, right: 12),
                                controller: scrollController,
                                children: [
                                  Visibility(
                                      visible: !swiped,
                                      child: GestureDetector(
                                        onTap: () {
                                          StoreService.instance
                                              .set('swipedUploaded', true);
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
                                              .set('swipedUploaded', false);
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
                                          // Because tags can be renamed, we need to set a key here to avoid recycling them if they change.
                                          key: Key('uploaded-' + tag),
                                          tagColor: tagColor(actualTag),
                                          tagName: tag,
                                          view: 'uploaded',
                                          onTap: () {
                                            // We need to wrap this in another function, otherwise it gets executed on view draw. Madness.
                                            return () {
                                              StoreService.instance.set(
                                                  'currentlyTaggingUploaded',
                                                  actualTag);
                                            };
                                          },
                                        );
                                      })
                                ],
                              ),
                            ),
                          );
                        })),
              ),
            )),
        // Delete modal
        Visibility(
            visible: currentlyDeletingModal,
            child: Center(
              child: Container(
                height: 225,
                width: 225,
                decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    border: Border.all(color: kGreyLight, width: .5)),
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Column(
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.only(bottom: 20.0, right: 15, left: 15),
                        child: Text(
                          'Delete from your cloud?',
                          textAlign: TextAlign.center,
                          style: kDeleteModalTitle,
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(bottom: 10.0, right: 15, left: 15),
                        child: Text(
                          'This action cannot be undone. This will permanently delete these photos and videos from our servers.',
                          textAlign: TextAlign.center,
                          style: kGridBottomRowText,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          'Are you sure?',
                          textAlign: TextAlign.center,
                          style: kGridBottomRowText,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: kGreyLight, width: 1),
                            bottom: BorderSide(color: kGreyLight, width: 1),
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            var pivsToDelete = StoreService.instance
                                .get('currentlyDeletingPivsUploaded');
                            TagService.instance
                                .deleteUploadedPivs(pivsToDelete);
                            StoreService.instance
                                .remove('currentlyDeletingUploaded');
                            StoreService.instance
                                .remove('currentlyDeletingPivsUploaded');
                            StoreService.instance
                                .remove('currentlyDeletingModalUploaded');
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10.0),
                            child: Text(
                              'Delete',
                              textAlign: TextAlign.center,
                              style: kDeleteModalTitle,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: () {
                            StoreService.instance
                                .remove('currentlyDeletingUploaded');
                            StoreService.instance
                                .remove('currentlyDeletingPivsUploaded');
                            StoreService.instance
                                .remove('currentlyDeletingModalUploaded');
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text(
                              'Cancel',
                              textAlign: TextAlign.center,
                              style: kGridTagListElement,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
        // Rename tag modal
        Visibility(
            visible: renameTagUploaded != '',
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: kGreyLight, width: .5)),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Column(
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.only(right: 15, left: 15, bottom: 10),
                          child: Text(
                            'Edit tag',
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: kTaglineTextBold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              autofocus: true,
                              controller: renameTagController,
                              style: kTaglineTextBold,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                fillColor: kGreyLightest,
                                hintMaxLines: 1,
                                hintStyle: kTaglineText,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: kGreyDarker)),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: kGreyLight, width: 1),
                              bottom: BorderSide(color: kGreyLight, width: 1),
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              TagService.instance.renameTag(
                                  renameTagUploaded, renameTagController.text);
                              StoreService.instance.remove('renameTagUploaded');
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 10.0),
                              child: Text(
                                'Done',
                                textAlign: TextAlign.center,
                                style: kGridTagListElementBlue,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () {
                              StoreService.instance.remove('renameTagUploaded');
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(top: 10.0),
                              child: Text(
                                'Cancel',
                                textAlign: TextAlign.center,
                                style: kGridTagListElement,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )),
        // Delete tag modal
        Visibility(
            visible: deleteTagUploaded != '',
            child: Center(
              child: Container(
                height: 200,
                width: 225,
                decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    border: Border.all(color: kGreyLight, width: .5)),
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Column(
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.only(right: 15, left: 15, bottom: 10),
                        child: Text(
                          'Delete the tag ',
                          textAlign: TextAlign.center,
                          style: kTaglineText,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(right: 15, left: 15, bottom: 10),
                        child: Text(
                          deleteTagUploaded + '?',
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: kTaglineTextBold,
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(bottom: 10.0, right: 15, left: 15),
                        child: Text(
                          'This will not delete any photos or videos, just the tag itself.',
                          textAlign: TextAlign.center,
                          style: kTaglineText,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: kGreyLight, width: 1),
                            bottom: BorderSide(color: kGreyLight, width: 1),
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            TagService.instance.deleteTag(deleteTagUploaded);
                            StoreService.instance.remove('deleteTagUploaded');
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10.0),
                            child: Text(
                              'Delete',
                              textAlign: TextAlign.center,
                              style: kGridDeleteElement,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: () {
                            StoreService.instance.remove('deleteTagUploaded');
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text(
                              'Cancel',
                              textAlign: TextAlign.center,
                              style: kGridTagListElement,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ))
      ],
    );
  }
}

class UploadGrid extends StatefulWidget {
  const UploadGrid({Key? key}) : super(key: key);

  @override
  State<UploadGrid> createState() => _UploadGridState();
}

class _UploadGridState extends State<UploadGrid> {
  dynamic cancelListener;
  dynamic cancelListener2;
  dynamic queryResult = {'pivs': [], 'total': 0};
  dynamic monthEdges = {'previousMonth': '', 'nextMonth': ''};
  final ScrollController gridController = ScrollController();

  dynamic visibleItems = [];

  @override
  void initState() {
    super.initState();
    StoreService.instance.set('gridControllerUploaded', gridController);
    if (StoreService.instance.get('queryTags') == '')
      StoreService.instance.set('queryTags', []);
    // The listeners are separated because we don't want to query pivs again once queryResult is updated.
    cancelListener = StoreService.instance.listen(['queryTags'], (v1) {
      if (v1 == '') v1 = [];
      TagService.instance.queryPivs(v1);
    });
    cancelListener2 = StoreService.instance.listen([
      'queryResult',
    ], (v1) {
      if (v1 != '')
        setState(() {
          queryResult = v1;
          monthEdges = TagService.instance.getMonthEdges();
        });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
    cancelListener2();
    gridController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, top: 180),
      child: SizedBox.expand(
        child: Directionality(
            textDirection: TextDirection.rtl,
            child: GridView.builder(
                controller: gridController,
                reverse: true,
                shrinkWrap: true,
                cacheExtent: 50,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 1,
                ),
                itemCount: queryResult['pivs'].length + 2,
                itemBuilder: (BuildContext context, index) {
                  // Return first tile, either Begin Journey or Previous Month
                  if (index == 0) {
                    if (monthEdges['nextMonth'] == '')
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            kStartOfJourneyIcon,
                            color: kAltoBlue,
                            size: 40,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Start Journey',
                            style:
                                SizeService.instance.screenWidth(context) <= 375
                                    ? kBottomNavigationText
                                    : kPlainTextBold,
                          )
                        ],
                      );
                    else
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              TagService.instance.queryPivs(
                                  StoreService.instance.get('queryTags'),
                                  false,
                                  monthEdges['nextMonth']);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(40, 40),
                              backgroundColor: Colors.grey[50],
                              shape: const CircleBorder(),
                            ),
                            child: const Icon(
                              kSolidCircleRight,
                              color: kAltoBlue,
                              size: 40,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Next Month',
                            style:
                                SizeService.instance.screenWidth(context) <= 375
                                    ? kBottomNavigationText
                                    : kPlainTextBold,
                          ),
                        ],
                      );
                  }
                  // Return last tile, either End Journey or Next Month
                  if (index == queryResult['pivs'].length + 1) {
                    if (monthEdges['previousMonth'] == '')
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            kEndOfJourneyIcon,
                            color: kAltoBlue,
                            size: 40,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'End of Journey',
                            style:
                                SizeService.instance.screenWidth(context) <= 375
                                    ? kBottomNavigationText
                                    : kPlainTextBold,
                          )
                        ],
                      );
                    else
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              TagService.instance.queryPivs(
                                  StoreService.instance.get('queryTags'),
                                  false,
                                  monthEdges['previousMonth']);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(40, 40),
                              backgroundColor: Colors.grey[50],
                              shape: const CircleBorder(),
                            ),
                            child: const Icon(
                              kSolidCircleLeft,
                              color: kAltoBlue,
                              size: 40,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Previous Month',
                            style:
                                SizeService.instance.screenWidth(context) <= 375
                                    ? kBottomNavigationText
                                    : kPlainTextBold,
                          ),
                        ],
                      );
                  }
                  return UploadedGridItem(
                      key: Key('uploaded-' + index.toString()),
                      pivIndex: index - 1);
                })),
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
  dynamic queryTags = [];
  dynamic queryResult = {'total': 0};
  final PageController pageController = PageController();
  bool currentlyDeleting = false;

  @override
  void initState() {
    super.initState();
    StoreService.instance.set('timeHeaderController', pageController);
    StoreService.instance.set('timeHeaderPage', 0);
    cancelListener = StoreService.instance.listen([
      'currentlyTaggingUploaded',
      'taggedPivCountUploaded',
      'timeHeader',
      'queryTags',
      'queryResult',
      'currentlyDeletingUploaded'
    ], (v1, v2, v3, v4, v5, v6) {
      setState(() {
        currentlyTagging = v1;
        taggedPivCount = v2;
        timeHeader = v3 == '' ? [] : v3;
        if (v4 != '') queryTags = v4;
        if (v5 != '') queryResult = v5;
        currentlyDeleting = v6 != '';
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
                      Visibility(
                          visible: !currentlyDeleting,
                          child: ElevatedButton(
                            onPressed: () {
                              StoreService.instance
                                  .set('currentlyDeletingUploaded', true);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(40, 40),
                              backgroundColor: kAltoRed,
                              shape: const CircleBorder(),
                            ),
                            child: const Icon(
                              kTrashCanIcon,
                              color: Colors.white,
                              size: 20,
                            ),
                          )),
                      const Expanded(
                        child: Align(
                            alignment: Alignment(0.5, .9),
                            child: YearUploaded()),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, 'querySelector');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kAltoBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 8.0, bottom: 2),
                                child: Text(
                                  'Search',
                                  style: kButtonText,
                                ),
                              ),
                              Icon(
                                kSearchIcon,
                                color: Colors.white,
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
                            StoreService.instance.set('timeHeaderPage', index);
                            StoreService.instance.set(
                                'yearUploaded',
                                timeHeader[timeHeader.length - index - 1][0][0]
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
                                            1 -
                                            semesterIndex]
                                        .forEach((month) {
                                      output.add(GridMonthElement(
                                          roundedIcon: month[2] == 'green'
                                              ? kCircleCheckIcon
                                              : (month[2] == 'gray'
                                                  ? kSolidCircleIcon
                                                  : kEmptyCircle),
                                          roundedIconColor: month[2] == 'green'
                                              ? kAltoOrganized
                                              : kGreyDarker,
                                          month: shortMonthNames[month[1] - 1],
                                          whiteOrAltoBlueDashIcon: month[3]
                                              ? kAltoBlue
                                              : Colors.white,
                                          onTap: () {
                                            if (month[2] != 'white') {
                                              TagService.instance.queryPivs(
                                                  StoreService.instance
                                                      .get('queryTags'),
                                                  false,
                                                  [month[0], month[1]]);
                                            }
                                          }));
                                    });
                                  return output;
                                })());
                          })),
                )
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
            : Container(),
        currentlyTagging == ''
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
                    queryTags.forEach((tag) {
                      // Show first two tags only
                      if (output.length > 1) return;
                      if (tag == 'u::')
                        return output.add(GridTagUploadedQueryElement(
                          gridTagElementIcon: kTagIcon,
                          iconColor: kGrey,
                          gridTagName: 'Untagged',
                        ));
                      if (tag == 't::')
                        return output.add(GridTagUploadedQueryElement(
                          gridTagElementIcon: kBoxArchiveIcon,
                          iconColor: kGrey,
                          gridTagName: 'To Organize',
                        ));
                      if (tag == 'o::')
                        return output.add(GridTagUploadedQueryElement(
                          gridTagElementIcon: kCircleCheckIcon,
                          iconColor: kAltoOrganized,
                          gridTagName: 'Organized',
                        ));
                      // DATE TAG
                      if (RegExp('^d::M').hasMatch(tag))
                        return output.add(GridTagUploadedQueryElement(
                            gridTagElementIcon: kClockIcon,
                            iconColor: kGreyDarker,
                            gridTagName: [
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
                            ][int.parse(tag.substring(4)) - 1]));
                      if (RegExp('^d::').hasMatch(tag))
                        return output.add(GridTagUploadedQueryElement(
                            gridTagElementIcon: kClockIcon,
                            iconColor: kGreyDarker,
                            gridTagName: tag.substring(3)));
                      // GEO TAG
                      if (RegExp('^g::').hasMatch(tag))
                        return output.add(GridTagUploadedQueryElement(
                            gridTagElementIcon: kLocationDotIcon,
                            iconColor: kGreyDarker,
                            gridTagName: tag.substring(3)));
                      // NORMAL TAG
                      output.add(GridTagUploadedQueryElement(
                          gridTagElementIcon: kTagIcon,
                          iconColor: tagColor(tag),
                          gridTagName: tag));
                    });
                    if (queryTags.isEmpty) {
                      output.add(Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Text(
                          'You’re looking at',
                          style: kLookingAtText,
                        ),
                      ));
                      output.add(GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                              context, 'querySelector');
                        },
                        child: GridTagElement(
                            gridTagElementIcon: kCameraIcon,
                            iconColor: kGreyDarker,
                            gridTagName: 'Everything'),
                      ));
                    }
                    if (queryTags.length > 1) output.add(GridSeeMoreElement());
                    output.add(Expanded(
                      child: Text(
                        queryResult['total'].toString(),
                        textAlign: TextAlign.right,
                        style: kUploadedAmountOfPivs,
                      ),
                    ));
                    return output;
                  })()),
                ),
              )
            : Container(),
      ],
    );
  }
}
