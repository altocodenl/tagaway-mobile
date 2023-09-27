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
  dynamic cancelListener;

  final PageController pageController = PageController();
  dynamic localPagesLength = StoreService.instance.get('localPagesLength') == ''
      ? 0
      : StoreService.instance.get('localPagesLength');

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance.listen([
      'localPagesLength',
    ], (LocalPagesLength) {
      setState(() {
        localPagesLength = LocalPagesLength;
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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return PageView.builder(
      reverse: true,
      controller: pageController,
      itemCount: localPagesLength == '' ? 0 : localPagesLength,
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

  @override
  void dispose() {
    super.dispose();
    cancelListener();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: page != '',
      child: Padding(
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
                              page['pivs'][index], page['pivs']);
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
  dynamic displayMode = '';
  dynamic prev = '';
  dynamic page = '';
  dynamic next = '';

  @override
  void initState() {
    PhotoManager.requestPermissionExtend();
    super.initState();
    cancelListener = StoreService.instance.listen([
      'currentlyTaggingLocal',
      'taggedPivCountLocal',
      'displayMode',
      'localPage:' + (widget.localPagesIndex - 1).toString(),
      'localPage:' + widget.localPagesIndex.toString(),
      'localPage:' + (widget.localPagesIndex + 1).toString()
    ], (v1, v2, v3, v4, v5, v6) {
      setState(() {
        currentlyTagging = v1;
        taggedPivCount = v2;
        displayMode = v3;
        prev = v4;
        page = v5;
        next = v6;
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
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20),
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
                          Visibility(
                            visible: displayMode == 'all',
                            child: Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: GestureDetector(
                                onTap: () {
                                  StoreService.instance.set('displayMode', '');
                                },
                                child: const Icon(
                                  kEyeIcon,
                                  color: kGreyDarker,
                                  size: 20,
                                ),
                              ),
                            ),
                            replacement: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: GestureDetector(
                                onTap: () {
                                  StoreService.instance
                                      .set('displayMode', 'all');
                                },
                                child: const Icon(
                                  kSlashedEyeIcon,
                                  color: kGreyDarker,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                  Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              page['left'].toString() + ' left',
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
            : Container()
      ],
    );
  }
}
