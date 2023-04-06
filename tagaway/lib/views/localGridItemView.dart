import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';

class LocalGridItem extends StatelessWidget {
  final AssetEntity asset;

  const LocalGridItem(this.asset);

  // String parseVideoDuration(Duration duration) {
  //   String twoDigits(int n) => n.toString().padLeft(2, "0");
  //   String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  //   return "${twoDigits(duration.inMinutes)}:$twoDigitSeconds";
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize.square(1000)),
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) {
          return const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kAltoBlue),
          );
        }
        return GestureDetector(
            onTap: () {
              var currentlyTagging =
                  StoreService.instance.get('currentlyTaggingLocal');
              if (currentlyTagging == '')
                StoreService.instance.set('startTaggingModal', true);
              else
                TagService.instance.tagPiv(asset, currentlyTagging, 'local');
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
                            border: Border.all(color: Colors.white, width: 2)),
                    // If we don't pass a key, despite the fact that we are passing a STRING ARGUMENT that is different to the widget, Flutter still thinks it is a great idea to reuse the child widget.
                        child: GridItemSelection(asset.id, 'local', key: Key(asset.id)))),
              ],
            ));
      },
    );
  }
}
