import 'dart:core';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tagaway/main.dart';
import 'package:tagaway/services/authService.dart';
import 'package:tagaway/services/pivService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/services/tools.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/accountView.dart';
import 'package:tagaway/views/uploadedGridItemView.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/sizeService.dart';

class OldHomeView extends StatefulWidget {
  static const String id = 'oldHome';

  const OldHomeView({Key? key}) : super(key: key);

  @override
  State<OldHomeView> createState() => _OldHomeViewState();
}

class _OldHomeViewState extends State<OldHomeView> {
  dynamic cancelListener;

  dynamic hometags = '';
  dynamic thumbs = {};
  dynamic tags = '';
  dynamic account = {
    'username': '',
    'usage': {'byfs': 0}
  };
  dynamic organized = {'total': '...', 'today': '...'};

  @override
  void initState() {
    super.initState();
    cancelListener = store
        .listen(['hometags', 'tags', 'account', 'thumbs', 'organized'],
            (v1, v2, v3, v4, Organized) {
      setState(() {
        hometags = v1;
        if (v2 != '')
          tags = v2
              .toList()
              .where((tag) => !RegExp('^(t|u|o)::').hasMatch(tag))
              .toList();
        if (v3 != '') account = v3;
        if (v4 != '') thumbs = v4;
        if (Organized != '') organized = Organized;
      });
    });

    AuthService.instance.getAccount();
    TagService.instance.getTags();
    (() async {
      // AVAILABILITY THRESHOLD TO SHOW MODAL: 1GB
      var availableThreshold = 1000 * 1000 * 1000;
      // POTENTIAL THRESHOLD TO SHOW MODAL: 100MB
      var potentialThreshold = 100 * 1000 * 1000;
      var availableBytes = await getAvailableStorage();
      var potentialCleanup = await PivService.instance.deletePivsByRange('all');
      if (availableBytes < availableThreshold &&
          potentialCleanup > potentialThreshold)
        TagawaySpaceCleanerModal1(
            scaffoldKey.currentContext!, availableBytes, potentialCleanup);
    })();
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
  }

  _launchUrl() async {
    if (!await launchUrl(Uri.parse(kTagawayURL),
        mode: LaunchMode.externalApplication)) {
      throw "cannot launch url";
    }
  }

  mailto() async {
    EmailContent email = EmailContent(
      to: [
        'info@altocode.nl',
      ],
      subject: 'Tagaway Feedback!',
      body: 'What needs to be improved in Tagaway is:',
    );

    OpenMailAppResult result = await OpenMailApp.composeNewEmailInMailApp(
        nativePickerTitle: 'Select email app to compose', emailContent: email);
    if (!result.didOpen && !result.canOpen) {
      showNoMailAppsDialog(context);
    } else if (!result.didOpen && result.canOpen) {
      showDialog(
        context: context,
        builder: (_) => MailAppPickerDialog(
          mailApps: result.options,
          emailContent: email,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: kAltoBlue),
        leading: Image.asset(
          'images/tag blue with white - 400x400.png',
          scale: 8,
        ),
        title: Row(
          children: [
            const Expanded(
                flex: 2, child: Text('tagaway', style: kTagawayMain)),
            Padding(
              padding: const EdgeInsets.only(top: 1.0),
              child: Text(
                account['username'],
                style: kPlainText,
              ),
            ),
          ],
        ),
        centerTitle: false,
        titleSpacing: 0.0,
      ),
      endDrawer: Drawer(
          child: ListView(
        // padding: const EdgeInsets.all(8),
        children: <Widget>[
          SizedBox(
            height: 64,
            child: DrawerHeader(
              child: Text(account['username'], style: kSubPageAppBarTitle),
            ),
          ),
          UserMenuElementTransparent(
              textOnElement: 'Your usage: ' +
                  (account['usage']['byfs'] / (1000 * 1000 * 1000))
                      .round()
                      .toString() +
                  'GB of your free 5GB'),
          UserMenuElementLightGrey(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return const AccountView();
              }));
            },
            textOnElement: 'Account',
          ),
          UserMenuElementLightGrey(
              onTap: () {
                _launchUrl();
              },
              textOnElement: 'Go to tagaway web'),
          UserMenuElementLightGrey(
              onTap: () {
                mailto();
              },
              textOnElement: 'Send Us Feedback'),
          UserMenuElementLightGrey(
              onTap: () {
                Navigator.pushReplacementNamed(context, 'deleteAccount');
              },
              textOnElement: 'Delete My Account'),
          // UserMenuElementKBlue(
          //   onTap: () async {
          //     var availableBytes = await getAvailableStorage();
          //     var potentialCleanup =
          //         await PivService.instance.deletePivsByRange('all');
          //     TagawaySpaceCleanerModal1(scaffoldKey.currentContext!,
          //         availableBytes, potentialCleanup);
          //   },
          //   textOnElement: 'Clear Up Space',
          // ),
          UserMenuElementDarkGrey(
              onTap: () {
                // We need to wrap this in another function, otherwise it gets executed on view draw. Madness.
                return () {
                  AuthService.instance.logout().then((value) {
                    if (value == 200)
                      return Navigator.pushReplacementNamed(
                          context, 'distributor');
                    SnackBarGlobal.buildSnackBar(context,
                        'Something is wrong on our side. Sorry.', 'red');
                  });
                };
              },
              textOnElement: 'Log out'),
        ],
      )),
      body: SafeArea(
        child: tags == ''
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kAltoBlue),
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  return TagService.instance.getTags();
                },
                child: Stack(
                  children: [
                    // TAG GRID
                    Padding(
                        padding:
                            const EdgeInsets.only(left: 12, right: 12, top: 0),
                        child: GridView.builder(
                            shrinkWrap: true,
                            cacheExtent: 50,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 50,
                              crossAxisSpacing: 8,
                            ),
                            itemCount: tags.length,
                            itemBuilder: (BuildContext context, int index) {
                              var tag = tags[index];
                              // If thumb hasn't loaded yet, do not return anything.
                              if (thumbs[tag] == null) return Container();
                              return GestureDetector(
                                  onTap: () async {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (_) {
                                      return CarrouselView(
                                          initialPiv: 0,
                                          pivs: [thumbs[tag]],
                                          currentTag: tag);
                                    }));
                                    TagService.instance.getTags();
                                  },
                                  child: HomeCard(
                                      color: tagColor(tag),
                                      tag: tag,
                                      thumb: thumbs[tag]['id'],
                                      localPiv: thumbs[tag]['local'] == true
                                          ? thumbs[tag]['piv']
                                          : null,
                                      deg: thumbs[tag]['deg'] == null
                                          ? 0
                                          : thumbs[tag]['deg']));
                            })),
                    /* HOME AWARDS
                          HomeAwardsView(
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 80,
                                    child: Center(
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              organized['total'].toString(),
                                              style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: kAltoOrganized),
                                            ),
                                            Text(
                                              'organized',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: kGreyDarker),
                                            ),
                                          ]),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 80,
                                    child: Center(
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              organized['today'].toString(),
                                              style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: kAltoOrganized),
                                            ),
                                            Text(
                                              'today',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: kGreyDarker),
                                            ),
                                          ]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          */
                    Align(
                      alignment: const Alignment(0, .9),
                      child: FloatingActionButton.extended(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          extendedPadding:
                              const EdgeInsets.only(left: 20, right: 20),
                          backgroundColor: kAltoBlue,
                          elevation: 20,
                          label: const Icon(
                            kSearchIcon,
                            color: Colors.white,
                            size: 15,
                          ),
                          icon: const Text('Search', style: kButtonText),
                          key: const Key('homeFabQuerySelectorOld'),
                          onPressed: () {
                            store.set('queryTags', []);
                            Navigator.pushReplacementNamed(
                                context, 'querySelector');
                          }),
                    )
                  ],
                )),
      ),
      /* EDIT HOMETAGS
      floatingActionButton: Visibility(
        visible: hometags.isNotEmpty,
        child: FloatingActionButton(
          heroTag: null,
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.pushReplacementNamed(context, 'editHomeTags');
          },
          backgroundColor: kAltoBlue,
          child: const Icon(
            Icons.create_rounded,
            color: Colors.white,
          ),
        ),
      ),
      */
    );
  }

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Open Mail App"),
          content: const Text("No mail apps installed"),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}

class HomeAwardsView extends StatefulWidget {
  final Widget child;

  const HomeAwardsView({Key? key, required this.child}) : super(key: key);

  @override
  State<HomeAwardsView> createState() => _HomeAwardsViewState();
}

class _HomeAwardsViewState extends State<HomeAwardsView> {
  dynamic cancelListener;
  dynamic cancelListener2;

  dynamic achievements = [];

  @override
  void initState() {
    super.initState();
    TagService.instance.getOverallAchievements();
    cancelListener = store.listen(['achievements'], (Achievements) {
      setState(() {
        if (Achievements != '') achievements = Achievements;
      });
    });
    cancelListener2 = store.listen(['localPage:*'], (LocalPage) {
      setState(() {
        // Recompute when local pages change
        TagService.instance.getOverallAchievements();
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
    return GestureDetector(
      onTap: () {
        showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return Container(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  color: Colors.white,
                  height: SizeService.instance.screenHeight(context) > 860
                      ? SizeService.instance.screenHeight(context) * .8
                      : SizeService.instance.screenHeight(context) * .77,
                  child: Stack(
                    children: [
                      ListView(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        children: [
                          const Icon(
                            kMinusIcon,
                            color: kGreyDarker,
                            size: 30,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Your Achievements',
                                  style: kLookingAtText,
                                ),
                              ],
                            ),
                          ),
                          GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: achievements.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                              itemBuilder: (BuildContext context, index) {
                                return HexagonWidget(achievements[index]);
                              }),
                        ],
                      ),
                      Align(
                        alignment: const Alignment(0, .8),
                        child: FloatingActionButton.extended(
                          onPressed: () {
                            // This function is lightly adapted from the one we use in the score of the local view
                            // The main difference is that we start from the beginning
                            var jumpToIndex;
                            store.getKeys('^localPage:').forEach((pageIndex) {
                              if (jumpToIndex != null)
                                return; // We found a match, no need to do anything else.

                              pageIndex = pageIndex.split(':');
                              pageIndex = int.parse(pageIndex[1]);

                              if (store
                                      .get('localPage:' + pageIndex.toString())[
                                          'pivs']
                                      .length >
                                  0) jumpToIndex = pageIndex;
                            });

                            if (jumpToIndex != null)
                              store
                                  .get('localPageController')
                                  .jumpToPage(jumpToIndex);
                            else
                              SnackBarGlobal.buildSnackBar(
                                  context,
                                  'You are all done organizing! If only we were like you...',
                                  'green');
                            Navigator.pop(context); // Collapse modal
                            store.set('viewIndex', 1); // Go to local view
                          },
                          extendedPadding:
                              const EdgeInsets.only(left: 20, right: 20),
                          heroTag: null,
                          backgroundColor: kAltoBlue,
                          elevation: 20,
                          label: const Text('Keep Going!', style: kStartButton),
                        ),
                      )
                    ],
                  ));
            });
      },
      child: widget.child,
    );
  }
}

class HexagonWidget extends StatelessWidget {
  final achievement;

  const HexagonWidget(this.achievement);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: HexagonPainter(achievement[1] == 'all'),
          child: const SizedBox(
            width: 200,
            height: 200,
          ),
        ),
        Align(
          alignment: Alignment(0, -.5),
          child: Text(
            achievement[1] == 'all'
                ? 'Year'
                : longMonthNames[achievement[1] - 1],
            style: kButtonText,
          ),
        ),
        Align(
          alignment: Alignment(0, 0),
          child: Text(
            achievement[0].toString(),
            style: TextStyle(
              fontFamily: 'Montserrat-Regular',
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, .7),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white, width: 1.5)),
            child: const Icon(
              kCircleCheckIcon,
              color: kAltoOrganized,
              size: 15,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.white, width: 1.5)),
        )
      ],
    );
  }
}

class HexagonPainter extends CustomPainter {
  final isYear;
  const HexagonPainter(this.isYear);
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = isYear ? kAltoOrganized : kAltoBlue
      ..style = PaintingStyle.fill;

    var path = Path();

    // Radius is half the width of the container
    double radius = size.width / 2;
    // Angle for hexagon points (60 degrees in radians)
    double angle = math.pi / 3;

    // Calculate the points for a regular hexagon
    for (int i = 0; i < 6; i++) {
      double x = radius * math.cos(angle * i - math.pi / 6) +
          radius; // Adjust for upward point
      double y = radius * math.sin(angle * i - math.pi / 6) + radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class HomeCard extends StatelessWidget {
  const HomeCard(
      {Key? key,
      required this.color,
      required this.tag,
      required this.thumb,
      required this.deg,
      this.localPiv})
      : super(key: key);

  final Color color;
  final String tag;
  final String thumb;
  final int deg;
  final dynamic localPiv;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Transform.rotate(
                angle: deg * math.pi / 180.0,
                child: localPiv == null
                    ? Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                            border: Border.all(color: Colors.transparent),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(kTagawayThumbSURL + thumb,
                                    headers: {
                                      'cookie': store.get('cookie'),
                                    }))))
                    : FutureBuilder<Uint8List?>(
                        future: localPiv.thumbnailDataWithSize(
                            const ThumbnailSize.square(400)),
                        builder: (_, snapshot) {
                          final bytes = snapshot.data;
                          if (bytes == null) {
                            return const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(kAltoBlue),
                            );
                          }
                          return Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: MemoryImage(bytes),
                              ),
                            ),
                          );
                        }))),
        Positioned(
          bottom: -30,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Padding(
                padding: EdgeInsets.only(top: 2.0),
                child: FaIcon(
                  tagIcon(tag),
                  color: tagIconColor(tag),
                  size: 16,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                shortenSuggestion(tagTitle(tag), context),
                textAlign: TextAlign.center,
                style: kHomeStackedTagText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            ]),
          ),
        ),
      ],
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
