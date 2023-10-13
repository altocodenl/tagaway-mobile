import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tagaway/services/sizeService.dart';
import 'package:tagaway/services/storeService.dart';
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
    pageController.addListener(() {
      var maxPage = StoreService.instance.get('localPagesLength');
      if (maxPage == '') maxPage = 0;
      if (pageController.page! >= maxPage)
        pageController.jumpToPage(maxPage - 1);
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
            DoneButton(view: 'Local'),
            AddMoreTagsButton(view: 'Local'),
            StartButton(buttonText: 'Start', view: 'Local'),
            DeleteButton(view: 'Local'),
            TagButton(view: 'Local'),
            TagPivsScrollableList(view: 'Local'),
            DeleteModal(view: 'Local'),
            RenameTagModal(view: 'Local'),
            DeleteTagModal(view: 'Local'),
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

  final ScrollController scrollController = ScrollController();
  final GlobalKey gridPositionKey = GlobalKey ();
  RenderBox getBox() => context.findRenderObject() as RenderBox;

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance
        .listen(['localPage:' + widget.localPagesIndex.toString()], (v1) {
      // If the list of ids in page['pivs'] is unchanged, we don't update the state to avoid redrawing the grid and experiencing a flicker.
      if (page != '') {
        var existingIds = page['pivs'].map((asset) => asset.id).toList();
        var newIds = v1['pivs'].map((asset) => asset.id).toList();
        if (DeepCollectionEquality().equals(existingIds, newIds)) return;
      }
      setState(() {
        page = v1;
      });
    });
  }

  dynamic lastDraggedPivIndex;
  dynamic sel = false;

  int getIndex (dynamic details) {
    final RenderBox? box = gridPositionKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || gridPositionKey.currentContext == null) return -1;
    final Offset localPosition = box.globalToLocal(details.globalPosition);
    final gridSize = box.size;

    // We need to invert our local position because the grid is shown in inverted order
    var invertedLocalPosition = [gridSize.width - localPosition.dx, gridSize.height - localPosition.dy];
    // Add up the scroll offset
    invertedLocalPosition [1] += scrollController.offset;
    // There seems to be an extra Y offset that we need to substract.
    invertedLocalPosition [1] -= 33;
    //debug (['INVERTED LOCAL POSITION', invertedLocalPosition]);

    // localPosition now contains the coordinates of the gesture relative to this grid item.
    // Do what you want with the coordinates.

    int crossAxisCount = 3; // This is your grid cross axis count
    double childWidth = getBox().size.width / crossAxisCount;
    double childHeight = childWidth; // This assumes square children

    int rowIndex = (invertedLocalPosition [1] / childHeight).floor();
    int columnIndex = (invertedLocalPosition [0] / childWidth).floor();

    int index = rowIndex * crossAxisCount + columnIndex;
    return index;
  }

  void onPanDown(DragDownDetails details) {
    var index = getIndex (details);
    if (index >= page['pivs'].length) return;
    var piv = page['pivs'][index];
    sel = StoreService.instance.get ('tagMap:' + piv.id) == '';
    debug (['touching', index]);
    // onPanUpdate(DragUpdateDetails(globalPosition: details.globalPosition, delta: Offset.zero));
  }

  void onPanEnd(DragEndDetails details) {
    lastDraggedPivIndex = null;
  }

  void onPanUpdate(DragUpdateDetails details) {
     var index = getIndex (details);
    if (index >= page['pivs'].length) return;
    if (index != lastDraggedPivIndex) {
      lastDraggedPivIndex = index;
      var piv = page['pivs'][index];
      // TODO
              //} else if (StoreService.instance.get('currentlyTaggingLocal') !=
      // StoreService.instance.set ('
      debug (['touching', index]);
    }
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
    scrollController.dispose();
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

          child: GestureDetector(
            key: gridPositionKey,
            onPanDown: (details) => onPanDown(details),
            onPanEnd: (details) => onPanEnd(details),
            onPanUpdate: (details) => onPanUpdate(details),
                  child: GridView.builder(
                      controller: scrollController,
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
                        return LocalGridItem(page['pivs'][index], page['pivs']);
                      }))),
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
  dynamic taggedPivCount = '';
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
      'taggedPivCountLocal',
      'localPage:' + (widget.localPagesIndex - 1).toString(),
      'localPage:' + widget.localPagesIndex.toString(),
      'localPage:' + (widget.localPagesIndex + 1).toString(),
      'displayMode'
    ], (v1, v2, v3, v4, v5, DisplayMode) {
      setState(() {
        currentlyTagging = v1;
        taggedPivCount = v2;
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
                              color: kAltoBlue,
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
                            padding: EdgeInsets.only(right: 2),
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
                              page['left'].toString() + (displayMode ['cameraOnly'] ? ' camera pivs' : '') + ' left',
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
            : Container()
      ],
    );
  }
}
