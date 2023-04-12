import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';

class UploadedGridItem extends StatelessWidget {
  final dynamic piv;
  final dynamic pivs;

  UploadedGridItem({Key? key, required this.piv, required this.pivs})
      : super(key: key);

  // String parseVideoDuration(Duration duration) {
  //   String twoDigits(int n) => n.toString().padLeft(2, "0");
  //   String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  //   return "${twoDigits(duration.inMinutes)}:$twoDigitSeconds";
  // }
  bool selected = true;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Stack(
      children: [
        CachedNetworkImage(
            imageUrl: (kTagawayThumbSURL) + (piv['id']),
            httpHeaders: {'cookie': StoreService.instance.get('cookie')},
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
          onTap: () {
            var currentlyTagging =
                StoreService.instance.get('currentlyTaggingUploaded');
            if (currentlyTagging == '')
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) {
                  return CarrouselView(
                      initialPiv: pivs.indexOf(piv), pivs: pivs);
                }),
              );
            else
              TagService.instance.tagPiv(piv, currentlyTagging, 'uploaded');
          },
        ),
        Align(
            alignment: const Alignment(0.9, -.9),
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.white, width: 2)),
                // If we don't pass a key, despite the fact that we are passing a STRING ARGUMENT that is different to the widget, Flutter still thinks it is a great idea to reuse the child widget.
                child: GridItemSelection(piv['id'], 'uploaded',
                    key: Key(piv['id'])))),
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

  @override
  void initState() {
    super.initState();
    controller = TransformationController();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() => controller.value = animation!.value);
  }

  @override
  void dispose() {
    controller.dispose();
    animationController.dispose();
    super.dispose();
  }

  void resetAnimation() {
    animation = Matrix4Tween(
      begin: controller.value,
      end: Matrix4.identity(),
    ).animate(
        CurvedAnimation(parent: animationController, curve: Curves.linear));
    animationController.forward(from: 0);
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
      physics: const BouncingScrollPhysics(),
      controller: PageController(
        initialPage: widget.initialPiv,
        keepPage: false,
      ),
      // pageSnapping: true,
      itemCount: widget.pivs.length,
      itemBuilder: (context, index) {
        var piv = widget.pivs[index];
        var date = DateTime.fromMillisecondsSinceEpoch(piv['date']);
        var pad = (n) => n < 10 ? '0' + n.toString() : n.toString();
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
                  Text(pad(date.day), style: kDarkBackgroundBigTitle),
                  const Text(
                    '/',
                    style: kDarkBackgroundBigTitle,
                  ),
                  Text(
                    pad(date.month),
                    style: kDarkBackgroundBigTitle,
                  ),
                  const Text(
                    '/',
                    style: kDarkBackgroundBigTitle,
                  ),
                  Text(
                    date.year.toString(),
                    style: kDarkBackgroundBigTitle,
                  ),
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
                    imageBuilder: (context, imageProvider) => Transform.rotate(
                          angle: (piv['deg'] == null ? 0 : piv['deg']) *
                              math.pi /
                              180.0,
                          child: InteractiveViewer(
                            transformationController: controller,
                            clipBehavior: Clip.none,
                            minScale: 1,
                            maxScale: 8,
                            onInteractionEnd: (details) {
                              resetAnimation();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: kGreyDarkest,
                                  image: DecorationImage(
                                      alignment: Alignment.center,
                                      fit: BoxFit.contain,
                                      image: imageProvider)),
                            ),
                          ),
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
                                  Uri.parse((kTagawayThumbMURL) + (piv['id'])),
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
                                  Uri.parse((kTagawayVideoURL) + (piv['id'])),
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
