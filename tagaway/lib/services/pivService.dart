import 'dart:io';
import 'dart:async';
import 'package:photo_manager/photo_manager.dart';
import 'package:collection/collection.dart';
import 'package:tagaway/ui_elements/constants.dart';

import 'package:tagaway/services/tools.dart';
import 'package:tagaway/services/authService.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:flutter_isolate/flutter_isolate.dart';

class PivService {
   PivService._privateConstructor ();
   static final PivService instance = PivService._privateConstructor ();

   var uploadQueue = [];
   var upload      = {};
   var localPivs   = [];
   var localPivsLoaded = false;
   bool uploading  = false;
   var recomputeLocalPages = true;

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

      if (! AuthService.instance.isLogged ()) return;

      if (response ['code'] == 200) {
         StoreService.instance.set ('pivMap:'  + piv.id, response ['body'] ['id']);
         StoreService.instance.set ('rpivMap:' + response ['body'] ['id'], piv.id);
         // We set the hashMap in case it wasn't already locally set. If we overwrite it, it shouldn't matter, since the server and the client compute them in the same way.
         StoreService.instance.set ('hashMap:' + piv.id, response ['body'] ['hash']);
         var pendingTags = StoreService.instance.get ('pendingTags:' + piv.id);
         if (pendingTags != '') {
            // Done preventively before tagPivById
            StoreService.instance.set ('orgMap:' + response ['body'] ['id'], true);
            for (var tag in pendingTags) {
               // We don't await for this, we keep on going to fire the tag operations as quickly as possible without delaying further uploads.
               TagService.instance.tagPivById (response ['body'] ['id'], tag, false);
            }
         }
         StoreService.instance.remove ('pendingTags:' + piv.id, 'disk');
         if (StoreService.instance.get ('pendingDeletion:' + piv.id) != '') {
            deleteLocalPivs ([piv.id]);
            StoreService.instance.remove ('pendingDeletion:' + piv.id, 'disk');
         }
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
   queuePiv (dynamic piv) async {
      if (piv != null) {
         // If not set, we set pivMap:ID to `true` to mark the piv as uploaded already, to avoid confusion to the user.
         if (StoreService.instance.get ('pivMap:' + piv.id) == '') {
            StoreService.instance.set ('pivMap:' + piv.id, true);
         }
         bool pivAlreadyInQueue = false;
         uploadQueue.forEach ((queuedPiv) {
            if (piv.id == queuedPiv.id) pivAlreadyInQueue = true;
         });
         if (pivAlreadyInQueue) return;
         uploadQueue.add (piv);
         updateUploadQueue ();

         if (uploading) return;
         uploading = true;
      }

      var nextPiv = uploadQueue [0];
      // If we don't have an entry in pivMap for this piv, we haven't already uploaded it earlier, so we upload it now. `true` entries are mere placeholders.
      if (['', true].contains (StoreService.instance.get ('pivMap:' + nextPiv.id))) {
         // If an upload takes over 9 minutes, it will become stalled and we'll simply create a new one. The logic in `startUpload` takes care of this. So we don't need to create a `setInterval` that keeps on sending `start` ops to POST /upload.
         var result = await uploadPiv (nextPiv);
         if (! AuthService.instance.isLogged ()) return;
         if (result ['code'] == 200) {
            // Success, remove from queue and keep on going.
            // It could be that an untagging just removed the piv from the queue, so we check.
            // TODO: iterate and make sure we're removing the proper one, in case an untagging just removed the one we just uploaded.
            if (uploadQueue.length > 0) uploadQueue.removeAt (0);
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

   loadLocalPivs ([initialLoad = true]) async {

      var firstLoadSize = 500;

      FilterOptionGroup makeOption () {
         return FilterOptionGroup ()..addOrderOption (const OrderOption (type: OrderOptionType.createDate, asc: false));
      }

      final option = makeOption ();
      // Set onlyAll to true, to fetch only the 'Recent' album which contains all the photos/videos in the storage
      final albums = await PhotoManager.getAssetPathList (onlyAll: true, filterOption: option);
      if (albums.length == 0) return localPivsLoaded = true;
      final recentAlbum = albums.first;

      localPivs = await recentAlbum.getAssetListRange (start: 0, end: initialLoad ? firstLoadSize : 100000);
      localPivs.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

      localPivsLoaded = true;

      StoreService.instance.set ('countLocal', localPivs.length);

      for (var piv in localPivs) {
         StoreService.instance.set ('pivDate:' + piv.id, piv.createDateTime.millisecondsSinceEpoch);
      }

      if (initialLoad) {
         // Check if we have uploads we should revive
         await reviveUploads ();

         // Query for local pivs
         await queryExistingHashes ();
      }

      await queryOrganizedIds ();
      // No need to await this function since it's sync.
      computeLocalPages ();

      // If more pivs to load, call itself recursively
      if (initialLoad && localPivs.length == firstLoadSize) return loadLocalPivs (false);

      // We won't await for the computation of hashes, but we will for querying the existing hashes.
      // We only compute hashes once all pivs are loaded
      computeHashes ();
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
      var response = await ajax ('post', 'idsFromHashes', {'hashes': hashesToQuery.values.toList ()});
      if (response ['code'] != 200) return false;

      var output = {};

      hashesToQuery.forEach ((localId, hash) {
         output [localId] = response ['body'] [hash];
      });
      return output;
   }

   queryExistingHashes () async {
      // Get all hash entries and remove those that don't belong to a piv
      // We do this in a loop instead of a `forEach` to make sure that the `await` will be waited for.
      var localPivIds = {};
      localPivs.forEach ((v) {
         localPivIds [v.id] = true;
      });

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

      // If we cannot query hashes, it may be that we don't have a valid session. We refrain from any further action until the user logs in.
      if (queriedHashes == false) return;

      queriedHashes.forEach ((localId, uploadedId) {
         if (uploadedId == null) return;
         StoreService.instance.set ('pivMap:'  + localId,    uploadedId);
         StoreService.instance.set ('rpivMap:' + uploadedId, localId);
      });
   }

   computeHashes () async {

      // Compute hashes for local pivs that do not have them
      // We don't `await` for this because this will run in the background and might take a long time.

      for (var piv in localPivs) {
         if (StoreService.instance.get ('hashMap:' + piv.id) != '') continue;
         // NOTE: in debug mode, running `flutterCompute` will trigger a general redraw.
         var hash = await flutterCompute (hashPiv, piv.id);
         StoreService.instance.set ('hashMap:' + piv.id, hash, 'disk');

         // Check if the local piv we just hashed as an uploaded counterpart
         var queriedHash = await queryHashes ({piv.id: hash});
         if (queriedHash [piv.id] != null) {
            StoreService.instance.set ('pivMap:'  + piv.id,               queriedHash [piv.id]);
            StoreService.instance.set ('rpivMap:' + queriedHash [piv.id], piv.id);
         }
      }
   }

   computeLocalPages () {

      recomputeLocalPages = false;

      DateTime tomorrow        = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch + 24 * 60 * 60 * 1000);
      tomorrow                 = DateTime (tomorrow.year, tomorrow.month, tomorrow.year);
      DateTime Now             = DateTime.now ();
      DateTime today           = DateTime (Now.year, Now.month, Now.day);
      DateTime monday          = DateTime (Now.year, Now.month, Now.day - (Now.weekday - 1));
      DateTime firstDayOfMonth = DateTime (Now.year, Now.month, 1);

      var pages = [['Today', today], ['This week', monday], ['This month', firstDayOfMonth]].map ((pair) {
         return {'title': pair [0], 'total': 0, 'left': 0, 'pivs': [], 'from': ms (pair [1]), 'to': ms (tomorrow)};
      }).toList ();

      var displayMode = StoreService.instance.get ('displayMode');
      var currentlyTaggingPivs = StoreService.instance.get ('currentlyTaggingPivs');
      if (currentlyTaggingPivs == '') currentlyTaggingPivs = [];

      localPivs.forEach ((piv) {
         var cloudId        = StoreService.instance.get ('pivMap:' + piv.id);
         var pivIsOrganized = cloudId == true || StoreService.instance.get ('orgMap:' + cloudId) != '';

         var pivIsCurrentlyBeingTagged = currentlyTaggingPivs.contains (piv.id);

         var showPiv = pivIsCurrentlyBeingTagged || displayMode == 'all' || ! pivIsOrganized;

         var placed = false, pivDate = piv.createDateTime;
         pages.forEach ((page) {
            if ((page ['from'] as int) <= ms (pivDate) && (page ['to'] as int) >= ms (pivDate)) {
               placed = true;
               page ['total'] = (page ['total'] as int) + 1;
               if (showPiv) (page ['pivs'] as List).add (piv);
               if (! pivIsOrganized) page ['left'] = (page ['left'] as int) + 1;
            }
         });
         if (! placed) pages.add ({
            'title': shortMonthNames [pivDate.month - 1] + ' ' + pivDate.year.toString (),
            'total': 1,
            'pivs': showPiv ? [piv] : [],
            'left': pivIsOrganized ? 0 : 1,
            'from': ms (DateTime (pivDate.year, pivDate.month, 1)),
            'to':   ms (pivDate.month < 12 ? DateTime (pivDate.year, pivDate.month + 1, 1) : DateTime (pivDate.year + 1, 1, 1)) - 1
         });
      });

      if (StoreService.instance.get ('localPagesLength') != pages.length) {
         StoreService.instance.set ('localPagesLength', pages.length);
      }
      pages.asMap ().forEach ((index, page) {
         var existingPage = StoreService.instance.get ('localPage:' + index.toString ());
         if (existingPage == '' || ! DeepCollectionEquality ().equals (existingPage, page)) {
            StoreService.instance.set ('localPage:' + index.toString (), page);
         }
      });

      if (StoreService.instance.get ('localPagesListener') == '') {
         StoreService.instance.set ('localPagesListener', StoreService.instance.listen ([
            'currentlyTaggingPivs',
            'displayMode',
            'pivMap:*',
            'orgMap:*',
         ], (v1, v2, v3, v4) {
            recomputeLocalPages = true;
         }));

         // We also set a timer to periodically check if `recomputeLocalPages` is set to `true` and, if so, execute computeLocalPages.
         // This will be done only once.
         Timer.periodic(Duration(milliseconds: 200), (timer) {
            if (recomputeLocalPages == true) computeLocalPages ();
         });
      }
   }

   deleteLocalPivs (ids) async {
      var currentlyUploading = [];
      uploadQueue.forEach ((queuedPiv) {
         if (ids.contains (queuedPiv.id)) {
            StoreService.instance.set ('pendingDeletion:' + queuedPiv.id, true, 'disk');
            ids.remove (queuedPiv.id);
         }
      });

      if (ids.length == 0) return;

      List<String> typedIds = ids.cast<String>();
      await PhotoManager.editor.deleteWithIds (typedIds);
      var indexesToDelete = [];
      for (int k = 0; k < localPivs.length; k++) {
         if (ids.contains (localPivs [k].id)) indexesToDelete.add (k);
      }
      indexesToDelete.reversed.forEach ((k) {
         localPivs.removeAt (k);
      });
      recomputeLocalPages = true;
  }

   // Used only for local pivs
   queryOrganizedIds () async {
      var ids = [];
      for (var piv in PivService.instance.localPivs) {
         var uploadedId = StoreService.instance.get ('pivMap:' + piv.id);
         // If piv exists and is not being uploaded, add it.
         if (uploadedId != '' && uploadedId != true) ids.add (uploadedId);
      }

      // TODO: Why do we need to pass 'csrf' here? We don't do it on any other ajax calls! And yet, if we don't, the ajax call fails with a type error. Madness.
      var response = await ajax ('post', 'organized', {'ids': ids, 'csrf': 'foo'});
      // TODO: handle errors
      if (response ['code'] != 200) return;

      var organizedIds = {};
      response ['body'].forEach ((id) {
         organizedIds [id] = true;
      });

      ids.forEach ((id) {
         var desiredValue = organizedIds [id] == true ? true : '';
         var currentValue = StoreService.instance.get ('orgMap:' + id);
         if (currentValue != desiredValue) StoreService.instance.set ('orgMap:' + id, desiredValue);
      });
   }
}
