import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagaway/services/sizeService.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/uploadedGridItemView.dart';

class UploadedYear extends StatefulWidget {
  const UploadedYear({Key? key}) : super(key: key);

  @override
  State<UploadedYear> createState() => _UploadedYearState();
}

class _UploadedYearState extends State<UploadedYear> {
  dynamic cancelListener;
  dynamic year = '';

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance.listen([
      'uploadedYear',
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
  final TextEditingController newTagName = TextEditingController();

  dynamic usertags = [];
  String currentlyTagging = '';
  bool swiped = false;
  dynamic newTag = '';
  dynamic startTaggingModal = '';

  // When clicking on one of the buttons of this widget, we want the ScrollableDraggableSheet to be opened. Unfortunately, the methods provided in the controller for it (`animate` and `jumpTo`) change the scroll position of the sheet, but not its height.
  // For this reason, we need to set the `initialChildSize` directly. This is not a clean solution, and it lacks an animation. But it's the best we've come up with so far.
  // For more info, refer to https://github.com/flutter/flutter/issues/45009
  double initialScrollableSize =
      StoreService.instance.get('initialScrollableSize');
  double initialChildSize = StoreService.instance.get('initialScrollableSize');

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance.listen([
      'usertags',
      'currentlyTaggingUploaded',
      'swipedUploaded',
      'newTagUploaded',
      'startTaggingModal'
    ], (v1, v2, v3, v4, v5) {
      var currentView = StoreService.instance.get('currentIndex');
      // If on this view and just finished tagging, refresh the query
      if (currentView == 2 && v2 == '' && currentlyTagging != '')
        TagService.instance.queryPivs(StoreService.instance.get('queryTags'));
      // Invoke the service only if local is not the current view
      if (v2 != '' && currentView != 1)
        TagService.instance.getTaggedPivs(v2, 'uploaded');
      setState(() {
        if (v1 != '') usertags = v1;
        if (currentView != 1) {
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
    return Stack(
      children: [
        const UploadGrid(),
        const TopRow(),
        Visibility(
            visible: currentlyTagging != '',
            child: Align(
                alignment: const Alignment(0.8, .9),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    StoreService.instance.set('swipedUploaded', false);
                    StoreService.instance.set('currentlyTaggingUploaded', '');
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
                        StoreService.instance.set('swipedUploaded', false);
                      if (state.extent > (0.77 - 0.0001))
                        StoreService.instance.set('swipedUploaded', true);
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
                                padding:
                                    const EdgeInsets.only(left: 12, right: 12),
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
                                  Visibility(
                                      visible: swiped,
                                      child: const Center(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 8.0, bottom: 8),
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
                                      physics:
                                          const NeverScrollableScrollPhysics(),
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
                                                  'currentlyTaggingUploaded',
                                                  tag);
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
                              StoreService.instance.set('newTagUploaded', '');
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
                              StoreService.instance.set('newTagUploaded', '');
                              StoreService.instance
                                  .set('currentlyTaggingUploaded', text);
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
                  StoreService.instance.set('newTagUploaded', true);
                },
                backgroundColor: kAltoBlue,
                label: const Text('Create tag', style: kSelectAllButton),
              ),
            )),
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

  dynamic visibleItems = [];

  @override
  void initState() {
    super.initState();
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
        });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
    cancelListener2();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, top: 180),
      child: SizedBox.expand(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: GridView.builder(
              reverse: true,
              shrinkWrap: true,
              cacheExtent: 50,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
              ),
              itemCount: queryResult['pivs'].length,
              itemBuilder: (BuildContext context, index) {
               return VisibilityDetector(
                  key: Key('uploaded-' + index.toString()),
                  onVisibilityChanged: (VisibilityInfo info) {
                     // If we're redrawing, we might try to get a piv that is out of range, so we prevent this by doing this check.
                     if (queryResult ['pivs'].length - 1 < index) return;
                     TagService.instance.toggleVisibility ('uploaded', queryResult ['pivs'] [index], info.visibleFraction > 0.2);
                  },
                  child: UploadedGridItem(
                    piv: queryResult['pivs'][index], pivs: queryResult['pivs']));
              }),
        ),
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

  @override
  void initState() {
    super.initState();
    StoreService.instance.set ('uploadedTimeHeaderController', pageController);
    StoreService.instance.set ('uploadedTimeHeaderPage', 0);
    cancelListener = StoreService.instance.listen([
      'currentlyTaggingUploaded',
      'taggedPivCountUploaded',
      'uploadedTimeHeader',
      'queryTags',
      'queryResult'
    ], (v1, v2, v3, v4, v5) {
      setState(() {
        currentlyTagging = v1;
        taggedPivCount = v2;
        timeHeader = v3 == '' ? [] : v3;
        if (v4 != '') queryTags = v4;
        if (v5 != '') queryResult = v5;
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
                  padding: const EdgeInsets.only(left: 12.0, right: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                          onTap: () {},
                          child: const Icon(
                            kTrashCanIcon,
                            color: Colors.transparent,
                            size: 25,
                          )),
                      const Expanded(
                        child: Align(
                            alignment: Alignment(0.29, .9),
                            child: UploadedYear()),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, 'searchTags');
                        },
                        child: const Icon(
                          kSearchIcon,
                          color: kGreyDarker,
                          size: 25,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, 'querySelector');
                          },
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
                      child: PageView.builder(
                          itemCount: timeHeader.length,
                          reverse: true,
                          scrollDirection: Axis.horizontal,
                          controller: pageController,
                          onPageChanged: (int index) {
                            StoreService.instance.set ('uploadedTimeHeaderPage', index);
                            StoreService.instance.set(
                                'uploadedYear',
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
                                          month: month[1],
                                          whiteOrAltoBlueDashIcon:
                                              month[3] ? kAltoBlue : Colors.white,
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
                      output.add(GridTagElement(
                          gridTagElementIcon: kCameraIcon,
                          iconColor: kGreyDarker,
                          gridTagName: 'Everything'));
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
