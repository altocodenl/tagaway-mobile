import 'dart:core';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagaway/services/authService.dart';
import 'package:tagaway/services/pivService.dart';
import 'package:tagaway/services/sizeService.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/services/tools.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class SnackBarGlobal {
  SnackBarGlobal._();

  static buildSnackBar(
      BuildContext context, String message, String backgroundColorSnackBar) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: kSnackBarText,
        ),
        backgroundColor: Color(backgroundColorSnackBar == 'green'
            ? 0xFF04E762
            : backgroundColorSnackBar == 'red'
                ? 0xFFD33E43
                : 0xFFffff00),
        //  var colors = {green: '#04E762', red: '#D33E43', yellow: '#ffff00'};
      ),
    );
  }
}

class SixSecondSnackBar {
  SixSecondSnackBar._();

  static buildSnackBar(
      BuildContext context, String message, String backgroundColorSnackBar) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: kSnackBarText,
        ),
        backgroundColor: Color(backgroundColorSnackBar == 'green'
            ? 0xFF04E762
            : backgroundColorSnackBar == 'red'
                ? 0xFFD33E43
                : 0xFFffff00),
        //  var colors = {green: '#04E762', red: '#D33E43', yellow: '#ffff00'};
      ),
    );
  }
}

class WhiteSnackBar {
  WhiteSnackBar._();

  static buildSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: kWhiteSnackBarText,
        ),
        backgroundColor: Colors.white,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.only(bottom: 50),
        padding: const EdgeInsets.all(20),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}

class RoundedButton extends StatelessWidget {
  const RoundedButton(
      {Key? key,
      required this.title,
      required this.colour,
      required this.onPressed})
      : super(key: key);

  final Color colour;
  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(title,
            style: SizeService.instance.screenWidth(context) < 380
                ? kBottomNavigationText
                : kButtonText),
        style: ElevatedButton.styleFrom(
            backgroundColor: colour,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            minimumSize: SizeService.instance.screenWidth(context) < 380
                ? const Size(150, 42)
                : const Size(200, 42)),
      ),
    );
  }
}

class WhiteRoundedButton extends StatelessWidget {
  const WhiteRoundedButton(
      {Key? key, required this.title, required this.onPressed})
      : super(key: key);

  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(title, style: kWhiteButtonText),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            minimumSize: const Size(200, 42)),
      ),
    );
  }
}

class HomeCard extends StatelessWidget {
  const HomeCard({
    Key? key,
    required this.color,
    required this.title,
  }) : super(key: key);

  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Container(
        height: 140,
        width: 1000,
        padding: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 20),
          child: Text(
            title,
            style: kHomeTagBoxText,
          ),
        ),
      ),
    );
  }
}

class HomeCardTransparent extends StatelessWidget {
  const HomeCardTransparent(
      {Key? key, required this.color, required this.title})
      : super(key: key);

  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: Border.all(color: Colors.transparent),
                image: const DecorationImage(
                    colorFilter: ColorFilter.matrix(<double>[
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ]),
                    fit: BoxFit.cover,
                    image: NetworkImage(
                        'https://drumeoblog.s3.amazonaws.com/beat/wp-content/uploads/2020/11/02110525/lars-ulrich-1-1.jpg')),
              ),
            ),
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: color.withOpacity(.4),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.8),
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: kHomeStackedTagText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TagListElement extends StatefulWidget {
  const TagListElement({
    Key? key,
    required this.tagColor,
    required this.tagName,
    required this.view,
    required this.onTap,
  }) : super(key: key);

  final Color tagColor;
  final String tagName;
  final String view;
  final Function onTap;

  @override
  State<TagListElement> createState() => _TagListElementState();
}

class _TagListElementState extends State<TagListElement> {
  bool showDeleteAndRenameTagModal = false;

  showDeleteAndRenameTagModalFunction() {
    setState(() {
      showDeleteAndRenameTagModal = !showDeleteAndRenameTagModal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap(),
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Container(
          height: 70,
          decoration: const BoxDecoration(
              color: kGreyLighter,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: FaIcon(
                        kTagIcon,
                        color: widget.tagColor,
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth:
                            SizeService.instance.screenWidth(context) * .65,
                      ),
                      child: Text(
                        widget.tagName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: kTagListElementText,
                      ),
                    ),
                    Visibility(
                      visible: ['local', 'uploaded'].contains(widget.view),
                      child: Expanded(
                        child: Align(
                          alignment: const Alignment(1, 0),
                          child: GestureDetector(
                            onTap: () {
                              showDeleteAndRenameTagModalFunction();
                            },
                            child: Container(
                              width: 60,
                              decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: const Icon(
                                kEllipsisVerticalIcon,
                                color: kGreyDarker,
                              ),
                            ),
                          ),
                        ),
                      ),
                      replacement: Expanded(
                        child: Container(),
                      ),
                    )
                  ],
                ),
              ),
              Visibility(
                  visible: showDeleteAndRenameTagModal,
                  child: DeleteAndRenameTagModal(
                      tagName: widget.tagName, view: widget.view)),
            ],
          ),
        ),
      ),
    );
  }
}

class DeleteAndRenameTagModal extends StatelessWidget {
  const DeleteAndRenameTagModal({
    Key? key,
    required this.tagName,
    required this.view,
  }) : super(key: key);

  final String tagName;
  final String view;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(.65, 0),
      child: Container(
        height: 60,
        width: 100,
        decoration: const BoxDecoration(
          color: kGreyLighter,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
                color: Colors.grey, //New
                blurRadius: 1.0,
                offset: Offset(0, 1))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                StoreService.instance.set(
                    view == 'local' ? 'deleteTagLocal' : 'deleteTagUploaded',
                    tagName);
              },
              child: const Icon(
                kTrashCanIcon,
                color: kAltoRed,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            GestureDetector(
              onTap: () {
                StoreService.instance.set(
                    view == 'local' ? 'renameTagLocal' : 'renameTagUploaded',
                    tagName);
              },
              child: const Icon(
                kPenToSquareSolidIcon,
                color: kAltoBlue,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class EditTagListElement extends StatelessWidget {
  const EditTagListElement({
    Key? key,
    required this.tagColor,
    required this.tagName,
    required this.onTapOnRedCircle,
    required this.onTagElementVerticalDragDown,
  }) : super(key: key);

  final Color tagColor;
  final String tagName;
  final Function onTapOnRedCircle;
  final Function onTagElementVerticalDragDown;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTapOnRedCircle(),
            child: Container(
              child: const Icon(
                FontAwesomeIcons.circleMinus,
                color: kAltoRed,
              ),
              color: Colors.transparent,
              margin: const EdgeInsets.only(left: 10, right: 12),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onVerticalDragDown: onTagElementVerticalDragDown(),
              child: Container(
                height: 70,
                decoration: const BoxDecoration(
                    color: kGreyLighter,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: FaIcon(
                          kTagIcon,
                          color: tagColor,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          tagName,
                          style: kTagListElementText,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 12, right: 12.0),
                        // child: FaIcon(
                        //   FontAwesomeIcons.bars,
                        //   color: kGrey,
                        // ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GridTagElement extends StatelessWidget {
  const GridTagElement(
      {Key? key,
      required this.gridTagElementIcon,
      required this.iconColor,
      required this.gridTagName,
      required this.view})
      : super(key: key);

  final IconData gridTagElementIcon;
  final Color iconColor;
  final String gridTagName;
  final String view;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (view == 'local' ||
            StoreService.instance.get('currentlyTaggingUploaded') != '') return;
        Navigator.pushReplacementNamed(context, 'querySelector');
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Container(
          height: 40,
          padding: const EdgeInsets.only(left: 12, right: 12),
          decoration: const BoxDecoration(
              color: kGreyLighter,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: FaIcon(
                  gridTagElementIcon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  maxWidth: SizeService.instance
                      .gridTagUploadedQueryElementMaxWidthCalculator(context),
                  // Maybe we need to use this max width calculator? Let's check if we have issues.
                  // .gridTagElementMaxWidthCalculator(context),
                ),
                child: Text(gridTagName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: kGridTagListElement),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GridDeleteTagElement extends StatelessWidget {
  const GridDeleteTagElement({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        height: 40,
        padding: const EdgeInsets.only(left: 12, right: 12),
        decoration: const BoxDecoration(
            color: kGreyLighter,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Row(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: FaIcon(
                kTrashCanIcon,
                color: kAltoRed,
                size: 20,
              ),
            ),
            Container(
              constraints: BoxConstraints(
                maxWidth: SizeService.instance
                    .gridTagElementMaxWidthCalculator(context),
              ),
              child: const Text('Deleting photos and videos',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: kGridDeleteElement),
            ),
          ],
        ),
      ),
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
    cancelListener = StoreService.instance.listen([
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

class UserMenuElementTransparent extends StatelessWidget {
  const UserMenuElementTransparent({
    Key? key,
    required this.textOnElement,
  }) : super(key: key);

  final String textOnElement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 20, top: 5),
      child: Container(
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Center(
            child: Text(
          textOnElement,
          style: kPlainTextBold,
        )),
      ),
    );
  }
}

class UserMenuElementLightGrey extends StatelessWidget {
  const UserMenuElementLightGrey({
    Key? key,
    required this.onTap,
    required this.textOnElement,
  }) : super(key: key);

  final VoidCallback onTap;
  final String textOnElement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 20, top: 5),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: const BoxDecoration(
            color: kGreyLight,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Center(
              child: Text(
            textOnElement,
            style: kPlainText,
          )),
        ),
      ),
    );
  }
}

class UserMenuElementKBlue extends StatelessWidget {
  const UserMenuElementKBlue({
    Key? key,
    required this.onTap,
    required this.textOnElement,
  }) : super(key: key);

  final VoidCallback onTap;
  final String textOnElement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 20, top: 5),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: const BoxDecoration(
            color: kAltoBlue,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: FaIcon(
                  kBroomIcon,
                  color: Colors.white,
                ),
              ),
              Center(
                  child: Text(
                textOnElement,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  color: Colors.white,
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class UserMenuElementDarkGrey extends StatelessWidget {
  const UserMenuElementDarkGrey({
    Key? key,
    required this.onTap,
    required this.textOnElement,
  }) : super(key: key);

  final Function onTap;
  final String textOnElement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 20, top: 5),
      child: GestureDetector(
        onTap: onTap(),
        child: Container(
          height: 50,
          decoration: const BoxDecoration(
            color: kGreyDarker,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Center(
              child: Text(textOnElement,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    color: Colors.white,
                  ))),
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

class QuerySelectionTagElement extends StatelessWidget {
  const QuerySelectionTagElement({
    Key? key,
    required this.elementColor,
    required this.icon,
    required this.iconColor,
    required this.tagTitle,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;
  final Color elementColor;
  final IconData icon;
  final Color iconColor;
  final String tagTitle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: elementColor,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    right: SizeService.instance.screenWidth(context) < 380
                        ? 8
                        : 12.0),
                child: FaIcon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              Text(
                tagTitle,
                style: kLookingAtText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CloudVideoPlayerWidget extends StatefulWidget {
  const CloudVideoPlayerWidget({Key? key, required this.pivId})
      : super(key: key);
  final String pivId;

  @override
  State<CloudVideoPlayerWidget> createState() => _CloudVideoPlayerWidgetState();
}

class _CloudVideoPlayerWidgetState extends State<CloudVideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool initialized = false;

  @override
  void initState() {
    _initVideo();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _initVideo() async {
    _controller = VideoPlayerController.network(
      (kTagawayVideoURL) + (widget.pivId),
      httpHeaders: {
        'cookie': StoreService.instance.get('cookie'),
        'Range': 'bytes=0-',
      },
    );
    // Play the video again when it ends
    _controller.setLooping(true);
    // initialize the controller and notify UI when done
    _controller.initialize().then((_) => setState(() {
          initialized = true;
          _controller.play();
        }));
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Stack(
            children: [
              Container(
                alignment: Alignment.topCenter,
                decoration: const BoxDecoration(
                  color: kGreyDarkest,
                ),
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
              Align(
                alignment: const Alignment(0.8, .7),
                child: FloatingActionButton(
                  backgroundColor: kAltoBlue,
                  onPressed: () {
                    // Wrap the play or pause in a call to `setState`. This ensures the
                    // correct icon is shown.
                    setState(() {
                      // If the video is playing, pause it.
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        // If the video is paused, play it.
                        _controller.play();
                      }
                    });
                  },
                  // Display the correct icon depending on the state of the player.
                  child: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                ),
              ),
            ],
          )
        : const Center(
            child: CircularProgressIndicator(
            backgroundColor: kGreyDarkest,
            color: kAltoBlue,
          ));
  }
}

class VideoPending extends StatelessWidget {
  const VideoPending({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 12.0,
          right: 12,
          bottom: SizeService.instance.screenHeight(context) * .1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Image.asset(
              'images/tag blue with white - 400x400.png',
              scale: 4,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              'Your video is currently being converted in our servers.',
              textAlign: TextAlign.center,
              style: kBigTitle,
            ),
          ),
          const Text(
            'Please try again in a few seconds.',
            textAlign: TextAlign.center,
            style: kPlainText,
          ),
        ],
      ),
    );
  }
}

class VideoError extends StatelessWidget {
  const VideoError({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 12.0,
          right: 12,
          bottom: SizeService.instance.screenHeight(context) * .1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Image.asset(
              'images/tag blue with white - 400x400.png',
              scale: 4,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              'There\'s an error with your video.',
              textAlign: TextAlign.center,
              style: kBigTitle,
            ),
          ),
          const Text(
            'The problem is on our side. Sorry.',
            textAlign: TextAlign.center,
            style: kPlainText,
          ),
        ],
      ),
    );
  }
}

class GridItemSelection extends StatefulWidget {
  final String id;
  final String type;

  const GridItemSelection(this.id, this.type, {Key? key}) : super(key: key);

  @override
  State<GridItemSelection> createState() => _GridItemSelectionState(id, type);
}

class _GridItemSelectionState extends State<GridItemSelection> {
  dynamic cancelListener;
  final String id;
  final String type;
  var mode = 'none';

  _GridItemSelectionState(this.id, this.type);

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance.listen([
      (type == 'local' ? 'pivMap:' : 'orgMap:') + id,
      'tagMap:' + id,
      'currentlyTagging' + (type == 'local' ? 'Local' : 'Uploaded'),
      'displayMode',
      'deleteMode',
      'currentlyDeleting' + (type == 'local' ? 'Local' : 'Uploaded'),
      'currentlyDeletingPivs' + (type == 'local' ? 'Local' : 'Uploaded')
    ], (v1, v2, v3, v4, v5, v6, v7) {
      setState(() {
        // Tagging mode: set mode to `green` for pivs that are tagged and `gray` for those that are not. This goes for local and uploaded.
        if (v3 != '') {
          mode = v2 == '' ? 'gray' : 'green';
        } else if (v6 != '') {
          var currentlyDeletingPivs = v7;
          if (currentlyDeletingPivs == '') currentlyDeletingPivs = [];
          mode = currentlyDeletingPivs.contains(id) ? 'red' : 'gray';
          // Normal mode
        } else {
          var organized = type == 'uploaded'
              ? v1 != ''
              // If the piv is currently being uploaded (`v1 == true`) we consider it as organized.
              : (v1 == true ||
                  StoreService.instance.get('orgMap:' + v1.toString()) != '');
          mode = organized ? 'green' : 'gray';
          if (type == 'local' && v4 != 'all') mode = 'none';
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
    if (mode == 'none')
      return const Visibility(visible: false, child: Text(''));
    return Icon(
      mode == 'gray' ? kSolidCircleIcon : kCircleCheckIcon,
      color: mode == 'green'
          ? kAltoOrganized
          : (mode == 'gray' ? kGreyDarker : kAltoRed),
      size: 15,
    );
  }
}

class AltocodeCommit extends StatelessWidget {
  const AltocodeCommit({
    Key? key,
  }) : super(key: key);

  launchAltocodeHome() async {
    if (!await launchUrl(Uri.parse(kAltoURL),
        mode: LaunchMode.externalApplication)) {
      throw "cannot launch url";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: TextButton(
        onPressed: () {
          launchAltocodeHome();
        },
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'altocode',
              style: kBlueAltocodeSubtitle,
            ),
            Text(
              'Commit to the future',
              style: kTaglineText,
            ),
          ],
        ),
      ),
    );
  }
}

class UploadingNumber extends StatefulWidget {
  const UploadingNumber({
    Key? key,
  }) : super(key: key);

  @override
  State<UploadingNumber> createState() => _UploadingNumberState();
}

class _UploadingNumberState extends State<UploadingNumber> {
  dynamic cancelListener;
  int numeroli = 0;

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance.listen(['uploadQueue'], (v1) {
      if (v1 != '') setState(() => numeroli = v1.length);
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
  }

  @override
  Widget build(BuildContext context) {
    if (numeroli == 0) return const Text('');
    return Positioned(
      left: SizeService.instance.screenWidth(context) * .31,
      top: 10,
      child: SizedBox(
        height: 30,
        child: Center(
          child: Column(
            children: [
              Text(
                numeroli.toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: kAltoBlue),
              ),
              const Icon(
                kArrowLeftLong,
                color: kAltoBlue,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeleteButton extends StatefulWidget {
  const DeleteButton({
    Key? key,
    required this.view,
  }) : super(key: key);

  final String view;

  @override
  State<DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<DeleteButton> {
  dynamic cancelListener;
  bool visible = false;

  @override
  void initState() {
    super.initState();
    cancelListener =
        StoreService.instance.listen(['showButtons' + widget.view], (v1) {
      setState(() {
        visible = v1 == true;
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
    if (!visible) return Container();
    return Align(
      alignment: const Alignment(0, .45),
      child: FloatingActionButton(
        heroTag: null,
        elevation: 10,
        key: const Key('delete'),
        onPressed: () {
          StoreService.instance.set('currentlyDeleting' + widget.view, true);
          StoreService.instance.set('showButtons' + widget.view, false);
        },
        backgroundColor: kAltoRed,
        child: const Icon(kTrashCanIcon),
      ),
    );
  }
}

class TagButton extends StatefulWidget {
  const TagButton({
    Key? key,
    required this.view,
  }) : super(key: key);

  final String view;

  @override
  _TagButtonState createState() => _TagButtonState();
}

class _TagButtonState extends State<TagButton> {
  dynamic cancelListener;
  bool visible = false;

  @override
  void initState() {
    super.initState();
    cancelListener =
        StoreService.instance.listen(['showButtons' + widget.view], (v1) {
      setState(() {
        visible = v1 == true;
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
    if (!visible) return Container();
    return Align(
      alignment: const Alignment(0, .68),
      child: FloatingActionButton(
        heroTag: null,
        elevation: 10,
        key: const Key('tag'),
        onPressed: () {
          StoreService.instance.set('swiped' + widget.view, true);
          StoreService.instance.set('showButtons' + widget.view, false);
        },
        backgroundColor: kAltoBlue,
        child: const Icon(kTagIcon),
      ),
    );
  }
}

class StartButton extends StatefulWidget {
  const StartButton({
    Key? key,
    required this.buttonText,
    required this.view,
  }) : super(key: key);
  final String buttonText;
  final String view;

  @override
  State<StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<StartButton> {
  bool secondElapsed = false;
  bool visible = false;
  bool showButtons = false;
  dynamic cancelListener;

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance.listen([
      'showButtons' + widget.view,
      'currentlyTagging' + widget.view,
      'currentlyDeleting' + widget.view
    ], (ShowButtons, CurrentlyTagging, CurrentlyDeleting) {
      if (CurrentlyTagging != '' &&
          StoreService.instance.get('viewIndex') ==
              (widget.view == 'Local' ? 1 : 0))
        TagService.instance
            .getTaggedPivs(CurrentlyTagging, widget.view.toLowerCase());

      setState(() {
        showButtons = ShowButtons == true;
        visible = secondElapsed &&
            CurrentlyTagging == '' &&
            CurrentlyDeleting != true;
      });
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          secondElapsed = true;
          visible = secondElapsed &&
              StoreService.instance.get('currentlyTagging' + widget.view) ==
                  '' &&
              StoreService.instance.get('currentlyDeleting' + widget.view) !=
                  true;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
  }

  @override
  Widget build(BuildContext context) {
    if (!visible) return Container();
    return Align(
      alignment: const Alignment(0, .9),
      child: Visibility(
        visible: !showButtons,
        child: FloatingActionButton.extended(
          extendedPadding: const EdgeInsets.only(left: 20, right: 20),
          heroTag: null,
          key: Key('startTagging' + widget.view),
          onPressed: () {
            StoreService.instance.set('showButtons' + widget.view, true);
          },
          backgroundColor: kAltoBlue,
          elevation: 20,
          label: Text(widget.buttonText, style: kStartButton),
        ),
        replacement: FloatingActionButton(
          onPressed: () {
            setState(() {
              StoreService.instance.set('showButtons' + widget.view, false);
            });
          },
          backgroundColor: Colors.white,
          child: const Icon(
            Icons.close,
            size: 30,
            color: kAltoBlue,
          ),
        ),
      ),
    );
  }
}

void TagawaySpaceCleanerModal1(
    BuildContext context, int availableBytes, int potentialCleanup) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: Container(
          height: 400,
          width: 340,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              border: Border.all(color: kGreyLight, width: .5)),
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: FaIcon(
                          kBroomIcon,
                          color: kAltoBlue,
                        ),
                      ),
                      Text(
                        'Clean up space?',
                        textAlign: TextAlign.center,
                        style: kDoneEditText,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 10.0, right: 20, left: 20),
                  child: Text(
                    'You have ' +
                        printBytes(availableBytes) +
                        ' of available space in your device.',
                    textAlign: TextAlign.center,
                    style: kPlainTextBold,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 10.0, right: 20, left: 20),
                  child: Text(
                    'Would you like to free up space by deleting your already organized photos and videos?',
                    textAlign: TextAlign.center,
                    style: kPlainTextBold,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 20.0, right: 20, left: 20),
                  child: Text(
                    'You will free up to ' +
                        printBytes(potentialCleanup) +
                        ' of space.',
                    textAlign: TextAlign.center,
                    style: kPlainTextBold,
                  ),
                ),
                Container(
                  width: 200,
                  decoration: BoxDecoration(
                      color: kGreyDarker,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: kGreyLight, width: .5)),
                  child: Visibility(
                    visible: false,
                    child: GestureDetector(
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10.0),
                        child: Text(
                          'No. Don’t ask me again.',
                          textAlign: TextAlign.center,
                          style: kButtonText,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: 200,
                  decoration: BoxDecoration(
                      color: kGreyDarker,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: kGreyLight, width: .5)),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10.0),
                      child: Text(
                        'Not now.',
                        textAlign: TextAlign.center,
                        style: kButtonText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: 200,
                  decoration: BoxDecoration(
                      color: kAltoBlue,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: kGreyLight, width: .5)),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      TagawaySpaceCleanerModal2(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10.0),
                      child: Text(
                        'Tell me more.',
                        textAlign: TextAlign.center,
                        style: kButtonText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void TagawaySpaceCleanerModal2(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: Container(
          height: 450,
          width: 340,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              border: Border.all(color: kGreyLight, width: .5)),
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: FaIcon(
                          kBroomIcon,
                          color: kAltoBlue,
                        ),
                      ),
                      Text(
                        'Tagaway Space Cleaner',
                        textAlign: TextAlign.center,
                        style: kDoneEditText,
                      ),
                    ],
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.only(bottom: 10.0, right: 20, left: 20),
                    child: Text.rich(
                      TextSpan(
                        text: 'Tagaway will delete ',
                        style: kPlainTextBold, // default text style
                        children: <TextSpan>[
                          TextSpan(text: 'only ', style: kPlainTextBoldDarkest),
                          TextSpan(
                              text:
                                  'the photos and videos that you have organized.',
                              style: kPlainTextBold),
                        ],
                      ),
                    )),
                const Padding(
                    padding: EdgeInsets.only(bottom: 10.0, right: 20, left: 20),
                    child: Text.rich(
                      TextSpan(
                        text: 'Your organized photos and videos are ',
                        style: kPlainTextBold, // default text style
                        children: <TextSpan>[
                          TextSpan(
                              text: 'safe in Tagaway’s cloud',
                              style: kPlainTextBoldDarkest),
                          TextSpan(
                              text:
                                  ', which you can always access from this app or Tagaway Web (from web you can download the high-quality versions).',
                              style: kPlainTextBold),
                        ],
                      ),
                    )),
                const Padding(
                  padding: EdgeInsets.only(bottom: 20.0, right: 20, left: 20),
                  child: Text(
                    'Delete your organized photos and videos from this device?',
                    textAlign: TextAlign.center,
                    style: kPlainTextBold,
                  ),
                ),
                Container(
                  width: 320,
                  decoration: BoxDecoration(
                      color: kGreyDarker,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: kGreyLight, width: .5)),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10.0),
                      child: Text(
                        'No, take me back.',
                        textAlign: TextAlign.center,
                        style: kButtonText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: 320,
                  decoration: BoxDecoration(
                      color: kAltoBlue,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: kGreyLight, width: .5)),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      PivService.instance.deletePivsByRange('3m', true);
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10.0),
                      child: Text(
                        'Yes, but organized pivs 3 months or older.',
                        textAlign: TextAlign.center,
                        style: kButtonText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: 320,
                  decoration: BoxDecoration(
                      color: kAltoBlue,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: kGreyLight, width: .5)),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      PivService.instance.deletePivsByRange('all', true);
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10.0),
                      child: Text(
                        'Yes, delete all organized pivs.',
                        textAlign: TextAlign.center,
                        style: kButtonText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class AddMoreTagsButton extends StatefulWidget {
  const AddMoreTagsButton({
    Key? key,
    required this.view,
  }) : super(key: key);
  final String view;

  @override
  State<AddMoreTagsButton> createState() => _AddMoreTagsButtonState();
}

class _AddMoreTagsButtonState extends State<AddMoreTagsButton> {
  dynamic cancelListener;
  bool visible = false;

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance.listen([
      'currentlyTagging' + widget.view,
      'hideAddMoreTagsButton' + widget.view
    ], (CurrentlyTagging, Hide) {
      setState(() {
        // Show this button only when there is a single tag in `currentlyTagging(Local|Uploaded)`
        visible = CurrentlyTagging != '' &&
            CurrentlyTagging.length == 1 &&
            Hide != true;
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
    if (!visible) return Container();
    return Align(
      alignment: const Alignment(-0.8, .9),
      child: FloatingActionButton.extended(
        onPressed: () {
          StoreService.instance.set('swiped' + widget.view, true);
          StoreService.instance.set('showButtons' + widget.view, false);
        },
        backgroundColor: kAltoBlue,
        key: Key('addMoreTags-' + widget.view),
        label: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              kPlusIcon,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(
              width: 5,
            ),
            Icon(
              kTagIcon,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class DoneButton extends StatefulWidget {
  const DoneButton({
    Key? key,
    required this.view,
  }) : super(key: key);
  final String view;

  @override
  State<DoneButton> createState() => _DoneButtonState();
}

class _DoneButtonState extends State<DoneButton> {
  dynamic cancelListener;
  bool visible = false;
  dynamic currentlyTagging = '';
  bool currentlyDeleting = false;

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance.listen(
        ['currentlyTagging' + widget.view, 'currentlyDeleting' + widget.view],
        (CurrentlyTagging, CurrentlyDeleting) {
      setState(() {
        visible = CurrentlyTagging != '' || CurrentlyDeleting == true;
        currentlyTagging = CurrentlyTagging;
        currentlyDeleting = CurrentlyDeleting == true;
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
    if (!visible) return Container();
    return Align(
        alignment: const Alignment(0.8, .9),
        child: FloatingActionButton.extended(
          onPressed: () {
            // Done tagging
            if (currentlyTagging != '') {
              StoreService.instance.set('swiped' + widget.view, false);
              StoreService.instance.set('currentlyTagging' + widget.view, '');
              StoreService.instance
                  .set('hideAddMoreTagsButton' + widget.view, '');
              // We update the tag list in case we just created a new one.
              TagService.instance.getTags();
              if (widget.view == 'Local') {
                StoreService.instance.remove('currentlyTaggingPivs');
                PivService.instance.queryOrganizedLocalPivs();
              }
              // We update the list of organized pivs for those uploaded pivs that have a local counterpart
              // Done deleting
            } else {
              var currentlyDeleting = StoreService.instance
                  .get('currentlyDeletingPivs' + widget.view);
              if (currentlyDeleting != '' && currentlyDeleting.length > 0) {
                StoreService.instance
                    .set('currentlyDeletingModal' + widget.view, true);
              } else {
                StoreService.instance.remove('currentlyDeleting' + widget.view);
              }
            }
          },
          backgroundColor: currentlyDeleting ? kAltoRed : kAltoBlue,
          label: const Text('Done', style: kSelectAllButton),
          icon: const Icon(Icons.done),
        ));
  }
}

class TagPivsScrollableList extends StatefulWidget {
  const TagPivsScrollableList({
    Key? key,
    required this.view,
  }) : super(key: key);
  final String view;

  @override
  State<TagPivsScrollableList> createState() => _TagPivsScrollableListState();
}

class _TagPivsScrollableListState extends State<TagPivsScrollableList> {
  dynamic cancelListener;
  final TextEditingController searchTagController = TextEditingController();

  dynamic usertags = [];
  bool swiped = false;

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
      'currentlyTagging' + widget.view,
      'tagFilter' + widget.view,
      'swiped' + widget.view,
    ], (Usertags, CurrentlyTagging, TagFilter, Swiped) {
      setState(() {
        if (Usertags != '') {
          var lastNTags = StoreService.instance.get('lastNTags');
          if (lastNTags == '') lastNTags = [];
          usertags = List.from(lastNTags)
            ..addAll(Usertags.where((tag) => !lastNTags.contains(tag)));
          usertags = usertags
              .where((tag) =>
                  RegExp(TagFilter, caseSensitive: false).hasMatch(tag))
              .toList();
          if (TagFilter != '' && !usertags.contains(TagFilter))
            usertags.insert(0, TagFilter + ' (new tag)');
          // Remove from usertags tags that already are in currentlyTagging
          if (CurrentlyTagging != '')
            usertags = usertags
                .where((tag) => !CurrentlyTagging.contains(tag))
                .toList();
        }

        swiped = Swiped == true;
        if (swiped == false) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
        if (swiped == false && currentScrollableSize > initialScrollableSize)
          currentScrollableSize = initialScrollableSize;
        if (swiped == true && currentScrollableSize < 0.77)
          currentScrollableSize = 0.77;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
    searchTagController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!swiped) return Container();
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox.expand(
        child: NotificationListener<DraggableScrollableNotification>(
            onNotification: (state) {
              if (state.extent < (initialScrollableSize + 0.0001))
                StoreService.instance.set('swiped' + widget.view, false);
              if (state.extent > (0.77 - 0.0001))
                StoreService.instance.set('swiped' + widget.view, true);
              return true;
            },
            child: DraggableScrollableSheet(
                key: Key(currentScrollableSize.toString()),
                snap: true,
                initialChildSize: currentScrollableSize,
                minChildSize: initialScrollableSize,
                maxChildSize: 0.77,
                builder:
                    (BuildContext context, ScrollController scrollController) {
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
                          GestureDetector(
                            onTap: () {
                              StoreService.instance
                                  .set('swiped' + widget.view, false);
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
                          ),
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 8.0, bottom: 8),
                              child: Text(
                                'Tag your pics and videos',
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: kAltoBlue),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: SizedBox(
                              height: 50,
                              child: TextField(
                                controller: searchTagController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  fillColor: kGreyLightest,
                                  hintText: 'Create or search a tag',
                                  hintMaxLines: 1,
                                  hintStyle: kPlainTextBold,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: kGreyDarker)),
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
                                onChanged: (String query) {
                                  StoreService.instance
                                      .set('tagFilter' + widget.view, query);
                                },
                              ),
                            ),
                          ),
                          ListView.builder(
                              itemCount: usertags.length,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                var tag = usertags[index];
                                var actualTag = tag;
                                if (index == 0 &&
                                    RegExp(' \\(new tag\\)\$').hasMatch(tag)) {
                                  actualTag = tag.replaceFirst(
                                      RegExp(' \\(new tag\\)\$'), '');
                                  actualTag = actualTag.trim();
                                }
                                return TagListElement(
                                  // Because tags can be renamed, we need to set a key here to avoid recycling them if they change.
                                  key: Key(widget.view + '-' + tag),
                                  tagColor: tagColor(actualTag),
                                  tagName: tag,
                                  view: widget.view.toLowerCase(),
                                  onTap: () {
                                    // We need to wrap this in another function, otherwise it gets executed on view draw. Madness.
                                    return () {
                                      if (RegExp('^[a-z]::')
                                          .hasMatch(actualTag))
                                        return showSnackbar(
                                            'Alas, you cannot use that tag.',
                                            'yellow');
                                      StoreService.instance
                                          .set('swiped' + widget.view, false);
                                      var currentlyTagging =
                                          StoreService.instance.get(
                                              'currentlyTagging' + widget.view);
                                      StoreService.instance.set(
                                          'currentlyTagging' + widget.view,
                                          currentlyTagging == ''
                                              ? [actualTag]
                                              : currentlyTagging + [actualTag]);
                                      StoreService.instance
                                          .set('tagFilter' + widget.view, '');
                                      searchTagController.clear();
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
    );
  }
}

class DeleteModal extends StatefulWidget {
  const DeleteModal({
    Key? key,
    required this.view,
  }) : super(key: key);
  final String view;

  @override
  State<DeleteModal> createState() => _DeleteModalState();
}

class _DeleteModalState extends State<DeleteModal> {
  dynamic cancelListener;
  bool visible = false;

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance
        .listen(['currentlyDeletingModal' + widget.view], (CurrentlyDeleting) {
      setState(() {
        visible = CurrentlyDeleting == true;
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
    if (!visible) return Container();
    return Center(
      child: Container(
        height: 270,
        width: 340,
        decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            border: Border.all(color: kGreyLight, width: .5)),
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 20.0, right: 15, left: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: FaIcon(
                        kTrashCanIcon,
                        color: kAltoRed,
                      ),
                    ),
                    Text(
                      'Delete From Your ' +
                          (widget.view == 'Local' ? 'Phone' : 'Cloud') +
                          '?',
                      textAlign: TextAlign.center,
                      style: kDeleteModalTitle,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.0, right: 15, left: 15),
                child: Text(
                  'This action cannot be undone. This will permanently delete these photos and videos from ' +
                      (widget.view == 'Local' ? 'your device' : 'our servers') +
                      '.',
                  textAlign: TextAlign.center,
                  style: kPlainTextBold,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Are you sure?',
                  textAlign: TextAlign.center,
                  style: kPlainTextBold,
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
                        .get('currentlyDeletingPivs' + widget.view);
                    if (widget.view == 'Local')
                      PivService.instance.deleteLocalPivs(pivsToDelete);
                    else
                      TagService.instance.deleteUploadedPivs(pivsToDelete);
                    StoreService.instance
                        .remove('currentlyDeleting' + widget.view);
                    StoreService.instance
                        .remove('currentlyDeletingPivs' + widget.view);
                    StoreService.instance
                        .remove('currentlyDeletingModal' + widget.view);
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
                        .remove('currentlyDeleting' + widget.view);
                    StoreService.instance
                        .remove('currentlyDeletingPivs' + widget.view);
                    StoreService.instance
                        .remove('currentlyDeletingModal' + widget.view);
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
    );
  }
}

class RenameTagModal extends StatefulWidget {
  const RenameTagModal({
    Key? key,
    required this.view,
  }) : super(key: key);
  final String view;

  @override
  State<RenameTagModal> createState() => _RenameTagModalState();
}

class _RenameTagModalState extends State<RenameTagModal> {
  dynamic cancelListener;
  final TextEditingController renameTagController = TextEditingController();
  String renameTag = '';

  @override
  void initState() {
    super.initState();
    cancelListener =
        StoreService.instance.listen(['renameTag' + widget.view], (RenameTag) {
      setState(() {
        renameTag = RenameTag;
        if (renameTag != '') renameTagController.text = renameTag;
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
    if (renameTag == '') return Container();
    return Center(
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
                  padding: EdgeInsets.only(right: 15, left: 15, bottom: 10),
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
                            borderSide: const BorderSide(color: kGreyDarker)),
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
                      TagService.instance
                          .renameTag(renameTag, renameTagController.text);
                      StoreService.instance.remove('renameTag' + widget.view);
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
                      StoreService.instance.remove('renameTag' + widget.view);
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
    );
  }
}

class DeleteTagModal extends StatefulWidget {
  const DeleteTagModal({
    Key? key,
    required this.view,
  }) : super(key: key);
  final String view;

  @override
  State<DeleteTagModal> createState() => _DeleteTagModalState();
}

class _DeleteTagModalState extends State<DeleteTagModal> {
  dynamic cancelListener;
  String deleteTag = '';

  @override
  void initState() {
    super.initState();
    cancelListener =
        StoreService.instance.listen(['deleteTag' + widget.view], (DeleteTag) {
      setState(() {
        deleteTag = DeleteTag;
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
    if (deleteTag == '') return Container();
    return Center(
        child: Container(
      height: 230,
      width: 340,
      decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          border: Border.all(color: kGreyLight, width: .5)),
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 15, left: 15, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: FaIcon(
                      kTrashCanIcon,
                      color: kAltoRed,
                    ),
                  ),
                  Text(
                    'Delete the tag ',
                    textAlign: TextAlign.center,
                    style: kDeleteModalTitle,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15, left: 15, bottom: 10),
              child: Text(
                deleteTag + '?',
                textAlign: TextAlign.center,
                softWrap: true,
                style: kPlainTextBold,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0, right: 15, left: 15),
              child: Text(
                'This will not delete any photos or videos, just the tag itself.',
                textAlign: TextAlign.center,
                style: kPlainTextBold,
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
                  StoreService.instance.remove('deleteTag' + widget.view);
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
                  StoreService.instance.remove('deleteTag' + widget.view);
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
    ));
  }
}

class GeotaggingSwitch extends StatefulWidget {
  const GeotaggingSwitch({super.key});

  @override
  State<GeotaggingSwitch> createState() => _GeotaggingSwitchState();
}

class _GeotaggingSwitchState extends State<GeotaggingSwitch> {
  dynamic cancelListener;
  dynamic account = {'geo': false};

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance.listen(['account'], (v1) {
      setState(() {
        if (v1 != '') account = v1;
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
            value: account['geo'] != null,
            onChanged: (bool value) {
              setState(() {
                AuthService.instance.geotagging(value ? 'enable' : 'disable');
                // We do this to give instant feedback.
                account = {'geo': value};
              });
            },
          ),
        ),
      ],
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
                                Expanded(child: HideOrganizedPivsSwitch()),
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

class HideOrganizedPivsSwitch extends StatefulWidget {
  const HideOrganizedPivsSwitch({super.key});

  @override
  State<HideOrganizedPivsSwitch> createState() => _HideOrganizedPivsSwitch();
}

class _HideOrganizedPivsSwitch extends State<HideOrganizedPivsSwitch> {
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
            value: displayMode['hideOrganized'],
            onChanged: (bool value) {
              StoreService.instance.set('displayMode', {
                'hideOrganized': value ? true : false,
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
                'hideOrganized': displayMode['hideOrganized'],
                'cameraOnly': value ? true : false
              });
            },
          ),
        ),
      ],
    );
  }
}
