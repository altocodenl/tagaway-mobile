import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagaway/services/sizeService.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/uploadedGridItemView.dart';

class UploadedView extends StatefulWidget {
  static const String id = 'uploaded';

  const UploadedView({Key? key}) : super(key: key);

  @override
  State<UploadedView> createState() => _UploadedViewState();
}

class _UploadedViewState extends State<UploadedView> {
  dynamic cancelListener;
  final TextEditingController renameTagController = TextEditingController();

  String renameTag = '';
  String deleteTag = '';

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance.listen([
      'renameTagUploaded',
      'deleteTagUploaded',
    ], (RenameTag, DeleteTag) {

      setState(() {
        renameTag = RenameTag;
        if (renameTag != '') renameTagController.text = renameTag;
        deleteTag = DeleteTag;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
    renameTagController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const UploadGrid(),
        const TopRow(),
        DoneButton (view: 'Uploaded'),
        AddMoreTagsButton(view: 'Uploaded'),
        StartButton(buttonText: 'Organize', view: 'Uploaded'),
        DeleteButton(view: 'Uploaded'),
        TagButton(view: 'Uploaded'),
        TagPivsScrollableList(view: 'Uploaded'),
        DeleteModal(view: 'Uploaded'),
        // Rename tag modal
        Visibility(
            visible: renameTag != '',
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Container(
                  height: 200,
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
                            style: kTagListElementText,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              autofocus: true,
                              controller: renameTagController,
                              style: kPlainTextBold,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                fillColor: kGreyLightest,
                                hintMaxLines: 1,
                                hintStyle: kPlainText,
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
                                  renameTag, renameTagController.text);
                              StoreService.instance.remove('renameTagUploaded');
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 10.0),
                              child: Text(
                                'Done',
                                textAlign: TextAlign.center,
                                style: kBlueAltocodeSubtitle,
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
                                style: kTagListElementText,
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
            visible: deleteTag != '',
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
                          deleteTag + '?',
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
                            TagService.instance.deleteTag(deleteTag);
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

    cancelListener =
        StoreService.instance.listen(['queryTags', 'queryResult'], (v1, v2) {
      // queryPivs will not make an invocation if `queryResult` changes because it will check if the tags have changed.
      TagService.instance.queryPivs();
      if (v2 != '')
        setState(() {
          queryResult = v2;
          monthEdges = TagService.instance.getMonthEdges();
        });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
    gridController.dispose();
  }

  Future<void> _refreshGrid() async {
    await TagService.instance.queryPivs(true, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, top: 180),
      child: RefreshIndicator(
        displacement: 70,
        color: kAltoBlue,
        onRefresh: _refreshGrid,
        child: SizedBox.expand(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: GridView.builder(
                controller: gridController,
                reverse: true,
                shrinkWrap: true,
                cacheExtent: 50,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
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
                              TagService.instance
                                  .queryPivsForMonth(monthEdges['nextMonth']);
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
                              TagService.instance.queryPivsForMonth(
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
                }),
          ),
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

  dynamic currentlyTagging = '';
  dynamic taggedPivCount = '';
  dynamic timeHeader = [];
  dynamic queryTags = [];
  dynamic queryResult = {'total': 0};
  String yearUploaded = '';
  final PageController pageController = PageController();

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
      'yearUploaded'
    ], (v1, v2, v3, v4, v5, YearUploaded) {
      setState(() {
        currentlyTagging = v1;
        taggedPivCount = v2;
        timeHeader = v3 == '' ? [] : v3;
        if (v4 != '') queryTags = v4;
        if (v5 != '') queryResult = v5;
        yearUploaded = YearUploaded.toString();
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
                        onTap: () {
                          StoreService.instance.set('currentIndex', 0);
                        },
                        child: const Icon(
                          kHomeIcon,
                          color: kAltoBlue,
                          size: 25,
                        ),
                      ),
                      Expanded(
                        child: Align(
                            alignment: Alignment(0.5, .9),
                            child: Text(yearUploaded, textAlign: TextAlign.center, style: kLocalYear))
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
                                padding: EdgeInsets.only(right: 8.0),
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
                                              TagService.instance
                                                  .queryPivsForMonth(
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
                      output.add(GridTagUploadedQueryElement(
                          gridTagElementIcon: tagIcon(tag),
                          iconColor: tagIconColor(tag),
                          gridTagName: tagTitle(tag)));
                    });
                    output.add(Expanded(
                      child: Text(
                        taggedPivCount.toString(),
                        textAlign: TextAlign.right,
                        style: kOrganizedAmountOfPivs,
                      ),
                    ));
                    return output;
                  })()),
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
                      return output.add(GridTagUploadedQueryElement(
                          gridTagElementIcon: tagIcon(tag),
                          iconColor: tagIconColor(tag),
                          gridTagName: tagTitle(tag)));
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
