import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tagaway/services/pivService.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/services/tools.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:video_player/video_player.dart';

class LocalGridItem extends StatelessWidget {
  final AssetEntity asset;
  final dynamic page;

  const LocalGridItem(this.asset, this.page, {Key? key}) : super(key: key);

  // String parseVideoDuration(Duration duration) {
  //   String twoDigits(int n) => n.toString().padLeft(2, "0");
  //   String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  //   return "${twoDigits(duration.inMinutes)}:$twoDigitSeconds";
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize.square(400)),
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) {
          return const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kAltoBlue),
          );
        }
        return GestureDetector(
            onTap: () {
              if (StoreService.instance.get('currentlyDeletingLocal') != '') {
                TagService.instance.toggleDeletion(asset.id, 'local');
              } else if (StoreService.instance.get('currentlyTaggingLocal') !=
                  '') {
                TagService.instance.tagPiv(
                    asset,
                    StoreService.instance.get('currentlyTaggingLocal'),
                    'local');
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return LocalCarrousel(pivFile: asset, page: page);
                }));
              }
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: MemoryImage(bytes),
                    ),
                  ),
                ),
                asset.type == AssetType.video
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
                Align(
                    alignment: const Alignment(0.9, -.9),
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            border:
                                Border.all(color: Colors.white, width: 1.5)),
                        // If we don't pass a key, despite the fact that we are passing a STRING ARGUMENT that is different to the widget, Flutter still thinks it is a great idea to reuse the child widget.
                        child: GridItemSelection(asset.id, 'local',
                            key: Key(asset.id + ':' + now().toString())))),
              ],
            ));
      },
    );
  }
}

class LocalCarrousel extends StatefulWidget {
  final AssetEntity pivFile;
  final dynamic page;

  const LocalCarrousel({Key? key, required this.pivFile, required this.page})
      : super(key: key);

  @override
  State<LocalCarrousel> createState() => _LocalCarrouselState();
}

class _LocalCarrouselState extends State<LocalCarrousel>
    with SingleTickerProviderStateMixin {
  late TransformationController controller;
  late AnimationController animationController;
  Animation<Matrix4>? animation;
  OverlayEntry? entry;
  ScrollPhysics? pageBuilderScroll;

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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    var currentIndex = widget.page.indexOf(widget.pivFile);
    return PageView.builder(
        reverse: true,
        physics: pageBuilderScroll,
        controller: PageController(
          initialPage: currentIndex,
          keepPage: false,
        ),
        itemCount: widget.page.length,
        itemBuilder: (context, index) {
          var piv = widget.page[index];
          return Scaffold(
            appBar: AppBar(
              iconTheme: const IconThemeData(color: kGreyLightest, size: 30),
              centerTitle: true,
              elevation: 0,
              backgroundColor: kGreyDarkest,
              title: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(pad(piv.createDateTime.day),
                        style: kDarkBackgroundBigTitle),
                    const Text(
                      '/',
                      style: kDarkBackgroundBigTitle,
                    ),
                    Text(pad(piv.createDateTime.month),
                        style: kDarkBackgroundBigTitle),
                    const Text(
                      '/',
                      style: kDarkBackgroundBigTitle,
                    ),
                    Text(piv.createDateTime.year.toString(),
                        style: kDarkBackgroundBigTitle),
                  ],
                ),
              ),
            ),
            body: Stack(
              children: [
                Visibility(
                  visible: piv.type == AssetType.image,
                  child: Stack(
                    children: [
                      ValueListenableBuilder(
                          valueListenable: controller,
                          builder: (context, Matrix4 matrix, child) {
                            if (matrixAlmostEqual(matrix, Matrix4.identity())) {
                              if (pageBuilderScroll is! BouncingScrollPhysics) {
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
                              // panEnabled: false,
                              minScale: 1,
                              maxScale: 8,
                              child: Container(
                                color: kGreyDarkest,
                                alignment: Alignment.center,
                                child: FutureBuilder<File?>(
                                  future: piv.file,
                                  builder: (_, snapshot) {
                                    final file = snapshot.data;
                                    if (file == null) return Container();
                                    return Image.file(file);
                                  },
                                ),
                              ),
                            );
                          }),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          color: kGreyDarkest,
                          child: SafeArea(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: IconButton(
                                    onPressed: () async {
                                      WhiteSnackBar.buildSnackBar(context,
                                          'Preparing your image for sharing...');
                                      final response = await piv.originBytes;
                                      final bytes = response;
                                      final temp =
                                          await getTemporaryDirectory();
                                      final path = '${temp.path}/image.jpg';
                                      File(path).writeAsBytesSync(bytes!);
                                      await Share.shareXFiles([XFile(path)]);
                                    },
                                    icon: const Icon(
                                      kShareArrownUpIcon,
                                      size: 25,
                                      color: kGreyLightest,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                    onPressed: () {
                                      PivService.instance
                                          .deleteLocalPivs([piv.id]);
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(
                                      kTrashCanIcon,
                                      size: 25,
                                      color: kGreyLightest,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  replacement: LocalVideoPlayerWidget(
                    videoFile: piv,
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class LocalVideoPlayerWidget extends StatefulWidget {
  const LocalVideoPlayerWidget({Key? key, required this.videoFile})
      : super(key: key);
  final AssetEntity videoFile;

  @override
  _LocalVideoPlayerWidgetState createState() => _LocalVideoPlayerWidgetState();
}

class _LocalVideoPlayerWidgetState extends State<LocalVideoPlayerWidget> {
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
    final video = await widget.videoFile.file;
    _controller = VideoPlayerController.file(video!)
      // Play the video again when it ends
      ..setLooping(true)
      // initialize the controller and notify UI when done
      ..initialize().then((_) => setState(() {
            initialized = true;
            _controller.play();
          }));
    // _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: initialized
          // If the video is initialized, display it
          ? Scaffold(
              backgroundColor: kGreyDarkest,
              body: Stack(children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    // Use the VideoPlayer widget to display the video.
                    child: VideoPlayer(_controller),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    color: kGreyDarkest,
                    child: SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: IconButton(
                              onPressed: () async {
                                WhiteSnackBar.buildSnackBar(context,
                                    'Preparing your video for sharing...');
                                final response =
                                    await widget.videoFile.originBytes;
                                final bytes = response;
                                final temp = await getTemporaryDirectory();
                                final path = '${temp.path}/video.mp4';
                                File(path).writeAsBytesSync(bytes!);
                                await Share.shareXFiles([XFile(path)]);
                              },
                              icon: const Icon(
                                kShareArrownUpIcon,
                                size: 25,
                                color: kGreyLightest,
                              ),
                            ),
                          ),
                          Expanded(
                            child: IconButton(
                              onPressed: () {
                                PivService.instance
                                  .deleteLocalPivs([widget.videoFile.id]);
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                kTrashCanIcon,
                                size: 25,
                                color: kGreyLightest,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
              floatingActionButton: FloatingActionButton(
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
                ),
              ),
            )
          // If the video is not yet initialized, display a spinner
          : const Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kAltoBlue),
            )),
    );
  }
}
