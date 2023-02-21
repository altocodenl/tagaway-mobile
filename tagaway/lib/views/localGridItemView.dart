import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tagaway/services/uploadService.dart';
import 'package:tagaway/ui_elements/constants.dart';

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
        return GestureDetector(
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
                            parseVideoDuration(
                                Duration(seconds: item.duration)),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
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
            ));
      },
    );
  }
}

//
// class SelectedAsset extends StatefulWidget {
//   final StreamController<int> selectedListLengthStreamController;
//   final ValueChanged<bool> isSelected;
//   final AssetEntity item;
//
//   SelectedAsset(
//       {this.isSelected, this.item, this.selectedListLengthStreamController});
//
//   @override
//   _SelectedAssetState createState() => _SelectedAssetState();
// }
//
// class _SelectedAssetState extends State<SelectedAsset>
//     with AutomaticKeepAliveClientMixin {
//   bool isSelected = false;
//
//   @override
//   void initState() {
//     // --- If 'all' is true, all items are selected ---
//     if (Provider.of<ProviderController>(context, listen: false).all == true) {
//       isSelected = true;
//     }
//     // IF UPLOAD WAS CANCELLED RESTATE THE SELECTED THUMBNAILS
//     SharedPreferencesService.instance
//         .getStringListValue('selectedListID')
//         .then((value) async {
//       if (value == null) {
//         return;
//       } else if (value.contains(widget.item.id)) {
//         setState(() {
//           isSelected = !isSelected;
//         });
//         Provider.of<ProviderController>(context, listen: false)
//             .selectionInProcess(true);
//         // NOW DENOMINATOR IS PROVIDED AT UPLOADHANDLER()
//         // widget.selectedListLengthStreamController.add(value.length);
//       }
//     });
//     super.initState();
//   }
//
//   void selectItem() {
//     setState(() {
//       isSelected = !isSelected;
//       widget.isSelected(isSelected);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return GestureDetector(
//       onTap: () {
//         if (Provider.of<ProviderController>(context, listen: false)
//             .isUploadingInProcess ==
//             false) {
//           selectItem();
//         }
//       },
//       onLongPress: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) {
//             if (widget.item.type == AssetType.image) {
//               return ImageBig(imageFile: widget.item.file);
//             } else {
//               return VideoBig(videoFile: widget.item.file);
//             }
//           }),
//         );
//       },
//       child: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color:
//               isSelected ? kAltoBlue.withOpacity(.3) : Colors.transparent,
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           isSelected
//               ? Align(
//             alignment: Alignment.topRight,
//             child: Icon(
//               Icons.circle,
//               size: 25,
//               color: kAltoBlue,
//             ),
//           )
//               : Container(),
//         ],
//       ),
//     );
//   }
//
//   @override
//   bool get wantKeepAlive => true;
// }
