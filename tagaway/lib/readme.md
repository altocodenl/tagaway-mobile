# Tagaway Mobile

## TODO

- Load up all pivs after deletion anyway.
- Why new tag doesn't appear immediately on search? update list of tags after each tagging before updating lastNTags: without await, fire off call to getTags from queryPivs. Make update of lastNTags directly in getTags.
- Performance of query: avoid double round trip for first draw of uploadedView.
- Handle >= 400 errors with snackbar on tagService
- Finish annotated source code.

- Create settings view with Change Password and enable/disable geotagging: merge & dynamize
- Stop flickering when opening FAB or clicking on "done".
- Remove edit & delete tag buttons after cancel or when tapping anywhere else
- Make uploaded grid only accessible through clicking on a tag in home or the query selector. Liberate space on bottom navigation, put Share icon, put "coming soon!"

- Liberate space (Tom)
- Write a QA script (Tom)
- Add cloud icon for pivs in cloud that are being uploaded (Tom)
- Draggable selection (Tom)

- Show pivs being uploaded in the queries, with a cloud icon
   - When querying, add logic after first 200 items return (with o:: result)
      - Get list
         - Iterate pending.
         - If tag, filter out by tag.
         - If tag with date, filter out by date.
         - Also filter out by date to the current month.
      - Generate piv entry with different features:
         - id: PENDING:...
         - date
      - Sort into existing pivs
   - Do this again after getting long list
   - Ops on piv:
      - Delete: remove from queue
      - Tag/untag: change pendingTags
   - Icon
-----
- Home: add tabs for pinned vs recent, remove add hometags button if not on pinned
- Home: display tags in a better, different way
- Tutorial (Tom)
- Add login flow with Google, Apple and Facebook (Tom)

## Store structure

```
- account: {username: STRING, email: STRING, type: STRING, created: INTEGER, usage: {limit: INTEGER, byfs: INTEGER, bys3: INTEGER}, geo: true|UNDEFINED, geoInProgress: true|UNDEFINED, suggestGeotagging: true|UNDEFINED, suggestSelection: true|UNDEFINED}
- context: a reference to the context of a Flutter widget, which comes useful for services that want to draw widgets into views.
- cookie <str> [DISK]: cookie of current session, brought from server - deleted on logout.
- csrf <str> [DISK]: csrf token of current session, brought from server - deleted on logout.
- currentIndex <int>: 0 if on HomeView, 1 if on LocalView, 2 if on UploadedView
- currentMonth `[<int (year)>, <int (month)>]`: if set, indicates the current month of the uploaded view.
- currentlyTaggingPivs <list>: list of *local* piv ids currently being tagged, to avoid hiding them before the operation is complete.
- currentlyTagging(Local|Uploaded) <str>: tag currently being tagged in LocalView/UploadedView
- currentlyDeleting(Local|Uploaded) <bool>: if set, we are in delete mode in LocalView/UploadedView
- currentlyDeletingModal(Local|Uploaded) <bool>: if set, we are showing the delete confirmation modal for Local/Uploaded view.
- currentlyDeletingPivs(Local|Uploaded) <list>: list of pivs that are currently being deleted, either Local or Uploaded.
- displayMode <str>: if set to `'all'`, shows all local pivs; otherwise, it only shows local pivs that are not organized.
- deleteTag(Local|Uploaded) <str>: tag currently being deleted in LocalView/UploadedView
- gridControllerUploaded <scroll controller>: controller that drives the scroll of the uploaded grid
- hashMap:<id> [DISK]: maps the id of a local piv to a hash.
- hometags [<str>, ...]: list of hometags, brought from the server
- initialScrollableSize <float>: the percentage of the screen height that the unexpanded scrollable sheets should take.
- lastNTags [<str>, ...] [DISK]: list of the last N tags used to tag or untag, either on local or uploaded.
- localPage:INT `{name: STRING: pivs: [<asset>, ...], total: INTEGER, from: INTEGER, to: INTEGER}` - contains all the pages of local pivs to be shown, one per grid.
- localPagesLength <int>: number of local pages.
- localPagesListener <listener>: listener that triggers the function to compute the local pages.
- localYear <str>: displayed year in LocalView time header
- orgMap:<pivId> (bool): if set, it means that this uploaded piv is organized
- pendingDeletion:<assetId> <true|undefined> [DISK]: if set, the piv must be deleted after it being uploaded.
- pendingTags:<assetId> [<str>, ...] [DISK]: list of tags that should be applied to a local piv that hasn't been uploaded yet - deleted on logout.
- pivDate:<assetId> <int>: date of each local piv
- pivMap:<assetId> <str>: maps the id of a local piv to the id of its uploaded counterpart - the converse of `rpivMap`. They are temporarily set to `true` for pivs on the upload queue.
- previousError <object> [DISK]: stores the last error experienced by the application, if any
- recurringUser <bool> [DISK]: whether the user is new to the app or has already used it - to redirect to either signup or login
- renameTag(Local|Uploaded) <str>: tag currently being renamed in LocalView/UploadedView
- queryFilter <str>: contains the filter (if any) used to filter out tags in the query/search view
- queryResult: {total: <int>, tags: {<tag>: <int>, ...}, pivs: [{...}, ...], timeHeader: {<year:month>: true|false, ...}}: result of query, brought from server
- queryTags: [<string>, ...]: list of tags of the current query
- rpivMap:<pivId> <str>: maps the id of an uploaded piv to the id of its local counterpart - the converse of `pivMap`
- showButtons(Local|Uploaded) (boolean): if true, shows buttons to perform actions in LocalView/UploadedView
- swiped(Local|Uploaded) (boolean): controls the swipable tag list on LocalView/UploadedView
- tagFilter(Local|Uploaded) <str>: value of filter of tagging modal in LocalView/UploadedView
- taggedPivCount(Local|Uploaded) (int): shows how many pivs are tagged with the current tag on LocalView/UploadedView
- tagMap:<assetId|pivId> (bool): if set, it means that this piv (whether local or uploaded) is tagged with the current tag
- tags [<string>, ...]: list of tags relevant to the current query, brought from the server
- uploadQueue [<string>, ...] [DISK]: list of ids of pivs that are going to be uploaded - deleted on logout.
- timeHeader [<semester 1>, <semester 2>, ...]: information for UploadedView time header
   where <semester> is [<month 1>, <month 2>, ..., <month 6>]
   where <month> is [<year>, <month>, 'white|gray|green', <undefined>|<pivId of last piv in month>]
- timeHeaderController <page controller>: controller that drives the timeHeader
- timeHeaderPage <int>: page in timeHeader currently displayed.
- usertags [<string>, ...]: list of user tags, computed from the tags brought from the server.
- userWasAskedPermission (boolean) [DISK]: whether the user was already asked for piv access permission once
- yearUploaded <str>: displayed year in localView|UploadedView time header
```

## Creating a build

- In Android Studio:
- Go to the menu File -> Open
- Open the `android` folder in a new window.
- The first time it can take a while to load
- Go to the menu Build -> generate signed bundle/apk
   - If this is not yet available, click on Build -> Make project, then retry
- Select APK + next
- Create new key or use an existing one
- If creating a new key, check on box for remember password
- Use release & create
- When it's done, build will be in the `android/app/release` folder.

## Annotated source code

For now, we only have annotated fragments of the code. This might be expanded comprehensively later.

### `services/pivService.dart`

The pivService is concerned with operations concerning local pivs. Some of them don't involve the server, and others do.

We start by importing native packages, then libraries, and finally other parts of our app.

```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/services/authService.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/services/tools.dart';
```

We initialize the class `PivService`.

```dart
class PivService {
```

PivService, like the rest of our services, will be initialized as a singleton. That means that the class will only be initialized once, so for practical purposes the class and its instance are the same thing. The class will expose itself through its `instance` property. Other services will be able to use its methods and access its properties through `PivService.instance`.

```dart
   PivService._ ();
   static final PivService instance = PivService._ ();
```

The function `computeLocalPages` will create each of the "pages" of the local view. Each page represents a time period and contains zero or more local pivs.

The function takes no arguments, since it gets all its info from the store. While the function is synchronous, it will set up a couple of asynchronous operation the first time is executed.

PivService has three properties that hold data:

- `localPivs`, an array with all local pivs, sorted with the most recent ones first.
- `upload`, an upload object of the form `{'id': ..., 'time': INT}`, which indicates the id of the last upload object created from this client. The `time` entry indicates when the upload object was last used, since the server makes them expire after 10 minutes of inactivity.
- `uploadQueue`, which contains the pivs to be uploaded.

```dart
   var localPivs   = [];
   var upload      = {};
   var uploadQueue = [];
```


PivService has also two properties that are flags:

- `recomputeLocalPages`, a flag that is set to `true` if we need to recompute the local pages. The local pages are data objects that determine how many months - and which pivs - are visible in the Local view.
- `uploading`, a flag that is set to `true` if we are currently uploading a piv.

```dart
   bool recomputeLocalPages = true;
   bool uploading           = false;
```

We now define `startUpload`. The tagaway server groups multiple uploaded pivs into a single upload group. This function doesn't actually perform a piv upload, but instead create a new upload group with the server - or reuses an existing one, if it's still active.

The concept of upload group makes much more sense for the web version of tagaway, where users upload things in batch; grouping uploads in the context of a mobile app is much more arbitrary, since the only thing binding uploads together is their proximity in time; but we continue with this logic to be consistent with the web version - and it sure looks nicer than creating an individual upload group for each uploaded piv.

```dart
   startUpload () async {
```

If there's an existing upload that has been used less than nine minutes ago, the function will update its `time` property and return the id of the upload. While the server allows for 10 minutes of inactivity, we remove one minute to have a margin of error.

```dart
      if (upload ['time'] != null && (upload ['time'] + 9 * 60 * 1000 >= now ())) {
         upload ['time'] = now ();
         return upload ['id'];
      }
```

We make a call to `POST /upload` indicating the `'start'` operation, sending no tags (since the tags will be added after each individual upload), and indicating that the total is 1; the total as 1 will be plain wrong if the user uplaods more than one piv on this upload group, but it's a required value.

```dart
      var response = await ajax ('post', 'upload', {'op': 'start', 'tags': [], 'total': 1});
```

If we receive anything other than a 200, we report the error in the snackbar and return. The error code will be `UGROUP:CODE`. We then return `false` to indicate an error. Note however that we don't report the error if we get a 403, since an error message will be shown by the `ajax` function, defined elsewhere.

```dart
      if (response ['code'] != 200) {
         if (response ['code'] != 403) showSnackbar ('There was an error uploading your piv - CODE UGROUP:' + response ['code'].toString (), 'yellow');
         return false;
      }
```

We set the `upload` property of PivService to a new object with the `id` we just obtained, as well as the current time.

```dart
      upload = {'id': response ['body'] ['id'], 'time': now ()};
```

We return the `id` and close the function.

```dart
      return upload ['id'];
   }
```

We now define `completeUpload`, the converse operation of `startUpload`. This function will let the server know that a given upload group is finished. Later we will see that this function is executed when the upload queue is empty and there are no more pivs left to upload.


```dart
   completeUpload () async {
```

If we have an upload id, we will simply make the call to the server. If the upload queue just finished processing, there should be an upload group id, so we shouldn't check whether there is one or not.

```dart
      if (upload ['id'] != null) await ajax ('post', 'upload', {'op': 'complete', 'id': upload ['id']});
```

We update the `upload` property to an empty object to indicate that a new upload group has to be created in future uploads. This closes the function.

```dart
      upload = {};
   }
```

We define `uploadPiv`, the function that will actually upload a piv to the server. It takes a single piv - this will be one of the pivs inside `localPivs`. It's typed as dynamic because of my blatant disregard for Dart's type system.

```dart
   uploadPiv (dynamic piv) async {
```

We get the actual file of the piv. This functionality is provided by PhotoManager.

```dart
      File file = await piv.originFile;
```

We get the `uploadId` from `startUpload`, which will either give us an existing upload group id or make a new one; if we get `false`, the operation failed and we cannot proceed, so we don't do anything else. In this case, we don't even print an error, since that will have been done by `startUpload`.

```dart
      var uploadId = await startUpload ();
      if (uploadId == false) return;
```

We send the actual piv to the server using the `ajaxMulti` function. Besides the piv itself, we send three text fields:

- `id`, the upload group id.
- `tags`, an empty list of tags that should be applied to this piv. We send none, since the piv will be tagged later, after it is uploaded.
- `lastModified`, the create time of the piv converted to milliseconds.

```dart
      var response = await ajaxMulti ('piv', {
         'id':           uploadId,
         'tags':         '[]',
         'lastModified': piv.createDateTime.millisecondsSinceEpoch
      }, file.path);
```

If we do not get a 200, we return the response and do not do anything else. The calling function, `queuePiv` (which we'll define later) will handle any errors.

```dart
      if (response ['code'] != 200) return response;
```

We set a `pivMap` entry for this piv, mapping it to the id of the freshly uploaded piv. We also add a reverse entry (`rpivMap`) connecting the freshly uploaded piv with its local counterpart.

```dart
      StoreService.instance.set ('pivMap:'  + piv.id, response ['body'] ['id']);
      StoreService.instance.set ('rpivMap:' + response ['body'] ['id'], piv.id);
```

We set the `hashMap` for this piv. The client and the server determine this hash in the same way using the same algorithm, so if we overwrite our local entry, it should make no difference. The reason we write this `hashMap` here is that if we are uploading a piv that hasn't been hashed by the client yet, we can already set it and save the client the expense of hashing the piv.

Note the `hashMap` entry is stored in disk and will persist if the app restarts.

```dart
      StoreService.instance.set ('hashMap:' + piv.id, response ['body'] ['hash'], 'disk');
```

After the piv is successfully added, it is now time to tag it. If there are tags that should be applied to it, they will be at the `pendingTags:ID` key.

```dart
      var pendingTags = StoreService.instance.get ('pendingTags:' + piv.id);
```

If there are pending tags, then we will start by setting `orgMap:ID` (the `orgMap` entry for the uploaded counterpart of this local piv) to `true`. The rationale is the following: if the piv will be tagged, we automatically consider it as tagged. Therefore, it is correct to set this entry.

The practical reason for preventively setting this entry is that the tagging operation will take anywhere between 100ms and a second - in that time, the piv can briefly reappear in the local pivs page, since it will be considered uploaded but not organized yet.

```dart
      if (pendingTags != '') {
         StoreService.instance.set ('orgMap:' + response ['body'] ['id'], true);
```

We now iterate the tags in `pendingTags` and invoke `tagPivById`. Rather than `await`ing for these operations, we fire them concurrently since we want to continue the next upload as soon as possible.


```dart
         for (var tag in pendingTags) {
            TagService.instance.tagPivById (response ['body'] ['id'], tag, false);
         }
```

This concludes the logic for tagging the uploaded piv.

```dart
      }
```

We remove the `pendingTags` key. Note we do this on disk as well, since that key needs to persist if the app is restarted.

```dart
      StoreService.instance.remove ('pendingTags:' + piv.id, 'disk');
```

If the piv was set to be deleted, but we couldn't delete it yet because it was queued to be uploaded first, it is now safe to delete it. We invoke `deleteLocalPivs` passing the piv id inside an array. We also remove the `pendingDeletion` key, also from disk.

```dart
      if (StoreService.instance.get ('pendingDeletion:' + piv.id) != '') {
         deleteLocalPivs ([piv.id]);
         StoreService.instance.remove ('pendingDeletion:' + piv.id, 'disk');
      }
```

There's nothing else to do, so we return the response and close the function.

```dart
      return response;
   }
```

We now define `updateDryUploadQueue`, the function that is in charge of storing the upload queue in disk. If it wasn't for this function, the upload queue would be reset if the app was closed.

The function is quite simple, but since it is used in multiple places, it is handy to define it.

```dart
   updateDryUploadQueue () async {
```

We iterate the pivs in `uploadQueue` and add their ids to a `dryUploadQueue` list.

```dart
      var dryUploadQueue = [];
      uploadQueue.forEach ((v) => dryUploadQueue.add (v.id));
```

We store `dryUploadQueue` in the `uploadQueue` key; note we store this key in disk.

This concludes the function.

```dart
      StoreService.instance.set ('uploadQueue', dryUploadQueue, 'disk');
   }
```

We now define `queuePiv`, the function that adds pivs to the upload queue.

This function takes an optional argument, `piv`, which is a piv to be uploaded.

If no `piv` is passed, this is a recursive call done by `queuePiv` to itself, to keep uploads going. We will see how and why below.

```dart
   queuePiv (dynamic piv) async {
```

We first consider the case where an actual `piv` was passed.

```dart
      if (piv != null) {
```

As soon as the piv is placed in the queue, we want the interface to consider it as uploaded. The user should not have to wait for an upload to complete to see a piv as organized; if we did this, we would lose the essential instant feedback that makes the app valuable. Even if the user knew about this, it would be plain annoying to have the pivs slowly disappearing as they are uploaded.

For this reason, we preemptively set `pivMap:ID` to `true`, to indicate that the piv is being uploaded. This entry will later be overwritten with the id of the cloud counterpart of the uploaded piv.

Note however we do not unconditionally set `pivMap:ID` to `true`: if `pivMap:ID` is already set, we do not overwrite it. This precaution might be rarely useful, but not useless, if by chance the user tags a piv that just has completed uploading.

```dart
         if (StoreService.instance.get ('pivMap:' + piv.id) == '') StoreService.instance.set ('pivMap:' + piv.id, true);
```

We check whether the piv is already in the upload queue.

```dart
         bool pivAlreadyInQueue = false;
         uploadQueue.forEach ((queuedPiv) {
            if (piv.id == queuedPiv.id) pivAlreadyInQueue = true;
         });
```

If the piv is already in the queue, there's nothing else to do, so we return.

```dart
         if (pivAlreadyInQueue) return;
```

If the piv is not in the queue, we add it; we then immediately update the dry upload queue, to persist this change.


```dart
         uploadQueue.add (piv);
         updateDryUploadQueue ();
```

If we are already uploading pivs, we return since this piv will be picked up later. The `uploading` property belongs to the class itself.

```dart
         if (uploading) return;
```

If we are not uploading yet, we set the `uploading` flag to `true`.

```dart
         uploading = true;
```

We close the body of the conditional that we entered if `piv` was present. If we're here, either we just added a piv to an empty upload queue, or we are in a recursive call to `queuePiv`.

```dart
      }
```

You might have suspected that `queuePiv` does more than just putting pivs in the queue. And you'd been right. This function is also in charge of picking up the next piv and uploading it, if there are no pivs being uploaded yet.

The underlying design decision here is that there should only be a single concurrent upload at a time; that is, only one piv should be uploaded at a time. But as soon as that piv is uploaded, the next piv should be picked up from the queue (if any).

We pick up the next piv from the queue.

```dart
      var nextPiv = uploadQueue [0];
```

We upload the piv through `uploadPiv` and await for the result.

```dart
      var result = await uploadPiv (nextPiv);
```

If we got a 403, it is almost certainly because our session has expired. This can happen when reopening the app after a few days, after leaving it with pivs in the queue. When the app is revived, the upload will be attempted and it will fail. In this case, an error message will be shown by our `ajaxMulti` function, which is defined elsewhere. We will not do anything else, leaving the piv in the queue.

```dart
      if (result ['code'] == 403) return;
```

For convenience's sake, we store the error that came in the body (if any) in a variable `error`. If there's no body, we will set it to an empty string.

```dart
      var error = result ['body'] != null ? result ['body'] ['error'] : '';
```

If we obtained a 200, the piv was successfully uploaded. In this case, we simply remove the piv from the upload queue and update the dry upload queue. We do not return since we will do further actions if we got a 200.

```dart
      if (result ['code'] == 200) {
         if (uploadQueue.length > 0) uploadQueue.remove (nextPiv);
         updateDryUploadQueue ();
      }
```

If we obtained a 400, and the error is not one of the following: 1) invalid piv; 2) a piv that's too large; or 3) a piv in an unsupported format, then we have encountered an unexpected error. We report the error with code `UPLOAD:400` and set the `uploading` flag to `false`. We will return since in this case we don't want to perform any more actions. By setting the flag to `false` and not performing any more actions, we essentially freeze the upload queue until the issue is resolved.

```dart
      else if (result ['code'] == 400) {
         if (! ['Invalid piv', 'tooLarge', 'format'].contains (error)) return uploading = false;
            showSnackbar ('There was an error uploading your piv - CODE UPLOAD:' + result ['code'].toString (), 'yellow');
            return uploading = false;
         }
```

If we obtained a 400 that falls under one of the three cases we covered, we report the error.

```dart
         if (error == 'Invalid piv') showSnackbar ('One of the pivs you tagged is invalid, so we cannot tag it or save it in the cloud - CODE UPLOAD:INVALID', 'yellow');
         if (error == 'tooLarge')    showSnackbar ('One of the pivs you tagged is too large, so we cannot tag it or save it in the cloud - CODE UPLOAD:TOOLARGE', 'yellow');
         if (error == 'format')      showSnackbar ('One of the pivs you tagged is in an unsupported format, so we cannot tag it or save it in the cloud - CODE UPLOAD:FORMAT', 'yellow');
```

We also remove the piv from the queue and update the dry upload queue - exactly as we did in the case of a 200. Note we don't return, since we will do further actions.

```dart
         uploadQueue.remove (nextPiv);
         updateDryUploadQueue ();
      }
```

If we got a 409 and it's because the user ran out of space:

```dart
      else if (result ['code'] == 409) {
         if (error == 'capacity') {
```

We then clear the upload queue, update the dry upload queue, report the error and set `uploading` to `false`. We will also `return`, just like we did in the case of an unexpected 400.

```dart
            uploadQueue = [];
            updateDryUploadQueue ();
            showSnackbar ('Alas! You\'ve exceeded the maximum capacity for your account so you cannot upload any more pictures.', 'yellow');
            return uploading = false;
         }
```

If we encountered another 409 error, it has to do with the upload group expiring. In this case, we simply set `upload ['time']` to `null` and retry the upload by making a recursive call to `queuePiv`. The recursive call will retry this piv with a new upload group.

```dart
         else {
            upload ['time'] = null;
            return queuePiv (null);
         }
      }
```

If there was an unexpected error, we will report it, set `uploading` to `false` and return, as we did with unexpected 400 errors.

```dart
      else {
         showSnackbar ('There was an error uploading your piv - CODE UPLOAD:' + result ['code'].toString (), 'yellow');
         return uploading = false;
      }
```

If we're here we didn't find any errors that made us stop the upload queue.

If there are no more pivs left in the queue, we invoke `completeUpload`, set `uploading` to `false` and return.

```dart
      if (uploadQueue.length == 0) {
         await completeUpload ();
         return uploading = false;
      }
```

Otherwise, there are still more pivs to upload. We invoke `queuePiv` recursively, passing `null`. This will process the next piv. Note that recursive calls will not be halted by the `uploading` flag, so we know that this recursive call will pick up the next piv in the queue.

```dart
      queuePiv (null);
```

This concludes the function.

```dart
   }
```

We now define `loadLocalPivs`, a function that is a sort of entry point for loading up all the info required for the local view.

The function takes an optional parameter, `initialLoad`, which if not present is initialized to `true`. The function might call itself recursively, in which case `initialLoad` will be set to `false`.

```dart
   loadLocalPivs ([initialLoad = true]) async {
```

The reason this function might be called multiple times is that loading up all the local pivs could take about 10 seconds on devices with thousands of local pivs. For this reason, if the amount of local pivs is greater than `firstLoadSize`, it will call itself recursively to load the rest of the pivs later.

```dart
      var firstLoadSize = 500;
```

This function will do the following things:

- Load the local pivs using PhotoManager.
- Set the `pivDate:ID` entries, using the dates coming from each of the pivs.
- Invoke `queryExistingHashes`, the function that will take all existing `hashMap` entries (which are stored on disk) and query the server to attempt to match them to cloud piv ids. This will be done only if `initialLoad` is `true`, since it only needs to be done once.
- Invoke `queryOrganizedLocalPivs`, the function that will check whether the cloud counterparts of our local pivs are organized, and if so set the corresponding `orgMap:ID` entries.
- Invoke `computeLocalPages`, the function that will determine what is shown in the local view.
- Invoke `reviveUploads`, the function that will start re-uploading pivs from the dry upload queue. This will be done only if `initialLoad` is `true`, since it only needs to be done once.
- Invoke `computeHashes`, the function that will compute the hashes for the local pivs for which we haven't done so yet. This will only be executed on the *last* time that `loadLocalPivs` is invoked.

We start by loading the pivs from PhotoManager. By setting `onlyAll` to `true`, we access the `Recent` album, which contains all the photos/videos in the storage.

```dart
      final albums = await PhotoManager.getAssetPathList (onlyAll: true);
```

We get pivs from `albums.first` (which is the `Recent` album). How many pivs will depend on whether we are in the first invocation to `loadLocalPivs` or not: if we are in the first one, we only load `firstLoadSize` elements; otherwise we upload all of them (since we cannot pass infinity as an argument, we go with a million pivs, which should be enough to get all the pivs of any phone).

We assign the result to `localPivs`, which is a data property of the service.

```dart
      localPivs = await albums.first.getAssetListRange (start: 0, end: initialLoad ? firstLoadSize : 1000000);
```

We sort `localPivs` by `createDateTime` and place the most recent pivs first.

```dart
      localPivs.sort ((a, b) => b.createDateTime.compareTo (a.createDateTime));
```

We iterate `localPivs`: for each of them, we will set `pivDate:ID` to the creation date of the piv, expressed in milliseconds.

Since we don't store `pivDate:ID` entries in disk, we don't have to clean up old entries that might not belong to any local piv.

```dart
      for (var piv in localPivs) {
         StoreService.instance.set ('pivDate:' + piv.id, piv.createDateTime.millisecondsSinceEpoch);
      }
```

If this is the first time that `loadLocalPivs` was called, we invoke `queryExistingHashes`, to map the hashed local pivs to cloud pivs. We don't need to do this on a recursive call to `loadLocalPivs`, because loading more local pivs will not load up more hashes; rather, all the hashes are either computed or will continue to be computed - we'll see how later.

```dart
      if (initialLoad) await queryExistingHashes ();
```

For all the local pivs that have a cloud counterpart (that we know of), we check whether they are organized or not.

```dart
      await queryOrganizedLocalPivs ();
```

Now that we have a list of local pivs, that we have tried to map all of their existing hashes to cloud ids, and that we queried all of those matching cloud ids to see which ones are organized, we are in a position to create the list of local pages that will be shown! We will do this through `computeLocalPages`. There's no need to await this function, since it's synchronous.

```dart
      computeLocalPages ();
```

Now that we already showed the user a page of local pivs, we can do less urgent operations, like reviving the uploads in the dry queue. We only do this the first time we execute the function.

```dart
      if (initialLoad) await reviveUploads ();
```

If we are in the initial call to `loadLocalPivs`, and we loaded a number of local pivs equal to `firstLoadSize`, it may be the case that there are more pivs to be loaded. In that case, we invoke `loadLocalPivs` recursively, passing `false` to indicate that this won't be an initial load, but rather a recursive one. Note the return, which prevents us from executing code further done this function.

```dart
      if (initialLoad && localPivs.length == firstLoadSize) return loadLocalPivs (false);
```

We invoke `computeHashes`, to compute the hashes of any local pivs that don't have a hash. Note we do this at the end of the function, to ensure that this is done *after* all the local pivs are loaded into `localPivs`.

We don't `await` for this function, since it can take a very long time to complete and it is meant to run in the background.

```dart
      computeHashes ();
```

This concludes the function.

```dart
   }
```


TODO: add annotated source code between these two functions.


We now define `computeLocalPages`, the function that will determine what is shown in the local view.

```dart
   computeLocalPages () {
```

This function is not cheap to execute; we will see later that there's a timer that periodically checks the `recomputeLocalPages` flag to see if it's necessary to compute the local pages again. If we are here, it means that `recomputeLocalPages` is set to `true`, so we will make `computeLocalPages` set it to `false` to indicate that the local pages will be updated now.

```dart
      recomputeLocalPages = false;
```

We set up a few datetime variables:
- `tomorrow`, which represents midnight of the next day.
- `Now`, the present moment. It is uppercased to not conflict with the `now` helper function we use everywhere to get the timestamp of the present moment.
- `today`, which represents midnight of the present day.
- `monday`, which represents midnight of the Monday of the present week.
- `firstDayOfMonth`, which represents midnight of the first day of the month. In some cases, `firstDayOfMonth` might be further in the future than `monday`.

```dart
      DateTime tomorrow        = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch + 24 * 60 * 60 * 1000);
      tomorrow                 = DateTime (tomorrow.year, tomorrow.month, tomorrow.year);
      DateTime Now             = DateTime.now ();
      DateTime today           = DateTime (Now.year, Now.month, Now.day);
      DateTime monday          = DateTime (Now.year, Now.month, Now.day - (Now.weekday - 1));
      DateTime firstDayOfMonth = DateTime (Now.year, Now.month, 1);
```

The purpose of this function is to build an array of objects, each of them representing a page of local pivs. We start building this array of pages by iterating `today`, `monday` and `firstDayOfMonth` to create pages for today, this week and this month.

```dart
      var pages = [['Today', today], ['This week', monday], ['This month', firstDayOfMonth]].map ((pair) {
```

Each page has the following properties:

- `title`, which is the title that will be shown to the user.
- `total`, the total amount of pivs.
- `left`, the amount of pivs that are not marked as organized.
- `pivs`, the actual pivs that should be shown on the page.
- `from`, the earliest timestamp that a piv that belongs to this page can have.
- `from`, the latest timestamp that a piv that belongs to this page can have.

```javasscript
         return {'title': pair [0], 'total': 0, 'left': 0, 'pivs': [], 'from': ms (pair [1]), 'to': ms (tomorrow)};
```

We convert the result to a list.

```dart
      }).toList ();
```

We get the `displayMode` from the store, which can be either `'all'` (which means that all pivs should be visible, not just unorganized ones); or an empty string `''` (which means that only unorganized pivs should be visible).

```dart
      var displayMode = StoreService.instance.get ('displayMode');
```

We get `currentlyTaggingPivs`, a list of pivs currently being tagged. If there's no such key in the store, we will initialize our local variable to an empty array.

The reason we need this list is to avoid prematurely hiding pivs that are just being tagged. As soon as a piv is tagged, it is marked as organized, so if `displayMode` is `'all'`, that piv would immediately disappear, which is undesirable. By having a reference to this list, we can prevent prematurely removing those pivs from the local page.

```dart
      var currentlyTaggingPivs = StoreService.instance.get ('currentlyTaggingPivs');
      if (currentlyTaggingPivs == '') currentlyTaggingPivs = [];
```

We iterate `localPivs`, which is the list of all local pivs held by our `pivService`. For each of them:

```dart
      localPivs.forEach ((piv) {
```

If the piv is scheduled for deletion after it is uploaded, we do not consider it at all for any pages.

```dart
         if (StoreService.instance.get ('pendingDeletion:' + piv.id) != '') return;
```

We determine whether the local piv is organized by checking if there's an `orgMap` entry for its cloud counterpart. We get the cloud counterpart of the local piv by querying `pivMap:ID`.

It might be that `pivMap:ID` is set to `true`. This happens if the local piv is currently in the upload queue. In this case, we consider the piv to be organized, since we assume that any pending tagging operation will mark as organized the cloud counterpart of this local piv.

```dart
         var cloudId        = StoreService.instance.get ('pivMap:' + piv.id);
         var pivIsOrganized = cloudId == true || StoreService.instance.get ('orgMap:' + cloudId) != '';
```

We check whether the piv is currently being tagged, by checking if it is inside `currentlyTaggingPivs`.

```dart
         var pivIsCurrentlyBeingTagged = currentlyTaggingPivs.contains (piv.id);
```

We determine whether the piv should be shown and store the result in `showPiv`. The piv should be shown if any of the following is true:
- The piv is currently being tagged.
- `displayMode` is `'all'` - which means that all pivs should be visible.
- The piv is not organized.

```dart
         var showPiv = pivIsCurrentlyBeingTagged || displayMode == 'all' || ! pivIsOrganized;
```

We initialize two variables: `placed`, to determine whether the piv has been already placed in a page; and `pivDate`, the create datetime of the piv. `pivDate` will instruct us in which page to place the piv.

```dart
         var placed = false, pivDate = piv.createDateTime;
```

We iterate `pages`:

```dart
         pages.forEach ((page) {
```

If the datetime of the piv falls between `from` and `to`, it belongs to this page. We start by setting `placed` to `true`.

```dart
            if ((page ['from'] as int) <= ms (pivDate) && (page ['to'] as int) >= ms (pivDate)) {
               placed = true;
```

We increment the `total` of the current page.

```dart
               page ['total'] = (page ['total'] as int) + 1;
```

If we need to show this piv, we will also add it to the `pivs` list of the page. Note we are adding the entire piv, not just its id.

```dart
               if (showPiv) (page ['pivs'] as List).add (piv);
```

If the piv is not organized, we increment the `left` entry of the page.

```dart
               if (! pivIsOrganized) page ['left'] = (page ['left'] as int) + 1;
```

We are now done iterating the existing pages.

```dart
            }
         });
```

If the piv hasn't been placed yet, we need to add a new page!

```dart
         if (! placed) pages.add ({
```

We construct the `title` from the month and year of the piv.

```dart
            'title': shortMonthNames [pivDate.month - 1] + ' ' + pivDate.year.toString (),
```

We add the total and initialize `pivs` to either an empty list (if the piv shouldn't be shown) or to a list with the piv itself (if the piv should be shown).

```dart
            'total': 1,
            'pivs': showPiv ? [piv] : [],
```

We set `left` to either 0 or 1 depending on whether the piv is organized.

```dart
            'left': pivIsOrganized ? 0 : 1,
```

We finally add `from` and `to` to the page. The logic for `to` is not so straightforward: if the date of the piv is in any month except December, we just take the beginning of the next month as our `to`. If the piv is in December, then we use January of the following year as our `to` instead.

```dart
            'from': ms (DateTime (pivDate.year, pivDate.month, 1)),
            'to':   ms (pivDate.month < 12 ? DateTime (pivDate.year, pivDate.month + 1, 1) : DateTime (pivDate.year + 1, 1, 1)) - 1
         });
```

Before we close the iteration on local pivs, you might ask: how do you know that the pages will be created in the right order, with the latest pages first? Well, we initialized `pages` already to start with Today, followed by This Week and This Month. Because `localPivs` is sorted by date, with the latest pivs first, we know that if a piv hasn't a page yet, that page will be the right page to create to maintain things in order - otherwise, another piv without a page would have been processed first.

```dart
      });
```

We are now done constructing `pages` and are ready to perform updates in the store. We first set `localPagesLength` to the length of local pages, but notice we only do the set if the amount changes. This is to avoid unnecessary updates which would make the  screen to be redrawn - and conequently, the UI to flash.

```dart
      if (StoreService.instance.get ('localPagesLength') != pages.length) StoreService.instance.set ('localPagesLength', pages.length);
```

We iterate the pages, noting both the page itself and its index. We then update `localPage:INDEX` with the new page.

```dart
      pages.asMap ().forEach ((index, page) {
         StoreService.instance.set ('localPage:' + index.toString (), page);
      });
```

This concludes the updating of the pages in the store.

```dart
      });
```

If this is the first time that `computeLocalPages` is executed, we will set up a listener that determines whether `computeLocalPages` should be executed again.

Notice that we store the listener in the `localPagesListener` key of the store, so by checking whether `localPagesListener` is set, we will know whether this logic has been already executed or not.

```dart
      if (StoreService.instance.get ('localPagesListener') == '') {
         StoreService.instance.set ('localPagesListener', StoreService.instance.listen ([
```

The listener will be matched if there's a change on any of these store keys:

- `currentlyTaggingPivs`: the list of local pivs currently being tagged.
- `displayMode`: whether to show all local pivs or just the unorganized ones.
- All of the `pivMap` entries, which map a local piv to a cloud piv and which, together with `orgMap`, determines whether the local piv is organized or not.
- All of the `orgMap` entries, which together with `pivMap`, determines whether the local piv is organized or not.

```dart
            'currentlyTaggingPivs',
            'displayMode',
            'pivMap:*',
            'orgMap:*',
         ], (v1, v2, v3, v4) {
```

The listener function, when matched, merely sets `recomputeLocalPages` to `true`, to indicate that we need to calculate the local pages again.

```dart
            recomputeLocalPages = true;
         }));
```

Secondly, we set a timer that executes every 200ms. If `recomputeLocalPages` is set to `true`, then it will execute `computeLocalPages`.

Why did we do this instead of calling `computeLocalPages` in the listener we defined above? For the following reason: `pivMap` and `orgMap` entries can be updated tens or even hundreds of times per second, depending on the loading patterns. Therefore it is prohibitively expensive to compute the local pages on every single change. By having a timer that executes periodically, we limit the frequency of recomputation to an acceptable value.

```dart
         Timer.periodic (Duration (milliseconds: 200), (timer) {
            if (recomputeLocalPages == true) computeLocalPages ();
         });
```

This concludes the initialization logic and the function itself.

```dart
      }
   }
```

We now define `deleteLocalPivs`, the function that will delete local pivs from the phone. It takes a single argument, `ids`, which is an array of the ids of the asssets to be deleted.

```dart
   deleteLocalPivs (ids) async {
```

We first start by iterating our `uploadQueue`, since it's *essential* that we do not delete pivs that are in the upload queue. If we didn't do this, users may well tag a piv, consider it uploaded (even if it's not) and then delete it, which would mean that the user would lose the file forever!

```dart
      uploadQueue.forEach ((queuedPiv) {
```

If a piv in the queue is not included in `ids`, we don't care about it.


```dart
         if (! ids.contains (queuedPiv.id)) return;
```

If we are here, this piv in the queue should also be deleted. If this is the case, we will set a key `pendingDeletion:ID`, which will mark it for deletion once it is uploaded. Note we set this key in the disk.

```dart
         StoreService.instance.set ('pendingDeletion:' + queuedPiv.id, true, 'disk');
```

We will also remove this id from `ids`, since we don't want to delete it now.

```dart
         ids.remove (queuedPiv.id);
      });
```

If there are no pivs that we want to delete now, there's nothing else to do.

```dart
      if (ids.length == 0) return;
```

We now delete the pivs from the phone, using a method from PhotoManager.

```dart
      List<String> typedIds = ids.cast<String>();
      await PhotoManager.editor.deleteWithIds (typedIds);
```

We now remove the pivs from `localPivs`. While we could invoke `loadLocalPivs`, that could take many seconds in a phone with thousands of pivs, so we instead remove them quickly from `localPivs`.

We start by creating a list of the indexes of the deleted pivs.

```dart
      var indexesToDelete = [];
```

We iterate `localPivs` to find the indexes of the deleted pivs, and add them to `indexesToDelete`.

```dart
      for (int k = 0; k < localPivs.length; k++) {
         if (ids.contains (localPivs [k].id)) indexesToDelete.add (k);
      }
```

We reverse `indexesToDelete` - this is because if we remove the first deleted pivs from `localPivs`, then all the indexes of the pivs to delete would have to be shifted! But if we delete the pivs in reverse order, deleting a piv will not affect the indexes of the other pivs that should be deleted.

```dart
      indexesToDelete.reversed.forEach ((k) {
```

For each index, we delete its corresponding piv from `localPivs`.

```dart
         localPivs.removeAt (k);
      });
```

We finally set `recomputeLocalPages` to `true`, to indicate that we need to recompute them and update the local view.

```dart
      recomputeLocalPages = true;
```

This concludes the function.

```dart
  }
```

This concludes the `PivService` class.

```dart
}
```

### `services/tagService.dart`

We now define `tagPiv`, the function that is in charge of handling the logic for tagging or untagging a piv, whether the piv is local or cloud.

The function takes three arguments:
- A `piv`, which can be either a local piv or a cloud piv.
- A `tag`, which is the tag to add (tag) or remove (untag) from the piv.
- The `type` of piv, either `uploaded` (for cloud pivs) or `local` (for local pivs).

```dart
   tagPiv (dynamic piv, String tag, String type) async {
```

We first define two local variables, a `pivId` that will hold the id of the piv to be tagged; as well as a `cloudId`, which will be equal to `pivId` for a cloud piv, and which will be the cloud id of the cloud counterpart for a local id (if any).

```dart
      var pivId   = type == 'uploaded' ? piv ['id'] : piv.id;
      var cloudId = type == 'uploaded' ? pivId      : StoreService.instance.get ('pivMap:' + pivId);
```

We determine whether we are tagging or untagging the piv by reading `tagMap:ID`. If it's set to an empty string, this will be a tag operation; otherwise, it will be an untag operation.

```dart
      var untag = StoreService.instance.get ('tagMap:' + pivId) != '';
```

If this is an untag operation, we will set `tagMap:ID` to `''`, otherwise we will set it to `true`. Besides holding state for us, doing this also allows us to immediately show the piv as tagged or untagged, before the operation is sent to the server.

```dart
      StoreService.instance.set ('tagMap:' + pivId, untag ? '' : true);
```

We either increment (for tagging) or decrement (for untagging) the `taggedPivCountLocal` (or `taggedPivCountUploaded`) key.

```dart
      StoreService.instance.set ('taggedPivCount' + (type == 'local' ? 'Local' : 'Uploaded'), StoreService.instance.get ('taggedPivCount' + (type == 'local' ? 'Local': 'Uploaded')) + (untag ? -1 : 1));
```

If we are tagging a local piv, we need to add it to `currentlyTaggingPivs`. We first check whether `currentlyTaggingPivs` already exists. If not, we initialize it to an empty list.

```dart
      if (! untag && type == 'local') {
         var currentlyTaggingPivs = StoreService.instance.get ('currentlyTaggingPivs');
         if (currentlyTaggingPivs == '') currentlyTaggingPivs = [];
```

We then the piv id to `currentlyTaggingPivs` and update the key in the store.

```dart
         currentlyTaggingPivs.add (pivId);
         StoreService.instance.set ('currentlyTaggingPivs', currentlyTaggingPivs);
      }
```

We invoke `updateLastNTags`, a function that will update the list of the last few used tags. We pass `tag` as the sole argument of the invocation.

```dart
      updateLastNTags (tag);
```

If `cloudId` is neither an empty string nor `true`, then we are dealing either with a cloud piv or with a local piv that has a cloud counterpart. We deal with this case.

Note: `cloudId` can be `true` for local pivs that are currently in the upload queue and haven't been uploaded yet.

```dart
      if (cloudId != '' && cloudId != true) {
```

We invoke the `tagPivById` function, passing the `cloudId`, the `tag` itself and the `untag` flag. This function will be the one making the call to the server. We store the code returned by the call in a variable `code`.

```dart
         var code = await tagPivById (cloudId, tag, untag);
```

If we are tagging a local piv, we can expect either a 200 (success) or a 404. The latter will happen if the cloud counterpart of the local piv we are tagging was removed from another tagaway client (for example, a web browser).

If we are tagging a cloud piv, a 404 is considerably more unlikely, because the piv had to be queried recently in order to be shown now to the user - otherwise, the user could not initiate its tagging. Unless the user is concurrently using two tagaway clients (and deleting uploaded pivs on one of them), this should not happen. For all of this, we only expect a 200 for tagging/untagging cloud pivs.

```dart
         var unexpectedError = type == 'local' ? (code != 200 && code != 404) : code != 200;
```

If there was an unexpected error, we invoke the `showSnackbar` function with an error message indicating the error code. The error code will be `TAG:L:CODE` (for local pivs) and `TAG:C:CODE` for cloud pivs.

```dart
         if (unexpectedError) {
            return showSnackbar ('There was an error tagging your piv - CODE TAG:' + (type == 'local' ? 'L' : 'C') + code.toString (), 'yellow');
         }
```

If the tag/untag operation was successful, there's nothing else to do.

```dart
         if (code == 200) return;
```

If we are here, it's because we attempted to tag a local piv that had a cloud counterpart in the past, but is now deleted. What we'll do is remove the linkage between this local piv and its deleted cloud counterpart, and fall through to the remaining logic of the function, which will upload this local piv.

We remove the `pivMap` and `rpivMap` entries for this local piv and its deleted cloud counterpart.

```dart
            StoreService.instance.remove ('pivMap:'  + pivId);
            StoreService.instance.remove ('rpivMap:' + cloudId);
         }
```

We fall through to the logic that will upload the piv, by closing the conditional and not returning from the function.

```dart
      }
```

Before uploading the local piv, we will store this tag (or remove this tag) from a list that holds all the tags that should be applied to a local piv *once* it is uploaded.

We get the key `pending:ID`; if it's an empty string, we initialize it to an array.

```dart
      var pendingTags = StoreService.instance.get ('pending:' + pivId);
      if (pendingTags == '') pendingTags = [];
```

If we are tagging, we add the tag to `pendingTags`; if we are untagging, we remove the tag from it.

```dart
      untag ? pendingTags.remove (tag) : pendingTags.add (tag);
```

If `pendingTags` has one or more tags in it, we store it in the store. Note we use the `'disk'` parameter since we want this data to persist even if the app is restarted. If the list has no tags, we directly remove the key from the store.

```dart
      if (pendingTags.length > 0) StoreService.instance.set    ('pendingTags:' + pivId, pendingTags, 'disk');
      else                        StoreService.instance.remove ('pendingTags:' + pivId, 'disk');
```

If we are tagging the piv, all we have left to do is call the `queuePiv` function of the `PivService`.

```dart
      if (! untag) return PivService.instance.queuePiv (piv);
```

Now for an interesting bit of logic. If we are untagging a local piv that hasn't been uploaded yet, and we happen to have removed the last tag in `pendingTags`, there should be no need to actually upload the piv at all! If the piv has been completely untagged before being uploaded, uploading it serves no purpose.

```dart
      if (pendingTags.length == 0) {
```

We first unset `pivMap:ID`, which was temporarily set to `true` when the piv was queued by a previous tagging operation.

```dart
         StoreService.instance.remove ('pivMap:' + pivId);
```

We will now find index of this piv in the `uploadQueue` of the PivService. Note we use `asMap` to be able to iterate the list and still get both its index and the piv itself at the same time.

```dart
         var uploadQueueIndex;
         PivService.instance.uploadQueue.asMap ().forEach ((index, queuedPiv) {
```

If the id of the queued piv is equal to `pivId`, we've found the piv, so we set `uploadQueueIndex`.

```dart
            if (queuedPiv.id == pivId) uploadQueueIndex = index;
         });
```

If the piv is in the upload queue, we it from the upload queue. We check whether `uploadQueueIndex` is `null`, because it may be the case that the piv in question is currently being uploaded, in which case it will no longer be in the queue.

```dart
         if (uploadQueueIndex != null) {
            PivService.instance.uploadQueue.removeAt (uploadQueueIndex);
         }
```

This concludes the function.

```dart
      }
   }
```

TODO: add annotated source code between `tagPiv` and `queryPivs`.

We now define `queryPivs`, the function that will query pivs and their associated tags from the server.

This function takes three functions:
- `tags`: a list of tags.
- `refresh`: an optional flag, by default set to `false`, which indicates whether we should query the server with the same query we did on the last query.
- `currentMonth`: an optional parameter of the form `[year, month]`, which indicates that the query should get only the pivs for a given month - by default it is set to `false`, which means that only the pivs for the last month will be retrieved.

In general, this information will get the tags and total amount for all the pivs in the query, but only get the pivs for one month at a time; this is because we only show pivs one month a time.

```dart
   queryPivs (dynamic tags, [refresh = false, currentMonth = false]) async {
```

We sort the received the tags, because we'll need to compare them to the tags of a previous query; since the order of the tags doesn't affect the result of the query, we need to compare sorted list of tags to determine if the two lists are the same or not.

```dart
      tags.sort ();
```

We will determine now whether we can avoid querying the server at all. To avoid querying the server at all, five things need to happen at the same time!

1. `queryResult`, the result of the last query, is not an empty string. If it is an empty string, we haven't yet performed the first query, so we definitely need to query the server.
2. `refresh` is `false`, so we do not need to refresh the query.
3. `currentMonth` is `false`; when it is not `false`, that means that the user wants to see the pivs of another month, therefore in that case we'd have to query the server again.
4. `tags` is the same as `queryTags`.

If all four conditions are true simultaneously, we will `return` since there's nothing else to do.

In practice, this only happens when switching between the query selector view and the cloud view, where the query is already done but the view doesn't know whether the existing query is fresh.

```dart
      if (StoreService.instance.get ('queryResult') != '' && refresh == false && currentMonth == false && listEquals (tags, queryTags)) return;
```

We update `queryTags` with a copy of `tags`.

```dart
      queryTags = List.from (tags);
```

We query `POST /query`, passing the `tags`; note we only get a single piv, since we don't want the list of pivs yet. Note also we pass the `timeHeader` field set to `true`, since we want the time header.

This query, the first we do, will give us the total amount of pivs, their associated tags, and the time header. Everything, except for the pivs themselves.

```dart
      var response = await ajax ('post', 'query', {
         'tags': tags,
         'sort': 'newest',
         'from': 1,
         'to': 1,
         'timeHeader': true
      });
```

If we didn't get back a 200 code, we have encountered an error. If we experienced a 403, there's another error message already shown by the `ajax` function informing the user that their session has expired; if the error, however, is not a 403, we inform the user with an error code `QUERY:A:CODE`.

```dart
      if (response ['code'] != 200) {
         if (response ['code'] != 403) showSnackbar ('There was an error getting your pivs - CODE QUERY:A:' + response ['code'].toString (), 'yellow');
```

Whatever the error is, we cannot continue the function, so we return.

```dart
         return;
      }
```

If the tags in the query changed in the meantime, don't do anything else, since there will be another instance of queryPivs being executed concurrently that will be in charge of updating `queryResult`.

This check is why we copied `tags` before setting it to `queryTags`, and why we hold `queryTags` as part of the class. Tagaway is very interactive and the queries can take over half a second, so it's perfectly possible for the user to trigger a new query before the results of the old query are available.

```dart
      if (! listEquals (queryTags, tags)) return;
```
