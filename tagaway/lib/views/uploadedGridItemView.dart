import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tagaway/services/sizeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/services/tools.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:video_player/video_player.dart';

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
                return CarrouselView(
                    initialPiv: pivIndex,
                    pivs: pivs,
                    currentTag: (piv['tags']..shuffle())[0]);
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
                  return CarrouselView(
                      initialPiv: pivIndex,
                      pivs: pivs,
                      currentTag: (piv['tags']..shuffle())[0]);
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
  const CarrouselView(
      {Key? key,
      required this.initialPiv,
      required this.pivs,
      required this.currentTag})
      : super(key: key);

  final dynamic initialPiv;
  final dynamic pivs;
  final dynamic currentTag;

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
  final TextEditingController searchTagController = TextEditingController();
  dynamic addMoreTags;
  dynamic cancelListener;
  bool fullScreen = false;
  bool showTags = true;

  // This function checks if the keyboard is visible
  bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

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
    cancelListener = store.listen(['addMoreTags', 'tagFilterCarrousel'],
        (AddMoreTags, TagFilterCarrousel) {
      setState(() {
        addMoreTags = AddMoreTags == true;
      });
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
    cancelListener();
    searchTagController.dispose();
  }

  bool matrixAlmostEqual(Matrix4 a, Matrix4 b, [double epsilon = 10]) {
    for (var i = 0; i < 16; i++) {
      if ((a.storage[i] - b.storage[i]).abs() > epsilon) {
        return false;
      }
    }
    return true;
  }

  // This is only for LOCAL pivs, not cloud pivs.
  Future<File?> loadImage(piv) async {
    // piv will be `null` in the case of cloud pivs
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
    // Check if the keyboard is visible
    bool keyboardIsVisible = isKeyboardVisible(context);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    return PageView.builder(
      reverse: true,
      // physics: pageBuilderScroll,
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
            title: Padding(
              padding: const EdgeInsets.only(right: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(pad(date.day), style: kLightBackgroundDate),
                  const Text(
                    '/',
                    style: kLightBackgroundDate,
                  ),
                  Text(
                    pad(date.month),
                    style: kLightBackgroundDate,
                  ),
                  const Text(
                    '/',
                    style: kLightBackgroundDate,
                  ),
                  Text(
                    date.year.toString(),
                    style: kLightBackgroundDate,
                  ),
                ],
              ),
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
                                    AnimatedContainer(
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
                        })),
            // const DeleteButtonTunnel(
            //   view: 'uploaded',
            // ),
            // const ShareButtonTunnel(
            //   view: 'uploaded',
            // ),
            GestureDetector(
              onTap: () {
                setState(() => fullScreen = !fullScreen);
                // One second for the other animation to execute, 100ms of changui
                if (fullScreen == false)
                  Future.delayed(Duration(milliseconds: 1100), () {
                    setState(() => showTags = !fullScreen);
                  });
                else
                  setState(() => showTags = !fullScreen);
              },
              child: Visibility(
                visible: showTags,
                replacement: const Align(
                  alignment: Alignment(.85, .8),
                  child: FaIcon(
                    kFullScreenIcon,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                child: const Align(
                  alignment: Alignment(.85, -.05),
                  child: FaIcon(
                    kFullScreenIcon,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: showTags,
              child: GestureDetector(
                onTap: () {},
                child: const Align(
                  alignment: Alignment(-.85, -.05),
                  child: FaIcon(
                    kEllipsisVerticalIcon,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: showTags,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                    width: SizeService.instance.screenWidth(context),
                    height: SizeService.instance.screenWidth(context) * .75,
                    child: Stack(children: [
                      Visibility(
                          visible: addMoreTags != true,
                          child: Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: GestureDetector(
                                // This onTap handles the jumping to the grid by clicking on the tag
                                onTap: () async {
                                  var piv = widget.pivs[widget.initialPiv];
                                  var currentMonth = piv['currentMonth'];
                                  // If we don't have the current month in the piv, we didn't come here from a thumb.
                                  // Then get the current month of the piv from its tag dates.
                                  if (currentMonth == null) {
                                    currentMonth = [0, 0];
                                    piv['tags'].forEach((tag) {
                                      if (RegExp('^d::\\d+').hasMatch(tag))
                                        currentMonth[0] =
                                            int.parse(tag.substring(3));
                                      if (RegExp('^d::M').hasMatch(tag))
                                        currentMonth[1] =
                                            int.parse(tag.substring(4));
                                    });
                                  }
                                  store.set('queryTags', [widget.currentTag],
                                      '', 'mute');
                                  await TagService.instance
                                      .queryPivsForMonth(currentMonth);
                                  Navigator.pushReplacementNamed(
                                      context, 'uploaded');
                                },
                                child: SizedBox(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 2.0),
                                        child: FaIcon(
                                          tagIcon(widget.currentTag),
                                          color:
                                              tagIconColor(widget.currentTag),
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        shortenN(
                                            tagTitle(widget.currentTag), 20),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Montserrat-Regular',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: kGreyDarker,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                          replacement: SizedBox(
                            height: 35,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8),
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
                                        right: 12, left: 12, top: 10),
                                    child: FaIcon(
                                      kSearchIcon,
                                      size: 16,
                                      color: kGreyDarker,
                                    ),
                                  ),
                                ),
                                onChanged: (String query) {
                                  store.set('tagFilterCarrousel', query);
                                },
                              ),
                            ),
                          )),
                      SuggestionGrid(
                          searchTagController: searchTagController,
                          pivId: piv['id'],
                          pivTags: piv['tags'])
                    ])),
              ),
            ),
            Visibility(
              visible: keyboardIsVisible,
              replacement: Container(),
              child: Container(
                color: Colors.white.withOpacity(0.8),
              ),
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
  const SuggestionGrid(
      {Key? key,
      required this.pivTags,
      required this.pivId,
      required this.searchTagController})
      : super(key: key);

  final dynamic pivTags;
  final dynamic pivId;
  final dynamic searchTagController;

  @override
  State<SuggestionGrid> createState() => _SuggestionGridState();
}

class _SuggestionGridState extends State<SuggestionGrid> {
  final ScrollController suggestionGridController = ScrollController();

  // We need to hold the tags for the piv here because:
  // 1) We need to change them from the suggestion grid
  // 2) The piv information can come from either a thumb or an actual piv (depending on how the user came to the view), so we'd have to have conditional logic to update it in multiple places, as well as depend on it from the state
  // 3) As soon as we go to the next piv, this state can be dropped and refreshed by data that comes from the server
  dynamic pivTags = [];
  bool addMoreTags = false;
  dynamic cancelListener;

  @override
  void initState() {
    // On widget creation, we take the pivTags we got as argument from the outer view to initialize our pivTagsCarrousel
    store.set('pivTagsCarrousel', widget.pivTags);
    super.initState();
    cancelListener = store
        .listen(['addMoreTags', 'pivTagsCarrousel', 'tagFilterCarrousel'],
            (AddMoreTags, PivTagsCarrousel, TagFilterCarrousel) {
      setState(() {
        addMoreTags = AddMoreTags == true;
        pivTags = getList(
            'pivTagsCarrousel'); // getList also copies the list, so we can modify pivTags and then set it in the store in a way that will trigger a change event on pivTagsCarrousel
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
    var tags;
    if (addMoreTags == true) {
      tags = TagService.instance.getTagList(
          pivTags.where((tag) => !RegExp('^[a-z]::').hasMatch(tag)).toList(),
          store.get('tagFilterCarrousel'),
          false);
    } else {
      tags = pivTags
          .where((tag) => !RegExp('^(t|u|o)::').hasMatch(tag))
          .toList()
        ..shuffle();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: SizedBox.expand(
        child: GridView.builder(
            controller: suggestionGridController,
            shrinkWrap: true,
            cacheExtent: 3,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio:
                  SizeService.instance.timeHeaderChildAspectRatio(context),
              crossAxisCount: 3,
              mainAxisSpacing: 20,
              crossAxisSpacing: 1,
            ),
            itemCount: tags.length + 1,
            itemBuilder: (BuildContext context, index) {
              if (index == 0) {
                return GestureDetector(
                    onTap: () {
                      store.set('addMoreTags', !addMoreTags);
                      widget.searchTagController.clear();
                    },
                    child: Column(
                      children: [
                        Container(
                          width: SizeService.instance.screenWidth(context) * .3,
                          height:
                              SizeService.instance.screenWidth(context) * .3,
                          color:
                              addMoreTags == true ? kAltoOrganized : kAltoBlue,
                          child: Visibility(
                            visible: addMoreTags == false,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  kPlusIcon,
                                  color: Colors.white,
                                  size: 35,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                FaIcon(
                                  kTagIcon,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ],
                            ),
                            replacement: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  kCheckIcon,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                          width: SizeService.instance.screenWidth(context) * .3,
                          child: Text(
                            addMoreTags == true ? 'Done Tagging' : 'Add Tag',
                            textAlign: TextAlign.center,
                            style: kGridBottomRowText,
                          ),
                        ),
                      ],
                    ));
              }
              var tag = tags[index - 1];
              var thumb = store.get('thumbs')[tag];
              var isTagged = addMoreTags && pivTags.contains(tag);

              return GestureDetector(
                  onTap: () async {
                    if (addMoreTags) {
                      if (RegExp(' \\(new tag\\)\$').hasMatch(tag)) {
                        // If we're creating a tag on this piv, put it provisionally as thumb
                        var thumbs = store.get('thumbs');
                        thumbs[tag.replaceFirst(RegExp(r' \(new tag\)$'), '')] =
                            {'id': widget.pivId};
                        store.set('thumbs', thumbs);
                      }

                      tag = tag.replaceFirst(RegExp(r' \(new tag\)$'), '');
                      tag = tag.replaceFirst(RegExp(r' \(example\)$'), '');
                      TagService.instance.tagCloudPiv(widget.pivId, [tag],
                          isTagged); // if the piv is tagged, we will untag it by passing `true` as the third argument
                      pivTags.contains(tag)
                          ? pivTags.remove(tag)
                          : pivTags.add(tag);
                      store.set('pivTagsCarrousel', pivTags);
                      return;
                    }
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) {
                      return CarrouselView(
                          initialPiv: 0, pivs: [thumb], currentTag: tag);
                    }));
                    TagService.instance.getTags();
                  },
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width:
                                SizeService.instance.screenWidth(context) * .3,
                            height:
                                SizeService.instance.screenWidth(context) * .3,
                            child: thumb != null
                                ? CachedNetworkImage(
                                    imageUrl: (kTagawayThumbSURL) + thumb['id'],
                                    httpHeaders: {
                                      'cookie': store.get('cookie')
                                    },
                                    placeholder: (context, url) => const Center(
                                            child: CircularProgressIndicator(
                                          color: kAltoBlue,
                                        )),
                                    imageBuilder: (context, imageProvider) =>
                                        Transform.rotate(
                                          angle: (thumb['deg'] == null
                                                  ? 0
                                                  : thumb['deg']) *
                                              math.pi /
                                              180.0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: imageProvider)),
                                          ),
                                        ))
                                : Container(),
                          ),
                          Positioned.fill(
                              child: IgnorePointer(
                            child: Container(
                              color: isTagged
                                  ? kAltoOrganized.withOpacity(.6)
                                  : Colors.transparent,
                            ),
                          )),
                          isTagged
                              ? Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(right: 20.0, top: 8),
                                    child: Icon(
                                      kCircleCheckIcon,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
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
      ),
    );
  }
}
