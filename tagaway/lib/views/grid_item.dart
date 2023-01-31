import 'dart:typed_data';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class GridItem extends StatelessWidget {
  final AssetEntity item;
  final ValueChanged<bool> isSelected;

  const GridItem({Key? key, required this.item, required this.isSelected})
      : super(key: key);

  String parseVideoDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inMinutes)}:$twoDigitSeconds";
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: item.thumbnailData,
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
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            )
                : Container(),
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
