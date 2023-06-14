import 'dart:typed_data';
import 'dart:convert';
import 'package:tagaway/ui_elements/constants.dart';

class ToolsService {
   ToolsService._privateConstructor ();
   static final ToolsService instance = ToolsService._privateConstructor ();

   // Taken from https://github.com/HosseinYousefi/murmurhash/blob/master/lib/murmurhash.dart
   // Thank you Hossein Yousefi!
   // Adapted to behave like the JS implementation through the `zeroFillRightShift` function.
   // Also adapted to take a `partialHash`, which is the hash computed from all previous chunks of the file, so that we don't have to read large files onto memory at once.
   // The chunking should be done in chunks that are a multiple of 4, except for the last chunk.
   // When invoking the last chunk, the `totalLength` of the original input should be passed. This is required by the algorithm, and it also lets the function know that it is processing the last chunk.

   static int murmurhashV3 (Uint8List key, int seed, dynamic partialHash, [dynamic totalLength = 0]) {
      int zeroFillRightShift (int n, int amount) {
         return (n & 0xFFFFFFFF) >> amount;
      }
      int remainder = key.length & 3;
      int bytes = key.length - remainder;
      int h1 = partialHash == null ? seed : partialHash;
      int c1 = 0xcc9e2d51;
      int c2 = 0x1b873593;
      int i = 0;
      int k1, h1b;
      while (i < bytes) {
         k1 = ((key[i] & 0xff)) |
             ((key[++i] & 0xff) << 8) |
             ((key[++i] & 0xff) << 16) |
             ((key[++i] & 0xff) << 24);
         ++i;
         k1 = ((((k1 & 0xffff) * c1) + (((zeroFillRightShift (k1, 16) * c1) & 0xffff) << 16))) &
             0xffffffff;
         k1 = (k1 << 15) | zeroFillRightShift (k1, 17);
         k1 = ((((k1 & 0xffff) * c2) + (((zeroFillRightShift (k1, 16) * c2) & 0xffff) << 16))) &
             0xffffffff;

         h1 ^= k1;
         h1 = (h1 << 13) | zeroFillRightShift (h1, 19);
         h1b = ((((h1 & 0xffff) * 5) + (((zeroFillRightShift (h1, 16) * 5) & 0xffff) << 16))) &
             0xffffffff;
         h1 = (((h1b & 0xffff) + 0x6b64) +
             (((zeroFillRightShift (h1b, 16) + 0xe654) & 0xffff) << 16));
      }
      k1 = 0;

      switch (remainder) {
         case 3:
            k1 ^= (key[i + 2] & 0xff) << 16;
            continue case2;
         case2:
         case 2:
            k1 ^= (key[i + 1] & 0xff) << 8;
            continue case1;
         case1:
         case 1:
            k1 ^= (key[i] & 0xff);

            k1 = (((k1 & 0xffff) * c1) + (((zeroFillRightShift (k1, 16) * c1) & 0xffff) << 16)) &
                0xffffffff;
            k1 = (k1 << 15) | zeroFillRightShift (k1, 17);
            k1 = (((k1 & 0xffff) * c2) + (((zeroFillRightShift (k1, 16) * c2) & 0xffff) << 16)) &
                0xffffffff;
            h1 ^= k1;
      }
      if (totalLength == 0) return h1;
      h1 ^= totalLength;

      h1 ^= zeroFillRightShift (h1, 16);
      h1 = (((h1 & 0xffff) * 0x85ebca6b) +
         (((zeroFillRightShift (h1, 16) * 0x85ebca6b) & 0xffff) << 16)) &
          0xffffffff;
      h1 ^= zeroFillRightShift (h1, 13);
      h1 = ((((h1 & 0xffff) * 0xc2b2ae35) +
         (((zeroFillRightShift (h1, 16) * 0xc2b2ae35) & 0xffff) << 16))) &
          0xffffffff;
      h1 ^= zeroFillRightShift (h1, 16);

      return zeroFillRightShift (h1, 0);
   }

   hashPiv (dynamic piv) async {
      var file = await piv.originFile;
      var fileLength = await file.length ();
      var inputStream = file.openRead ();

      var hash = null;
      var remainder = <int>[];
      int processedBytes = 0;
      await for (var data in inputStream) {
         processedBytes += data.length as int;
         var currentData = remainder + data;
         var excess = currentData.length % 4;

         // If we have excess bytes, move them to the remainder for the next iteration.
         remainder = currentData.sublist(currentData.length - excess);
         currentData = currentData.sublist(0, currentData.length - excess);

         if (processedBytes == fileLength && remainder.length == 0) hash = murmurhashV3 (Uint8List.fromList (currentData), 0, hash, fileLength);
         else                                                       hash = murmurhashV3 (Uint8List.fromList (currentData), 0, hash);
      }
      if (remainder.length > 0) hash = murmurhashV3 (Uint8List.fromList (remainder), 0, hash, fileLength);
      debug (['HASH', hash.toString () + ':' + fileLength.toString ()]);
   }
}
