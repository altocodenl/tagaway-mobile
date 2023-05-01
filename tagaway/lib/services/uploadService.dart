import 'dart:io';

import 'package:photo_manager/photo_manager.dart';
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

   updateUploadQueue () async {
      var dryUploadQueue = [];
      uploadQueue.forEach ((v) => dryUploadQueue.add (v.id));
      StoreService.instance.set ('uploadQueue', dryUploadQueue, 'disk');
   }

   // Calls with piv argument come from another service
   // Calls with no piv argument are recursive to keep the ball rolling
   // Recursive calls do not get blocked by the `uploading` flag.
   // TODO: add logic to revive uploads that haven't been completed if the application is restarted
   queuePiv (dynamic piv) async {
      if (piv != null) {
         uploadQueue.add (piv);
         updateUploadQueue ();

         if (uploading) return;
         uploading = true;
      }

      var nextPiv = uploadQueue [0];
      await ajax ('post', 'error', {'nextPiv': nextPiv.id});
      // If we don't have an entry in pivMap for this piv, we haven't already uploaded it earlier, so we upload it now.
      if (StoreService.instance.get ('pivMap:' + nextPiv.id) == '') {
         // If an upload takes over 9 minutes, it will become stalled and we'll simply create a new one. The logic in `startUpload` takes care of this. So we don't need to create a `setInterval` that keeps on sending `start` ops to POST /upload.
         var result= await uploadPiv (nextPiv);
         await ajax ('post', 'error', {'nextPiv': nextPiv.id, 'uploadResult': result ['code']});
         if (result ['code'] == 200) {
            // Success, remove from queue and keep on going.
            uploadQueue.removeAt (0);
            updateUploadQueue ();
         }
         else if (result ['code'] > 400) {
            // Invalid piv, remove from queue and keep on going
            uploadQueue.removeAt (0);
            updateUploadQueue ();
            // TODO: report error
         }
         else if (result ['code'] == 409) {
            if (result ['body'] ['error'] == 'capacity') {
                // No space left, stop uploading all pivs and clear the queue
               uploadQueue = [];
               updateUploadQueue ();
               return uploading = false;
               // TODO: report
            }
            else {
               // Issue with the upload group, reinitialize the upload object and retry this piv
               upload ['time'] = null;
               return queuePiv (null);
            }
         }
         else {
           // Server error, connection error or unexpected error. Stop all uploads but do not clear the queue.
           return uploading = false;
           // TODO: report
         }
      }

      if (uploadQueue.length == 0) {
         // TODO: handle error in completeUpload
         await completeUpload ();
         return uploading = false;
      }

      // Recursive call to keep the ball rolling since we have further pivs in the queue
      queuePiv (null);
   }

   reviveUploads () async {
      var queue = await StoreService.instance.getBeforeLoad ('uploadQueue');
      if (queue == '' || queue.length == 0) return;

      final albums = await PhotoManager.getAssetPathList(onlyAll: true);
      final recentAlbum = albums.first;

      await ajax ('post', 'error', {'queueLength': queue.length});

      // Now that we got the album, fetch all the assets it contains
      final recentAssets = await recentAlbum.getAssetListRange(
        start: 0, // start at index 0
        end: 1000000, // end at a very big index (to get all the assets)
      );

      recentAssets.forEach ((v) {
         if (queue.contains (v.id)) uploadQueue.add (v);
      });

      await ajax ('post', 'error', {'uploadQueue': uploadQueue.length});

      queuePiv (null);
   }
}
