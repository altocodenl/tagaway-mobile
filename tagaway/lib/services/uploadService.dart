import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:tagaway/services/tools.dart';
import 'package:tagaway/services/permissionService.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:flutter_isolate/flutter_isolate.dart';

class UploadService {
   UploadService._privateConstructor ();
   static final UploadService instance = UploadService._privateConstructor ();

   var uploadQueue = [];
   var upload      = {};
   var localPivs   = [];
   var localPivsLoaded = false;
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
         StoreService.instance.set ('pivMap:'  + piv.id, response ['body'] ['id']);
         StoreService.instance.set ('rpivMap:' + response ['body'] ['id'], piv.id);
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
      // If we don't have an entry in pivMap for this piv, we haven't already uploaded it earlier, so we upload it now.
      if (StoreService.instance.get ('pivMap:' + nextPiv.id) == '') {
         // If an upload takes over 9 minutes, it will become stalled and we'll simply create a new one. The logic in `startUpload` takes care of this. So we don't need to create a `setInterval` that keeps on sending `start` ops to POST /upload.
         var result = await uploadPiv (nextPiv);
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
      else {
         uploadQueue.removeAt (0);
         updateUploadQueue ();
      }

      if (uploadQueue.length == 0) {
         // TODO: handle error in completeUpload
         await completeUpload ();
         return uploading = false;
      }

      // Recursive call to keep the ball rolling since we have further pivs in the queue
      queuePiv (null);
   }

   loadLocalPivs () async {

      var permissionStatus = await checkPermission ();
      // If user has granted complete or partial permissions, go to the main part of the app.
      if (permissionStatus != 'granted' && permissionStatus != 'limited') return;

      FilterOptionGroup makeOption () {
         return FilterOptionGroup ()..addOrderOption (const OrderOption (type: OrderOptionType.createDate, asc: false));
      }

      final option = makeOption ();
      // Set onlyAll to true, to fetch only the 'Recent' album which contains all the photos/videos in the storage
      final albums = await PhotoManager.getAssetPathList (onlyAll: true, filterOption: option);
      final recentAlbum = albums.first;

      localPivs = await recentAlbum.getAssetListRange (start: 0, end: 1000000);
      localPivsLoaded = true;

      StoreService.instance.set ('countLocal', localPivs.length);

      for (var piv in localPivs) {
         StoreService.instance.set ('pivDate:' + piv.id, piv.createDateTime.millisecondsSinceEpoch);
      }

      TagService.instance.getLocalTimeHeader ();

      // Check if we have uploads we should revive
      UploadService.instance.reviveUploads ();

      // Compute hashes for local pivs
      UploadService.instance.computeHashes ();
   }

   reviveUploads () async {
      var queue = await StoreService.instance.getBeforeLoad ('uploadQueue');

      if (queue == '' || queue.length == 0) return;

      localPivs.forEach ((v) {
         if (queue.contains (v.id)) uploadQueue.add (v);
      });

      queuePiv (null);
   }

   queryHashes (dynamic hashesToQuery) async {
      debug (['HASHES TO QUERY', hashesToQuery]);
      var response = await ajax ('post', 'idsFromHashes', {'hashes': hashesToQuery.values.toList ()});
      // TODO: handle errors
      if (response ['code'] != 200) return;

      var output = {};

      hashesToQuery.forEach ((localId, hash) {
         output [localId] = response ['body'] [hash];
      });
      return output;
   }

   computeHashes () async {
      // Get all hash entries and remove those that don't belong to a piv
      var localPivIds = {};
      localPivs.forEach ((v) {
         localPivIds [v.id] = true;
      });

      // We do this in a loop instead of a `forEach` to make sure that the `await` will be waited for.
      for (var k in StoreService.instance.store.keys.toList ()) {
         if (! RegExp ('^hashMap:').hasMatch (k)) continue;
         var id = k.replaceAll ('hashMap:', '');
         if (localPivIds [id] == null) await StoreService.instance.remove (k, 'disk');
      }

      // Query existing hashes
      var hashesToQuery = {};

      StoreService.instance.store.keys.toList ().forEach ((k) {
         if (! RegExp ('^hashMap:').hasMatch (k)) return;
         var id = k.replaceAll ('hashMap:', '');
         hashesToQuery [id] = StoreService.instance.get (k);
      });

      var queriedHashes = await queryHashes (hashesToQuery);

      queriedHashes.forEach ((localId, uploadedId) {
         if (uploadedId == null) return;
         StoreService.instance.set ('pivMap:'  + localId,    uploadedId);
         StoreService.instance.set ('rpivMap:' + uploadedId, localId);
      });

      // Compute hashes for local pivs that do not have them
      for (var piv in localPivs) {
         if (StoreService.instance.get ('hashMap:' + piv.id) != '') continue;
         var hash = await flutterCompute (hashPiv, piv.id);
         StoreService.instance.set ('hashMap:' + piv.id, hash, 'disk');
         debug (['STORE NEW HASH', piv.id, hash]);

         // Check if the local piv we just hashed as an uploaded counterpart
         var queriedHash = await queryHashes ({[piv.id]: hash});
         if (queriedHash [piv.id] != null) {
            StoreService.instance.set ('pivMap:'  + piv.id,               queriedHash [piv.id]);
            StoreService.instance.set ('rpivMap:' + queriedHash [piv.id], piv.id);
         }
      }

   }

}
