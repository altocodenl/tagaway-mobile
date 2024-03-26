import 'dart:io' show File;
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tagaway/services/authService.dart';
import 'package:tagaway/services/pivService.dart';
import 'package:tagaway/services/sizeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/services/tools.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/accountView.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class HomeView extends StatefulWidget {
  static const String id = 'home';

  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  dynamic cancelListener;
  dynamic cancelListener2;

  dynamic account = {
    'username': '',
    'usage': {'byfs': 0}
  };
  dynamic queryResult = {'pivs': [], 'total': 0};

  dynamic seenPivIndexes = [];
  final ScrollController scrollController = ScrollController();

  getNextIndex(int length) {
    var index = (new math.Random().nextInt(length));
    if (!seenPivIndexes.contains(index)) {
      seenPivIndexes.add(index);
      return index;
    }
    return getNextIndex(length);
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

  @override
  void initState() {
    super.initState();
    AuthService.instance.getAccount();
    // Wait for some local pivs to be loaded.
    Future.delayed(Duration(seconds: 1), () {
      store.set('queryTags', []);
    });
    cancelListener =
        store.listen(['account', 'queryResult'], (Account, QueryResult) {
      // Because of the sheer liquid modernity of this interface, we might need to make this `mounted` check.
      if (!mounted) return;
      setState(() {
        if (Account != '') account = Account;
        if (QueryResult != '') queryResult = QueryResult;
      });
    });
    cancelListener2 = store.listen(['queryTags'], (QueryTags) {
      if (!mounted) return;
      if (QueryTags == '') return;
      if (scrollController.hasClients) scrollController.jumpTo(0);
      seenPivIndexes = [];
      store.remove('deletedPivs');
      TagService.instance.queryPivs(true);
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
    cancelListener2();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAltoBlack,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kAltoBlack,
        title: GestureDetector(
            onTap: () {
              var tags = store.get('queryTags');
              store.set('queryTags', ['nosuchquery'], '', 'mute');
              store.set('queryTags', tags);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/tag check - 0c0c0cff - 400x400.png',
                  scale: 10,
                ),
                const Text('tagaway', style: kTagawayMain),
              ],
            )),
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
          child: queryResult['pivs'].length == 0
              ? const Center(
                  child: CircularProgressIndicator(
                  color: kAltoBlue,
                ))
              : RefreshIndicator(
                  onRefresh: () async {
                    seenPivIndexes = [];
                    store.remove('deletedPivs');
                    TagService.instance.queryPivs(true);
                    if (scrollController.hasClients) scrollController.jumpTo(0);
                  },
                  child: Stack(children: [
                    CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        SliverList.builder(
                            itemCount: queryResult['pivs'].length,
                            itemBuilder: (BuildContext context, int index) {
                              var nextIndex;
                              if (seenPivIndexes.length - 1 < index)
                                nextIndex =
                                    getNextIndex(queryResult['pivs'].length);
                              else
                                nextIndex = seenPivIndexes[index];
                              return Padding(
                                  padding: const EdgeInsets.only(bottom: 40),
                                  child: (() {
                                    // We check whether the index is in bound, because sometimes when the query changes, we might no longer be in bound
                                    var piv;
                                    try {
                                      piv = queryResult['pivs'][nextIndex];
                                    } catch (error) {
                                      return Container();
                                    }
                                    var date =
                                        DateTime.fromMillisecondsSinceEpoch(
                                            piv['date']);
                                    // LOCAL PHOTO
                                    if (piv['local'] == true &&
                                        piv['piv'].type == AssetType.image)
                                      return LocalPhoto(
                                        piv: piv['piv'],
                                        date: date,
                                      );
                                    // LOCAL VIDEO
                                    if (piv['local'] == true &&
                                        piv['piv'].type != AssetType.image)
                                      return LocalVideo(
                                        piv: piv['piv'],
                                        date: date,
                                      );
                                    // CLOUD PHOTO
                                    if (piv['local'] == null &&
                                        piv['vid'] == null)
                                      return CloudPhoto(
                                        piv: piv,
                                        date: date,
                                      );
                                    // CLOUD VIDEO
                                    if (piv['local'] == null &&
                                        piv['vid'] != null)
                                      return CloudVideo(
                                        piv: piv,
                                        date: date,
                                      );
                                  })());
                            })
                      ],
                    ),
                    Align(
                      alignment: const Alignment(0, .9),
                      child: FloatingActionButton.extended(
                          key: const Key('homeFabQuerySelector'),
                          heroTag: 'homeFabQuerySelector',
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
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, 'querySelector');
                          }),
                    ),
                    DeleteModal(view: 'Uploaded')
                  ]))),
    );
  }
}

class LocalPhoto extends StatefulWidget {
  final AssetEntity piv;
  final DateTime date;

  const LocalPhoto({Key? key, required this.piv, required this.date})
      : super(key: key);

  @override
  State<LocalPhoto> createState() => _LocalPhotoState();
}

class _LocalPhotoState extends State<LocalPhoto>
    with SingleTickerProviderStateMixin {
  dynamic cancelListener;
  bool hidePiv = false;
  dynamic pendingTags = [];

  Future<File?> loadImage(piv) async {
    var file = await piv.file;
    return file;
  }

  @override
  void initState() {
    super.initState();
    cancelListener = store.listen([
      'deletedPivs',
      'hideMap:' + widget.piv.id,
      'pendingTags:' + widget.piv.id
    ], (DeletedPivs, PivHidden, PendingTags) {
      if (DeletedPivs == '') DeletedPivs = [];
      if (DeletedPivs.contains(widget.piv.id) && hidePiv == false) {
        setState(() => hidePiv = true);
      }
      if (PivHidden == true && hidePiv == false) {
        setState(() => hidePiv = true);
      }
      if (PendingTags != '') setState(() => pendingTags = PendingTags);
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
  }

  computeHeight() {
    print('I am in LocalPhoto and height is ${widget.piv.height}');
    print('I am in LocalPhoto and width is ${widget.piv.width}');
    print(
        'I am in LocalPhoto and height/width is ${widget.piv.height / widget.piv.width}');

    if (widget.piv.height > widget.piv.width * 1.7)
      return SizeService.instance.screenHeight(context) * .85;
    if (widget.piv.height > widget.piv.width * 1.4)
      return SizeService.instance.screenHeight(context) * .7;
    if (widget.piv.height > widget.piv.width * 1.2)
      return SizeService.instance.screenHeight(context) * .6;
    if (widget.piv.height >= widget.piv.width)
      return SizeService.instance.screenHeight(context) * .5;
    if (widget.piv.height * 1.4 > widget.piv.width)
      return SizeService.instance.screenHeight(context) * .4;
    return SizeService.instance.screenHeight(context) * .35;
  }

  @override
  Widget build(BuildContext context) {
    Future<File?> file = loadImage(widget.piv);

    if (hidePiv) return Container();

    return Column(
      children: [
        TagsRow(tags: pendingTags),
        Container(
          height: computeHeight(),
          alignment: Alignment.center,
          child: FutureBuilder<File?>(
            future: file,
            builder: (_, snapshot) {
              final file = snapshot.data;
              if (file == null) return Container();
              return Image.file(file);
            },
          ),
        ),
        IconsRow(
          piv: {'piv': widget.piv, 'local': true},
          pivHeight: widget.piv.height,
          pivWidth: widget.piv.width,
          deletePiv: () {
            PivService.instance.deleteLocalPivs([widget.piv.id], null, () {
              store.set(
                  'deletedPivs', getList('deletedPivs') + [widget.piv.id]);
            });
          },
          hidePiv: () {
            store.set('hideMap:' + widget.piv.id, true, 'disk');
          },
          sharePiv: () {
            shareLocalPiv(context, widget.piv, false);
          },
          tagPiv: () {},
        ),
        Padding(
          padding: widget.piv.height > widget.piv.width
              ? const EdgeInsets.only(left: 12.0, top: 10)
              : const EdgeInsets.only(left: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                shortMonthNames[widget.date.month - 1].toString(),
                style: kLightBackgroundDate,
              ),
              const Text(
                ' ',
                style: kLightBackgroundDate,
              ),
              Text(pad(widget.date.day), style: kLightBackgroundDate),
              const Text(
                ', ',
                style: kLightBackgroundDate,
              ),
              Text(
                widget.date.year.toString(),
                style: kLightBackgroundDate,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LocalVideo extends StatefulWidget {
  const LocalVideo({Key? key, required this.piv, required this.date})
      : super(key: key);
  final AssetEntity piv;
  final DateTime date;

  @override
  _LocalVideoState createState() => _LocalVideoState();
}

class _LocalVideoState extends State<LocalVideo> {
  late VideoPlayerController _controller;
  bool initialized = false;
  bool hidePiv = false;
  dynamic cancelListener;
  dynamic pendingTags = [];

  @override
  void initState() {
    _initVideo();
    super.initState();
    cancelListener = store.listen([
      'deletedPivs',
      'hideMap:' + widget.piv.id,
      'pendingTags:' + widget.piv.id
    ], (DeletedPivs, PivHidden, PendingTags) {
      if (DeletedPivs == '') DeletedPivs = [];
      if (DeletedPivs.contains(widget.piv.id) && hidePiv == false) {
        setState(() => hidePiv = true);
      }
      if (PivHidden == true && hidePiv == false) {
        setState(() => hidePiv = true);
      }
      if (PendingTags != '') setState(() => pendingTags = PendingTags);
    });
  }

  @override
  void dispose() {
    try {
      super.dispose();
      cancelListener();
      _controller.dispose();
    } catch (_) {
      // We ignore the error.
    }
  }

  _initVideo() async {
    // Because of the sheer liquid modernity of this interface, we might need to make this `mounted` check.
    if (!mounted) return;
    final video = await widget.piv.file;
    // If video was deleted or hidden, don't do anything.
    if (hidePiv == true || video == null) return;
    _controller = VideoPlayerController.file(video)
      // Play the video again when it ends
      ..setLooping(true)
      // initialize the controller and notify UI when done
      ..initialize().then((_) => setState(() {
            initialized = true;
            _controller.pause();
          }));
  }

  @override
  Widget build(BuildContext context) {
    var height = widget.piv.height > widget.piv.width
        ? SizeService.instance.screenHeight(context) * .8
        : SizeService.instance.screenHeight(context) * .35;
    if (hidePiv) return Container();
    return initialized
        // If the video is initialized, display it
        ? Stack(children: [
            Column(
              children: [
                TagsRow(tags: pendingTags),
                Container(
                  alignment: Alignment.center,
                  height: height,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    // Use the VideoPlayer widget to display the video.
                    child: VideoPlayer(_controller),
                  ),
                ),
                IconsRow(
                  piv: {'piv': widget.piv, 'local': true},
                  pivHeight: widget.piv.height,
                  pivWidth: widget.piv.width,
                  deletePiv: () {
                    PivService.instance.deleteLocalPivs([widget.piv.id], null,
                        () {
                      store.set('deletedPivs',
                          getList('deletedPivs') + [widget.piv.id]);
                    });
                  },
                  hidePiv: () {
                    store.set('hideMap:' + widget.piv.id, true, 'disk');
                  },
                  sharePiv: () {
                    shareLocalPiv(context, widget.piv, true);
                  },
                  tagPiv: () {},
                ),
                Padding(
                  padding: widget.piv.height > widget.piv.width
                      ? EdgeInsets.only(left: 12.0, top: 10)
                      : EdgeInsets.only(left: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        shortMonthNames[widget.date.month - 1].toString(),
                        style: kLightBackgroundDate,
                      ),
                      const Text(
                        ' ',
                        style: kLightBackgroundDate,
                      ),
                      Text(pad(widget.date.day), style: kLightBackgroundDate),
                      const Text(
                        ', ',
                        style: kLightBackgroundDate,
                      ),
                      Text(
                        widget.date.year.toString(),
                        style: kLightBackgroundDate,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 90,
              left: SizeService.instance.screenWidth(context) * .43,
              child: FloatingActionButton(
                key: Key('vidPlay' + widget.piv.id),
                heroTag: 'vidPlay' + widget.piv.id,
                shape: const CircleBorder(),
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
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
            ),
          ])
        // If the video is not yet initialized, display a spinner
        : Container(
            height: height,
            child: Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kAltoBlue),
            )));
  }
}

class CloudPhoto extends StatefulWidget {
  final dynamic piv;
  final DateTime date;

  const CloudPhoto({Key? key, required this.piv, required this.date})
      : super(key: key);

  @override
  State<CloudPhoto> createState() => _CloudPhotoState();
}

class _CloudPhotoState extends State<CloudPhoto> {
  dynamic cancelListener;
  late TransformationController controller;
  ScrollPhysics? pageBuilderScroll;
  bool hidePiv = false;

  bool matrixAlmostEqual(Matrix4 a, Matrix4 b, [double epsilon = 10]) {
    for (var i = 0; i < 16; i++) {
      if ((a.storage[i] - b.storage[i]).abs() > epsilon) {
        return false;
      }
    }
    return true;
  }

  @override
  void initState() {
    controller = TransformationController();
    super.initState();
    cancelListener = store
        .listen(['deletedPivs', 'hideMap:' + widget.piv['id']],
            (DeletedPivs, PivHidden) {
      if (DeletedPivs == '') DeletedPivs = [];
      if (DeletedPivs.contains(widget.piv['id']) && hidePiv == false) {
        setState(() => hidePiv = true);
      }
      if (PivHidden == true && hidePiv == false) {
        setState(() => hidePiv = true);
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
    if (hidePiv) return Container();
    return CachedNetworkImage(
        imageUrl: (kTagawayThumbMURL) + (widget.piv['id']),
        httpHeaders: {'cookie': store.get('cookie')},
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(
              color: kAltoBlue,
            )),
        imageBuilder: (context, imageProvider) {
          final askance = widget.piv['deg'] == 90 || widget.piv['deg'] == -90;
          final height = askance ? widget.piv['dimw'] : widget.piv['dimh'];
          final width = askance ? widget.piv['dimh'] : widget.piv['dimw'];

          var containerHeight = () {
            print('I am in CloudPhoto and height is $height');
            print('I am in CloudPhoto and width is $width');
            print('I am in CloudPhoto and height/width is ${height / width}');
            if (height > width * 1.7) {
              print('height > width * 1.7');
              return SizeService.instance.screenHeight(context) * .85;
            }
            if (height > width * 1.4) {
              print('height > width * 1.4');
              return SizeService.instance.screenHeight(context) * .7;
            }
            if (height > width * 1.2) {
              print('height > width * 1.2');
              return SizeService.instance.screenHeight(context) * .6;
            }
            if (height >= width) {
              print('height >= width');
              return SizeService.instance.screenHeight(context) * .5;
            }
            if (height * 1.4 > width) {
              print('height * 1.4 > width');
              return SizeService.instance.screenHeight(context) * .4;
            }
            return SizeService.instance.screenHeight(context) * .35;
          };
          var containerWidth = SizeService.instance.screenWidth(context);

          var left = (askance ? -(width - height) / 2 : 0).toDouble();
          // The 50px are to center the image a bit. We need to properly compute the space taken up by the header and the footer.
          var top = (askance ? -(height - width + 50) / 2 : 0).toDouble();

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: askance
                    ? const EdgeInsets.only(bottom: 80.0)
                    : const EdgeInsets.all(8.0),
                child: TagsRow(
                    tags: widget.piv['tags']
                        .where((tag) => !RegExp('^[a-z]::').hasMatch(tag))
                        .toList()),
              ),
              Transform.rotate(
                angle: (widget.piv['deg'] == null ? 0 : widget.piv['deg']) *
                    math.pi /
                    180.0,
                child: Container(
                  width: askance ? containerHeight() : containerWidth,
                  height: askance ? containerWidth : containerHeight(),
                  child: Transform.scale(
                    scale: askance ? 1.4 : 1,
                    child: Image(
                      fit: BoxFit.contain,
                      image: imageProvider,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: askance
                    ? const EdgeInsets.only(top: 80.0)
                    : const EdgeInsets.all(8.0),
                child: IconsRow(
                  piv: widget.piv,
                  pivHeight: height,
                  pivWidth: width,
                  deletePiv: () {
                    store.set(
                        'currentlyDeletingPivsUploaded', [widget.piv['id']]);
                    store.set('currentlyDeletingModalUploaded', true);
                  },
                  hidePiv: () {
                    store.set('hideMap:' + widget.piv['id'], true, 'disk');
                  },
                  sharePiv: () {
                    shareCloudPiv(context, widget.piv['id'], true);
                  },
                  tagPiv: () {},
                ),
              ),
              Padding(
                padding: height > width
                    ? EdgeInsets.only(left: 12.0, top: 10)
                    : EdgeInsets.only(left: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      shortMonthNames[widget.date.month - 1].toString(),
                      style: kLightBackgroundDate,
                    ),
                    const Text(
                      ' ',
                      style: kLightBackgroundDate,
                    ),
                    Text(pad(widget.date.day), style: kLightBackgroundDate),
                    const Text(
                      ', ',
                      style: kLightBackgroundDate,
                    ),
                    Text(
                      widget.date.year.toString(),
                      style: kLightBackgroundDate,
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}

class CloudVideo extends StatefulWidget {
  const CloudVideo({Key? key, required this.piv, required this.date})
      : super(key: key);
  final dynamic piv;
  final DateTime date;

  @override
  State<CloudVideo> createState() => _CloudVideoState();
}

class _CloudVideoState extends State<CloudVideo> {
  late VideoPlayerController _controller;
  bool initialized = false;
  bool hidePiv = false;
  dynamic cancelListener;

  @override
  void initState() {
    _initVideo();
    super.initState();
    cancelListener = store
        .listen(['deletedPivs', 'hideMap:' + widget.piv['id']],
            (DeletedPivs, PivHidden) {
      if (DeletedPivs == '') DeletedPivs = [];
      if (DeletedPivs.contains(widget.piv['id']) && hidePiv == false) {
        setState(() => hidePiv = true);
      }
      if (PivHidden == true && hidePiv == false) {
        setState(() => hidePiv = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    cancelListener();
    super.dispose();
  }

  _initVideo() async {
    // If video was deleted or hidden, don't do anything.
    if (hidePiv == true) return;
    _controller = VideoPlayerController.network(
      (kTagawayVideoURL) + (widget.piv['id']),
      httpHeaders: {
        'cookie': store.get('cookie'),
        'Range': 'bytes=0-',
      },
    );
    // Play the video again when it ends
    _controller.setLooping(true);
    // initialize the controller and notify UI when done
    _controller.initialize().then((_) => setState(() {
          initialized = true;
          _controller.pause();
        }));
  }

  @override
  Widget build(BuildContext context) {
    if (hidePiv) return Container();
    var height = _controller.value.size.height > _controller.value.size.width
        ? SizeService.instance.screenHeight(context) * .8
        : SizeService.instance.screenHeight(context) * .25;
    return _controller.value.isInitialized
        ? Stack(
            children: [
              Column(
                children: [
                  TagsRow(
                      tags: widget.piv['tags']
                          .where((tag) => !RegExp('^[a-z]::').hasMatch(tag))
                          .toList()),
                  Container(
                    width: SizeService.instance.screenWidth(context),
                    height: height,
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  Padding(
                    padding: _controller.value.size.height >
                            _controller.value.size.width
                        ? EdgeInsets.only(top: 0)
                        : EdgeInsets.only(top: 15.0),
                    child: IconsRow(
                        piv: widget.piv,
                        pivHeight: _controller.value.size.height.toInt(),
                        pivWidth: _controller.value.size.width.toInt(),
                        deletePiv: () {
                          store.set('currentlyDeletingPivsUploaded',
                              [widget.piv['id']]);
                          store.set('currentlyDeletingModalUploaded', true);
                        },
                        hidePiv: () {
                          store.set(
                              'hideMap:' + widget.piv['id'], true, 'disk');
                        },
                        sharePiv: () {
                          shareCloudPiv(context, widget.piv['id'], true);
                        },
                        tagPiv: () {}),
                  ),
                  Padding(
                    padding: _controller.value.size.height >
                            _controller.value.size.width
                        ? EdgeInsets.only(left: 12.0, top: 10)
                        : EdgeInsets.only(left: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          shortMonthNames[widget.date.month - 1].toString(),
                          style: kLightBackgroundDate,
                        ),
                        const Text(
                          ' ',
                          style: kLightBackgroundDate,
                        ),
                        Text(pad(widget.date.day), style: kLightBackgroundDate),
                        const Text(
                          ', ',
                          style: kLightBackgroundDate,
                        ),
                        Text(
                          widget.date.year.toString(),
                          style: kLightBackgroundDate,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 90,
                left: SizeService.instance.screenWidth(context) * .43,
                child: FloatingActionButton(
                  key: Key('vidPlay' + widget.piv['id']),
                  heroTag: 'vidPlay' + widget.piv['id'],
                  shape: const CircleBorder(),
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
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          )
        : Center(
            child: Container(
            height: height,
            width: SizeService.instance.screenWidth(context),
            child: const CircularProgressIndicator(
              backgroundColor: kGreyDarkest,
              color: kAltoBlue,
            ),
          ));
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

class IconsRow extends StatefulWidget {
  const IconsRow({
    super.key,
    required this.pivHeight,
    required this.pivWidth,
    required this.deletePiv,
    required this.hidePiv,
    required this.sharePiv,
    required this.tagPiv,
    required this.piv,
  });

  final int pivHeight;
  final int pivWidth;
  final Function deletePiv;
  final Function hidePiv;
  final Function sharePiv;
  final Function tagPiv;
  final dynamic piv;

  @override
  State<IconsRow> createState() => _IconsRowState();
}

class _IconsRowState extends State<IconsRow> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.pivHeight > widget.pivWidth
          ? const EdgeInsets.only(left: 12.0, right: 12, top: 10)
          : const EdgeInsets.only(left: 12.0, right: 12, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              widget.deletePiv();
            },
            child: const Icon(
              kTrashCanIcon,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          GestureDetector(
            onTap: () {
              widget.hidePiv();
            },
            child: const Icon(
              kSlashedEyeIcon,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            width: 30,
          ),
          GestureDetector(
            onTap: () {
              widget.sharePiv();
            },
            child: const Icon(
              kShareIcon,
              color: Colors.white,
            ),
          ),
          const Expanded(
            child: SizedBox(),
          ),
          TagInHome(piv: widget.piv),
        ],
      ),
    );
  }
}

class TagInHome extends StatefulWidget {
  const TagInHome({
    super.key,
    required this.piv,
  });

  final dynamic piv;

  @override
  State<TagInHome> createState() => _TagInHomeState();
}

class _TagInHomeState extends State<TagInHome> {
  bool showModalBottomSheetBig = false;
  final TextEditingController searchTagController = TextEditingController();

  dynamic currentTags = [];
  dynamic tagList = [];
  String filter = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      currentTags = widget.piv['local'] == true
          ? getList('pendingTags:' + widget.piv['piv'].id)
          : widget.piv['tags']
              .where((tag) => !RegExp('^[a-z]::').hasMatch(tag))
              .toList();
    });
  }

  @override
  void dispose() {
    searchTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          tagList = TagService.instance.getTagList(currentTags, filter, false);
        });
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                  builder: (context, StateSetter setModalState) {
                return AnimatedContainer(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  color: Colors.black,
                  height: showModalBottomSheetBig
                      ? SizeService.instance.screenHeight(context) * .85
                      : SizeService.instance.screenHeight(context) * .5,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.fastOutSlowIn,
                  child: Stack(
                    children: [
                      ListView(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        children: [
                          const Icon(
                            kMinusIcon,
                            color: Colors.white,
                            size: 30,
                          ),
                          const Text(
                            'Add/Change Tags',
                            textAlign: TextAlign.center,
                            style: kLightBackgroundTitle,
                          ),
                          Visibility(
                            visible: showModalBottomSheetBig == false,
                            replacement: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: TextField(
                                        controller: searchTagController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        autofocus: true,
                                        textAlign: TextAlign.left,
                                        enableSuggestions: true,
                                        style: kLightBackgroundDate,
                                        decoration: const InputDecoration(
                                          prefixIcon: Icon(
                                            kSearchIcon,
                                            color: kGreyLightest,
                                            size: 15,
                                          ),
                                          hintText: 'Search or add new tag',
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 20.0),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25)),
                                          ),
                                        ),
                                        onChanged: (String query) {
                                          setModalState(() {
                                            filter = query;
                                            tagList = TagService.instance
                                                .getTagList(
                                                    currentTags, filter, false);
                                          });
                                        }),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setModalState(() {
                                        searchTagController.clear();
                                        filter = '';
                                        tagList = TagService.instance
                                            .getTagList(
                                                currentTags, filter, false);
                                        showModalBottomSheetBig = false;
                                      });
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style: kLightBackgroundDate,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    showModalBottomSheetBig = true;
                                  });
                                },
                                child: Container(
                                  height: 40,
                                  width: SizeService.instance
                                          .screenWidth(context) *
                                      .8,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(
                                      color: kGreyLightest, // Border color
                                      width: 1, // Border width
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        25), // Rounded border with radius of 10
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Icon(
                                        kSearchIcon,
                                        color: kGreyLightest,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'Search or add new tag',
                                        style: kLightBackgroundDate,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // LIST OF THUMBS FOR TAGS
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: tagList.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: .9,
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 1,
                                  crossAxisSpacing: 1,
                                ),
                                itemBuilder: (BuildContext context, index) {
                                  var tag = tagList[index];
                                  var greenBorder = currentTags.contains(tag);
                                  return GestureDetector(
                                      onTap: () {
                                        var originalTag = tag;
                                        tag = tag.replaceFirst(
                                            RegExp(r' \(new tag\)$'), '');
                                        tag = tag.replaceFirst(
                                            RegExp(r' \(example\)$'), '');

                                        if (widget.piv['local'] == true) {
                                          store.set(
                                              'currentlyTaggingLocal', [tag]);
                                          TagService.instance.toggleTags(
                                              widget.piv['piv'], 'local');
                                          TagService.instance
                                              .doneTagging('local');
                                          store.remove('currentlyTaggingLocal');
                                        } else {
                                          TagService.instance.tagCloudPiv(
                                              widget.piv['id'],
                                              [tag],
                                              currentTags.contains(
                                                  tag)); // if the piv is tagged, we will untag it by passing `true` as the third argument
                                        }
                                        setModalState(() {
                                          if (!currentTags.contains(tag)) {
                                            tagList.remove(originalTag);
                                            tagList = [tag] + tagList;
                                          }
                                          currentTags.contains(tag)
                                              ? currentTags.remove(tag)
                                              : currentTags.add(tag);
                                          currentTags = currentTags;
                                          searchTagController.clear();
                                          filter = '';
                                          tagList = TagService.instance
                                              .getTagList(
                                                  currentTags, filter, false);
                                          showModalBottomSheetBig = false;
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                            height: SizeService.instance
                                                    .screenWidth(context) *
                                                .25,
                                            child: (() {
                                              var thumb =
                                                  store.get('thumbs')[tag];
                                              // If we're creating a tag on this piv, put it provisionally as thumb
                                              if (thumb == null)
                                                thumb = widget.piv;

                                              // Cloud thumb
                                              if (thumb['local'] == null) {
                                                return CachedNetworkImage(
                                                    imageUrl:
                                                        (kTagawayThumbSURL) +
                                                            thumb['id'],
                                                    httpHeaders: {
                                                      'cookie':
                                                          store.get('cookie')
                                                    },
                                                    placeholder: (context,
                                                            url) =>
                                                        const Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                          color: kAltoBlue,
                                                        )),
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Transform.rotate(
                                                          angle: (thumb['deg'] ==
                                                                      null
                                                                  ? 0
                                                                  : thumb[
                                                                      'deg']) *
                                                              math.pi /
                                                              180.0,
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color:
                                                                        kAltoOrganized,
                                                                    width:
                                                                        greenBorder
                                                                            ? 6
                                                                            : 0),
                                                                shape: BoxShape
                                                                    .circle,
                                                                image: DecorationImage(
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    image:
                                                                        imageProvider)),
                                                          ),
                                                        ));
                                              } else {
                                                return FutureBuilder<
                                                        Uint8List?>(
                                                    future: thumb['piv']
                                                        .thumbnailDataWithSize(
                                                            const ThumbnailSize
                                                                .square(400)),
                                                    builder: (_, snapshot) {
                                                      final bytes =
                                                          snapshot.data;
                                                      if (bytes == null) {
                                                        return const CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  kAltoBlue),
                                                        );
                                                      }
                                                      return Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          image:
                                                              DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: MemoryImage(
                                                                bytes),
                                                          ),
                                                        ),
                                                      );
                                                    });
                                              }
                                              /*
                                              return BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: kAltoOrganized,
                                                  width: greenBorder ? 6 : 0,
                                                ),
                                              );
                                              */
                                            })(),
                                          ),
                                          SizedBox(
                                            height: 20,
                                            width: SizeService.instance
                                                    .screenWidth(context) *
                                                .3,
                                            child: Text(
                                              tag,
                                              textAlign: TextAlign.center,
                                              style: kLightBackgroundTagName,
                                            ),
                                          )
                                        ],
                                      ));
                                }),
                          )
                        ],
                      )
                    ],
                  ),
                );
              });
            });
      },
      child: const Icon(
        kTagIcon,
        color: Colors.white,
      ),
    );
  }
}

class TagsRow extends StatefulWidget {
  TagsRow({
    super.key,
    required this.tags,
  });

  dynamic tags;

  @override
  State<TagsRow> createState() => _TagsRowState();
}

class _TagsRowState extends State<TagsRow> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, left: 12, right: 12),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: widget.tags.take(2).toList().map<Widget>((tag) {
            return GestureDetector(
                onTap: () {
                  store.set('queryTags', [tag]);
                },
                child: Row(children: [
                  Icon(
                    kTagIcon,
                    color: tagIconColor(tag),
                    size: 20,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    tag,
                    style: kLightBackgroundDate,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ]));
          }).toList()),
    );
  }
}
