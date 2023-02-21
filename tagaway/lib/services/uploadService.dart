import 'dart:io';

import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/services/storeService.dart';

class UploadService {
   dynamic pivMap;

   // UploadService._privateConstructor ();
   UploadService._privateConstructor () {
      () async {
         var pivMap = await StoreService.instance.get ('pivMap');
         if (pivMap == '') pivMap = {};
         this.pivMap = pivMap;
      } ();
   }
   static final UploadService instance = UploadService._privateConstructor ();

   var uploadQueue = [];
   var upload      = {};
   bool uploading  = false;

   startUpload () async {
      // Reuse existing upload if it has been used less than nine minutes ago.
      if (upload ['time'] != null && (upload ['time'] + 9 * 60 * 1000 >= now ())) {
         upload ['time'] = now ();
         return upload ['id'];
      }
      var response = await ajax ('post', 'upload', {'op': 'start', 'tags': [], 'total': 1});
      upload = {'id': response ['body'] ['id'], 'time': now ()};
      return upload ['id'];
   }

   completeUpload () async {
      if (upload ['time'] == null) return;
      var response = await ajax ('post', 'upload', {'op': 'complete', 'id': upload ['id']});
      upload = {};
      return response ['code'];
   }

   uploadPiv (dynamic piv) async {
      File file = await piv.originFile;

      var response = await ajaxMulti ('piv', {
         'id':           await startUpload (),
         'tags':         '[]',
         'lastModified': piv.createDateTime.millisecondsSinceEpoch
      }, file.path);

      if (response ['code'] == 200) {
        pivMap [piv.id] = response ['body'] ['id'];
        await StoreService.instance.set ('pivMap', pivMap);
      }
      return response;
   }

   // Calls with piv are from the service
   // Calls with no piv are recursive to keep the ball rolling
   queuePiv (dynamic piv) async {
      if (piv != null) {
         // If we have an entry in pivMap for this piv, we have already uploaded it earlier.
         if (pivMap [piv.id] != null) return;
         // The `true` means it is currently uploading.
         pivMap [piv.id] = true;
         uploadQueue.add (piv);

         if (uploading) return;
         uploading = true;
      }

      var nextPiv = uploadQueue [0];
      uploadQueue.removeAt (0);
      // If upload takes over 9 minutes, it will become stalled and we'll simply create a new one. The logic in `startUpload` takes care of this. So we don't need to create a `setInterval` that keeps on sending `start` ops to POST /upload.
      var result = await uploadPiv (nextPiv);
      // TODO: report & stop if 409 no capacity
      // TODO: report & stop if any other errors

      if (uploadQueue.length == 0) return completeUpload ();

      return queuePiv (null);
   }
}
