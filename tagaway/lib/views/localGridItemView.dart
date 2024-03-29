import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tagaway/services/pivService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/services/tools.dart';
import 'package:tagaway/views/uploadedGridItemView.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';

// This widget is also used in the uploaded grid to show local elements that match the query and currently are in the uploaded queue
class LocalGridItem extends StatelessWidget {
  final AssetEntity asset;
  final dynamic page;
  final String view;
  final dynamic pivIndex;

  // page is only used when view is local; pivIndex is only used when view is uploaded
  const LocalGridItem(this.asset, this.page, this.view, this.pivIndex,
      {Key? key})
      : super(key: key);

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
            onLongPress: () {
              if (view == 'local')
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return LocalCarrousel(pivFile: asset, page: page);
                }));
              else {
                var pivs = [];
                if (store.get('queryResult') != '')
                  pivs = store.get('queryResult')['pivs'];

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) {
                    return CarrouselView(initialPiv: pivIndex, pivs: pivs);
                  }),
                );
              }
            },
            onTap: () {
              var View = view[0].toUpperCase() + view.substring(1);
              if (store.get('currentlyDeleting' + View) != '') {
                TagService.instance.toggleDeletion(asset.id, view);
                store.set('showSelectAllButton' + View, true);
              } else if (store.get('currentlyTagging' + View) != '') {
                // Tagging/untagging is the same, whether we are in the local or the uploaded grid
                TagService.instance.toggleTags(asset, 'local');
                store.set('hideAddMoreTagsButton' + View, true);
                store.set('showSelectAllButton' + View, true);
              } else {
                if (view == 'local')
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return LocalCarrousel(pivFile: asset, page: page);
                  }));
                else {
                  var pivs = [];
                  if (store.get('queryResult') != '')
                    pivs = store.get('queryResult')['pivs'];

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) {
                      return CarrouselView(initialPiv: pivIndex, pivs: pivs);
                    }),
                  );
                }
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
                        child: GridItemSelection(asset.id,
                            view == 'local' ? 'local' : 'localUploaded',
                            key: Key(asset.id + ':' + now().toString())))),
                Visibility(
                    visible: view == 'uploaded',
                    child: Align(
                        alignment: const Alignment(-0.9, -.9),
                        child: UploadingIcon())),
                GridItemMask(
                    asset.id, view == 'local' ? 'local' : 'localUploaded',
                    key: Key(asset.id + '-mask:' + now().toString())),
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
  dynamic loadedImages = {};

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
    var currentPageIndex = widget.page.indexOf(widget.pivFile);
    return PageView.builder(
        reverse: true,
        physics: pageBuilderScroll,
        controller: PageController(
          initialPage: currentPageIndex,
          keepPage: false,
        ),
        itemCount: widget.page.length,
        itemBuilder: (context, index) {
          var piv = widget.page[index];
          Future<File?> file = loadImage(piv);
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
                                  future: file,
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
