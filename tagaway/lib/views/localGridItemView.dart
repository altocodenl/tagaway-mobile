import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/services/uploadService.dart';

class LocalGridItem extends StatelessWidget {
  final AssetEntity item;
  final ValueChanged<bool> isSelected;

  const LocalGridItem({Key? key, required this.item, required this.isSelected})
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
        return GestureDetector (
          onTap: () {
            UploadService.instance.queuePiv (item);
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
            Align(
                alignment: const Alignment(0.9, -.9),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: Colors.white, width: 2)),
                  child: const Icon(
                    // kSolidCircleIcon,
                    // color: kGreyDarker,
                    kCircleCheckIcon,
                    color: kAltoOrganized,
                    size: 25,
                  ),
                )),

            // SelectedAsset(
            //   selectedListLengthStreamController:
            //   selectedListLengthStreamController,
            //   isSelected: isSelected,
            //   item: item,
            // ),
          ],
        )
      );
      },
    );
  }
}
