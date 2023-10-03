# Tagaway Mobile

## TODO


- Write a QA script (Tom)
- Share Tagaway button and link (Tom)
- Draggable selection
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
   - Add cloud icon for pivs in cloud that are being uploaded (Tom)
   - Add icon
- Finish annotated source code.
-----
- Tutorial (Tom)
- Add login flow with Google, Apple and Facebook (Tom)

## Store structure

```
- account: {username: STRING, email: STRING, type: STRING, created: INTEGER, usage: {limit: INTEGER, byfs: INTEGER, bys3: INTEGER}, geo: true|UNDEFINED, geoInProgress: true|UNDEFINED, suggestGeotagging: true|UNDEFINED, suggestSelection: true|UNDEFINED}
- camearPiv:ID <bool>: if `true`, the local piv with this id is in the camera.
- context: a reference to the context of a Flutter widget, which comes useful for services that want to draw widgets into views.
- cookie <str> [DISK]: cookie of current session, brought from server - deleted on logout.
- csrf <str> [DISK]: csrf token of current session, brought from server - deleted on logout.
- currentMonth `[<int (year)>, <int (month)>]`: if set, indicates the current month of the uploaded view.
- currentlyTaggingPivs <list>: list of *local* piv ids currently being tagged, to avoid hiding them before the operation is complete.
- currentlyTagging(Local|Uploaded) <str>: tag currently being tagged in LocalView/UploadedView
- currentlyDeleting(Local|Uploaded) <bool>: if set, we are in delete mode in LocalView/UploadedView
- currentlyDeletingModal(Local|Uploaded) <bool>: if set, we are showing the delete confirmation modal for Local/Uploaded view.
- currentlyDeletingPivs(Local|Uploaded) <list>: list of pivs that are currently being deleted, either Local or Uploaded.
- displayMode <obj>: if set, has the form `{hideOrganized: BOOLEAN, cameraOnly: BOOLEAN}`. `hideOrganized` hides organized pivs from the local view; `cameraOnly` hides non-camera pivs from the local view.
- deleteTag(Local|Uploaded) <str>: tag currently being deleted in LocalView/UploadedView
- gridControllerUploaded <scroll controller>: controller that drives the scroll of the uploaded grid
- hashMap:<id> [DISK]: maps the id of a local piv to a hash.
- hometags [<str>, ...]: list of hometags, brought from the server
- initialScrollableSize <float>: the percentage of the screen height that the unexpanded scrollable sheets should take.
- lastNTags [<str>, ...] [DISK]: list of the last N tags used to tag or untag, either on local or uploaded - deleted on logout.
- localPage:INT `{name: STRING: pivs: [<asset>, ...], total: INTEGER, from: INTEGER, to: INTEGER}` - contains all the pages of local pivs to be shown, one per grid.
- localPagesLength <int>: number of local pages.
- localPagesListener <listener>: listener that triggers the function to compute the local pages.
- localYear <str>: displayed year in LocalView time header
- orgMap:<pivId> (bool): if set, it means that this uploaded piv is organized
- pendingDeletion:<assetId> <true|undefined> [DISK]: if set, the piv must be deleted after it being uploaded - deleted on logout.
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
- viewIndex <int>: 0 if on HomeView, 1 if on LocalView, 2 if on ShareView
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

## QA Script
- Environment for QA must be DEV
- Make sure device has been logged out before start.
- Open app
- Insert log in credentials.
- If permissions have been granted on previous sessions, the app should open in the 'Home' view'
- If it's the first time the app is run on device, the 'allow permissions' screen should show.
  - Tap on 'allow' if on Android and 'allow all photos' if iOS
- The app should open in the 'Home' view.
- If user has hometags, they should show.
- If user has no hometags and haven't tagged a single pic before, the 'Your tags’ shortcuts will be here. Start tagging and get your first shortcut!' should show
- If user has no hometags, but has tagged pics, 'Start adding your shortcuts!' should appear.
- If user has hometags, tap on a hometag. it should go to the 'cloud view', and that particular tag should be showing.
- If user has no hometags and no tags, then go to 'Phone', tap on 'start' > tag icon, and create a tag.
- Tag Phone pivs
- As you tag, pivs should change their color from grey to green.
- Once you tap 'Done' the piv should disappear from grid and the amount of pivs being uploaded should show on bottom left of the screen (from 'Phone' to 'Home').
- 


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

If we receive anything other than a 200, we report the error in the snackbar and return. The error code will be `UGROUP:CODE`. We then return `false` to indicate an error. Note however that we don't report the error if we get a 0 code (no connection) or a 403 (unauthorized), since an error message will be shown by the `ajax` function, defined elsewhere.

```dart
      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error uploading your piv - CODE UGROUP:' + response ['code'].toString (), 'yellow');
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

We invoke `clearFile` (defined in `tools.dart`) passing the `file` as argument, to clear it out from the phone's cache.

```dart
      clearFile (file);
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

We now invoke `tagCloudPiv`, passing to it `pendingTags`, as well as the id of the cloud id.

We will only print an error if the error is neither a code 0 (no connection) or a 403 (invalid session).

```dart
         var code = await TagService.instance.tagCloudPiv (response ['body'] ['id'], pendingTags, false);
         if (! [0, 200, 403].contains (code)) showSnackbar ('There was an error tagging your piv - CODE TAG:L:' + code.toString (), 'yellow');
```

If we experienced an error, we return the error code.

```dart
         if (code != 200) return {'code': code};
```

This concludes the logic for tagging the uploaded piv.

```dart
      }
```

We remove the `pendingTags` key. Note we do this on disk as well, since that key needs to persist if the app is restarted. A drawback of not awaiting for the results of each tagging operation is that if there are any errors in the tagging, the pending tags will be lost.

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

Before we pick up the first piv from the queue, we will sort the queue to put the smallest pivs first. The objective is to upload pivs as quickly as possible, which is what is most useful from an organization perspective. It also gives the user a sense of progress.

Getting the size of the piv is not as easy as it may seem; if we want to get the bytes, we need to call the OS which takes time. Instead, we are going to make use of the fact that most local pivs are already hashed. The second part of the hash is the size of the pivs in bytes.

```dart
      uploadQueue.sort ((a, b) {
         var sizeA = StoreService.instance.get ('hashMap:' + a.id);
         var sizeB = StoreService.instance.get ('hashMap:' + b.id);
```

If a piv has no hash cmoputed, we set its size (for the purposes of hashing) to a large number (1GB). Otherwise, we get the size from the second part of the hash.

```dart
         sizeA = sizeA == '' ? 1000 * 1000 * 1000 : int.parse (sizeA.split (':') [1]);
         sizeB = sizeB == '' ? 1000 * 1000 * 1000 : int.parse (sizeB.split (':') [1]);
```

We sort the upload queue to contain the smallest pivs first.

```dart
         return sizeA.compareTo (sizeB);
      });
```

Now that we sorted `uploadQueue`, we pick up the next piv from the queue.

```dart
      var nextPiv = uploadQueue [0];
```

We upload the piv through `uploadPiv` and await for the result.

```dart
      var result = await uploadPiv (nextPiv);
```

If we got an error code 0, we have no connection. If we got a 403, it is almost certainly because our session has expired. This can happen when reopening the app after a few days, after leaving it with pivs in the queue. When the app is revived, the upload will be attempted and it will fail. In the case of a 403, an error message will be shown by our `ajaxMulti` function, which is defined elsewhere. And if there's no connection, the user will be redirected to an `offline` view. We will not do anything else, leaving the piv in the queue.

```dart
      if ([0, 403].contains (result ['code'])) return;
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

We now define `loadAndroidCameraPivs`, a function that will detect which pivs are camera pivs. This function is only for Android.

```dart
   loadAndroidCameraPivs () async {
```

If we're in iOS, there's nothing to do, so we return.

```dart
      if (Platform.isIOS) return;
```

We start by loading the albums.

```dart
      var albums = await PhotoManager.getAssetPathList(
        onlyAll: false,
      );
```

We then attempt to get an album whose name contains either `camera` or `dcim`.

```dart
      var cameraRoll;
      try {
         cameraRoll = albums.firstWhere(
            (element) => element.name.toLowerCase ().contains ('camera') || element.name.toLowerCase ().contains ('dcim'),
         );
      }
```

If we can't find one, we return.

```dart
      catch (error) {
         return;
      }
```

We will now load the pivs from the camera in groups of 50.

```dart
      int start = 0;
      int count = 50;
```

We will do this inside a `while` loop that we will `break` when we're done.

```dart
      while (true) {
```

We load the next 50 pivs.

```dart
        var assets = await cameraRoll.getAssetListPaged (page: start, size: count);
```

If we got no pivs, we end the loop.

```dart
        if (assets.isEmpty) break;
```

For each of the loaded pivs, we set the entry `cameraPiv:ID` to `true`. This is the way in which this function will indicate to the rest of the app that this is a camera piv.

```dart
        for (var piv in assets) {
           StoreService.instance.set ('cameraPiv:' + piv.id, true);
        }
```

We increment `start` by 50. We then close the loop and the function.

```dart
        start += count;
      }
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
- Set the `cameraPiv:ID` entries for pivs that belong to the camera roll.
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

Note: because this function is called by `distributorView`, and because `distributorView` awaits for the store service to finish loading up the store from disk, we can safely assume that the store service is fully loaded and we can set and get synchronously.

```dart
      for (var piv in localPivs) {
         StoreService.instance.set ('pivDate:' + piv.id, piv.createDateTime.millisecondsSinceEpoch);
```

If we are in iOS, we will also try to determine whether this piv is in the camera. iOS has no way to query this directly, so we do an approximation by getting the piv's MIME type and see if it is a HEIC or a MOV. If it is, we consider it a camera piv and therefore set `cameraPiv:ID`.

```dart
         if (Platform.isIOS) {
            var mime = await piv.mimeTypeAsync;
            if (['image/heic', 'video/quicktime'].contains (mime)) StoreService.instance.set ('cameraPiv:' + piv.id, true);
         }
```

This concludes the iteration of the pivs.

```dart
      }
```

If we are in the first call to the function, we will invoke `loadAndroidCameraPivs` -- this is how we will identify camera pivs in Android. Note we do not `await` for this function, since we want to proceed with loading as fast as possible.

```dart
      if (initialLoad) loadAndroidCameraPivs ();
```

We invoke `queryExistingHashes`, to map the hashed local pivs to cloud pivs. If this is a recursive call to `loadLocalPivs`, or we got all the pivs that we need, we will pass a `true` first argument, to clear out stale hash entries. If, however, not all the local pivs have been loaded yet, we cannot clear out stale hash entries, so we pass `false` to `queryExistingHashes` instead.

```dart
      await queryExistingHashes (! initialLoad || localPivs.length < firstLoadSize);
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

We now define `queryOrganizedLocalPivs`, the function that will check whether the cloud counterparts of our local pivs (for those local pivs that have them) are organized.

```dart
   queryOrganizedLocalPivs () async {
```

We define a list `cloudIds` with all the ids of cloud pivs that we want to check.

```dart
      var cloudIds = [];
```

We iterate the local pivs.

```dart
      for (var piv in localPivs) {
```

We get the `pivMap:ID` entry, which can contain the id of the cloud counterpart of this local piv.

```dart
         var cloudId = StoreService.instance.get ('pivMap:' + piv.id);
```

If the entry is empty, or it is set to `true`, we ignore it. Otherwise, we add it to `cloudIds`.

Note: the entry will be `true` if the piv is currently being uploaded - as we saw above, this is done by `queuePiv`.

```dart
         if (cloudId != '' && cloudId != true) cloudIds.add (cloudId);
      }
```

We will invoke `queryOrganizedIds`, a function that belongs to `TagService`, passing `cloudIds` as an argument. This concludes the function.

```dart
      await TagService.instance.queryOrganizedIds (cloudIds);
   }
```

We now define `reviveUploads`, the function that restores the upload queue from disk and sets in motion the uploading of the queued pivs.

```dart
   reviveUploads () async {
```

We get the dry upload queue which will be in the `uploadQueue` key. If there's no entry at all, or if the entry returns an empty list, we don't do anything else.

```dart
      var queue = StoreService.instance.get ('uploadQueue');

      if (queue == '' || queue.length == 0) return;
```

We iterate the local pivs and for each of them whose id is in the queue, we add them to `uploadQueue`. Note that this works because in the dry upload queue (the one stored at the `uploadQueue` key), we only store ids.

Note also that this will not restore the upload queue in the same order than the dry upload queue had them. The reason is purely practical: if we don't care about the order, we can simply add the queued pivs in the order they appear in `localPivs`. If we had to do it in the original order, we'd have to create a dictionary mapping each id of a local piv to an index, and then add the local pivs to the queue using those indexes.

```dart
      localPivs.forEach ((v) {
         if (queue.contains (v.id)) uploadQueue.add (v);
      });
```

Once we have put all the pivs in the `uploadQueue`, we invoke `queuePiv` with `null` (to indicate that the next piv in the queue can be uploaded) and close the function.

Note we do not `await` for `queuePiv`, since we want this function to start the uploads, not wait for them.

```dart
      queuePiv (null);
   }
```

We now define `queryHashes`, a function that will take a list of hashes and check against the server which of those hashes belong to a cloud piv.

Actually, `hashesToQuery` will not be a list, but an object (or map, if we use the Dart term) where the values are hashes.

```dart
   queryHashes (dynamic hashesToQuery) async {
```

We invoke `POST /idsFromHashes`, passing the values in the map as a list, in the key `hashes`.

```dart
      var response = await ajax ('post', 'idsFromHashes', {'hashes': hashesToQuery.values.toList ()});
```

If we didn't obtain a 200, we will return `false`. If the error was neither a 0 nor a 403, we will show an error with code `HASHES:CODE`. If this was a 0, the user will be redirected to an `offline` view. If this was a 403, `ajax` will already have shown a snackbar with a generic error.

```dart
      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error getting data from the server - CODE HASHES:' + response ['code'].toString (), 'yellow');
         return false;
      }
```

If we're here, the request was successful. We will now build an output object/map.

```dart
      var output = {};
```

We will iterate `hashesToQuery`. This object, which we received as the sole parameter to the function, has the ids of local pivs as its keys, and their corresponding hashes as values.

What we will do here is construct `output` in a way where the keys of output - like those of `hashesToQuery` also are the ids of local pivs, but its values - unlike those of `hashesToQuery` are the ids of cloud pivs. This information is what we wanted in the first place. In effect, this allows us to map a given local piv to a cloud piv through their hash, which is the same in the client and the server.

```dart
      hashesToQuery.forEach ((localId, hash) {
         output [localId] = response ['body'] [hash];
      });
```

We return `output` and close the function.

```dart
      return output;
   }
```

We now define `queryExistingHashes`, a function that will get, for each of the hashes of the local pivs, their cloud counterparts.

This function takes an optional argument, `cleanupStaleHashes`, that if passed as `true` will clear up old `hashMap` entries. This argument will default to `false`.

```dart
   queryExistingHashes ([cleanupStaleHashes = false]) async {
```

We first construct an object/map where each key is the id of a local piv. The value is set to `true` as a mere placeholder. We only set the keys in `localPivVids` if `cleanupStaleHashes` is `true` - otherwise we don't need it.

```dart
      var localPivIds = {};
      if (cleanupStaleHashes) {
         localPivs.forEach ((v) {
            localPivIds [v.id] = true;
         });
      }
```

We will create another object/map where each key is the id of a local piv that has a hash already computed.

```dart
      var hashesToQuery = {};
```

We are now going to iterate the existing `hashMap` entries, to see which entries exist.

```dart
      for (var k in StoreService.instance.store.keys.toList ()) {
```

If this entry is not a hashMap, we ignore it.

```dart
         if (! RegExp ('^hashMap:').hasMatch (k)) continue;
```

We extract the piv id from `hashMap:ID`.

```dart
         var id = k.replaceAll ('hashMap:', '');
```

If there is a local piv with this id, we will set the key `id` of `hashesToQuery` to the value of the hash of this piv.

```dart
         if (localPivIds [id] != null) hashesToQuery [id] = StoreService.instance.get (k);
```

If there is no local piv with this id, and `cleanupStaleHashes` is `true`, we will remove this hashMap entry. This is useful for clear up hashMap entries for pivs that were deleted. Note that the key is removed from disk. Note also that we don't `await` for this operation, since we want to keep on going as fast as possible in order to get the info from the server, which is necessary to do the first draw of the local view.

```dart
         else if (cleanupStaleHashes) StoreService.instance.remove (k, 'disk');
      }
```

We query the hashes using `queryHashes`.

```dart
      var queriedHashes = await queryHashes (hashesToQuery);
```

If we got a `false`, it may be that we don't have a valid session, or there was another error. In any case, the error will already have been reported already. We cannot do anything else, so we return.


```dart
      if (queriedHashes == false) return;
```

We iterate the queried hashes. Each of them will connect the id of a local piv with the id of a cloud piv. If there's no cloud piv, instead of the id of a cloud piv there will be a `null`.

```dart
      queriedHashes.forEach ((localId, uploadedId) {
```

If there is a cloud piv that matches this piv, we set the `pivMap:ID` and `rpivMap:ID` for this pair of pivs. `pivMap` points from a local id to a cloud id, whereas `rpivMap` (the `r` stands for `reverse`) points from a cloud id to a local id.

```dart
         StoreService.instance.set ('pivMap:'  + localId,    uploadedId);
         StoreService.instance.set ('rpivMap:' + uploadedId, localId);
      });
```

Otherwise, we will check whether we have a `pivMap:ID` entry. If we do, we remove the stale entries for `pivMap:ID` and `rpivMap:ID`.

```dart
         else {
            var oldUploadedId = StoreService.instance.get ('pivMap:' + localId);
            if (oldUploadedId != '') {
               StoreService.instance.remove ('pivMap:'  + localId);
               StoreService.instance.remove ('rpivMap:' + oldUploadedId);
            }
         }
```

Note: we do the removal of stale entries *only* because this function is used by another function that deletes local pivs that have been already uploaded. Because of how sensitive is the deletion of local pivs, we want to make sure that any piv that doesn't exist in the server should not be deleted. By removing stale `pivMap` entries, this function avoids the deletion of pivs that are no longer in the server.

This will only be useful if the user has deleted a piv already uploaded *after* they opened the app, and only if they do this deletion from another tagaway client (whether mobile or web). So this is quite the corner case.

There's nothing else to do, so we close the function.

```dart
   }
```

We now define `computeHashes`, the function that will set in motion the hashing of local pivs.

```dart
   computeHashes () async {
```

We iterate the local pivs.

```dart
      for (var piv in localPivs) {
```

If there's no hashMap entry for the piv, we move on to the next piv.

```dart
         if (StoreService.instance.get ('hashMap:' + piv.id) != '') continue;
```

We invoke `hashPiv`, another function that performs the hashing for us and that is defined in `tools.dart`. Note that instead of executing this function directly, we do it through `flutterCompute`. This function, provided by the Flutter Isolate library, allows us to run this function in an isolate.

By running this function in an isolate, we avoid blocking our main thread and can effectively hash pivs in the background.

A side-effect of this is that when running the app in debug mode, each call to `flutterCompute` will trigger a general redraw. This will not happen in release mode.

```dart
         var hash = await flutterCompute (hashPiv, piv.id);
```

We set the `hashMap:ID` entry to the hash we just obtained. Note we do this in disk.

```dart
         StoreService.instance.set ('hashMap:' + piv.id, hash, 'disk');
```

We now check if the local piv we just hashed as an uploaded counterpart, by invoking `queryHashes`.

```dart
         var queriedHash = await queryHashes ({piv.id: hash});
```

If we got a `false`, it may be that we don't have a valid session, we are offline, or there was another error. In any case, the error will already have been reported already. We will stop the hashing process altogether until the user has again the app in a normal state. When the user logs back in (or their connection comes back), the hashing process will start again through `loadLocalPivs`.

```dart
         if (queriedHash == false) break;
```

If this local piv has a cloud counterpart, we will set the `pivMap` and `rpivMap` entries for it.

```dart
         if (queriedHash [piv.id] != null) {
            StoreService.instance.set ('pivMap:'  + piv.id,               queriedHash [piv.id]);
            StoreService.instance.set ('rpivMap:' + queriedHash [piv.id], piv.id);
```

We will also invoke `queryOrganizedIds`, so that if this piv is organized, we will know it. Note we don't `await` for this since this update can happen in the background - we want to keep on hashing pivs as fast as possible.

```dart
            TagService.instance.queryOrganizedIds ([queriedHash [piv.id]]);
         }
```

We close the loop and the function.

```dart
      }
   }
```

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
      DateTime tomorrow        = DateTime.fromMillisecondsSinceEpoch (DateTime.now ().millisecondsSinceEpoch + 24 * 60 * 60 * 1000);
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

We get the `displayMode` from the store, which can be either an empty string or an object of the form `{hideOrganized: BOOLEAN, cameraOnly: BOOLEAN}`. If it is an empty string, we initialize it to the object, setting `hideOrganized` as `true` and `cameraOnly` as `false`.

```dart
      var displayMode = StoreService.instance.get ('displayMode');
      if (displayMode == '') displayMode = {'hideOrganized': true, 'cameraOnly': false};
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

We determine whether the piv should be shown and store the result in `showPiv`. The piv should be shown if it is currently being tagged. If it's not currently being tagged, it will be shown if two conditions are fulfilled simultaneously:
- `displayMode.hideOrganized` is `false` or the piv is not organized.
- `displayMode.cameraOnly` is `false` or the piv is a camera piv.

```dart
         var showPiv = pivIsCurrentlyBeingTagged || ((displayMode ['hideOrganized'] == false || ! pivIsOrganized) && (displayMode ['cameraOnly'] == false || StoreService.instance.get ('cameraPiv:' + piv.id) == true));
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

We are now done constructing `pages` and are ready to perform updates in the store. We first set `localPagesLength` to the length of local pages.

```dart
      StoreService.instance.set ('localPagesLength', pages.length);
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

Notice that we store the listener in the `localPagesListener` key of the store, so by checking whether `localPagesListener` is set, we will know whether this logic has been already executed once or not.

```dart
      if (StoreService.instance.get ('localPagesListener') == '') {
         StoreService.instance.set ('localPagesListener', StoreService.instance.listen ([
```

The listener will be matched if there's a change on any of these store keys:

- All of the `cameraPiv` entries, which indicate which pivs belong to the camera roll.
- `currentlyTaggingPivs`: the list of local pivs currently being tagged.
- `displayMode`: whether to show all local pivs or just the unorganized ones.
- All of the `pivMap` entries, which map a local piv to a cloud piv and which, together with `orgMap`, determines whether the local piv is organized or not.
- All of the `orgMap` entries, which together with `pivMap`, determines whether the local piv is organized or not.

```dart
            'cameraPiv:*',
            'currentlyTaggingPivs',
            'displayMode',
            'pivMap:*',
            'orgMap:*',
         ], (v1, v2, v3, v4, v5) {
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

The function also takes an optional argument, `reportBytes`, which if present will be a number of bytes liberated by a successful deletion, which will be printed in a snackbar.

```dart
   deleteLocalPivs (ids, [reportBytes = null]) async {
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
      List<String> typedIds = ids.cast<String> ();
      await PhotoManager.editor.deleteWithIds (typedIds);
```

We now reach an interesting point. The user will be shown a dialog from the OS, asking whether they want to delete or not the pivs from the device. It is quite complicated for us to find out when the user will click on one of the options of this dialog, as well as their choice. To avoid this complication, we are going to do a workaround that will let us know what the user decided in the end.

The trick consists on checking, for 60 seconds, whether the first of the pivs in the deleted batch was actually deleted or not. If it is, then we will consider it as deleted, and remove it from `localPivs` (along with the other pivs in the batch). Otherwise, if after 60 seconds the piv is still there, we will assume that the user cancelled the operation.

If the user did indeed take long to click on an option on that dialog, and the user declined to delete the pivs, the UI will be out of sync and will show pivs that were already deleted. For now, we are OK with this solution.

We initialize a `firstPivDeleted` flag set to `false`, as well as a time 60 seconds in the future where we will give up checking.

```dart
      var firstPivDeleted = false, giveUpAt = now () + 1000 * 60;
```

While the user has not deleted the first piv, nor the 60 seconds have elapsed:

```dart
      while (! firstPivDeleted && giveUpAt > now ()) {
```

We will wait 20 milliseconds between checks.

```dart
         await Future.delayed (Duration (milliseconds: 20));
```

If the piv was actually deleted, when attempting to get it by id, we will get a `null`. Therefore, we will set `firstPivDeleted` to whether the piv itself is now `null`. This concludes the loop.

```dart
         var deletedPiv = await AssetEntity.fromId (ids [0]);
         firstPivDeleted = deletedPiv == null;
      }
```

If we're here, either the user deleted the piv, or 60 seconds have elapsed.

If `firstPivDeleted` is still `false`, it means that the 60 seconds have elapsed. We consider that the user has not deleted the piv, so we return, since there's nothing else to do.

```dart
      if (! firstPivDeleted) return;
```

If we're here, the user indeed deleted the first piv of the batch. We now proceed to remove the pivs from `localPivs`. While we could invoke `loadLocalPivs`, that could take many seconds in a phone with thousands of pivs, so we instead remove them quickly from `localPivs`.

We start by creating a list of the indexes of the deleted pivs.

```dart
      var indexesToDelete = [];
```

We iterate `localPivs` to find the indexes of the deleted pivs.

```dart
      for (int k = 0; k < localPivs.length; k++) {
         if (ids.contains (localPivs [k].id)) {
```

If the piv should be deleted, we need to add its index to `indexesToDelete`.

However, we only have the certainty that the *first* piv of the batch was deleted. Because of the 60 second delay, we cannot really know whether the first piv of the batch was deleted together with the other ones in this batch, or if the user cancelled that operation and, before 60 seconds elapsed, also selected a different set of pivs, using the same piv as the first one, and actually deleted those.

For that reason, we need to re-check that the piv does no longer exist. We do this in the same way we did inside the `while` loop above.

```dart
            var existingPiv = await AssetEntity.fromId (localPivs [k].id);
```

If the piv does not exist, we add its index to `indexesToDelete`.

```dart
            if (existingPiv == null) indexesToDelete.add (k);
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

If `reportBytes` was passed to `deleteLocalPivs`, we print a message in the snackbar, using the `reportBytes` value. Note we use `printBytes`, a function defined in `tools.dart`, to format the number.

```dart
      if (reportBytes != null) showSnackbar ('You have freed up ' + printBytes (reportBytes) + ' of space!', 'green');
```

This concludes the function.

```dart
  }
```

We now define `deletePivsByRange`, a function that will be used to liberate space on the phone by potentially deleting local pivs that are already uploaded.

The function takes two arguments, `deletionType` (which can be either `'3m'`, to signify pivs older than 90 days; or `'all'`, to signify all pivs); and an optional argument, `delete`, which will actually perform a deletion rather than just report on what would be deleted. By default, `delete` is set to `false`.

```dart
   deletePivsByRange (String deletionType, [delete = false]) async {
```

We start by invoking `queryExistingHashes`. This is critical if, since the last time that the user loaded the app, some pivs have been deleted from the cloud in another tagaway client (be it mobile or web). By making this call, we make sure to know which local pivs are currently also uploaded to the cloud.

```dart
      await queryExistingHashes ();
```

We create two accumulator variables, one for the total size of the pivs that can be deleted; and a list containing the ids of the pivs we will potentially delete.

```dart
      var totalSize = 0, pivsToDelete = [];
```

We iterate the local pivs.

```dart
      localPivs.forEach ((piv) {
```

If we have a `hashMap` entry for the piv, and we also have a `pivMap` entry for the piv, we are certain that the piv is also in the cloud.

```dart
         var hash = StoreService.instance.get ('hashMap:' + piv.id);
         if (hash == '') return;
         var cloudId = StoreService.instance.get ('pivMap:' + piv.id);
         if (cloudId == '') return;
```

You may ask: isn't it enough to check whether there is a `pivMap` entry? And you'd be right. However, we need to have the hash of the piv in order to know its size without having to check with the OS. So we take the shortcut of ignoring pivs without a `hashMap` entry; in any case, any local pivs uploaded through the app will already have a `hashMap` entry, so this should not exclude any pivs uploaded through the phone. This might only affect users that deleted the app and then reinstalled it, and who are using this functionality before the background process that hashes all pivs (`computeHashes`) is done.

If `deletionType` is `'3m'` and the piv is not older than 90 days, we exclude it.

```dart
         if (deletionType == '3m') {
            var date = piv.createDateTime.millisecondsSinceEpoch;
            var limit = now () - 1000 * 60 * 60 * 24 * 90;
            if (date > limit) return;
         }
```

If we're here, we consider this piv for deletion. We first obtain the size of the piv in bytes from the second part of the hash.

```dart
         var size = int.parse (hash.split (':') [1]);
```

We increment `totalSize` by the size of the piv; we then add the piv's id to `pivsToDelete`. This concludes the loop over local pivs.

```dart
         totalSize += size;
         pivsToDelete.add (piv.id);
      });
```

If `delete` is `false`, we will just return the total size liberated.

```dart
      if (! delete) return totalSize;
```

If there are no pivs to delete, we will print a message in the snackbar.

```dart
      if (pivsToDelete.isEmpty) return showSnackbar ('Alas, there are no pivs to delete that are organized.', 'yellow');
```

If there are pivs to delete, we will invoke `deleteLocalPivs` with `pivsToDelete` and `totalSize` as arguments. `totalSize` is passed as well because the success snackbar can only happen only if the user actually deletes the pivs (and only after they do it), and the logic for detecting this resides in `deleteLocalPivs`.

```dart
      await deleteLocalPivs (pivsToDelete, totalSize);
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

The tagService is concerned with operations concerning tagging and querying. Almost every operation here involves the server.

We start by importing native packages, then libraries, and finally other parts of our app.

```dart
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:tagaway/services/pivService.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tools.dart';
```

We initialize the class `TagService`.

```dart
class TagService {
```

TagService, like the rest of our services, will be initialized as a singleton. That means that the class will only be initialized once, so for practical purposes the class and its instance are the same thing. The class will expose itself through its `instance` property. Other services will be able to use its methods and access its properties through `TagService.instance`.

```dart
   TagService._ ();
   static final TagService instance = TagService._ ();
```

PivService has only properties that hold data: `queryTags`, which will be initialized to an empty string, but will be replaced by a list of tags when a query is done. The reason we keep it here, side by side with another list of tags that we keep in the store (in a key named `queryTags`) is that we want to compare the class property against the value in the store to see if the query changed - in that way, we can save a roundtrip to the server.

```dart
   dynamic queryTags = '';
```

We now define `getTags`, the function that will get the list of tags from the server.

```dart
   getTags () async {
```

We start by simply querying the server at `GET /tags`.

```dart
      var response = await ajax ('get', 'tags');
```

First we will cover the case in which we obtained an error.

If we got an error code 0, we have no connection. If we got a 403, it is almost certainly because our session has expired. In both cases, other parts of the code will print an error message. If, however, the error was neither a 0 nor a 403, we will report it with a code `TAGS:CODE`.

```dart
      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error getting your tags - CODE TAGS:' + response ['code'].toString (), 'yellow');
```

If there was an error, there's nothing else to do, so we return.

```dart
         return;
      }
```

If we're here, the request was successful. We set `hometags` and `tags` in the store. We update `hometags` as well since they also come from this server endpoint.

```dart
      StoreService.instance.set ('hometags', response ['body'] ['hometags']);
      StoreService.instance.set ('tags',     response ['body'] ['tags']);
```

We will take all the tags and filter out those that start with a lowercase letter plus two colons (tags starting with those characters are special tags used by tagaway internally). Essentially, `usertags` will contain all the "normal" tags that a user can use.

We store usertags in a local variable, because we'll use it repeatedly below.

```dart
      var usertags = response ['body'] ['tags'].where ((tag) {
         return ! RegExp ('^[a-z]::').hasMatch (tag);
      }).toList ());
```

We iterate all the `pendingTags` entries to see if there are any usertags in there that are not in the server yet. This might be the case if a user tagged a queued piv with a new tag that is not on the server yet.

```dart
      StoreService.instance.store.keys.toList ().forEach ((k) {
         if (! RegExp ('^pendingTags:').hasMatch (k)) return;
         var pendingTags = StoreService.instance.get (k);
```

For each pending tag, if it is not contained in `usertags`, we add it.

```dart
         if (pendingTags != '') pendingTags.forEach ((tag) {
            if (! usertags.contains (tag)) usertags.add (tag);
         });
      });
```

We sort the usertags so that they are ordered again, in case we added some from `pendingTags`.

```dart
      usertags.sort ();
```

We now set `usertags` in the store.

```dart
      StoreService.instance.set ('usertags', usertags);
```

We will now go through the tags inside the `lastNTags` key and remove those that are not included in `usertags`. The resulting list will be again set to `lastNTags`. Effectively, this gets rid of any stale tags inside `lastNTags`.

Note we store `lastNTags` in disk, because we want the list to persist when the app is closed.

```dart
      StoreService.instance.set ('lastNTags', getList (StoreService.instance.get ('lastNTags')).where ((tag) {
         return usertags.contains (tag);
      }).toList (), 'disk');
```

We close the function.

```dart
   }
```

We now define `editHometags`, the function that will update the list of hometags in the server.

This function takes two arguments, `tag` (the tag to be either added or removed), and `bool`, a flag that indicates whether we are adding or removing the tag from the hometags.

```dart
   editHometags (String tag, bool add) async {
```

We start by updating the current list of tags, in case it was updated from another client.

```dart
      await getTags ();
```

We get a copy of the hometags that are stored at the key `hometags`.

```dart
      var hometags = getList ('hometags');
```

If we want to add the tag to the hometags and it is already there, or we want to remove it from the hometags and it is already not there, then there's nothing else to do! We just return.

```dart
      if ((add && hometags.contains (tag)) || (! add && ! hometags.contains (tag))) return;
```

We invoke `POST /hometags` passing the updated hometags.

```dart
      var response = await ajax ('post', 'hometags', {'hometags': hometags});
```

First we will cover the case in which we obtained an error.

If we got an error code 0, we have no connection. If we got a 403, it is almost certainly because our session has expired. In both cases, other parts of the code will print an error message. If, however, the error was neither a 0 nor a 403, we will report it with a code `HOMETAGS:CODE`.

```dart
      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error updating your hometags - CODE HOMETAGS:' + response ['code'].toString (), 'yellow');
      }
```

If we're here, the operation was successful. We invoke `getTags` again to retrieve the updated hometags, and close the function.

```dart
      await getTags ();
   }
```

We now define `updateLastNTags`, a function that updates the recently usertags used. This function takes a single argument, `tag`.

```dart
   updateLastNTags (tag) {
```

We start by getting a copy of `lastNTags`.

```dart
      var lastNTags = getList ('lastNTags');
```

If the tag is already in `lastNTags`, we remove it. We will then put it at the front of the list. If the tag wasn't in the list, we will put it at the front anyway.

```dart
      if (lastNTags.contains (tag)) lastNTags.remove (tag);
      lastNTags.insert (0, tag);
```

Inspired by old phone numbers, we will remember up to seven tags.

```dart
      var N = 7;
```

If we have more than seven tags, we will remove the last one.

```dart
      if (lastNTags.length > N) lastNTags = lastNTags.sublist (0, N);
```

We update `lastNTags` in the store and close the function.

```dart
      StoreService.instance.set ('lastNTags', lastNTags, 'disk');
   }
```

We now define `tagCloudPiv`, the function that will tag (or untag) a cloud piv.

The function takes three parameters:

- `id`, the id of the cloud piv that we want to tag/untag.
- `tags`, a list of tags.
- `del`, a flag that if `true` indicates that we want to *untag*.

```dart
   tagCloudPiv (String id, dynamic tags, bool del) async {
```

We iterate the tags.

```dart
      for (var tag in tags) {
```

We start by calling the server at `POST /tag`. We pass each of the tags (`tag`), the `id` wrapped in a list, and the `del` flag to indicate whether we're tagging or untagging. We also pass the `autoOrganize` flag set to `true`, since we want the autoorganize behavior, which means that every tagged piv is marked as organized, and if a piv has no tags, then it will be marked as unorganized.

```dart
         var response = await ajax ('post', 'tag', {'tag': tag, 'ids': [id], 'del': del, 'autoOrganize': true});
```

If we don't get a successful response from the server, we return the code. This concludes the iteration of the tags.

```dart
         if (response ['code'] != 200) return response ['code'];
      }
```

We pass a single id to `queryOrganizedIds` because if this cloud piv has a local counterpart, and the cloud piv is not in the current query, we need to know whether it is organized or not.

```dart
      await queryOrganizedIds ([id]);
```

We get the list of hometags. If there are no hometags set yet, and we are tagging a piv, we add the first tag in `tags` to the hometags. This allows us to "seed" the hometags with a first tag.

```dart
      var hometags = StoreService.instance.get ('hometags');
      if (! del && (hometags == '' || hometags.isEmpty)) await editHometags (tags [0], true);
```

We invoke `queryPivs` passing to it the `refresh` flag set to `true`. This flag will tell `queryPivs` to refresh the query if the `queryTags` haven't changed. We will also pass it the `preserveMonth`, so that we don't change the month currently being displayed on the query.

Note we do not await for the operation, since we want the query to happen in the background.

```dart
      queryPivs (true, true);
```

There's nothing else to do but to return the response code of the tagging operations (which was a 200) and close the function.

```dart
      return 200;
   }
```

We now define `tagPiv`, the function that is in charge of handling the logic for tagging or untagging a piv, whether the piv is local or cloud.

The function takes three arguments:
- A `piv`, which can be either a local piv or a cloud piv.
- `tags`, which is a list of tags to add (tag) or remove (untag) from the piv.
- The `type` of piv, either `uploaded` (for cloud pivs) or `local` (for local pivs).

```dart
   tagPiv (dynamic piv, dynamic tags, String type) async {
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

We invoke `updateLastNTags`, a function that will update the list of the last few used tags. We invoke the function with each of the `tags` in turn.

```dart
      tags.forEach ((tag) => updateLastNTags (tag));
```

If `cloudId` is neither an empty string nor `true`, then we are dealing either with a cloud piv or with a local piv that has a cloud counterpart. We deal with this case.

Note: `cloudId` can be `true` for local pivs that are currently in the upload queue and haven't been uploaded yet.

```dart
      if (cloudId != '' && cloudId != true) {
```

We invoke the `tagCloudPiv` function, passing the `cloudId`, the `tags` and the `untag` flag. This function will be the one making the call to the server. We store the code returned by the call in a variable `code`.

```dart
         var code = await tagCloudPiv (cloudId, tags, untag);
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

If we are tagging, we add each of the tags to `pendingTags`; if we are untagging, we remove each of the tags from it.

```dart
      tags.forEach ((tag) => untag ? pendingTags.remove (tag) : pendingTags.add (tag));
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

This function takes two arguments:
- `refresh`: an optional flag, by default set to `false`, which indicates whether we should query the server with the same query we did on the last query.
- `preserveMonth`: an optional flag, by default set to `false`, which indicates whether we should preserve the `currentMonth` of the query.

This function will essentially get two pieces of information:
- The metainformation of the pivs that belong to the query.
- Other info belonging to the query, namely: tags, total amount of pivs, and the data for the time header.

We don't want to bring back all the information at once because 1) that takes significant processing time on the server; 2) it can potentially require a lot of bandwidth for the client; 3) both #1 and #2 will slow down the drawing of the grid. For this reason, this function is particularly written with performance in mind.

```dart
   queryPivs ([refresh = false, preserveMonth = false]) async {
```

We get `queryTags` from the store. If it is not initialized yet, we set the local variable to an empty list.

```dart
      var tags = StoreService.instance.get ('queryTags');
      if (tags == '') tags = [];
```

We sort the received tags, because we'll need to compare them to the tags of a previous query; since the order of the tags doesn't affect the result of the query, we need to compare sorted list of tags to determine if the two lists are the same or not.

```dart
      tags.sort ();
```

We will determine now whether we can avoid querying the server at all. To avoid querying the server at all, three things need to happen at the same time!

1. `queryResult`, the result of the last query, is not an empty string. If it is an empty string, we haven't yet performed the first query, so we definitely need to query the server.
2. `refresh` is `false`, so we are not forded to refresh the query.
4. `tags` is equal to `queryTags`.

If all three conditions are true simultaneously, we will `return` since there's nothing else to do.

In practice, this only happens when switching between the query selector view and the cloud view, where the query is already done but the view doesn't know whether the existing query is fresh.

```dart
      if (StoreService.instance.get ('queryResult') != '' && refresh == false && listEquals (tags, queryTags)) return;
```

If `preserveMonth` is `true`, and `currentMonth` is also set, rather than continuing, we will just invoke `queryPivsForMonth` (a function defined below) passing the current month, and immediately return. This will refresn the query while preserving the current month.

```dart
      var currentMonth = StoreService.instance.get ('currentMonth');
      if (preserveMonth == true && currentMonth != '') return queryPivsForMonth (currentMonth);
```

We update `queryTags` to a copy of `tags`. We want to copy it because if we modify `tags`, those changes will also affect `queryTags`, and then we won't be able to know whether changes in `tags` took place when we compare it against `queryTags`.

This, by the way, is how `queryPivs` knows whether the query has changed. The `queryTags` entry in the store is always the latest one; the last list of `queryTags` to have been queried is at the `queryTags` property of the class.

```dart
      queryTags = List.from (tags);
```

In our first query, we will load up to 300 pivs. This is because we want the query to be lighter in both execution time and network transfer time, so we can show pivs to the user as quickly as possible.

```dart
      var firstLoadSize = 300;
```

We invoke `POST /query` in the server. We're going to pass the `tags` we received and get the latest pivs first. We also want to get the time header information, and we want to get the pivs starting from the first (which, in terms of dates, will be the last).

```dart
      var response = await ajax ('post', 'query', {
         'tags': tags,
         'sort': 'newest',
         'timeHeader': true,
         'from': 1,
```

We will already get 300 pivs, since some of these latest pivs will belong to the last month.

```dart
         'to': firstLoadSize
      });
```

If we didn't get back a 200 code, we have encountered an error. If we experienced a 403, there's another error message already shown by the `ajax` function informing the user that their session has expired; if the error, however, is not a 403, we inform the user with an error code `QUERY:A:CODE`.

```dart
      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error getting your pivs - CODE QUERY:A:' + response ['code'].toString (), 'yellow');
```

Whatever the error is, we cannot continue executing the function, so we return its response code.

```dart
         return response ['code'];
      }
```

If the tags in the query changed in the meantime, we don't do anything else in this function execution, since there will be another instance of queryPivs being executed concurrently that will be in charge of updating `queryResult`. We do return a 409 to indicate that there was a conflict between this query and another one executed shortly afterwards.

This check is a great example of why we copied `tags` before setting it to `queryTags`, and why we hold `queryTags` as part of the class. Tagaway is very interactive and the queries can take over half a second, so it's perfectly possible for the user to trigger a new query before the results of the old query are available.

```dart
      if (! listEquals (queryTags, tags)) return 409;
```

We return the result of the body in a local variable `queryResult`.

```dart
      var queryResult = response ['body'];
```

If we currently have tags in our query, and we got no pivs back, it may be the case that through an untagging operation, or a deletion, we have rendered the current query an empty one. Since we don't want to show an empty query to the user, in this case we will set `currentlyTaggingUploaded` to an empty string, to get the user out of "tagging mode" in the uploaded view.

We will also reset the query by setting `queryTags` to an empty list. There will be listeners in the views which, when we update `queryTags`, invoke `queryPivs` again, so we don't need to perform a recursive invocation to the function here.

In this case, there is nothing else to do, so we `return`.

```dart
      if (queryResult ['total'] == 0 && tags.length > 0) {
         StoreService.instance.set ('currentlyTaggingUploaded', '');
         return StoreService.instance.set ('queryTags', []);
      }
```

We will now put everything in place so that the time header can be computed. We start by setting the `timeHeader` inside `queryResult`. We do this just to put the data in there, but we don't want a redraw to be triggered yet, so we pass the `'mute'` flag. We must also add placeholders for the other fields (`total`, `tags` and `pivs`), since if the query is slow and another change redraws the view, an error will be thrown by the view if these fields are missing from `queryResult`.

```dart
      StoreService.instance.set ('queryResult', {
         'timeHeader':  queryResult ['timeHeader'],
         'total':       0,
         'tags':        {'a::': 0, 'u::': 0, 't::': 0, 'o::': 0},
         'pivs':        []
      }, '', 'mute');
```

If the server also didn't bring a last month, this must be a ronin query (a query without pivs). So we set `currentMonth` to an empty string. Note: this should only happen if either the user has no pivs uploaded, or if the query result was changed because of untaggings/deletions in another device.

```dart
      if (queryResult ['lastMonth'] == null) StoreService.instance.set ('currentMonth', '');
```

Otherwise, we extract the year and the month of the last month of the query, which will be present in the `lastMonth` key of the object returned by the server. We then set them in the `currentMonth` key of the store.

```dart
      else {
         var lastMonth = queryResult ['lastMonth'] [0].split (':');
         StoreService.instance.set ('currentMonth', [int.parse (lastMonth [0]), int.parse (lastMonth [1])]);
      }
```

Now that `queryResult.timeHeader` and `currentMonth` are placed, we can compute the time header by executing `computeTimeHeader`. The function is synchronous, so we do not need to await for it.

```dart
      computeTimeHeader ();
```

If we got the last 300 pivs, we might have gotten too many pivs! To know this, we look at the number of pivs belonging to the last month in `lastMonth`. If we have less than 300 pivs for the last month, we remove the extra pivs from `queryResult ['pivs']`. Note we do not do this if we get no pivs from the query.

```dart
      if (queryResult ['total'] > 0 && queryResult ['lastMonth'] [1] < queryResult ['pivs'].length) {
         queryResult ['pivs'].removeRange (queryResult ['lastMonth'] [1], queryResult ['pivs'].length);
      }
```

We now check whether the returned pivs are organized or not. If the `'o::'` tag was inside `tags`, then we know that all the pivs returned by the query are organized, so we simply set an `orgMap:ID` entry to `true` for each of them.

```dart
      if (tags.contains ('o::')) {
         queryResult ['pivs'].forEach ((piv) {
            StoreService.instance.set ('orgMap:' + piv ['id'], true);
         });
      }
```

Otherwise, we don't know whether they are organized or not, so we ask the server through `queryOrganizedIds`. Note we don't `await` on purpose, since we don't want to wait for the end of this operation to do the next query to the server.

```dart
      else queryOrganizedIds (queryResult ['pivs'].map ((v) => v ['id']).toList ());
```

If we have more pivs in the month than the pivs we brought, we will generate placeholder entries in `queryResult ['pivs']` for those that we don't have yet. This will allow us later to add the missing pivs without triggering a redraw. We know how many pivs we're missing because that info comes back in `queryResult ['lastMonth'] [1]`.

```dart
      if (queryResult ['total'] > 0 && queryResult ['pivs'].length < queryResult ['lastMonth'] [1]) {
         queryResult ['pivs'] = [...queryResult ['pivs'], ...List.generate (queryResult ['lastMonth'] [1] - queryResult ['pivs'].length, (v) => {'placeholder': true})];
      }
```

We update `queryResult` in its entirety, with a normal (non-mute) update. This will trigger a redraw of the grid and already show pivs.

```dart
      StoreService.instance.set ('queryResult', {
         'total':       queryResult ['total'],
         'tags':        queryResult ['tags'],
         'timeHeader':  queryResult ['timeHeader'],
         'pivs':        queryResult ['pivs']
      });
```

While we are at it, it's a good idea to refresh the list of tags. This is useful if some background uploads created tags in the meantime. Note we don't `await` for `getTags`, we simply run it in parallel as we did with `queryOrganizedIds`.

```dart
      getTags ();
```

If the last piv in `queryResult ['pivs']` is not a placeholder entry, or if there are no pivs in the query, then we loaded all the pivs we needed. We return 200.

Note: to know if we are missing pivs or not, we cannot compare the length of `queryResult ['pivs']` against `queryResult ['timeHeader'] [1]` because we already changed the length of the former!

```dart
      if (queryResult ['total'] == 0 || queryResult ['pivs'].last ['placeholder'] == null) return 200;
```

If we're here, we need to get all the pivs for the month. We do so by requesting all the pivs from 1 to the total number of pivs in the month.

```dart
      response = await ajax ('post', 'query', {
         'tags': tags,
         'sort': 'newest',
         'from': 1,
         'to': queryResult ['lastMonth'] [1],
      });
```

Why did we get them all and not those after `firstLoadSize`? Or why didn't we get them using extra tags for the year and the month of the last month? Quite simply, because if there is an inconsistency created by the delay between the two queries (when, in the background, there are uploads/taggings or deletions/untaggings that affect the query), we want to glaze over it by showing still the same amount of pivs as in the first query.

There might be room for improvement here, but this is a good solution for the time being. We're choosing performance over correctness. In the absence of updates between the first and second query, there will be no inconsistencies.

As before, if we didn't get back a 200 code, we have encountered an error. If we experienced a 403, there's another error message already shown by the `ajax` function informing the user that their session has expired; if the error, however, is not a 403, we inform the user with an error code `QUERY:B:CODE`.

```dart
      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error getting your pivs - CODE QUERY:B:' + response ['code'].toString (), 'yellow');
```

Whatever the error is, we cannot continue executing the function, so we return its response code.

```dart
         return response ['code'];
      }
```

As before, if the tags in the query changed in the meantime, we don't do anything else in this function execution, since there will be another instance of queryPivs being executed concurrently that will be in charge of updating `queryResult`.

```dart
      if (! listEquals (queryTags, tags)) return 409;
```

We store the result of the second query in a `secondQueryResult` variable.

```dart
      var secondQueryResult = response ['body'];
```

We only update the `queryResult.pivs` entry in `queryResult`, leaving the rest as it was before. Note we perform the update mutely, so that the extra pivs can "slide" into their positions without triggering a general redraw.

```dart
      StoreService.instance.set ('queryResult', {
         'total':       queryResult ['total'],
         'tags':        queryResult ['tags'],
         'timeHeader':  queryResult ['timeHeader'],
         'pivs':        secondQueryResult ['pivs']
      }, '', 'mute');
```

As before, we check whether the returned pivs are organized or not. If the `'o::'` tag was inside `tags`, then we know that all the pivs returned by the query are organized, so we simply set an `orgMap:ID` entry to `true` for each of them.

```dart
      if (tags.contains ('o::')) {
         secondQueryResult ['pivs'].forEach ((piv) {
            StoreService.instance.set ('orgMap:' + piv ['id'], true);
         });
      }
```

Otherwise, we don't know whether they are organized or not, so we ask the server through `queryOrganizedIds`.

```dart
      else queryOrganizedIds (secondQueryResult ['pivs'].map ((v) => v ['id']).toList ());
```

We return a 200 to indicate success and close the function.

```dart
      return 200;
   }
```



TODO


- `currentMonth`: an optional parameter of the form `[year, month]`, which indicates that the query should get only the pivs for a given month - by default it is set to `false`, which means that only the pivs for the last month will be retrieved.


If we received a `currentMonth` argument, we will add two tags into `currentMonthTags`: one for the year of the current month (`'d::DDDD'`) and one for the month itself (`'d::MDD'`) - in the last two expressions, `D` stands for digit. We need two tags because to query for a given year + month, tagaway requires a tag for each of them to be sent in the same query.

We'll use `currentMonthTags` shortly afterwards.

```dart
      if (currentMonth != false) var currentMonthTags = ['d::' + currentMonth [0].toString (), 'd::M' + currentMonth [1].toString ()];
```

We query `POST /query`, passing the `tags`. Note also we pass the `timeHeader` field set to `true`, since we want the time header.

This query, the first we do, will give us the total amount of pivs, their associated tags, the time header, and the first 300 pivs. The only thing that could be missing is any pivs after the first 300, but we'll deal with that in a minute.

Why do we preemptively get pivs, if we don't know how many they are? Quite simply, to avoid a double roundtrip to the server, which can add up for those far from our servers and/or with a slow internet connection.

Now for the tricky part: if `currentMonth` is `false`, the `tags` we sent to the server simply need to be the `tags` we received. But if we have a `currentMonth` we want to query, we want to pass those two tags that specify it into `tags`. For doing this, we merge `tags` and `currentMonthTags`. But that's not all. To eliminate potential duplicates (if, say, there was in `tags` already a tag for the year of the current month), we convert the list into a set (which removes duplicates), and then we convert it back into a list.

```dart
      var response = await ajax ('post', 'query', {
         'tags': currentMonth == false ? tags : ([...tags]..addAll (currentMonthTags)).toSet ().toList (),
         'sort': 'newest',
         'from': 1,
         'to': firstLoadSize,
         'timeHeader': true
      });
```


