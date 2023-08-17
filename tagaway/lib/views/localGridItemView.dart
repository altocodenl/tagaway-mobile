import 'dart:io' show File;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/services/tools.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:video_player/video_player.dart';

class LocalGridItem extends StatelessWidget {
  final AssetEntity asset;

  const LocalGridItem(this.asset, {Key? key}) : super(key: key);

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
                  if (asset.type == AssetType.image) {
                    return ImageBig(imageFile: asset);
                  }
                  return VideoBig(videoFile: asset);
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

class ImageBig extends StatelessWidget {
  final AssetEntity imageFile;
  const ImageBig({Key? key, required this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kGreyDarkest,
        title: Padding(
          padding: const EdgeInsets.only(right: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(imageFile.createDateTime.day.toString(),
                  style: kDarkBackgroundBigTitle),
              const Text(
                '/',
                style: kDarkBackgroundBigTitle,
              ),
              Text(imageFile.createDateTime.month.toString(),
                  style: kDarkBackgroundBigTitle),
              const Text(
                '/',
                style: kDarkBackgroundBigTitle,
              ),
              Text(imageFile.createDateTime.year.toString(),
                  style: kDarkBackgroundBigTitle),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: kGreyDarkest,
            alignment: Alignment.center,
            child: FutureBuilder<File?>(
              future: imageFile.file,
              builder: (_, snapshot) {
                final file = snapshot.data;
                if (file == null) return Container();
                return Image.file(file);
              },
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
                          WhiteSnackBar.buildSnackBar(
                              context, 'Preparing your image for sharing...');
                          final response = await imageFile.originBytes;
                          final bytes = response;
                          final temp = await getTemporaryDirectory();
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
                          // TagService.instance.deleteUploadedPivs([piv['id']]);
                          // Local pivs delete
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
    );
  }
}

class VideoBig extends StatefulWidget {
  const VideoBig({Key? key, required this.videoFile}) : super(key: key);
  final AssetEntity videoFile;

  @override
  _VideoBigState createState() => _VideoBigState();
}

class _VideoBigState extends State<VideoBig> {
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kGreyDarkest,
        title: Padding(
          padding: const EdgeInsets.only(right: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.videoFile.createDateTime.day.toString(),
                  style: kDarkBackgroundBigTitle),
              const Text(
                '/',
                style: kDarkBackgroundBigTitle,
              ),
              Text(widget.videoFile.createDateTime.month.toString(),
                  style: kDarkBackgroundBigTitle),
              const Text(
                '/',
                style: kDarkBackgroundBigTitle,
              ),
              Text(widget.videoFile.createDateTime.year.toString(),
                  style: kDarkBackgroundBigTitle),
            ],
          ),
        ),
      ),
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
                                // TagService.instance.deleteUploadedPivs([piv['id']]);
                                // Local pivs delete
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
