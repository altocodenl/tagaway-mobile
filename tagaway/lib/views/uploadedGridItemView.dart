import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

import 'package:tagaway/services/sizeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/services/tools.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/main.dart';

class UploadedGridItem extends StatelessWidget {
  dynamic pivIndex;
  dynamic pivs;

  UploadedGridItem({Key? key, required this.pivIndex}) : super(key: key);

  // String parseVideoDuration(Duration duration) {
  //   String twoDigits(int n) => n.toString().padLeft(2, "0");
  //   String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  //   return "${twoDigits(duration.inMinutes)}:$twoDigitSeconds";
  // }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    var pivs = [];
    if (store.get('queryResult') != '') pivs = store.get('queryResult')['pivs'];
    var piv = {};
    if (pivIndex < pivs.length) piv = pivs[pivIndex];
    if (piv['id'] == null)
      return const CircularProgressIndicator(color: kAltoBlue);
    return Stack(
      children: [
        CachedNetworkImage(
            imageUrl: (kTagawayThumbMURL) + (piv['id']),
            httpHeaders: {'cookie': store.get('cookie')},
            placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                  color: kAltoBlue,
                )),
            imageBuilder: (context, imageProvider) => Transform.rotate(
                  angle:
                      (piv['deg'] == null ? 0 : piv['deg']) * math.pi / 180.0,
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover, image: imageProvider)),
                  ),
                )),
        piv['vid'] != null
            ? const Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 10.0, bottom: 5),
                  child: Icon(
                    kVideoIcon,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              )
            : Container(),
        GestureDetector(
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) {
                return CarrouselView(initialPiv: pivIndex, pivs: pivs);
              }),
            );
          },
          onTap: () {
            if (store.get('currentlyDeletingUploaded') != '') {
              TagService.instance.toggleDeletion(piv['id'], 'uploaded');
              store.set('showSelectAllButtonUploaded', true);
            } else if (store.get('currentlyTaggingUploaded') != '') {
              TagService.instance.toggleTags(piv, 'uploaded');
              store.set('hideAddMoreTagsButtonUploaded', true);
              store.set('showSelectAllButtonUploaded', true);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) {
                  return CarrouselView(initialPiv: pivIndex, pivs: pivs);
                }),
              );
            }
          },
        ),
        Align(
            alignment: const Alignment(0.9, -.9),
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.white, width: 1.5)),
                // If we don't pass a key, despite the fact that we are passing a STRING ARGUMENT that is different to the widget, Flutter still thinks it is a great idea to reuse the child widget.
                // The piv selection status could change depending on the query, so we cannot just rely on the piv's id. We need to make sure these elements don't get recycled to avoid showing a stale GridItemSelection within them.
                child: GridItemSelection(piv['id'], 'uploaded',
                    key: Key(piv['id'] + ':' + now().toString())))),
        GridItemMask(piv['id'], 'uploaded',
            key: Key(piv['id'] + ':' + now().toString())),
      ],
    );
  }
}

class CarrouselView extends StatefulWidget {
  const CarrouselView({Key? key, required this.initialPiv, required this.pivs})
      : super(key: key);

  final dynamic initialPiv;
  final dynamic pivs;

  @override
  State<CarrouselView> createState() => _CarrouselViewState();
}

class _CarrouselViewState extends State<CarrouselView>
    with SingleTickerProviderStateMixin {
  late TransformationController controller;
  late AnimationController animationController;
  Animation<Matrix4>? animation;
  OverlayEntry? entry;
  ScrollPhysics? pageBuilderScroll;
  dynamic loadedImages = {};

  get http => null;

  @override
  void initState() {
    super.initState();
    controller = TransformationController();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )
      ..addListener(() => controller.value = animation!.value)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          removeOverlay();
        }
      });
  }

  void removeOverlay() {
    entry?.remove();
    entry = null;
  }

  @override
  void dispose() {
    controller.dispose();
    animationController.dispose();
    super.dispose();
  }

  bool matrixAlmostEqual(Matrix4 a, Matrix4 b, [double epsilon = 10]) {
    for (var i = 0; i < 16; i++) {
      if ((a.storage[i] - b.storage[i]).abs() > epsilon) {
        return false;
      }
    }
    return true;
  }

  Future<File?> loadImage(piv) async {
    if (piv == null) {
      // If the condition is met, return a future that never completes.
      final Completer<File?> completer = Completer<File?>();
      return completer.future; // This future will not complete.
    }
    if (loadedImages[piv.id] != null) return loadedImages[piv.id];
    var file = await piv.file;
    loadedImages[piv.id] = file;
    return file;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    return PageView.builder(
      reverse: true,
      physics: pageBuilderScroll,
      controller: PageController(
        initialPage: widget.initialPiv,
      ),
      itemCount: widget.pivs.length,
      itemBuilder: (context, index) {
        var piv = widget.pivs[index];
        var date = DateTime.fromMillisecondsSinceEpoch(piv['date']);

        Future<File?> file = loadImage(piv['piv']);

        return Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: kGreyDarker, size: 30),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.grey[50],
            title: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          'images/tag blue with white - 400x400.png',
                          scale: 8,
                        ),
                        const Text('tagaway', style: kTagawayMain),
                      ],
                    ),
                  ),
                ),
                const FaIcon(
                  kCloudGridIcon,
                  color: kGreyDarker,
                  size: 30,
                ),
              ],
            ),
          ),
          body: Stack(children: [
            piv['local'] == true
                ? Visibility(
                    visible: piv['piv'].type == AssetType.image,
                    replacement: LocalVideoPlayerWidget(
                      videoFile: piv['piv'],
                    ),
                    child: Stack(
                      children: [
                        ValueListenableBuilder(
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
                                    Container(
                                      width: SizeService.instance
                                          .screenWidth(context),
                                      height: SizeService.instance
                                              .screenHeight(context) *
                                          .5,
                                      decoration: const BoxDecoration(
                                          color: kGreyDarker,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15))),
                                      child: Stack(
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            child: FutureBuilder<File?>(
                                              future: file,
                                              builder: (_, snapshot) {
                                                final file = snapshot.data;
                                                if (file == null)
                                                  return Container();
                                                return Image.file(file);
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        const Align(
                            alignment: Alignment(-0.9, -.9),
                            child: UploadingIcon()),
                      ],
                    ),
                  )
                : Visibility(
                    visible: piv['vid'] == null,
                    replacement: piv['vid'] == 'pending'
                        ? const VideoPending()
                        : (piv['vid'] == 'error'
                            ? const VideoError()
                            : CloudVideoPlayerWidget(
                                pivId: piv['id'],
                              )),
                    child: CachedNetworkImage(
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
                                      child: Container(
                                        width: SizeService.instance
                                            .screenWidth(context),
                                        height: SizeService.instance
                                                .screenHeight(context) *
                                            .5,
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
                        })),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                  width: SizeService.instance.screenWidth(context),
                  height: SizeService.instance.screenWidth(context) * .7,
                  child: SuggestionGrid(tags: piv['tags'])),
            ),
            // TODO: SHARE & DELETE
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: Container(
            //     width: double.infinity,
            //     color: kGreyDarkest,
            //     child: SafeArea(
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         mainAxisSize: MainAxisSize.max,
            //         children: [
            //           Expanded(
            //             child: IconButton(
            //               onPressed: () async {
            //                 if (piv['local'] == null) {
            //                   if (piv['vid'] == null) {
            //                     WhiteSnackBar.buildSnackBar(context,
            //                         'Preparing your image for sharing...');
            //                     final response = await http.get(
            //                         Uri.parse(
            //                             (kTagawayThumbMURL) + (piv['id'])),
            //                         headers: {'cookie': store.get('cookie')});
            //                     final bytes = response.bodyBytes;
            //                     final temp = await getTemporaryDirectory();
            //                     final path = '${temp.path}/image.jpg';
            //                     File(path).writeAsBytesSync(bytes);
            //                     await Share.shareXFiles([XFile(path)]);
            //                   } else if (piv['vid'] != null) {
            //                     WhiteSnackBar.buildSnackBar(context,
            //                         'Preparing your video for sharing...');
            //                     final response = await http.get(
            //                         Uri.parse((kTagawayVideoURL) + (piv['id'])),
            //                         headers: {'cookie': store.get('cookie')});
            //
            //                     final bytes = response.bodyBytes;
            //                     final temp = await getTemporaryDirectory();
            //                     final path = '${temp.path}/video.mp4';
            //                     File(path).writeAsBytesSync(bytes);
            //                     await Share.shareXFiles([XFile(path)]);
            //                   }
            //                 } else {
            //                   WhiteSnackBar.buildSnackBar(context,
            //                       'Preparing your image for sharing...');
            //                   final response = await piv['piv'].originBytes;
            //                   final bytes = response;
            //                   final temp = await getTemporaryDirectory();
            //                   final path = '${temp.path}/image.jpg';
            //                   File(path).writeAsBytesSync(bytes!);
            //                   await Share.shareXFiles([XFile(path)]);
            //                 }
            //               },
            //               icon: const Icon(
            //                 kShareArrownUpIcon,
            //                 size: 25,
            //                 color: kGreyLightest,
            //               ),
            //             ),
            //           ),
            //           Expanded(
            //             child: IconButton(
            //               onPressed: () {
            //                 if (piv['local'] == null) {
            //                   TagService.instance
            //                       .deleteUploadedPivs([piv['id']]);
            //                   Navigator.pop(context);
            //                 } else {
            //                   PivService.instance.uploadQueue
            //                       .remove(piv['piv']);
            //                   store.remove('pendingTags:' + piv['piv'].id);
            //                   Navigator.pop(context);
            //                 }
            //               },
            //               icon: const Icon(
            //                 kTrashCanIcon,
            //                 size: 25,
            //                 color: kGreyLightest,
            //               ),
            //             ),
            //           )
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
          ]),
        );
      },
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
        'cookie': store.get('cookie'),
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
                width: SizeService.instance.screenWidth(context),
                height: SizeService.instance.screenHeight(context) * .5,
                alignment: Alignment.topCenter,
                decoration: const BoxDecoration(
                    color: kGreyDarker,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15))),
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
              Align(
                alignment: const Alignment(0.8, 0),
                child: FloatingActionButton(
                  shape: const CircleBorder(),
                  key: const Key('playPause'),
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

class SuggestionGrid extends StatefulWidget {
  const SuggestionGrid({Key? key, required this.tags}) : super(key: key);

  final dynamic tags;

  @override
  State<SuggestionGrid> createState() => _SuggestionGridState();
}

class _SuggestionGridState extends State<SuggestionGrid> {
  final ScrollController suggestionGridController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var tags = widget.tags.toList();
    tags.shuffle();
    return SizedBox.expand(
      child: GridView.builder(
          controller: suggestionGridController,
          // reverse: true,
          shrinkWrap: true,
          cacheExtent: 3,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio:
                SizeService.instance.timeHeaderChildAspectRatio(context),
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 1,
          ),
          itemCount: tags.length,
          itemBuilder: (BuildContext context, index) {
            var tag = tags[index];
            var thumb = store.get('thumbs')[tag];
            return GestureDetector(
                onTap: () async {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) {
                    return CarrouselView(initialPiv: 1, pivs: [thumb]);
                  }));
                  TagService.instance.getTags ();
                  // TODO: uncomment?
                  /*
                  store.set('queryTags', [tag], '', 'mute');
                  await TagService.instance
                      .queryPivsForMonth(thumb['currentMonth']);
                  var pivs = store.get('queryResult')['pivs'];
                  var pivIndex =
                      pivs.indexWhere((piv) => piv['id'] == thumb['id']);
                  Navigator.pushReplacement(
                    navigatorKey.currentState!
                        .context, // We use this as context because if this widget is redrawn, we'll get an error when trying to get its context.
                    MaterialPageRoute(builder: (_) {
                      return CarrouselView(initialPiv: pivIndex, pivs: pivs);
                    }),
                  );
                  */
                },
                child: Column(
                  children: [
                    Container(
                      width: SizeService.instance.screenWidth(context) * .3,
                      height: SizeService.instance.screenWidth(context) * .3,
                      child: CachedNetworkImage(
                          imageUrl: (kTagawayThumbSURL) + thumb['id'],
                          httpHeaders: {'cookie': store.get('cookie')},
                          placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                color: kAltoBlue,
                              )),
                          imageBuilder: (context, imageProvider) =>
                              Transform.rotate(
                                angle:
                                    (thumb['deg'] == null ? 0 : thumb['deg']) *
                                        math.pi /
                                        180.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: imageProvider)),
                                ),
                              )),
                    ),
                    SizedBox(
                      height: 15,
                      width: SizeService.instance.screenWidth(context) * .3,
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 2.0),
                            child: FaIcon(
                              tagIcon(tag),
                              color: tagIconColor(tag),
                              size: 15,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            shortenSuggestion(tagTitle(tag), context),
                            textAlign: TextAlign.center,
                            style: kGridBottomRowText,
                          ),
                        ],
                      ),
                    ),
                  ],
                ));
          }),
    );
  }
}
