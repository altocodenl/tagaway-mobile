import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';

class UploadedGridItem extends StatelessWidget {
  final dynamic item;
  final dynamic pivs;

  const UploadedGridItem({
    Key? key,
    required this.item,
    required this.pivs
  }) : super(key: key);

  // String parseVideoDuration(Duration duration) {
  //   String twoDigits(int n) => n.toString().padLeft(2, "0");
  //   String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  //   return "${twoDigits(duration.inMinutes)}:$twoDigitSeconds";
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CachedNetworkImage(
            imageUrl: (kTagawayThumbSURL) + (item['id']),
            httpHeaders: {'cookie': StoreService.instance.get('cookie')},
            placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                  color: kAltoBlue,
                )),
            imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover, image: imageProvider)),
                )),
        item['vid'] != null
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) {
                return CarrouselView(
                  initialPiv: pivs.indexOf(item),
                  pivs: pivs
                );
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
      ],
    );
    //   },
    // );
  }
}

class CarrouselView extends StatefulWidget {
  const CarrouselView(
      {Key? key,
      required this.initialPiv,
      required this.pivs
      })
      : super(key: key);

  final dynamic initialPiv;
  final dynamic pivs;

  @override
  State<CarrouselView> createState() => _CarrouselViewState();
}

class _CarrouselViewState extends State<CarrouselView> {
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      reverse: true,
      physics: const BouncingScrollPhysics(),
      controller: PageController(
        initialPage: widget.initialPiv,
        keepPage: false,
      ),
      // pageSnapping: true,
      itemCount: widget.pivs.length,
      itemBuilder: (context, index) {
        var piv = widget.pivs [index];
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
                  Text('$index'),
                  // Text(piv.createDateTime.day.toString(),
                  //     style: kDarkBackgroundBigTitle),
                  // const Text(
                  //   '/',
                  //   style: kDarkBackgroundBigTitle,
                  // ),
                  // Text(
                  //   piv.createDateTime.month.toString(),
                  //   style: kDarkBackgroundBigTitle,
                  // ),
                  // const Text(
                  //   '/',
                  //   style: kDarkBackgroundBigTitle,
                  // ),
                  // Text(
                  //   piv.createDateTime.year.toString(),
                  //   style: kDarkBackgroundBigTitle,
                  // ),
                ],
              ),
            ),
          ),
          body: Stack(children: [
            Visibility(
                visible: piv['vid'] == null,
                child: CachedNetworkImage(
                    imageUrl: (kTagawayThumbMURL) + (piv['id']),
                    httpHeaders: {
                      'cookie': StoreService.instance.get('cookie')
                    },
                    placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                          color: kAltoBlue,
                        )),
                    imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                              color: kGreyDarkest,
                              image: DecorationImage(
                                  alignment: Alignment.center,
                                  fit: BoxFit.none,
                                  image: imageProvider)),
                        )),
                replacement: VideoPlayerWidget(
                  pivId: piv['id'],
                )),
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
                            if (piv['vid'] == null) {
                              WhiteSnackBar.buildSnackBar(context,
                                  'Preparing your image for sharing...');
                              final response = await http.get(
                                  Uri.parse((kTagawayThumbMURL) +
                                      (piv['id'])),
                                  headers: {
                                    'cookie':
                                        StoreService.instance.get('cookie')
                                  });
                              final bytes = response.bodyBytes;
                              final temp = await getTemporaryDirectory();
                              final path = '${temp.path}/image.jpg';
                              File(path).writeAsBytesSync(bytes);
                              await Share.shareXFiles([XFile(path)]);
                            } else if (piv['vid'] != null) {
                              WhiteSnackBar.buildSnackBar(context,
                                  'Preparing your video for sharing...');
                              final response = await http.get(
                                  Uri.parse((kTagawayVideoURL) +
                                      (piv['id'])),
                                  headers: {
                                    'cookie':
                                        StoreService.instance.get('cookie')
                                  });

                              final bytes = response.bodyBytes;
                              final temp = await getTemporaryDirectory();
                              final path = '${temp.path}/video.mp4';
                              File(path).writeAsBytesSync(bytes);
                              await Share.shareXFiles([XFile(path)]);
                            }
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
                          onPressed: () {},
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
        );
      },
    );
  }
}

// class UploadedGridItem extends StatelessWidget {
//   final AssetEntity item;
//   final ValueChanged<bool> isSelected;
//
//   const UploadedGridItem(
//       {Key? key, required this.item, required this.isSelected})
//       : super(key: key);
//
//   String parseVideoDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "${twoDigits(duration.inMinutes)}:$twoDigitSeconds";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Uint8List?>(
//       future: item.thumbnailDataWithSize(const ThumbnailSize.square(1000)),
//       builder: (_, snapshot) {
//         final bytes = snapshot.data;
//         if (bytes == null) {
//           return const CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(kAltoBlue),
//           );
//         }
//         return Stack(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   fit: BoxFit.cover,
//                   image: MemoryImage(bytes),
//                 ),
//               ),
//             ),
//             item.type == AssetType.video
//                 ? Align(
//               alignment: Alignment.bottomRight,
//               child: Padding(
//                 padding: const EdgeInsets.only(right: 5.0, bottom: 5),
//                 child: Text(
//                   parseVideoDuration(Duration(seconds: item.duration)),
//                   style:
//                   const TextStyle(color: Colors.white, fontSize: 14),
//                 ),
//               ),
//             )
//                 : Container(),
//
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) {
//                     return CarrouselView(
//                       item: item,
//                       imageFile: item.originFile,
//                     );
//                     // if (item.type == AssetType.image) {
//                     //   return ImageBig(item: item, imageFile: item.originFile);
//                     // } else {
//                     //   return VideoBig(item: item, videoFile: item.originFile);
//                     // }
//                   }),
//                 );
//               },
//             )
//             // Align(
//             //     alignment: const Alignment(0.9, -.9),
//             //     child: Container(
//             //       decoration: BoxDecoration(
//             //           color: Colors.white,
//             //           borderRadius: BorderRadius.circular(100),
//             //           border: Border.all(color: Colors.white, width: 2)),
//             //       child: const Icon(
//             //         // kSolidCircleIcon,
//             //         // color: kGreyDarker,
//             //         kCircleCheckIcon,
//             //         color: kAltoOrganized,
//             //         size: 25,
//             //       ),
//             //     )),
//           ],
//         );
//       },
//     );
//   }
// }

// class ImageBig extends StatelessWidget {
//   final Future<File?> imageFile;
//   final AssetEntity item;
//   const ImageBig({Key? key, required this.imageFile, required this.item})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: kGreyLightest, size: 30),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: kGreyDarkest,
//         title: Padding(
//           padding: const EdgeInsets.only(right: 20.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(item.createDateTime.day.toString(),
//                   style: kDarkBackgroundBigTitle),
//               const Text(
//                 '/',
//                 style: kDarkBackgroundBigTitle,
//               ),
//               Text(
//                 item.createDateTime.month.toString(),
//                 style: kDarkBackgroundBigTitle,
//               ),
//               const Text(
//                 '/',
//                 style: kDarkBackgroundBigTitle,
//               ),
//               Text(
//                 item.createDateTime.year.toString(),
//                 style: kDarkBackgroundBigTitle,
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: Stack(children: [
//         Container(
//           color: kGreyDarkest,
//           alignment: Alignment.center,
//           child: FutureBuilder<File?>(
//             future: imageFile,
//             builder: (_, snapshot) {
//               final file = snapshot.data;
//               if (file == null) return Container();
//               return Image.file(file);
//             },
//           ),
//         ),
//         Align(
//           alignment: Alignment.bottomCenter,
//           child: Container(
//             width: double.infinity,
//             color: kGreyDarkest,
//             child: SafeArea(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.max,
//                 children: [
//                   Expanded(
//                     child: IconButton(
//                       onPressed: () async {
//                         var piv = await item.originFile;
//                         await Share.shareXFiles([XFile(piv!.path)]);
//                       },
//                       icon: const Icon(
//                         kShareArrownUpIcon,
//                         size: 25,
//                         color: kGreyLightest,
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: IconButton(
//                       onPressed: () {},
//                       icon: const Icon(
//                         kTrashCanIcon,
//                         size: 25,
//                         color: kGreyLightest,
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//         )
//       ]),
//     );
//   }
// }
//
// class VideoBig extends StatefulWidget {
//   const VideoBig({Key? key, required this.videoFile, required this.item})
//       : super(key: key);
//   final Future<File?> videoFile;
//   final AssetEntity item;
//
//   @override
//   _VideoBigState createState() => _VideoBigState();
// }

// class _VideoBigState extends State<VideoBig> {
//   late VideoPlayerController _controller;
//   bool initialized = false;
//
//   @override
//   void initState() {
//     _initVideo();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   _initVideo() async {
//     final video = await widget.videoFile;
//     _controller = VideoPlayerController.file(video!)
//       // Play the video again when it ends
//       ..setLooping(true)
//       // initialize the controller and notify UI when done
//       ..initialize().then((_) => setState(() {
//             initialized = true;
//             _controller.play();
//           }));
//     // _controller.play();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: kGreyDarkest,
//         iconTheme: const IconThemeData(color: kGreyLightest, size: 30),
//         centerTitle: true,
//         elevation: 0,
//         title: Padding(
//           padding: const EdgeInsets.only(right: 20.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 widget.item.createDateTime.day.toString(),
//                 style: kDarkBackgroundBigTitle,
//               ),
//               const Text(
//                 '/',
//                 style: kDarkBackgroundBigTitle,
//               ),
//               Text(
//                 widget.item.createDateTime.month.toString(),
//                 style: kDarkBackgroundBigTitle,
//               ),
//               const Text(
//                 '/',
//                 style: kDarkBackgroundBigTitle,
//               ),
//               Text(
//                 widget.item.createDateTime.year.toString(),
//                 style: kDarkBackgroundBigTitle,
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: initialized
//           // If the video is initialized, display it
//           ? Scaffold(
//               backgroundColor: kGreyDarkest,
//               body: SafeArea(
//                 child: Stack(children: [
//                   Center(
//                     child: AspectRatio(
//                       aspectRatio: _controller.value.aspectRatio,
//                       // Use the VideoPlayer widget to display the video.
//                       child: VideoPlayer(_controller),
//                     ),
//                   ),
//                   Align(
//                     alignment: Alignment.bottomCenter,
//                     child: Container(
//                       width: double.infinity,
//                       color: kGreyDarkest,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         mainAxisSize: MainAxisSize.max,
//                         children: [
//                           Expanded(
//                             child: IconButton(
//                               onPressed: () async {
//                                 var piv = await widget.item.originFile;
//                                 await Share.shareXFiles([XFile(piv!.path)]);
//                               },
//                               icon: const Icon(
//                                 kShareArrownUpIcon,
//                                 size: 25,
//                                 color: kGreyLightest,
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             child: IconButton(
//                               onPressed: () {},
//                               icon: const Icon(
//                                 kTrashCanIcon,
//                                 size: 25,
//                                 color: kGreyLightest,
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   )
//                 ]),
//               ),
//               floatingActionButton: Align(
//                 alignment: const Alignment(0.8, .85),
//                 child: FloatingActionButton(
//                   backgroundColor: kAltoBlue,
//                   onPressed: () {
//                     // Wrap the play or pause in a call to `setState`. This ensures the
//                     // correct icon is shown.
//                     setState(() {
//                       // If the video is playing, pause it.
//                       if (_controller.value.isPlaying) {
//                         _controller.pause();
//                       } else {
//                         // If the video is paused, play it.
//                         _controller.play();
//                       }
//                     });
//                   },
//                   // Display the correct icon depending on the state of the player.
//                   child: Icon(
//                     _controller.value.isPlaying
//                         ? Icons.pause
//                         : Icons.play_arrow,
//                   ),
//                 ),
//               ),
//             )
//           // If the video is not yet initialized, display a spinner
//           : const Center(
//               child: CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(kAltoBlue),
//             )),
//     );
//   }
// }
