import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagaway/services/sizeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/services/tools.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/localGridItemView.dart';
import 'package:tagaway/views/uploadedGridItemView.dart';

class UploadedView extends StatefulWidget {
  static const String id = 'uploaded';

  const UploadedView({Key? key}) : super(key: key);

  @override
  State<UploadedView> createState() => _UploadedViewState();
}

class _UploadedViewState extends State<UploadedView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        const UploadGrid(),
        const TopRow(),
        DoneButton(view: 'Uploaded'),
        AddMoreTagsButton(view: 'Uploaded'),
        StartButton(buttonText: 'Organize', view: 'Uploaded'),
        SelectAllButton(view: 'Uploaded'),
        DeleteButton(view: 'Uploaded'),
        TagButton(view: 'Uploaded'),
        TagPivsScrollableList(view: 'Uploaded'),
        DeleteModal(view: 'Uploaded'),
        RenameTagModal(view: 'Uploaded'),
        DeleteTagModal(view: 'Uploaded'),
      ],
    ));
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
  bool firstLoad = true;

  dynamic visibleItems = [];

  void jumpTo() {
    if (store.get('jumpTo') == '') return;
    var pivs = store.get('queryResult')['pivs'];
    if (pivs == '') return;
    var pivIndex = pivs.indexWhere((piv) => piv['id'] == store.get('jumpTo'));
    if (pivIndex == -1) return;
    store.remove('jumpTo');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) {
        return CarrouselView(initialPiv: pivIndex, pivs: pivs);
      }),
    );
  }

  @override
  void initState() {
    super.initState();

    store.set('gridControllerUploaded', gridController);

    if (store.get('queryTags') == '') store.set('queryTags', []);

    cancelListener = store.listen(['queryTags'], (v1) {
      if (firstLoad)
        return firstLoad =
            false; // Prevent calling queryPivs on the first load of the view. This prevents this call overwriting the call that could have been done from a hometag thumb to come here on a specific month.
      TagService.instance.queryPivs();
    });
    cancelListener2 = store.listen(['queryResult'], (QueryResult) {
      if (QueryResult != '')
        setState(() {
          queryResult = QueryResult;
          monthEdges = TagService.instance.getMonthEdges();
          jumpTo();
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
                              gridController.jumpTo(0);
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
                              gridController.jumpTo(0);
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
                  var piv = queryResult['pivs'][index - 1];
                  if (piv['local'] == true)
                    return LocalGridItem(piv['piv'], [], 'uploaded', index - 1);
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
  dynamic timeHeader = [];
  dynamic queryTags = [];
  dynamic queryResult = {'total': 0};
  String yearUploaded = '';
  final PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    store.set('timeHeaderController', pageController);
    store.set('timeHeaderPage', 0);
    cancelListener = store.listen([
      'currentlyTaggingUploaded',
      'timeHeader',
      'queryTags',
      'queryResult',
      'yearUploaded'
    ], (v1, v3, v4, v5, YearUploaded) {
      setState(() {
        currentlyTagging = v1;
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
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          store.remove('showButtonsUploaded');
                          store.remove('currentlyTaggingUploaded');
                          store.remove('currentlyDeletingUploaded');
                          store.remove('currentlyDeletingModalUploaded');
                          store.remove('currentlyDeletingPivsUploaded');
                          store.set('queryTags', []);
                          Navigator.pushReplacementNamed(
                              context, 'bottomNavigation');
                        },
                        child: const Icon(
                          kHomeIcon,
                          color: kAltoBlue,
                          size: 25,
                        ),
                      ),
                      Expanded(
                          child: Align(
                              alignment: const Alignment(0.5, .9),
                              child: Text(yearUploaded,
                                  textAlign: TextAlign.center,
                                  style: kLocalYear))),
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
                  child: Container(
                      color: Colors.white,
                      height: 67,
                      child: PageView.builder(
                          itemCount: timeHeader.length,
                          reverse: true,
                          scrollDirection: Axis.horizontal,
                          controller: pageController,
                          onPageChanged: (int index) {
                            store.set('timeHeaderPage', index);
                            store.set(
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
                                              if (store.get('gridController') !=
                                                  '')
                                                store
                                                    .get('gridController')
                                                    .jumpTo(0);
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
                      output.add(GridTagElement(
                          view: 'uploaded',
                          gridTagElementIcon: tagIcon(tag),
                          iconColor: tagIconColor(tag),
                          gridTagName: tagTitle(tag)));
                    });
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
                      return output.add(GridTagElement(
                          view: 'uploaded',
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
                            view: 'uploaded',
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

class GridSeeMoreElement extends StatefulWidget {
  const GridSeeMoreElement({Key? key}) : super(key: key);

  @override
  State<GridSeeMoreElement> createState() => _GridSeeMoreElementState();
}

class _GridSeeMoreElementState extends State<GridSeeMoreElement> {
  dynamic cancelListener;

  dynamic queryTags = [];

  @override
  void initState() {
    super.initState();
    cancelListener = store.listen([
      'queryTags',
    ], (v1) {
      setState(() {
        if (v1 != '') queryTags = v1;
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
    return GestureDetector(
      onTap: () {
        showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return Container(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  color: Colors.white,
                  height: 600,
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: [
                      const Icon(
                        kMinusIcon,
                        color: kGreyDarker,
                        size: 30,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'You’re looking at',
                              style: kLookingAtText,
                            ),
                          ],
                        ),
                      ),
                      GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: queryTags.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 4,
                          ),
                          itemBuilder: (BuildContext context, index) {
                            var tag = queryTags[index];
                            return GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                      context, 'querySelector');
                                },
                                child: GridTagElement(
                                    view: 'uploaded',
                                    gridTagElementIcon: tagIcon(tag),
                                    iconColor: tagIconColor(tag),
                                    gridTagName: tagTitle(tag)));
                          })
                    ],
                  ));
            });
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Container(
          height: 40,
          padding: const EdgeInsets.only(left: 12, right: 12),
          decoration: const BoxDecoration(
              color: kGreyLighter,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: const Center(
            child: FaIcon(
              kEllipsisIcon,
              color: kGreyDarker,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class GridMonthElement extends StatelessWidget {
  const GridMonthElement(
      {Key? key,
      required this.roundedIcon,
      required this.roundedIconColor,
      required this.month,
      required this.whiteOrAltoBlueDashIcon,
      required this.onTap})
      : super(key: key);

  final IconData roundedIcon;
  final Color roundedIconColor;
  final String month;
  final Color whiteOrAltoBlueDashIcon;
  final dynamic onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              color: Colors.transparent,
              width: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    roundedIcon,
                    color: roundedIconColor,
                    size: 12,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(month, style: kHorizontalMonth),
            FaIcon(
              kMinusIcon,
              color: whiteOrAltoBlueDashIcon,
            )
          ],
        ));
  }
}
