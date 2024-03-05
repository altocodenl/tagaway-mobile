import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tagaway/services/sizeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/services/tools.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:video_player/video_player.dart';

class HomeView extends StatefulWidget {
  static const String id = 'home';
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  dynamic cancelListener;

  dynamic queryResult = {'pivs': [], 'total': 0};

  @override
  void initState() {
    super.initState();
    // Wait for some local pivs to be loaded.
    Future.delayed(Duration(seconds: 3), () {
      TagService.instance.queryPivs();
    });
    cancelListener = store.listen(['queryResult'], (QueryResult) {
      // Because of the sheer liquid modernity of this interface, we might need to make this `mounted` check.
      if (mounted) {
        setState(() {
          if (QueryResult != '') queryResult = QueryResult;
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
    debug(['piv count', queryResult['pivs'].length]);
    return Scaffold(
      backgroundColor: kAltoBlack,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kAltoBlack,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/tag check - 0c0c0cff - 400x400.png',
              scale: 10,
            ),
            const Text('tagaway', style: kTagawayMain),
          ],
        ),
      ),
      body: SafeArea(
        child: queryResult['pivs'].length == 0
            ? const Center(
                child: CircularProgressIndicator(
                color: kAltoBlue,
              ))
            : CustomScrollView(
                slivers: [
                  SliverList.builder(
                      itemCount: queryResult['pivs'].length,
                      itemBuilder: (BuildContext context, int index) {
                        debug(['drawing piv', index]);
                        return Padding(
                            padding: const EdgeInsets.only(bottom: 40),
                            child: (() {
                              var piv = queryResult['pivs'][index];
                              var date = DateTime.fromMillisecondsSinceEpoch(
                                  piv['date']);
                              if (piv['local'] == true &&
                                  piv['piv'].type == AssetType.image)
                                return LocalPhoto(
                                  piv: piv['piv'],
                                  date: date,
                                );
                              if (piv['local'] == true &&
                                  piv['piv'].type != AssetType.image)
                                return LocalVideo(
                                  vid: piv['piv'],
                                  date: date,
                                );
                              /*
                        if (piv['vid'] == null) CachedNetworkImage(
                        imageUrl: (kTagawayThumbMURL) + (piv['id']),
                        httpHeaders: {'cookie': store.get('cookie')},
                        filterQuality: FilterQuality.high,
                        placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                              color: kAltoBlue,
                            )),
                        imageBuilder: (context, imageProvider) {
                          final screenWidth = MediaQuery.of(context).size.width;
                          final screenHeight =
                              MediaQuery.of(context).size.height - 100;
                          final askance = piv['deg'] == 90 || piv['deg'] == -90;
                          final height = askance ? screenWidth : screenHeight;
                          final width = askance ? screenHeight : screenWidth;

                          var left =
                              (askance ? -(width - height) / 2 : 0).toDouble();
                          // The 50px are to center the image a bit. We need to properly compute the space taken up by the header and the footer.
                          var top = (askance ? -(height - width + 50) / 2 : 0)
                              .toDouble();

                          return ValueListenableBuilder(
                            valueListenable: controller,
                            builder: (context, Matrix4 matrix, child) {
                              if (matrixAlmostEqual(
                                  matrix, Matrix4.identity())) {
                                if (pageBuilderScroll
                                    is! BouncingScrollPhysics) {
                                  Future.delayed(Duration.zero, () {
                                    setState(() => pageBuilderScroll =
                                        const BouncingScrollPhysics());
                                  });
                                }
                              } else {
                                if (pageBuilderScroll
                                    is! NeverScrollableScrollPhysics) {
                                  Future.delayed(Duration.zero, () {
                                    setState(() => pageBuilderScroll =
                                        const NeverScrollableScrollPhysics());
                                  });
                                }
                              }
                              return InteractiveViewer(
                                transformationController: controller,
                                clipBehavior: Clip.none,
                                minScale: 1,
                                maxScale: 8,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Transform.rotate(
                                      angle: (piv['deg'] == null
                                              ? 0
                                              : piv['deg']) *
                                          math.pi /
                                          180.0,
                                      child: AnimatedContainer(
                                        width: SizeService.instance
                                            .screenWidth(context),
                                        height: fullScreen
                                            ? SizeService.instance
                                                    .screenHeight(context) *
                                                .85
                                            : SizeService.instance
                                                    .screenHeight(context) *
                                                .45,
                                        duration: const Duration(seconds: 1),
                                        curve: Curves.fastOutSlowIn,
                                        decoration: const BoxDecoration(
                                            color: kGreyDarker,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                topRight: Radius.circular(15))),
                                        child: Image(
                                          // alignment: Alignment.center,
                                          fit: BoxFit.contain,
                                          image: imageProvider,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        });
                        */
                            })());
                      })
                ],
              ),
      ),
    );
  }
}

class LocalPhoto extends StatefulWidget {
  final dynamic piv;
  final DateTime date;
  const LocalPhoto({Key? key, required this.piv, required this.date})
      : super(key: key);

  @override
  State<LocalPhoto> createState() => _LocalPhotoState();
}

class _LocalPhotoState extends State<LocalPhoto> {
  dynamic cancelListener;

  Future<File?> loadImage(piv) async {
    var file = await piv.file;
    return file;
  }

  @override
  void initState() {
    super.initState();
    cancelListener = store.listen(['foo'], (Foo) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
  }

  @override
  Widget build(BuildContext context) {
    Future<File?> file = loadImage(widget.piv);
    return Column(
      children: [
        Container(
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
        Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 5),
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
  const LocalVideo({Key? key, required this.vid, required this.date})
      : super(key: key);
  final AssetEntity vid;
  final DateTime date;

  @override
  _LocalVideoState createState() => _LocalVideoState();
}

class _LocalVideoState extends State<LocalVideo> {
  late VideoPlayerController _controller;
  bool initialized = false;
  bool fullScreen = false;
  dynamic cancelListener;

  @override
  void initState() {
    _initVideo();
    setState(() {
      fullScreen = store.get('fullScreenCarrousel') == true;
    });
    cancelListener =
        store.listen(['fullScreenCarrousel'], (FullScreenCarrousel) {
      setState(() {
        fullScreen = FullScreenCarrousel == true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    try {
      _controller.dispose();
    } catch (_) {
      // We ignore the error.
    }
    cancelListener();
    super.dispose();
  }

  _initVideo() async {
    // Because of the sheer liquid modernity of this interface, we might need to make this `mounted` check.
    if (! mounted) return;
    final video = await widget.vid.file;
    _controller = VideoPlayerController.file(video!)
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
    return initialized
        // If the video is initialized, display it
        ? Stack(children: [
            Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    // Use the VideoPlayer widget to display the video.
                    child: VideoPlayer(_controller),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 5),
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
              bottom: 40,
              left: SizeService.instance.screenWidth(context) * .43,
              child: FloatingActionButton(
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
        : const Center(
            child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kAltoBlue),
          ));
  }
}
