import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:video_player/video_player.dart';

class UploadedGridItem extends StatelessWidget {
  final AssetEntity item;
  final ValueChanged<bool> isSelected;

  const UploadedGridItem(
      {Key? key, required this.item, required this.isSelected})
      : super(key: key);

  String parseVideoDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inMinutes)}:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: item.thumbnailDataWithSize(const ThumbnailSize.square(1000)),
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) {
          return const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kAltoBlue),
          );
        }
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: MemoryImage(bytes),
                ),
              ),
            ),
            item.type == AssetType.video
                ? Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5.0, bottom: 5),
                      child: Text(
                        parseVideoDuration(Duration(seconds: item.duration)),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  )
                : Container(),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) {
                    if (item.type == AssetType.image) {
                      return ImageBig(item: item, imageFile: item.originFile);
                    } else {
                      return VideoBig(item: item, videoFile: item.originFile);
                    }
                  }),
                );
              },
            )
            // Align(
            //     alignment: const Alignment(0.9, -.9),
            //     child: Container(
            //       decoration: BoxDecoration(
            //           color: Colors.white,
            //           borderRadius: BorderRadius.circular(100),
            //           border: Border.all(color: Colors.white, width: 2)),
            //       child: const Icon(
            //         // kSolidCircleIcon,
            //         // color: kGreyDarker,
            //         kCircleCheckIcon,
            //         color: kAltoOrganized,
            //         size: 25,
            //       ),
            //     )),

            // SelectedAsset(
            //   selectedListLengthStreamController:
            //   selectedListLengthStreamController,
            //   isSelected: isSelected,
            //   item: item,
            // ),
          ],
        );
      },
    );
  }
}

class ImageBig extends StatelessWidget {
  final Future<File?> imageFile;
  final AssetEntity item;
  const ImageBig({Key? key, required this.imageFile, required this.item})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kGreyDarker, size: 30),
        centerTitle: true,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.createDateTime.day.toString(),
                style: kBigTitle,
              ),
              const Text(
                '/',
                style: kBigTitle,
              ),
              Text(
                item.createDateTime.month.toString(),
                style: kBigTitle,
              ),
              const Text(
                '/',
                style: kBigTitle,
              ),
              Text(
                item.createDateTime.year.toString(),
                style: kBigTitle,
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(children: [
          Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: FutureBuilder<File?>(
              future: imageFile,
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
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: IconButton(
                      onPressed: () async {
                        // var piv = await item.originFile;
                        await Share.share(
                            'We are the handsome people of tagaway');
                      },
                      icon: const Icon(
                        kShareArrownUpIcon,
                        size: 25,
                        color: kGreyDarker,
                      ),
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        kTrashCanIcon,
                        size: 25,
                        color: kGreyDarker,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}

class VideoBig extends StatefulWidget {
  const VideoBig({Key? key, required this.videoFile, required this.item})
      : super(key: key);
  final Future<File?> videoFile;
  final AssetEntity item;

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
    final video = await widget.videoFile;
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
        iconTheme: const IconThemeData(color: kGreyDarker, size: 30),
        centerTitle: true,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.item.createDateTime.day.toString(),
                style: kBigTitle,
              ),
              const Text(
                '/',
                style: kBigTitle,
              ),
              Text(
                widget.item.createDateTime.month.toString(),
                style: kBigTitle,
              ),
              const Text(
                '/',
                style: kBigTitle,
              ),
              Text(
                widget.item.createDateTime.year.toString(),
                style: kBigTitle,
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: initialized
          // If the video is initialized, display it
          ? Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Stack(children: [
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
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                kShareArrownUpIcon,
                                size: 25,
                                color: kGreyDarker,
                              ),
                            ),
                          ),
                          Expanded(
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                kTrashCanIcon,
                                size: 25,
                                color: kAltoRed,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ]),
              ),
              floatingActionButton: Align(
                alignment: const Alignment(0.8, .85),
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
            )
          // If the video is not yet initialized, display a spinner
          : const Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kAltoBlue),
            )),
    );
  }
}
