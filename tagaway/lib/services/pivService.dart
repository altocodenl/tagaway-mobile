import 'dart:async';
import 'dart:io';

import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/services/tools.dart';

class PivService {
   PivService._ ();
   static final PivService instance = PivService._ ();

   var localPivs   = [];
   var upload      = {};
   var uploadQueue = [];

   bool recomputeLocalPages = true;
   bool uploading           = false;

   startUpload () async {
      if (upload ['time'] != null && (upload ['time'] + 9 * 60 * 1000 >= now ())) {
         upload ['time'] = now ();
         return upload ['id'];
      }

      var response = await ajax ('post', 'upload', {'op': 'start', 'tags': [], 'total': 1});

      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error uploading your piv - CODE UGROUP:' + response ['code'].toString (), 'yellow');
         return false;
      }

      upload = {'id': response ['body'] ['id'], 'time': now ()};
      return upload ['id'];
   }

   completeUpload () async {
      if (upload ['id'] != null) await ajax ('post', 'upload', {'op': 'complete', 'id': upload ['id']});
      upload = {};
   }

   uploadPiv (dynamic piv) async {
      File file = await piv.originFile;

      var uploadId = await startUpload ();
      if (uploadId == false) return;

      var response = await ajaxMulti ('piv', {
         'id':           uploadId,
         'tags':         '[]',
         'lastModified': piv.createDateTime.millisecondsSinceEpoch
      }, file.path);

      clearFile (file);

      if (response ['code'] != 200) return response;

      StoreService.instance.set ('pivMap:'  + piv.id, response ['body'] ['id']);
      StoreService.instance.set ('rpivMap:' + response ['body'] ['id'], piv.id);

      StoreService.instance.set ('hashMap:' + piv.id, response ['body'] ['hash'], 'disk');

      var pendingTags = StoreService.instance.get ('pendingTags:' + piv.id);
      if (pendingTags != '') {
         StoreService.instance.set ('orgMap:' + response ['body'] ['id'], true);
         var code = await TagService.instance.tagCloudPiv (response ['body'] ['id'], pendingTags, false);
         if (! [0, 200, 403].contains (code)) showSnackbar ('There was an error tagging your piv - CODE TAG:L:' + code.toString (), 'yellow');
         if (code != 200) return {'code': code};
      }

      StoreService.instance.remove ('pendingTags:' + piv.id, 'disk');
      if (StoreService.instance.get ('pendingDeletion:' + piv.id) != '') {
         deleteLocalPivs ([piv.id]);
         StoreService.instance.remove ('pendingDeletion:' + piv.id, 'disk');
      }
      return response;
   }

   updateDryUploadQueue () async {
      var dryUploadQueue = [];
      uploadQueue.forEach ((v) => dryUploadQueue.add (v.id));
      StoreService.instance.set ('uploadQueue', dryUploadQueue, 'disk');
   }

   queuePiv (dynamic piv) async {
      if (piv != null) {
         if (StoreService.instance.get ('pivMap:' + piv.id) == '') StoreService.instance.set ('pivMap:' + piv.id, true);

         bool pivAlreadyInQueue = false;
         uploadQueue.forEach ((queuedPiv) {
            if (piv.id == queuedPiv.id) pivAlreadyInQueue = true;
         });
         if (pivAlreadyInQueue) return;

         uploadQueue.add (piv);
         updateDryUploadQueue ();

         if (uploading) return;
         uploading = true;
      }

      uploadQueue.sort ((a, b) {
         var sizeA = StoreService.instance.get ('hashMap:' + a.id);
         var sizeB = StoreService.instance.get ('hashMap:' + b.id);
         sizeA = sizeA == '' ? 1000 * 1000 * 1000 : int.parse (sizeA.split (':') [1]);
         sizeB = sizeB == '' ? 1000 * 1000 * 1000 : int.parse (sizeB.split (':') [1]);
         return sizeA.compareTo (sizeB);
      });

      var nextPiv = uploadQueue [0];

      var result = await uploadPiv (nextPiv);

      if ([0, 403].contains (result ['code'])) return;

      var error = result ['body'] != null ? result ['body'] ['error'] : '';

      if (result ['code'] == 200) {
         if (uploadQueue.length > 0) uploadQueue.remove (nextPiv);
         updateDryUploadQueue ();
      }

      else if (result ['code'] == 400) {
         if (! ['Invalid piv', 'tooLarge', 'format'].contains (error)) {
            showSnackbar ('There was an error uploading your piv - CODE UPLOAD:' + result ['code'].toString (), 'yellow');
            return uploading = false;
         }

         if (error == 'Invalid piv') showSnackbar ('One of the pivs you tagged is invalid, so we cannot tag it or save it in the cloud - CODE UPLOAD:INVALID', 'yellow');
         if (error == 'tooLarge')    showSnackbar ('One of the pivs you tagged is too large, so we cannot tag it or save it in the cloud - CODE UPLOAD:TOOLARGE', 'yellow');
         if (error == 'format')      showSnackbar ('One of the pivs you tagged is in an unsupported format, so we cannot tag it or save it in the cloud - CODE UPLOAD:FORMAT', 'yellow');
         uploadQueue.remove (nextPiv);
         updateDryUploadQueue ();
      }
      else if (result ['code'] == 409) {
         if (error == 'capacity') {
            uploadQueue = [];
            updateDryUploadQueue ();
            showSnackbar ('Alas! You\'ve exceeded the maximum capacity for your account so you cannot upload any more pictures.', 'yellow');
            return uploading = false;
         }
         else {
            upload ['time'] = null;
            return queuePiv (null);
         }
      }
      else {
         showSnackbar ('There was an error uploading your piv - CODE UPLOAD:' + result ['code'].toString (), 'yellow');
         return uploading = false;
      }

      if (uploadQueue.length == 0) {
         await completeUpload ();
         return uploading = false;
      }

      queuePiv (null);
   }

   loadAndroidCameraPivs () async {
      var albums = await PhotoManager.getAssetPathList (onlyAll: false);
      var cameraRoll;
      try {
         cameraRoll = albums.firstWhere (
            (element) => element.name.toLowerCase ().contains ('camera') || element.name.toLowerCase ().contains ('dcim'),
         );
      }
      catch (error) {
         return;
      }

      int start = 0;
      int count = 1000;
      while (true) {
         var assets = await cameraRoll.getAssetListRange (start: start, end: count);
         if (assets.isEmpty) break;

         for (var piv in assets) {
            StoreService.instance.set ('cameraPiv:' + piv.id, true);
         }

         start += count;
      }
   }

   loadLocalPivs () async {

      await queryExistingHashes ();
      await queryOrganizedLocalPivs ();
      computeLocalPages ();
      if (! Platform.isIOS) loadAndroidCameraPivs ();

      final albums = await PhotoManager.getAssetPathList (
         onlyAll: true,
         filterOption: FilterOptionGroup ()..addOrderOption (const OrderOption (type: OrderOptionType.createDate, asc: false))
      );

      int offset = 0, pageSize = 1000;

      while (true) {
         var page = await albums.first.getAssetListRange (start: offset, end: pageSize + offset);
         if (page.isEmpty) break;

         for (var piv in page) {
            StoreService.instance.set ('pivDate:' + piv.id, piv.createDateTime.millisecondsSinceEpoch);
            if (Platform.isIOS) {
               var mime = await piv.mimeTypeAsync;
               if (['image/heic', 'video/quicktime'].contains (mime)) StoreService.instance.set ('cameraPiv:' + piv.id, true);
            }
            localPivs.add (piv);
         }

         localPivs.sort ((a, b) => b.createDateTime.compareTo (a.createDateTime));
         StoreService.instance.set ('cameraPiv:foo', now ());

         offset += pageSize;
      }

      cleanupStaleHashes ();
      computeHashes ();
      reviveUploads ();
   }

   queryOrganizedLocalPivs () async {
      var cloudIds = [];

      for (var k in StoreService.instance.store.keys.toList ()) {
         if (! RegExp ('^pivMap:').hasMatch (k)) continue;
         var cloudId = StoreService.instance.get (k);
         if (cloudId != '' && cloudId != true) cloudIds.add (cloudId);
      }
      await TagService.instance.queryOrganizedIds (cloudIds);
   }

   reviveUploads () {
      var queue = StoreService.instance.get ('uploadQueue');

      if (queue == '' || queue.length == 0) return;

      localPivs.forEach ((v) {
         if (queue.contains (v.id)) uploadQueue.add (v);
      });

      queuePiv (null);
   }

   queryHashes (dynamic hashesToQuery) async {
      var response = await ajax ('post', 'idsFromHashes', {'hashes': hashesToQuery.values.toList ()});

      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error getting data from the server - CODE HASHES:' + response ['code'].toString (), 'yellow');
         return false;
      }

      var output = {};

      hashesToQuery.forEach ((localId, hash) {
         output [localId] = response ['body'] [hash];
      });
      return output;
   }

   cleanupStaleHashes () async {
      var localPivIds = {};
      localPivs.forEach ((v) {
         localPivIds [v.id] = true;
      });

      for (var k in StoreService.instance.store.keys.toList ()) {
         if (! RegExp ('^hashMap:').hasMatch (k)) continue;
         var id = k.replaceAll ('hashMap:', '');
         if (localPivIds [id] == null) await StoreService.instance.remove (k, 'disk');
      }
   }

   queryExistingHashes () async {
      var hashesToQuery = {};

      for (var k in StoreService.instance.store.keys.toList ()) {
         if (! RegExp ('^hashMap:').hasMatch (k)) continue;
         var id = k.replaceAll ('hashMap:', '');
         hashesToQuery [id] = StoreService.instance.get (k);
      }

      var queriedHashes = await queryHashes (hashesToQuery);

      if (queriedHashes == false) return;

      queriedHashes.forEach ((localId, uploadedId) {
         if (uploadedId != null) {
            StoreService.instance.set ('pivMap:'  + localId,    uploadedId);
            StoreService.instance.set ('rpivMap:' + uploadedId, localId);
         }
         else {
            var oldUploadedId = StoreService.instance.get ('pivMap:' + localId);
            if (oldUploadedId != '' && oldUploadedId != true) {
               StoreService.instance.remove ('pivMap:'  + localId);
               StoreService.instance.remove ('rpivMap:' + oldUploadedId);
            }
         }
      });
   }

   computeHashes () async {

      for (int i = 0; i < localPivs.length; i++) {
         if (i >= localPivs.length) break;
         var piv = localPivs [i];

         if (StoreService.instance.get ('hashMap:' + piv.id) != '') continue;

         var hash = await flutterCompute (hashPiv, piv.id);
         if (hash == false) continue;
         StoreService.instance.set ('hashMap:' + piv.id, hash, 'disk');

         var queriedHash = await queryHashes ({piv.id: hash});
         if (queriedHash == false) break;

         if (queriedHash [piv.id] != null) {
            StoreService.instance.set ('pivMap:'  + piv.id,               queriedHash [piv.id]);
            StoreService.instance.set ('rpivMap:' + queriedHash [piv.id], piv.id);
            TagService.instance.queryOrganizedIds ([queriedHash [piv.id]]);
         }
      }
   }

   computeLocalPages () {

      recomputeLocalPages = false;

      DateTime tomorrow        = DateTime.fromMillisecondsSinceEpoch (DateTime.now ().millisecondsSinceEpoch + 24 * 60 * 60 * 1000);
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

         if (StoreService.instance.get ('pendingDeletion:' + piv.id) != '') return;

         var cloudId        = StoreService.instance.get ('pivMap:' + piv.id);
         var pivIsOrganized = cloudId == true || StoreService.instance.get ('orgMap:' + cloudId) != '';
         var pivIsLeft      = ! pivIsOrganized;
         if (displayMode ['cameraOnly'] == true && StoreService.instance.get ('cameraPiv:' + piv.id) != true) pivIsLeft = false;

         var pivIsCurrentlyBeingTagged = currentlyTaggingPivs.contains (piv.id);

         var showPiv = pivIsCurrentlyBeingTagged || ((displayMode ['showOrganized'] == true || ! pivIsOrganized) && (displayMode ['cameraOnly'] == false || StoreService.instance.get ('cameraPiv:' + piv.id) == true));

         var placed = false, pivDate = piv.createDateTime;
         pages.forEach ((page) {
            if ((page ['from'] as int) <= ms (pivDate) && (page ['to'] as int) >= ms (pivDate)) {
               placed = true;
               page ['total'] = (page ['total'] as int) + 1;
               if (showPiv) (page ['pivs'] as List).add (piv);
               if (pivIsLeft) page ['left'] = (page ['left'] as int) + 1;
            }
         });
         if (! placed) pages.add ({
            'title': shortMonthNames [pivDate.month - 1] + ' ' + pivDate.year.toString (),
            'total': 1,
            'pivs': showPiv ? [piv] : [],
            'left': pivIsLeft ? 1 : 0,
            'from': ms (DateTime (pivDate.year, pivDate.month, 1)),
            'to':   ms (pivDate.month < 12 ? DateTime (pivDate.year, pivDate.month + 1, 1) : DateTime (pivDate.year + 1, 1, 1)) - 1
         });
      });

      StoreService.instance.set ('localPagesLength', pages.length);
      pages.asMap ().forEach ((index, page) {
         StoreService.instance.set ('localPage:' + index.toString (), page);
      });

      if (StoreService.instance.get ('localPagesListener') == '') {
         StoreService.instance.set ('localPagesListener', StoreService.instance.listen ([
            'cameraPiv:*',
            'currentlyTaggingPivs',
            'displayMode',
            'pivMap:*',
            'orgMap:*',
         ], (v1, v2, v3, v4, v5) {
            recomputeLocalPages = true;
         }));

         Timer.periodic (Duration (milliseconds: 200), (timer) {
            if (recomputeLocalPages == true) computeLocalPages ();
         });
      }
   }

   deleteLocalPivs (ids, [reportBytes = null]) async {
      uploadQueue.forEach ((queuedPiv) {
         if (! ids.contains (queuedPiv.id)) return;
         StoreService.instance.set ('pendingDeletion:' + queuedPiv.id, true, 'disk');
         ids.remove (queuedPiv.id);
      });

      if (ids.length == 0) return;

      List<String> typedIds = ids.cast<String> ();
      await PhotoManager.editor.deleteWithIds (typedIds);

      var firstPivDeleted = false, giveUpAt = now () + 1000 * 60;

      while (! firstPivDeleted && giveUpAt > now ()) {
         await Future.delayed (Duration (milliseconds: 20));
         var deletedPiv = await AssetEntity.fromId (ids [0]);
         firstPivDeleted = deletedPiv == null;
      }

      if (! firstPivDeleted) return;

      var indexesToDelete = [];
      for (int k = 0; k < localPivs.length; k++) {
         if (ids.contains (localPivs [k].id)) {
            var existingPiv = await AssetEntity.fromId (localPivs [k].id);
            if (existingPiv == null) indexesToDelete.add (k);
         }
      }
      indexesToDelete.reversed.forEach ((k) {
         localPivs.removeAt (k);
      });
      recomputeLocalPages = true;
      if (reportBytes != null) showSnackbar ('You have freed up ' + printBytes (reportBytes) + ' of space!', 'green');
   }

   deletePivsByRange (String deletionType, [delete = false]) async {

      await queryExistingHashes ();

      var totalSize = 0, pivsToDelete = [];

      localPivs.forEach ((piv) {
         var hash = StoreService.instance.get ('hashMap:' + piv.id);
         if (hash == '') return;
         var cloudId = StoreService.instance.get ('pivMap:' + piv.id);
         if (cloudId == '') return;
         if (deletionType == '3m') {
            var date = piv.createDateTime.millisecondsSinceEpoch;
            var limit = now () - 1000 * 60 * 60 * 24 * 90;
            if (date > limit) return;
         }
         var size = int.parse (hash.split (':') [1]);
         totalSize += size;
         pivsToDelete.add (piv.id);
      });

      if (! delete) return totalSize;

      if (pivsToDelete.isEmpty) return showSnackbar ('Alas, there are no pivs to delete that are organized.', 'yellow');
      await deleteLocalPivs (pivsToDelete, totalSize);
   }
}
