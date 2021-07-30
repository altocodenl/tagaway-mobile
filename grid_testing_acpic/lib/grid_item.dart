import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'grid.dart';

class GridItem extends StatelessWidget {
  final Key key;
  final AssetEntity item;
  final ValueChanged<bool> isSelected;

  GridItem({
    this.key,
    this.item,
    this.isSelected,
  });

  String parseVideoDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inMinutes)}:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: item.thumbData,
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null)
          return CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5b6eff)),
          );
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
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
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  )
                : Container(),
            SelectedAsset(
              isSelected: isSelected,
              item: item,
            ),
          ],
        );
      },
    );
  }
}

class SelectedAsset extends StatefulWidget {
  final ValueChanged<bool> isSelected;
  final AssetEntity item;

  SelectedAsset({this.isSelected, this.item});

  @override
  _SelectedAssetState createState() => _SelectedAssetState();
}

class _SelectedAssetState extends State<SelectedAsset>
    with AutomaticKeepAliveClientMixin {
  bool isSelected = false;

  @override
  void initState() {
    Provider.of<ProviderController>(context, listen: false).all
        ? isSelected = true
        : false;
    super.initState();
  }

  void selectItem() {
    setState(() {
      isSelected = !isSelected;
      widget.isSelected(isSelected);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        Provider.of<ProviderController>(context, listen: false)
                    .isUploadingInProcess ==
                false
            ? selectItem()
            : null;
      },
      onLongPress: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) {
            if (widget.item.type == AssetType.image) {
              return ImageBig(imageFile: widget.item.file);
            } else {
              return VideoBig(videoFile: widget.item.file);
            }
          }),
        );
      },
      child: Stack(
        children: [
          Expanded(
            child: Container(
              color: isSelected
                  ? Color(0xFF5b6eff).withOpacity(.3)
                  : Colors.transparent,
            ),
          ),
          isSelected
              ? Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.circle,
                    size: 25,
                    color: Color(0xFF5b6eff),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ImageBig extends StatelessWidget {
  final Future<File> imageFile;
  const ImageBig({Key key, @required this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: FutureBuilder<File>(
        future: imageFile,
        builder: (_, snapshot) {
          final file = snapshot.data;
          if (file == null) return Container();
          return Image.file(file);
        },
      ),
    );
  }
}

class VideoBig extends StatefulWidget {
  const VideoBig({Key key, this.videoFile}) : super(key: key);
  final Future<File> videoFile;

  @override
  _VideoBigState createState() => _VideoBigState();
}

class _VideoBigState extends State<VideoBig> {
  VideoPlayerController _controller;
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
    _controller = VideoPlayerController.file(video)
      // Play the video again when it ends
      ..setLooping(true)
      // initialize the controller and notify UI when done
      ..initialize().then((_) => setState(() => initialized = true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: initialized
          // If the video is initialized, display it
          ? Scaffold(
              body: Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  // Use the VideoPlayer widget to display the video.
                  child: VideoPlayer(_controller),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Color(0xFF5b6eff),
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
          : Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5b6eff)),
            )),
    );
  }
}
