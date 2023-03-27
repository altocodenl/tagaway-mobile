import 'dart:io';

import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';

class UploadService {
   UploadService._privateConstructor ();
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
      // TODO: handle errors
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
         // TODO: handle error in startUpload
         'id':           await startUpload (),
         'tags':         '[]',
         'lastModified': piv.createDateTime.millisecondsSinceEpoch
      }, file.path);

      if (response ['code'] == 200) {
         StoreService.instance.set ('pivMap:'  + piv.id, response ['body'] ['id'], 'disk');
         StoreService.instance.set ('rpivMap:' + response ['body'] ['id'], piv.id, 'disk');
         TagService.instance.getLocalTimeHeader ();
         var pendingTags = StoreService.instance.get ('pendingTags:' + piv.id);
         if (pendingTags != '') {
            for (var tag in pendingTags) {
               // We don't await for this, we keep on going to fire the tag operations as quickly as possible without delaying further uploads.
               TagService.instance.tagPivById (response ['body'] ['id'], tag, false);
            }
         }
         StoreService.instance.remove ('pendingTags:' + piv.id, 'disk');
      }
      return response;
   }

   // Calls with piv are come from the view or another service
   // Calls with no piv are recursive to keep the ball rolling
   // Because there can only be a single upload going, a return is no guarantee of the action being done. Alas.
   // So the state must be checked periodically to see which uploads have completed.
   // TODO: add logic to revive uploads that haven't been completed if the application is restarted
   queuePiv (dynamic piv) async {
      if (piv != null) {
         uploadQueue.add (piv);
         if (uploading) return;
         uploading = true;
      }

      var nextPiv = uploadQueue [0];
      uploadQueue.removeAt (0);
      // If we don't have an entry in pivMap for this piv, we haven't already uploaded it earlier, so we upload it now.
      if (StoreService.instance.get ('pivMap:' + nextPiv.id) == '') {
         // If upload takes over 9 minutes, it will become stalled and we'll simply create a new one. The logic in `startUpload` takes care of this. So we don't need to create a `setInterval` that keeps on sending `start` ops to POST /upload.
         var result = await uploadPiv (nextPiv);
         // TODO: report & stop if 409 no capacity
         // TODO: report & stop if any other errors
      }

      if (uploadQueue.length == 0) {
         await completeUpload ();
         // TODO: handle error in completeUpload
         return uploading = false;
      }

      return queuePiv (null);
   }
}
