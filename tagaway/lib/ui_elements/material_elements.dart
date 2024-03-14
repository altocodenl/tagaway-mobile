import 'dart:core';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tagaway/services/pivService.dart';
import 'package:tagaway/services/sizeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/services/tools.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:url_launcher/url_launcher.dart';

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

class TagListElement extends StatefulWidget {
  const TagListElement(
      {Key? key,
      required this.tagColor,
      required this.tagName,
      required this.view,
      required this.onTap,
      this.icon})
      : super(key: key);

  final Color tagColor;
  final String tagName;
  final String view;
  final Function onTap;
  final dynamic icon;

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
                        widget.icon == null ? kTagIcon : widget.icon,
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
                      visible: ['local', 'uploaded', 'manageTags']
                          .contains(widget.view),
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
                store.set(
                    view == 'local'
                        ? 'deleteTagLocal'
                        : (view == 'uploaded'
                            ? 'deleteTagUploaded'
                            : 'deleteTagManageTags'),
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
                store.set(
                    view == 'local'
                        ? 'renameTagLocal'
                        : (view == 'uploaded'
                            ? 'renameTagUploaded'
                            : 'renameTagManageTags'),
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
        if (view == 'local' || store.get('currentlyTaggingUploaded') != '')
          return;
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
    cancelListener = store.listen([
      (type == 'local' ? 'pivMap:' : 'orgMap:') + id,
      'tagMap' + (type == 'local' ? 'Local' : 'Uploaded') + ':' + id,
      'currentlyTagging' + (type == 'local' ? 'Local' : 'Uploaded'),
      'displayMode',
      'currentlyDeleting' + (type == 'local' ? 'Local' : 'Uploaded'),
      'currentlyDeletingPivs' + (type == 'local' ? 'Local' : 'Uploaded')
    ], (v1, v2, v3, v4, v6, v7) {
      setState(() {
        // Tagging mode: set mode to `green` for pivs that are tagged and `gray` for those that are not. This goes for local and uploaded.
        if (v3 != '') {
          mode = v2 == true ? 'green' : 'gray';
          // Deleting mode
        } else if (v6 != '') {
          var currentlyDeletingPivs = v7;
          if (currentlyDeletingPivs == '') currentlyDeletingPivs = [];
          mode = currentlyDeletingPivs.contains(id) ? 'red' : 'gray';
          // Normal mode
        } else {
          // local pivs in the uploaded view (`localUploaded`) are considered as organized if they have pending tags
          var organized = type == 'localUploaded'
              ? getList('pendingTags:' + id).length > 0
              : (type == 'uploaded'
                  ? v1 != ''
                  // If the piv is local and is currently being uploaded (`v1 == true`) we consider it as organized.
                  : (v1 == true || store.get('orgMap:' + v1.toString()) != ''));
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

class localPivIcon extends StatefulWidget {
  const localPivIcon({Key? key}) : super(key: key);

  @override
  State<localPivIcon> createState() => _localPivIconState();
}

class _localPivIconState extends State<localPivIcon> {
  @override
  Widget build(BuildContext context) {
    return Icon(
      kMobilePhoneIcon,
      size: 15,
      color: Colors.white,
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
    cancelListener = store.listen(['showButtons' + widget.view], (v1) {
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
        shape: const CircleBorder(),
        heroTag: null,
        elevation: 10,
        key: const Key('delete'),
        onPressed: () {
          store.set('currentlyDeleting' + widget.view, true);
          store.set('showButtons' + widget.view, false);
          store.set('showSelectAllButton' + widget.view, true);
        },
        backgroundColor: kAltoRed,
        child: const Icon(
          kTrashCanIcon,
          color: Colors.white,
        ),
      ),
    );
  }
}

class DeleteButtonTunnel extends StatefulWidget {
  const DeleteButtonTunnel({
    super.key,
    required this.view,
    this.onPressed,
  });

  final String view;
  final dynamic onPressed;

  @override
  State<DeleteButtonTunnel> createState() => _DeleteButtonTunnelState();
}

class _DeleteButtonTunnelState extends State<DeleteButtonTunnel> {
  dynamic cancelListener;
  bool visible = false;

  @override
  void initState() {
    super.initState();
    cancelListener = store.listen(['showButtons' + widget.view], (v1) {
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
    if (visible) return Container();
    return Align(
      alignment: const Alignment(-.85, -0.3),
      child: FloatingActionButton(
        shape: const CircleBorder(),
        heroTag: null,
        elevation: 10,
        key: const Key('delete'),
        onPressed: widget.onPressed != null
            ? widget.onPressed
            : () {
                store.set('currentlyDeleting' + widget.view, true);
                store.set('showButtons' + widget.view, false);
                store.set('showSelectAllButton' + widget.view, true);
              },
        backgroundColor: kAltoRed,
        child: const Icon(
          kTrashCanIcon,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ShareButtonTunnel extends StatefulWidget {
  const ShareButtonTunnel({super.key, required this.view, this.onPressed});
  final String view;
  final dynamic onPressed;

  @override
  State<ShareButtonTunnel> createState() => _ShareButtonTunnelState();
}

class _ShareButtonTunnelState extends State<ShareButtonTunnel> {
  dynamic cancelListener;
  bool visible = false;

  @override
  void initState() {
    super.initState();
    cancelListener = store.listen(['showButtons' + widget.view], (v1) {
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
    if (visible) return Container();
    return Align(
      alignment: const Alignment(-.85, -0.65),
      child: FloatingActionButton(
        shape: const CircleBorder(),
        heroTag: null,
        elevation: 10,
        key: const Key('share'),
        onPressed: widget.onPressed != null ? widget.onPressed : () {},
        backgroundColor: kAltoShare,
        child: const Icon(
          kShareIcon,
          color: Colors.white,
        ),
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
    cancelListener = store.listen(['showButtons' + widget.view], (v1) {
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
        shape: const CircleBorder(),
        elevation: 10,
        key: const Key('tag'),
        onPressed: () {
          store.set('swiped' + widget.view, true);
          store.set('showButtons' + widget.view, false);
        },
        backgroundColor: kAltoOrganized,
        child: const Icon(
          kTagIcon,
          color: Colors.white,
        ),
      ),
    );
  }
}

class SelectAllButton extends StatefulWidget {
  const SelectAllButton({
    Key? key,
    required this.view,
  }) : super(key: key);
  final String view;

  @override
  State<SelectAllButton> createState() => _SelectAllButtonState();
}

class _SelectAllButtonState extends State<SelectAllButton> {
  dynamic cancelListener;
  dynamic status = '';
  dynamic operation;

  @override
  void initState() {
    super.initState();
    cancelListener = store.listen(
        ['showSelectAllButton' + widget.view, 'currentlyTagging' + widget.view],
        (v1, v2) {
      setState(() {
        status = v1;
        if (v2 == '')
          operation = 'delete';
        else
          operation = 'tag';
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
    if (status == '') return Container();
    return Align(
      alignment: const Alignment(-0.8, .9),
      child: FloatingActionButton.extended(
        shape: const CircleBorder(),
        onPressed: () {
          store.set('showSelectAllButton' + widget.view, !status);
          TagService.instance
              .selectAll(widget.view.toLowerCase(), operation, status);
        },
        backgroundColor: status == true
            ? (operation == 'tag' ? kAltoOrganized : kAltoRed)
            : kAltoBlue,
        key: Key('selectAll-' + widget.view),
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == true ? kSelectAllIcon : kDeselectIcon,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
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

  bool determineVisibility() {
    var currentlyTagging = store.get('currentlyTagging' + widget.view);
    var currentlyDeleting = store.get('currentlyDeleting' + widget.view);
    var emptyPage = false;
    if (widget.view == 'Local') {
      var page = store.get('localPage:' + store.get('localPage').toString());
      if (page == '' || page['pivs'].length == 0) emptyPage = true;
    }
    return secondElapsed == true &&
        currentlyTagging == '' &&
        currentlyDeleting != true &&
        emptyPage == false;
  }

  @override
  void initState() {
    super.initState();
    cancelListener = store.listen([
      'showButtons' + widget.view,
      'currentlyTagging' + widget.view,
      'currentlyDeleting' + widget.view,
      widget.view == 'Uploaded' ? 'noSuchKey' : 'localPage',
      // Respond to changes on any local page
      widget.view == 'Uploaded' ? 'noSuchKey' : 'localPage:*'
    ], (ShowButtons, currentlyTagging, currentlyDeleting, localPage,
        localPages) {
      if (currentlyTagging != '' &&
          store.get('viewIndex') == (widget.view == 'Local' ? 1 : 0))
        TagService.instance
            .getTaggedPivs(currentlyTagging, widget.view.toLowerCase());

      setState(() {
        showButtons = ShowButtons == true;
        visible = determineVisibility();
      });
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        secondElapsed = true;
        visible = determineVisibility();
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
      alignment: const Alignment(0, .9),
      child: Visibility(
        visible: !showButtons,
        child: FloatingActionButton.extended(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          key: const Key('startButton'),
          extendedPadding: const EdgeInsets.only(left: 20, right: 20),
          heroTag: null,
          onPressed: () {
            store.set('showButtons' + widget.view, true);
          },
          backgroundColor: kAltoBlue,
          elevation: 20,
          label: Text(widget.buttonText, style: kStartButton),
        ),
        replacement: FloatingActionButton(
          key: const Key('xButton'),
          onPressed: () {
            setState(() {
              store.set('showButtons' + widget.view, false);
            });
          },
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
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
    cancelListener = store.listen([
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        heroTag: null,
        onPressed: () {
          store.set('swiped' + widget.view, true);
          store.set('showButtons' + widget.view, false);
        },
        backgroundColor: kAltoOrganized,
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
    cancelListener = store.listen(
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          key: const Key('doneButton'),
          heroTag: null,
          onPressed: () {
            // Done tagging
            if (currentlyTagging != '') {
              TagService.instance.doneTagging(widget.view.toLowerCase());
              store.set('swiped' + widget.view, false);
              store.remove('currentlyTagging' + widget.view);
              store.remove('hideAddMoreTagsButton' + widget.view);
              store.remove('showSelectAllButton' + widget.view);
              store.remove('toggleTags' + widget.view);
              if (widget.view == 'Local') {
                PivService.instance.queryOrganizedLocalPivs();
                TagService.instance
                    .getLocalAchievements(store.get('localPage'));
              }
              // We update the list of organized pivs for those uploaded pivs that have a local counterpart
              // Done deleting
            } else {
              var currentlyDeleting =
                  store.get('currentlyDeletingPivs' + widget.view);
              store.remove('showSelectAllButton' + widget.view);
              if (currentlyDeleting != '' && currentlyDeleting.length > 0) {
                store.set('currentlyDeletingModal' + widget.view, true);
              } else {
                store.remove('currentlyDeleting' + widget.view);
              }
            }
          },
          backgroundColor: currentlyDeleting ? kAltoRed : kAltoOrganized,
          label: const Text('Done', style: kSelectAllButton),
          icon: const Icon(
            Icons.done,
            color: Colors.white,
          ),
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
  double initialScrollableSize = store.get('initialScrollableSize');
  double currentScrollableSize = store.get('initialScrollableSize');

  @override
  void initState() {
    super.initState();
    cancelListener = store.listen([
      'usertags',
      'currentlyTagging' + widget.view,
      'tagFilter' + widget.view,
      'swiped' + widget.view,
    ], (Usertags, CurrentlyTagging, TagFilter, Swiped) {
      setState(() {
        usertags = TagService.instance.getTagList(
            CurrentlyTagging == '' ? [] : CurrentlyTagging, TagFilter, true);

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
                store.set('swiped' + widget.view, false);
              if (state.extent > (0.77 - 0.0001))
                store.set('swiped' + widget.view, true);
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
                              store.set('swiped' + widget.view, false);
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
                                textCapitalization:
                                    TextCapitalization.sentences,
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
                                  store.set('tagFilter' + widget.view, query);
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
                                if (usertags.length == 3 &&
                                    RegExp(' \\(example\\)\$').hasMatch(tag)) {
                                  actualTag = tag.replaceFirst(
                                      RegExp(' \\(example\\)\$'), '');
                                  actualTag = actualTag.trim();
                                }
                                return TagListElement(
                                  // Because tags can be renamed, we need to set a key here to avoid recycling them if they change.
                                  key: Key(widget.view + '-' + tag),
                                  tagColor: tag == 'o::'
                                      ? kAltoOrganized
                                      : tagColor(actualTag),
                                  tagName: tag == 'o::' ? 'Organized' : tag,
                                  view: widget.view.toLowerCase(),
                                  icon: tag == 'o::' ? kCircleCheckIcon : null,
                                  onTap: () {
                                    // We need to wrap this in another function, otherwise it gets executed on view draw. Madness.
                                    return () {
                                      if (tag != 'o::' &&
                                          RegExp('^[a-z]::')
                                              .hasMatch(actualTag))
                                        return showSnackbar(
                                            'Alas, you cannot use that tag.',
                                            'yellow');
                                      store.set('swiped' + widget.view, false);
                                      var currentlyTagging = store.get(
                                          'currentlyTagging' + widget.view);
                                      store.set(
                                          'currentlyTagging' + widget.view,
                                          currentlyTagging == ''
                                              ? [actualTag]
                                              : currentlyTagging + [actualTag]);
                                      store.remove('tagFilter' + widget.view);
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
    cancelListener = store.listen(['currentlyDeletingModal' + widget.view],
        (CurrentlyDeleting) {
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
        height: SizeService.instance.screenWidth(context) * .75,
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
                    var pivsToDelete =
                        store.get('currentlyDeletingPivs' + widget.view);
                    if (widget.view == 'Local')
                      PivService.instance.deleteLocalPivs(pivsToDelete);
                    else
                      TagService.instance.deleteUploadedPivs(pivsToDelete);
                    store.remove('currentlyDeleting' + widget.view);
                    store.remove('currentlyDeletingPivs' + widget.view);
                    store.remove('currentlyDeletingModal' + widget.view);
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
                    store.remove('currentlyDeleting' + widget.view);
                    store.remove('currentlyDeletingPivs' + widget.view);
                    store.remove('currentlyDeletingModal' + widget.view);
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
    cancelListener = store.listen(['renameTag' + widget.view], (RenameTag) {
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
                      store.remove('renameTag' + widget.view);
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
                      store.remove('renameTag' + widget.view);
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
    cancelListener = store.listen(['deleteTag' + widget.view], (DeleteTag) {
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
                  store.remove('deleteTag' + widget.view);
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
                  store.remove('deleteTag' + widget.view);
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

class GridItemMask extends StatefulWidget {
  final String id;
  final String type;

  const GridItemMask(this.id, this.type, {Key? key}) : super(key: key);

  @override
  State<GridItemMask> createState() => _GridItemMaskState(id, type);
}

class _GridItemMaskState extends State<GridItemMask> {
  dynamic cancelListener;
  final String id;
  final String type;
  var mask = 'none';

  _GridItemMaskState(this.id, this.type);

  @override
  void initState() {
    super.initState();
    cancelListener = store.listen([
      'tagMap' + (type == 'local' ? 'Local' : 'Uploaded') + ':' + id,
      'currentlyDeletingPivs' + (type == 'local' ? 'Local' : 'Uploaded'),
      'currentlyTagging' + (type == 'local' ? 'Local' : 'Uploaded'),
      'currentlyDeleting' + (type == 'local' ? 'Local' : 'Uploaded'),
    ], (Tagged, CurrentlyDeletingPivs, CurrentlyTagging, CurrentlyDeleting) {
      setState(() {
        if (CurrentlyTagging == '' && CurrentlyDeleting == '') mask = 'none';
        if (CurrentlyDeleting != '') {
          if (CurrentlyDeletingPivs == '') CurrentlyDeletingPivs = [];
          mask = CurrentlyDeletingPivs.contains(id) ? 'delete' : 'none';
        }
        if (CurrentlyTagging != '') mask = Tagged == true ? 'tag' : 'none';
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
    if (mask == 'none')
      return const Visibility(visible: false, child: Text(''));
    return Positioned.fill(
        child: IgnorePointer(
            child: Container(
                color: (mask == 'tag' ? kAltoOrganized : kAltoRed)
                    .withOpacity(0.3))));
  }
}
