# Tagaway Mobile

## TODO

- Tags
   - Show thumbnails
   - Show list when things change
   - Show tags on top
-----
- Sorting
- Improve zoom
- Query videos
- Use metadata to get a better date for some pivs
- Show hidden in query to be able to unhide
- Show info of piv
- Share Tagaway button and link
- Finish annotated source code: tagService, storeService, tools.
- Add login flow with Google, Apple and Facebook

## Store structure

```
- account: {username: STRING, email: STRING, type: STRING, created: INTEGER, usage: {limit: INTEGER, byfs: INTEGER, bys3: INTEGER}, geo: true|UNDEFINED, geoInProgress: true|UNDEFINED, suggestGeotagging: true|UNDEFINED, suggestSelection: true|UNDEFINED}
- achievements: [[<year>, <month>|'all'>], ...]: indicates which months (or entire years) are completely organized both in cloud and on this device.
- addMoreTags <bool>: if `true`, the user is currently tagging within the carrousel.
- cameraPiv:ID <bool>: if `true`, the local piv with this id is in the camera.
- context: a reference to the context of a Flutter widget, which comes useful for services that want to draw widgets into views.
- cookie <str> [DISK]: cookie of current session, brought from server - deleted on logout.
- csrf <str> [DISK]: csrf token of current session, brought from server - deleted on logout.
- currentMonth `[<int (year)>, <int (month)>]`: if set, indicates the current month of the uploaded view.
- currentlyTagging(Local|Uploaded) <str>: tag currently being tagged in LocalView/UploadedView
- currentlyDeleting(Local|Uploaded) <bool>: if set, we are in delete mode in LocalView/UploadedView
- currentlyDeletingModal(Local|Uploaded) <bool>: if set, we are showing the delete confirmation modal for Local/Uploaded view.
- currentlyDeletingPivs(Local|Uploaded) <list>: list of ids of pivs that are currently being deleted, either Local or Uploaded.
- displayMode <obj>: if set, has the form `{showOrganized: BOOLEAN, cameraOnly: BOOLEAN}`. `showOrganized` shows organized pivs in the local view; `cameraOnly` hides non-camera pivs from the local view.
- deleteTag(Local|Uploaded|ManageTags) <str>: tag currently being deleted in LocalView/UploadedView/ManageTagsView
- deletedPivs [<str>, ...]: a list of piv ids that are shown on the current view and have just been deleted.
- fullScreenCarrousel (bool): if set, the piv is shown in full screen in CarrouselView
- gridControllerUploaded <scroll controller>: controller that drives the scroll of the uploaded grid
- hashMap:<id> [DISK]: maps the id of a local piv to a hash.
- hideMap:<id> [DISK]: indicates that a piv with that id should be hidden.
- hometags [<str>, ...]: list of hometags, brought from the server.
- hideAddMoreTagsButton(Local|Uploaded) <bool>: if set, this will hide the "add second tag" button when tagging.
- initialScrollableSize <float>: the percentage of the screen height that the unexpanded scrollable sheets should take.
- lastNTags [<str>, ...] [DISK]: list of the last N tags used to tag or untag, either on local or uploaded - deleted on logout.
- localAchievements:<int> [[TAG, INT], ...]: for the local page <int>, a summary of the most prevalent tags, as well as the total for the page and the all-time organized number.
- localPage <int>: the local page currently being shown.
- localPage:INT `{name: STRING: pivs: [<asset>, ...], total: INTEGER, from: INTEGER, to: INTEGER, dateTags: ['d::MM', 'd::YYYY']}` - contains all the pages of local pivs to be shown, one per grid.
- localPageController <page controller>: controller that drives the local pages.
- localPagesLength <int>: number of local pages.
- localPagesListener <listener>: listener that triggers the function to compute the local pages.
- localYear <str>: displayed year in LocalView time header
- organizedAtDaybreak [DISK]: `{midnight: INT, organized: INT}`. Contains the number of organized pivs at the beginning of the current day - deleted on logout.
- organized: `{total: INT, today: INT}`. Contains the total number of organized pivs, as well as an approximation of how many pivs were organized today.
- orgMap:<pivId> (bool): if set, it means that this uploaded piv is organized
- pendingDeletion:<assetId> <true|undefined> [DISK]: if set, the piv must be deleted after it being uploaded - deleted on logout.
- pendingTags:<assetId> [<str>, ...] [DISK]: list of tags that should be applied to a local piv that hasn't been uploaded yet - deleted on logout.
- pivDate:<assetId> <int>: date of each local piv
- pivMap:<assetId> <str>: maps the id of a local piv to the id of its uploaded counterpart - the converse of `rpivMap`. They are temporarily set to `true` for pivs on the upload queue.
- pivTagsCarrousel: [<str>, ...]: list of tags of the piv currently shown in CarrouselView
- previousError <object> [DISK]: stores the last error experienced by the application, if any
- recurringUser <bool> [DISK]: whether the user is new to the app or has already used it - to redirect to either signup or login
- renameTag(Local|Uploaded|ManageTags) <str>: tag currently being renamed in LocalView/UploadedView/ManageTagsView
- queryFilter <str>: contains the filter (if any) used to filter out tags in the query/search view
- queryInProgress <bool>: if set to `true`, indicates that a query is currently taking place.
- queryResult: {total: <int>, tags: {<tag>: <int>, ...}, pivs: [{...}, ...], timeHeader: {<year:month>: true|false, ...}}: result of query, brought from server
- queryTags: [<string>, ...]: list of tags of the current query
- rpivMap:<pivId> <str>: maps the id of an uploaded piv to the id of its local counterpart - the converse of `pivMap`
- showSelectAllButton(Local|Uploaded): if `undefined`, the button will not show; if `true`, it will show the "select all" button; if set to `false`, it will show the "unselect all" button.
- showButtons(Local|Uploaded) (boolean): if true, shows buttons to perform actions in LocalView/UploadedView
- showDeleteAndShareCarrousel (bool): if set, the delete & share buttons are shown in CarrouselView
- showTagsCarrousel (bool): if set, tags are shown in CarrouselView
- swiped(Local|Uploaded) (boolean): controls the swipable tag list on LocalView/UploadedView
- tagFilter(Local|Uploaded) <str>: value of filter of tagging modal in LocalView/UploadedView
- tagFilterCarrousel <str>: value of filter of tagging modal in CarrouselView
- tagMap(Local|Uploaded):<assetId|pivId> (bool): if set, it means that this piv (whether local or uploaded) is tagged with the tags currently being applied
- tags [<string>, ...]: list of tags relevant to the current query, brought from the server
- thumbs {TAG: {id: STRING, deg: INTEGER|UNDEFINED, date: INT, tags: [STRING, ...], vid: TRUE|UNDEFINED< currentMonth: [INTEGER (year), INTEGER (month)]}, ...}: maps each tag to a random piv, brought from the server.
- uploadQueue [<string>, ...] [DISK]: list of ids of pivs that are going to be uploaded - deleted on logout.
- timeHeader [<semester 1>, <semester 2>, ...]: information for UploadedView time header
   where <semester> is [<month 1>, <month 2>, ..., <month 6>]
   where <month> is [<year>, <month>, 'white|gray|green', <undefined>|<pivId of last piv in month>]
- timeHeaderController <page controller>: controller that drives the timeHeader
- timeHeaderPage <int>: page in timeHeader currently displayed.
- toggleTags(Local|Uploaded) {ID: true|false, ...}: indicates the local/uploaded pivs that are marked for tagging/untagging.
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

## Creating a build to publish in the stores

First, run `flutter clean`.

Update `android/local.properties` to:

```
flutter.versionName={VERSION_NUMBER}
flutter.versionCode={PREVIOUS VERSIONCODE + 1}
```

Also update the version in `pubspec.yaml`.


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
- Once you tap 'Done' the piv should disappear from grid and the amount of pivs being uploaded should show on bottom left of the screen (a blue arrow from 'Phone' to 'Home').
- Once the user has tags, tap on 'Start adding your shortcuts!'
- User goes to 'Edit your hometags' view
- Tap on '+'
- A list of the available tags and a search bar appears
- Tap on the desired tag to create a hometag
- After tapping, user should is taken back to 'Edit your hometags' view, where the new hometag appears on the list.
- Tap on 'Done'
- User should be taken to 'Home' view and the recently added hometag should appear.
- If user taps on a hometag, it should be taken to that query (that tag)
- The pivs shown first should be the latest.
- On the top of the screen, the 'timeHeader' should show with an either on green or grey circles the months were user has pivs.
- The current month is underlined in blue
- If user taps on a month with either a green (organized) or grey (not organized/untagged) circle, it should navigate to that month.
- On 'Home' view, tap on the 'search' button.
- User should be taken to query selection view
- In query selection view user should see all the tags created, plus all the years and countries automatically tagged.
- In addition, if the user started their experience with Tagaway on the web app, on query selector view the 'untagged', 'to organize' or 'to be organized' options should appear. (If user has only used smartphone app, then this should not appear. All tagged pivs on the smartphone app are automatically tagged as 'organized')
- When selecting a tag (either manual or automatic), that tag should be removed from the list and taken to the top of the view with blue shade color.
- The remaining tags to be seen are the ones that have intersection with the selected tag.
- Tap on the 'see XXXXX pivs' should be taken to query results.
- If on query selector view user does not select anything and taps on 'see XXXXX pivs', then the query result is 'everything'
-


## Annotated source code

For now, we only have annotated fragments of the code. This might be expanded comprehensively later.

### `services/pivService.dart`

The pivService is concerned with operations concerning local pivs. Some of them don't involve the server, and others do.

We start by importing native packages, then libraries, and finally other parts of our app.

```dart
import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
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

We now define a `reset` method that restores all the instance properties to their initial values. This method will be called by the logic to log out the user.

```dart
   reset () {
      localPivs = [];
      upload = {};
      uploadQueue = [];
      recomputeLocalPages = true;
      uploading = false;
   }
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
      var file;
      try {
         file = await piv.originFile;
      }
```

Note we wrapped the above in a `try` block. Sometimes, the file might not be available; for example, because it was removed with another app while the file was on the upload queue. For that reason, we cannot be sure there will be a piv. If there's not, we return an object with key `code` equalling `-1`, to indicate that the file was missing and nothing else can be done.

```dart
      catch (error) {
         return {'code': -1};
      }
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
      store.set ('pivMap:'  + piv.id, response ['body'] ['id']);
      store.set ('rpivMap:' + response ['body'] ['id'], piv.id);
```

We set the `hashMap` for this piv. The client and the server determine this hash in the same way using the same algorithm, so if we overwrite our local entry, it should make no difference. The reason we write this `hashMap` here is that if we are uploading a piv that hasn't been hashed by the client yet, we can already set it and save the client the expense of hashing the piv.

Note the `hashMap` entry is stored in disk and will persist if the app restarts.

```dart
      store.set ('hashMap:' + piv.id, response ['body'] ['hash'], 'disk');
```

After the piv is successfully added, it is now time to tag it. If there are tags that should be applied to it, they will be at the `pendingTags:ID` key.

```dart
      var pendingTags = store.get ('pendingTags:' + piv.id);
```

If there are pending tags, then we will start by setting `orgMap:ID` (the `orgMap` entry for the uploaded counterpart of this local piv) to `true`. The rationale is the following: if the piv will be tagged, we automatically consider it as tagged. Therefore, it is correct to set this entry.

The practical reason for preventively setting this entry is that the tagging operation will take anywhere between 100ms and a second - in that time, the piv can briefly reappear in the local pivs page, since it will be considered uploaded but not organized yet.

```dart
      if (pendingTags != '') {
         store.set ('orgMap:' + response ['body'] ['id'], true);
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
      store.remove ('pendingTags:' + piv.id, 'disk');
```

If the piv was set to be deleted, but we couldn't delete it yet because it was queued to be uploaded first, it is now safe to delete it. We invoke `deleteLocalPivs` passing the piv id inside an array. We also remove the `pendingDeletion` key, also from disk.

```dart
      if (store.get ('pendingDeletion:' + piv.id) != '') {
         deleteLocalPivs ([piv.id]);
         store.remove ('pendingDeletion:' + piv.id, 'disk');
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
      store.set ('uploadQueue', dryUploadQueue, 'disk');
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
         if (store.get ('pivMap:' + piv.id) == '') store.set ('pivMap:' + piv.id, true);
```

We check whether the piv is already in the upload queue. We use a for loop because sometimes Dart throws unexplicable range errors when we iterate the`uploadQueue` with a `forEach`.

```dart
         bool pivAlreadyInQueue = false;
         for (var queuedPiv in uploadQueue) {
            if (piv.id == queuedPiv.id) pivAlreadyInQueue = true;
         }
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
         var sizeA = store.get ('hashMap:' + a.id);
         var sizeB = store.get ('hashMap:' + b.id);
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

If there are no pivs left in the upload queue, there's nothing left to do, so we return.

```dart
      if (uploadQueue.length == 0) return;
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

If we obtained a -1 code, the file for this piv is no longer available. We report the error with code `UPLOAD:-1`, remove the piv from the upload queue and update the dry upload queue. As with the 200 code above, we will not return since we will do further actions in this case.

```dart
      else if (result ['code'] == -1) {
         if (uploadQueue.length > 0) uploadQueue.remove (nextPiv);
         updateDryUploadQueue ();
         showSnackbar ('There was an error uploading your piv - CODE UPLOAD:' + result ['code'].toString (), 'yellow');
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

We start by loading the albums.

```dart
      var albums = await PhotoManager.getAssetPathList (onlyAll: false);
```

We then attempt to get an album whose name contains either `camera` or `dcim`.

```dart
      var cameraRoll;
      try {
         cameraRoll = albums.firstWhere (
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

We will now load the pivs from the camera in groups of 500.

```dart
      int offset = 0, pageSize = 500;
```

We will do this inside a `while` loop that we will `break` when we're done.

```dart
      while (true) {
```

We load the next page of pivs.

```dart
         var assets = await cameraRoll.getAssetListRange (start: offset, end: pageSize + offset);
```

If we got no pivs, we end the loop.

```dart
         if (assets.isEmpty) break;
```

For each of the loaded pivs, we set the entry `cameraPiv:ID` to `true`. This is the way in which this function will indicate to the rest of the app that this is a camera piv.

```dart
         for (var piv in assets) {
            store.set ('cameraPiv:' + piv.id, true);
         }
```

We increment `start` by 50. We then close the loop and the function.

```dart
         offset += pageSize;
      }
   }
```


We now define `loadLocalPivs`, a function that is a sort of entry point for loading up all the info required for the local view.

```dart
   loadLocalPivs () async {
```

Before we start doing anything, we check whether `localPivs` actually has pivs inside. If it does, this means that `loadLocalPivs` has already been executed during this run of the app. In this case, we just call `queuePiv` to start processing the upload queue, which should already be present - and may be empty, or not. There's no need to do anything else, so we return.

An example of when this can happen is if the app loses connection and then recovers it; in that case, the user will be redirected to the offline view, and then, when the connection returns, to the distributor view, which in turn will invoke this function. The check below prevents us from doing all the initialization again if we already did it.

Why do we check whether `localPivs` is not `null`? We are getting intermittent "Range Errors" from Dart, so we hope this check will avoid the (to us) impossible situation of `localPivs` not being a list.

```dart
      if (localPivs != null && localPivs.length > 0) return queuePiv (null);
```

This function will start by doing three things:

- Invoke `queryExistingHashes`, the function that will take all existing `hashMap` entries (which are stored on disk) and query the server to attempt to match them to cloud piv ids. We will wait for this operation to be done before continuing, to avoid the screen flickering or abrupt changes when this info is loaded.
- Invoke `queryOrganizedLocalPivs` to find out which of the local pivs with a `hashMap` entry have a cloud counterpart. We will do this after `queryExistingHashes` because that function sets the `pivMap` entries that we need to use to query the server. Note we will `await` this operation.

Note that we make the second call wait until the first one, but the rest of the function doesn't await for any of them. In this way, we make the initial load of local pivs faster.

```dart
      queryExistingHashes ().then ((_) {
        queryOrganizedLocalPivs ();
      });
```
We will then invoke `loadAndroidCameraPivs`, which will add `cameraPiv:ID` entries for those local pivs that are considered to be camera pivs.

```dart
      if (! Platform.isIOS) loadAndroidCameraPivs ();
```

The function will now load local pivs incrementally. We cannot load all the pivs at once because in devices with thousands of pivs, that can make the interface unresponsive for a few seconds.

We start by getting all the albums from PhotoManager. We sort the pivs that come from the albums with the latest pivs first, since we want to show the most recent pivs first.

```dart
      final albums = await PhotoManager.getAssetPathList (
         onlyAll: true,
         filterOption: FilterOptionGroup ()..addOrderOption (const OrderOption (type: OrderOptionType.createDate, asc: false))
      );
```

We initialize two variables: `offset` and `pageSize`, which will be our variables to keep track of how many pivs we have loaded so far.

```dart
      int offset = 0, pageSize = 500;
```

We start a `while` loop that we'll keep on going until we break it.

```dart
      while (true) {
```

We get a `pageSize` number of pivs, starting with the piv at index `offset`.

```dart
         var page;
         try {
            page = await albums.first.getAssetListRange (start: offset, end: pageSize + offset);
```

If there are no pivs left, we stop loading pivs by breaking the loop. Before we do that, we will invoke `computeLocalPages`, to show that the default pages are empty.

```dart
            if (page.isEmpty) {
               computeLocalPages ();
               break;
            }
         }
```

If there are no albums or the first album is empty, we will have experienced an error. This is why we wrapped the code above in a try block. If we found an error, we'll simply break the loop, after invoking `computeLocalPages`.

```dart
         catch (error) {
            computeLocalPages ();
            break;
         }
```

Once we have loaded a local page of pivs, we will invoke `getLocalTagsThumbs`, which will add further tags & thumbs coming from local pivs to the lists of tags and thumbs.

```dart
         TagService.instance.getLocalTagsThumbs ();
```

We do the same thing with `localQuery`, but only if `queryResult` is set (otherwise, there's no place in which to add the local pivs).

```dart
         if (store.get ('queryResult') != '') {
```

We invoke `localQuery`, passing the current values of `queryTags` and `queryResult`. We store it directly in `queryResult`.

```dart
            store.set ('queryResult', TagService.instance.localQuery (getList ('queryTags'), store.get ('queryResult')));
```

Because we just updated `queryResult` in place, this will not trigger a change event. Therefore, we will do a hack and, rather than copying the entire `queryResult` to trigger the change event, we'll just trigger it manually using the `updateStream` method of the store service. This concludes the logic for `queryResult` after loading a page of pivs.

```dart
            StoreService.instance.updateStream.add ('queryResult');
         }
```

We iterate the pivs in `page`: for each of them, we will set `pivDate:ID` to the creation date of the piv, expressed in milliseconds.

Since we don't store `pivDate:ID` entries in disk, we don't have to clean up old entries that might not belong to any local piv.

Note: because this function is called by `distributorView`, and because `distributorView` awaits for the store service to finish loading up the store from disk, we can safely assume that the store service is fully loaded and we can set and get synchronously.

```dart
         for (var piv in page) {
            store.set ('pivDate:' + piv.id, piv.createDateTime.millisecondsSinceEpoch);
```

If we are in iOS, we will also try to determine whether this piv is in the camera. iOS has no way to query this directly, so we do an approximation by getting the piv's MIME type and see if it is a HEIC or a MOV. If it is, we consider it a camera piv and therefore set `cameraPiv:ID`. Note that we already did this earlier for Android by invoking `loadAndroidCameraPivs`.

```dart
         if (Platform.isIOS) {
            var mime = await piv.mimeTypeAsync;
            if (['image/heic', 'video/quicktime'].contains (mime)) store.set ('cameraPiv:' + piv.id, true);
         }
```

Finally, we add the piv to `localPivs`

```dart
            localPivs.add (piv);
```

This concludes the iteration of the pivs.

```dart
         }
```

We sort `localPivs` by `createDateTime` and place the most recent pivs first. We have to do this again, despite earlier having passed a sorting option when getting the albums, because empirically we've found that some pivs might still be shown out of order.

Note we sort the pivs after we have added the full page of pivs, rather than after adding each piv.

```dart
      localPivs.sort ((a, b) => b.createDateTime.compareTo (a.createDateTime));
```

Now for a hack: after adding each page of pivs, we want to make `computeLocalPages` recompute the local pages. For this reason, we set a dummy key (`cameraPiv:foo`) to a value it didn't have before. Since the listener set by `computeLocalPages` will be triggered by a change to any key starting with `cameraPiv`, this will work. Earlier we considered doing this by making the listener of `computeLocalPages` also be triggered by changes to `pivDate`; however, that could have triggered more than one redraw for each added page, which is undesirable. For that reason, we go with this dummy key approach instead, to make sure that the pages are recomputed at most only once per page of local pivs loaded.

```dart
         store.set ('cameraPiv:foo', now ());
```

If we're loading the first page of pivs, we invoke `computeLocalPages`, the function that will determine what is shown in the local view, for the first time. The first time that `computeLocalPages` is executed, it will set up a listener so that it will call itself recursively to compute the local pages. We will only compute local pages once we have all our `pivMap` and `orgMap` entries loaded (after the first two functions invoked by `loadLocalPivs` are executed), to avoid redraws and flickers.

```dart
         if (offset == 0) computeLocalPages ();
```

We increase `offset` by `pageSize`; at this point, the loop will start again until there are no more pivs left to load.

```dart
         offset += pageSize;
      }
```

If we're here, we have finished loading all local pivs. We can now execute three more functions that require us to have loaded all local pivs first:

- `cleanupStaleHashes`, to remove `hashMap` entries that no longer belong to a local piv. Since we check what's stale against all local pivs, we need to load local pivs first.
- `computeHashes`, the function that will compute the hashes for the local pivs for which we haven't done so yet. If we don't wait for the local pivs to be loaded, then we will not know for which pivs to compute hashes.
- `reviveUploads`, the function that will start re-uploading pivs from the dry upload queue. If we don't wait for the local pivs to be loaded, we won't have the piv themselves to be uploaded.

Note we do not await for any of these functions, since we want to execute them in parallel, without one operation waiting on another to be completed.

```dart
      cleanupStaleHashes ();
      computeHashes ();
      reviveUploads ();
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

We iterate the `pivMap` entries.

```dart
      for (var k in store.getKeys ('^pivMap:')) {
```

We get the `pivMap:ID` entry, which can contain the id of the cloud counterpart of this local piv.

```dart
         var cloudId = store.get ('pivMap:' + piv.id);
```

If the entry is empty, or it is set to `true` (which will be the case for local pivs currently in the upload queue), we ignore it. Otherwise, we add it to `cloudIds`.

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
   reviveUploads () {
```

We get the dry upload queue which will be in the `uploadQueue` key. If there's no entry at all, or if the entry returns an empty list, we don't do anything else.

```dart
      var queue = store.get ('uploadQueue');

      if (queue == '' || queue.length == 0) return;
```

We iterate the local pivs and for each of them whose id is in the queue, we add them to `uploadQueue`. Note that this works because in the dry upload queue (the one stored at the `uploadQueue` key), we only store ids.

Note also that this will not restore the upload queue in the same order than the dry upload queue had them. The reason is purely practical: if we don't care about the order, we can simply add the queued pivs in the order they appear in `localPivs`. If we had to do it in the original order, we'd have to create a dictionary mapping each id of a local piv to an index, and then add the local pivs to the queue using those indexes. In any case, we will call `queuePiv` below, which will sort the upload queue.

```dart
      localPivs.forEach ((v) {
         if (! queue.contains (v.id)) return;
         uploadQueue.add (v);
```

We also set the `pivMap:ID` entry to `true`, as was done by `queuePiv` when this piv was originally added to the queue, to indicate that this piv should be considered as organized.

```dart
         store.set ('pivMap:' + v.id, true);
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

We now define `cleanupStaleHashes`, a function that will clean up old `hashMap` entries that no longer belong to any local piv.

```dart
   cleanupStaleHashes () async {
```

We first construct an object/map where each key is the id of a local piv. The value is set to `true` as a mere placeholder.

```dart
      var localPivIds = {};
      localPivs.forEach ((v) {
         localPivIds [v.id] = true;
      });
```

We are now going to iterate the existing `hashMap` entries, to see which entries exist.

```dart
      for (var k in store.getKeys ('^hashMap:')) {
```

If we find a `hashMap:ID` entry where `ID` does not correspond to a local piv, we remove that entry. Note we remove it from disk.

```dart
         var id = k.replaceAll ('hashMap:', '');
         if (localPivIds [id] == null) await store.remove (k, 'disk');
      }
```

This concludes the function.

```datt
   }
```

We now define `queryExistingHashes`, a function that will get, for each of the hashes of the local pivs, their cloud counterparts.


```dart
   queryExistingHashes ([cleanupStaleHashes = false]) async {
```

We will create another object/map where each key is the id of a local piv that has a hash already computed.

```dart
      var hashesToQuery = {};
```

We are now going to iterate the existing `hashMap` entries, to see which entries exist.

```dart
      for (var k in store.getKeys ('^hashMap:')) {
```

We extract the piv id from `hashMap:ID`. We then set the key `id` of `hashesToQuery` to the value of the hash of this piv.

Because local pivs might not have been loaded yet, we might be querying a hash of a local piv that no longer exists, therefore creating unnecessary `pivMap` and `rpivMap` entries. But because these entries are only used for the local pivs that we have, they pose no issue, and they will be gone once stale hashes are cleaned up and the app is restarted.

```dart
         var id = k.replaceAll ('hashMap:', '');
         hashesToQuery [id] = store.get (k);
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
         store.set ('pivMap:'  + localId,    uploadedId);
         store.set ('rpivMap:' + uploadedId, localId);
      });
```

Otherwise, we will check whether we have a `pivMap:ID` entry. If we do, we remove the stale entries for `pivMap:ID` and `rpivMap:ID`.

Note we check that `oldUploadedId` is neither an empty string nor `true`.

```dart
         else {
            var oldUploadedId = store.get ('pivMap:' + localId);
            if (oldUploadedId != '' && oldUploadedId != true) {
               store.remove ('pivMap:'  + localId);
               store.remove ('rpivMap:' + oldUploadedId);
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

We iterate the local pivs. We do this in a strange way: rather than writing `for (var piv in localPivs)`, we do it using the index; furthermore, each time we start a new iteration of the loop, we check that indeed the index is not out of bounds.

The reason for this seemingly strange workaround is that this loop might potentially run for a very long time (since hashing of a piv can take a few seconds and there might be thousands of pivs to be hashed) and the length of the local pivs array can change because of additions or deletions while the app is running.

If more pivs are added to `localPivs`, they will be ignored during the current execution of `computeHashes`. This is unlikely and has a low impact (because new pivs are almost certainly not uploaded anyway, so they are not going to be wrongly marked as unorganized).

```dart
      for (int i = 0; i < localPivs.length; i++) {
         if (i >= localPivs.length) break;
         var piv = localPivs [i];
```

If there's no hashMap entry for the piv, we move on to the next piv.

```dart
         if (store.get ('hashMap:' + piv.id) != '') continue;
```

We invoke `hashPiv`, another function that performs the hashing for us and that is defined in `tools.dart`. Note that instead of executing this function directly, we do it through `flutterCompute`. This function, provided by the Flutter Isolate library, allows us to run this function in an isolate.

By running this function in an isolate, we avoid blocking our main thread and can effectively hash pivs in the background.

A side-effect of this is that when running the app in debug mode, each call to `flutterCompute` will trigger a general redraw. This will not happen in release mode.

```dart
         var hash = await flutterCompute (hashPiv, piv.id);
```

If `hashPiv` returns `false`, this means that the asset was deleted and the file is no longer accessible. In this case, we just `continue` since there's nothing else to do for this piv. We are careful not to `return` since otherwise this would interrupt the loop for all other pivs that need to be hashed.

```dart
         if (hash == false) continue;
```

We set the `hashMap:ID` entry to the hash we just obtained. Note we do this in disk.

```dart
         store.set ('hashMap:' + piv.id, hash, 'disk');
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
            store.set ('pivMap:'  + piv.id,               queriedHash [piv.id]);
            store.set ('rpivMap:' + queriedHash [piv.id], piv.id);
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
- `dateTags`, the relevant year and month tags for that month.

```javasscript
         return {'title': pair [0], 'total': 0, 'left': 0, 'pivs': [], 'from': ms (pair [1]), 'to': ms (tomorrow), 'dateTags': ['d::M' + Now.month.toString (), 'd::' + Now.year.toString ()]};
```

We convert the result to a list.

```dart
      }).toList ();
```

We get the `displayMode` from the store, which will be an object of the form `{showOrganized: BOOLEAN, cameraOnly: BOOLEAN}`.

```dart
      var displayMode = store.get ('displayMode');
```

We get `toggleTagsLocal`, a map with the list of local pivs currently being tagged/untagged and store it in a local variable `currentlyTaggingPivs`. If there's no such key in the store, we will initialize it to an empty map. We will then iterate the map and for those entries where `taggedLocally` is `true`, we will return the id of the piv.

The reason we need this list is to avoid prematurely hiding pivs that are just being tagged. As soon as a piv is tagged, it is marked as organized, so if `displayMode` is `'all'`, that piv would immediately disappear, which is undesirable. By having a reference to this list, we can prevent prematurely removing those pivs from the local page.

```dart
      var currentlyTaggingPivs = store.get ('toggleTagsLocal');
      if (currentlyTaggingPivs == '') currentlyTaggingPivs = {};
      currentlyTaggingPivs = currentlyTaggingPivs.map ((id, tagged) {
         if (tagged == true) return id;
      }).where ((value) => value != null).toList ();
```

We iterate `localPivs`, which is the list of all local pivs held by our `pivService`. For each of them:

```dart
      localPivs.forEach ((piv) {
```

If the piv is scheduled for deletion after it is uploaded, we do not consider it at all for any pages.

```dart
         if (store.get ('pendingDeletion:' + piv.id) != '') return;
```

We determine whether the local piv is organized by checking if there's an `orgMap` entry for its cloud counterpart. We get the cloud counterpart of the local piv by querying `pivMap:ID`.

It might be that `pivMap:ID` is set to `true`. This happens if the local piv is currently in the upload queue. In this case, we consider the piv to be organized, since we assume that any pending tagging operation will mark as organized the cloud counterpart of this local piv.

```dart
         var cloudId        = store.get ('pivMap:' + piv.id);
         var pivIsOrganized = cloudId == true || store.get ('orgMap:' + cloudId) != '';
```

We determine if the piv is considered "left", that is, if it still has to be organized. If the piv is not organized, we consider it as left.

```dart
         var pivIsLeft      = ! pivIsOrganized;
```

However, if we are only showing camera pivs, and the piv is not a camera piv, we will not consider it as "left".

We check that `displayMode` is initialized because sometimes we see an error in this line when logging out.

```dart
         if (displayMode != '' && displayMode ['cameraOnly'] == true && store.get ('cameraPiv:' + piv.id) != true) pivIsLeft = false;
```

We check whether the piv is currently being tagged, by checking if it is inside `currentlyTaggingPivs`.

```dart
         var pivIsCurrentlyBeingTagged = currentlyTaggingPivs.contains (piv.id);
```

We determine whether the piv should be shown and store the result in `showPiv`. The piv should be shown if it is currently being tagged. If it's not currently being tagged, it will be shown if two conditions are fulfilled simultaneously:
- `displayMode.showOrganized` is `true` or the piv is not organized.
- `displayMode.cameraOnly` is `false` or the piv is a camera piv.

```dart
         var showPiv = pivIsCurrentlyBeingTagged || ((displayMode ['showOrganized'] == true || ! pivIsOrganized) && (displayMode ['cameraOnly'] == false || store.get ('cameraPiv:' + piv.id) == true));
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

If the piv is considered as left, we increment the `left` entry of the page.

```dart
               if (pivIsLeft) page ['left'] = (page ['left'] as int) + 1;
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

We set `left` to either 0 or 1 depending on whether the piv is left.

```dart
            'left': pivIsLeft ? 1 : 0,
```

We add `from` and `to` to the page. The logic for `to` is not so straightforward: if the date of the piv is in any month except December, we just take the beginning of the next month as our `to`. If the piv is in December, then we use January of the following year as our `to` instead.

```dart
            'from': ms (DateTime (pivDate.year, pivDate.month, 1)),
            'to':   ms (pivDate.month < 12 ? DateTime (pivDate.year, pivDate.month + 1, 1) : DateTime (pivDate.year + 1, 1, 1)) - 1,
```

We finally add `dateTags`.

```dart
            'dateTags': ['d::M' + pivDate.month.toString (), 'd::' + pivDate.year.toString ()]
         });
```

Before we close the iteration on local pivs, you might ask: how do you know that the pages will be created in the right order, with the latest pages first? Well, we initialized `pages` already to start with Today, followed by This Week and This Month. Because `localPivs` is sorted by date, with the latest pivs first, we know that if a piv hasn't a page yet, that page will be the right page to create to maintain things in order - otherwise, another piv without a page would have been processed first.

```dart
      });
```

We are now done constructing `pages` and are ready to perform updates in the store. We first set `localPagesLength` to the length of local pages.

```dart
      store.set ('localPagesLength', pages.length);
```

We iterate the pages, noting both the page itself and its index.


```dart
      pages.asMap ().forEach ((index, page) {
```

We make a reference to the current value of the page, before updating it. We'll see why in a minute.

```dart
         var oldPage = store.get ('localPage:' + index.toString ());
```

We update `localPage:INDEX` with the new page.

```dart
         store.set ('localPage:' + index.toString (), page);
```

Now for a bit of involved logic!
1. If the page we are currently iterating is the same one being shown (which will be the case if `index` is equal to the key `localPage`).
2. And the page we just computed is different from the page already stored.
3. And the page has no pivs to be shown.
4. Then we will invoke `getLocalAchievements` passing the `index` as its argument.

The need for this is the following: we need to update the `localAchievements:INDEX` key when the corresponding local page changes; but only if the page is being shown - otherwise, we would be making unnecessary calls to the server. We also don't need to compute it if there are pivs in the page, because then, the view that shows local achievements will not be visible.

```dart
         if (
           index == store.get ('localPage')
           &&
           ! DeepCollectionEquality ().equals (oldPage, page)
           &&
           (page ['pivs'] as List).length == 0
         ) TagService.instance.getLocalAchievements (index);
```

We close the loop over the pages.

```dart
      });
```

If this is the first time that `computeLocalPages` is executed, we will set up a listener that determines whether `computeLocalPages` should be executed again.

Notice that we store the listener in the `localPagesListener` key of the store, so by checking whether `localPagesListener` is set, we will know whether this logic has been already executed once or not.

```dart
      if (store.get ('localPagesListener') == '') {
         store.set ('localPagesListener', store.listen ([
```

The listener will be matched if there's a change on any of these store keys:

- All of the `cameraPiv` entries, which indicate which pivs belong to the camera roll.
- `displayMode`: whether to show all local pivs or just the unorganized ones.
- All of the `pivMap` entries, which map a local piv to a cloud piv and which, together with `orgMap`, determines whether the local piv is organized or not.
- All of the `orgMap` entries, which together with `pivMap`, determines whether the local piv is organized or not.
- `toggleTagsLocal`: the list of local pivs currently being (un)tagged.

```dart
            'cameraPiv:*',
            'displayMode',
            'pivMap:*',
            'orgMap:*',
            'toggleTagsLocal'
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

The function also takes two optional arguments, `reportBytes`, which if present will be a number of bytes liberated by a successful deletion, which will be printed in a snackbar; and `onDelete`, an argument that, if passed, should contain a function that will be executed if the piv deletion is confirmed by the user.

```dart
   deleteLocalPivs (ids, [reportBytes = null, onDelete = null]) async {
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
         store.set ('pendingDeletion:' + queuedPiv.id, true, 'disk');
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

If we're here, the user indeed deleted the first piv of the batch. If `onDelete` was passed, we execute it.

```dart
      if (onDelete != null) onDelete ();
```

We now proceed to remove the pivs from `localPivs`. While we could invoke `loadLocalPivs`, that could take many seconds in a phone with thousands of pivs, so we instead remove them quickly from `localPivs`.

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
         var hash = store.get ('hashMap:' + piv.id);
         if (hash == '') return;
         var cloudId = store.get ('pivMap:' + piv.id);
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
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:photo_manager/photo_manager.dart';

import 'package:tagaway/services/pivService.dart';
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

PivService has only properties that hold data: `queryTags`, which will be initialized to an empty list, but will be replaced by a list of tags when a query is done. The reason we keep it here, side by side with another list of tags that we keep in the store (in a key named `queryTags`) is that we want to compare the class property against the value in the store to see if the query changed - in that way, we can save a roundtrip to the server.

```dart
   dynamic queryTags = [];
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

If we're here, the request was successful. We set `tags` in the store after shuffling its order randomly.

```dart
      store.set ('tags', response ['body'] ['tags'].toList ()..shuffle ());
```

We invoke `updateOrganizedCount` passing to it the current total number of organized pivs. This function will update this number, as well as a count of all the pivs organized today.

```dart
      updateOrganizedCount (response ['body'] ['organized']);
```

We update the `hometags` and `thumbs` keys with what comes from the response body. Note we map `homeThumbs` to `thumbs` (the server endpoint will be changed in the future; it hasn't been changed yet to avoid backward compatibility issues until we publish the next build).

Note that we pass a `mute` flag when we're setting the thumbs. This is so that the view won't be redrawn twice when, just below, we load the info of local pivs to add to or modify the list of thumbs.

```dart
      store.set ('hometags', response ['body'] ['hometags']);
      store.set ('thumbs', response ['body'] ['homeThumbs'], '', 'mute');
```

Once we have loaded the cloud tags & thumbs, we will invoke `getLocalTagsThumbs`, which will add further tags & thumbs coming from local pivs to the lists of tags and thumbs. We will pass a `true` argument to indicate that tags for which we have cloud entries for thumbs can be overwritten by a local entry. This will avoid us just seeing cloud thumbnails taking precedence always above local ones, which can make us get bored if we only have very few cloud pivs for a tag.

```dart
      getLocalTagsThumbs (true);
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
      store.getKeys ('^pendingTags:').forEach ((k) {
         var pendingTags = store.get (k);
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
      store.set ('usertags', usertags);
```

We will now go through the tags inside the `lastNTags` key and remove those that are not included in `usertags`. The resulting list will be again set to `lastNTags`. Effectively, this gets rid of any stale tags inside `lastNTags`.

Note we store `lastNTags` in disk, because we want the list to persist when the app is closed.

```dart
      store.set ('lastNTags', getList (store.get ('lastNTags')).where ((tag) {
         return usertags.contains (tag);
      }).toList (), 'disk');
```

We close the function.

```dart
   }
```

We now define `updateOrganizedCount`, the function that updates the count of organized pivs. It takes a single argument, the total number of pivs currently organized.

```dart
   updateOrganizedCount (organizedNow) {
```

This function has the task to calculate how many pivs were organized today. A true computation of this number is impossible on a client; this should be done in the server.

But we're getting away with doing it in the client through a heuristic: if the user only uses the mobile client, then we can know how many pivs the user organized today, in the following way:

- The first time the user uses the app in the current day (at the user's local time), we note the number of organized pivs.
- The total pivs organized by the user is the current number of organized pivs minus this number of organized pivs noted the first time that the user used the app in the current day. Note that this number can be negative if the user removes all the tags from one or more pivs.

So we start by computing midnight at the user's time.

```dart
      var midnight = DateTime (DateTime.now ().year, DateTime.now ().month, DateTime.now ().day);
```

We get the key `organizedAtDaybreak`, which, if it exists, will have been created by a previous invocation to this function.

By daybreak, we mean the first time in the current day that the user has used the app - and therefore, received the total count of organized pivs at that moment.

```dart
      var organizedAtDaybreak = store.get ('organizedAtDaybreak');
```

If the key doesn't exist, or the key was set yesterday (which we'll know because the midnight date is less than the midnight for the current date) we will (over)write the `organizedAtDaybreak` key.

```dart
      if (organizedAtDaybreak == '' || organizedAtDaybreak ['midnight'] < ms (midnight)) store.set ('organizedAtDaybreak', {
```

The shape of the key is `{midnight: INT (milliseconds of the date at midnight, local time), organized: INT (number of organized pivs the first time we checked that date)}`.

We will store the key on disk, so that it lasts even if the app is closed and reopened.

```dart
         'midnight': ms (midnight),
         'organized': organizedNow
      }, 'disk');
```

This midnight heuristic, by the way, will break while the user travels to an earlier timezone; if the user does that, the timezone will change, and midnight will be less than the existing one, so the user will start "anew" the count of pivs organized today. This should be relatively rare.

We iterate the `pendingTags:ID` keys; each of them represents an organized piv that hasn't been uploaded yet. We will increment `organizedNow` by that amount.

```dart
      store.getKeys ('^pendingTags:').forEach ((k) {
         if (store.get (k) != '') organizedNow++;
      });
```

We finally set the key `organized`, which is the one used by the view to show how many organized pivs are (in total and organized today). It has this shape: `{total: INT, today: INT}`.

Note that `today` is simply the total organized pivs minus the pivs organized at midnight.

```dart
      store.set ('organized', {
         'total': organizedNow,
         'today': organizedNow - store.get ('organizedAtDaybreak') ['organized']
      });
```

This concludes the function.

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

To avoid the user to keep on waiting for a server response, we immediately update the `hometags` key so that the UI is updated. If the call later fails, the hometags will revert to what they were when we invoke `getTags` below, which will re-update `hometags` with what comes from the server.

```dart
      store.set ('hometags', hometags);
```

We invoke `POST /hometags` passing the updated hometags.

```dart
      var response = await ajax ('post', 'hometags', {'hometags': hometags});
```

First we will cover the case in which we obtained an error.

If we got an error code 0, we have no connection. If we got a 403, it is almost certainly because our session has expired. In both cases, the `ajax` function will print an error message. If, however, the error was neither a 0 nor a 403, we will report it with a code `HOMETAGS:CODE`.

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

We will remember up to nine tags.

```dart
      var N = 9;
```

If we have more than seven tags, we will remove the last one.

```dart
      if (lastNTags.length > N) lastNTags = lastNTags.sublist (0, N);
```

We update `lastNTags` in the store and close the function.

```dart
      store.set ('lastNTags', lastNTags, 'disk');
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

We get the list of hometags. If there are no hometags set yet, and we are tagging a piv, we add the first tag in `tags` to the hometags through `editHometags`. This allows us to "seed" the hometags with a first tag.

```dart
      var hometags = getList ('hometags');
      if (! del && hometags.isEmpty) await editHometags (tags [0], true);
```

We invoke `queryPivs` passing to it the `refresh` flag set to `true`. This flag will tell `queryPivs` to refresh the query if the `queryTags` haven't changed.

Note we do not await for the operation, since we want the query to happen in the background.

```dart
      queryPivs (true);
```

There's nothing else to do but to return the response code of the tagging operations (which was a 200) and close the function.

```dart
      return 200;
   }
```

We now define `toggleTags`, the function that is in charge of handling the logic for tagging or untagging a piv, whether the piv is local or cloud.

The function takes three arguments:
- A `piv`, which can be either a local piv or a cloud piv.
- The `type` of piv, either `uploaded` (for cloud pivs) or `local` (for local pivs). For `localUploaded` pivs (pivs that appear in the uploaded view but are local because are still being uploaded), this argument will be `uploaded` as well.
- The `selectAll` argument, which is optional, and which is used by the `selectAll` function, changes the behavior of the function: if set to `true`, it will only perform a tagging, and if set to `false` it will perform an untagging. But if either of them is already done, rather than a toggle, this will just be a no-op and nothing else will happen.

```dart
   toggleTags (dynamic piv, String type, [selectAll = null]) {
```

We first get the id of the piv. This piv can be either a local piv, or a cloud piv. If it's the former, the id should be accessed as `piv.id`. If it's the latter, the id should be accessed as `piv ['id']`. If you are perplexed, so am I.

Checking for `null` doesn't work and will throw exceptions. So, to dispense with this problem without having to pass extra information to the function, we'll use a mere try/catch block.

```dart
      var pivId;
      try {
        pivId = piv.id;
      }
      catch (error) {
         pivId = piv ['id'];
      }
```

And now we have the `pivId`.

We will now define a `tagMapPrefix` variable which will be either `tagMapLocal:` or `tagMapUploaded:` depending on `type`. This will be the prefix for `tagMap` keys, which indicate if a piv is tagged with `tags` or not. Note this will also be `tagMapUploaded:` for `localUploaded` pivs.

```dart
      var tagMapPrefix = 'tagMap' + (type == 'local' ? 'Local' : 'Uploaded') + ':';
```

We will now initialize a variable `state` that will be the value of the key `toggleTagsLocal` or `toggleTagsUploaded`. If the key is empty, then we will initialize `state` to an empty map. When there's entries in this map, they will look like this: `{PIVID: true|false, ...}`. If the entry is set to `true`, it means that the piv is tagged with the tags currently being applied; if it's `false`, it means that the piv will not be tagged.

Note that this `state` doesn't care about what the initial tagging state of the piv was; later, when we're done tagging, all the pivs marked as tagged will be tagged, and those marked as not tagged will be untagged. The no-ops are harmless and, because they happen in a single request (well, one for tagging and one for untagging), are not costly.

```dart
      var state = store.get ('toggleTags' + (type == 'local' ? 'Local' : 'Uploaded'));
      if (state == '') state = {};
```

If the `selectAll` argument is passed, we want to set the piv's state to whatever the value of `selectAll` is (`true` or `false`).

```dart
      if (selectAll != null) state [pivId] = selectAll;
```

If `selectAll` is not passed, we need to toggle the piv to the opposite of its previous state, which is contained in `tagMapLocal:ID` or `tagMapUploaded:ID`. If it formerly was `true`, we'll set it to `false`. If it was `false` or not set, then it will now become `true`.

```dart
      else                   state [pivId] = store.get (tagMapPrefix + pivId) != true;
```

You might well ask: why are we storing redundant information in `toggleTags` and `tagMap`? We need the `tagMap` entries because they have one entry per piv, which is necessary for the components bound to a single piv to redraw themselves when that particular key changes (and indeed, we have not implemented an event system that can traverse arrays/objects stored at a single key and treat them granullarly for redraws). While we could do with only the `tagMap` entries, by also storing the keys of the pivs that were toggled in `toggleTags`, we only have to perform ops (or no-ops) on a few pivs, rather than all available pivs that have a `tagMap` entry. So we opt for some duplication of state.

For that reason, it is indispensable to put in sync the `tagMap` entry with our `state` entry.

```dart
      store.set (tagMapPrefix + pivId, state [pivId]);
```

We also have to store the `state` into the `toggleTags` key. We do exactly that and close the function.


```dart
      store.set ('toggleTags' + (type == 'local' ? 'Local' : 'Uploaded'), state);
   }
```

We now define `doneTagging`, the function that will execute tagging and untagging operations when the user is done tagging.

It takes a single argument, `view`, which can be either `local` or `uploaded`, depending from which view this function is called.

```dart
   doneTagging (String view) async {
```

We start by getting the tags that are currently being placed. We find this at either `currentlyTaggingLocal` or `currentlyTaggingUploaded`, depending on `view`.

```dart
      var tags = store.get ('currentlyTagging' + (view == 'local' ? 'Local' : 'Uploaded'));
```

We invoke `updateLastNTags`, a function that will update the list of the last few used tags. We invoke the function with each of the `tags` in turn.

```dart
      tags.forEach ((tag) => updateLastNTags (tag));
```

We now get the `state` of which pivs are tagged and not from `toggleTagsLocal` or `toggleTagsUploaded` (depending on `view`).

```dart
      var state = store.get ('toggleTags' + (view == 'local' ? 'Local' : 'Uploaded'));
      if (state == '') state = {};
```

We create three lists:
- `cloudPivsToTag`, with all the cloud pivs that should be tagged.
- `cloudPivsToUnTag`, with all the cloud pivs that should be untagged.
- `localPivsToTagUntag`, with all the cloud pivs that should be either tagged or untagged.

```dart
      var cloudPivsToTag = [], cloudPivsToUntag = [], localPivsToTagUntag = {};
```

We iterate the elements of `state`, each of them a piv.

```dart
      state.forEach ((id, tagged) {
```

We need to figure out which ids belong to local pivs and which to cloud pivs. We will go with the heuristic that cloud pivs have UUID v4s, whereas local pivs do not. We are sure only of the former, not the latter.

A better solution would store this information in the state in the first place - this would only be necessary for the case where `view` is `uploaded`, since if `view` is `local`, we can only find local pivs here.

```dart
         var cloudPiv = RegExp ('^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}').hasMatch (id);
```

If the piv's id is a uuid, we consider that id to be a `cloudId` (the id of the piv in the server). If not, this must be a local piv, in which case we get it from `pivMap:ID`.

```dart
         var cloudId = cloudPiv ? id : store.get ('pivMap:' + id);
```

If the `cloudId` is either an empty string (not set) or `true` (which will be the case if this is a local piv in the upload queue), this is a local piv. Therefore, we will add the piv in `localPivsToTagUntag`.

```dart
         if (cloudId == '' || cloudId == true) localPivsToTagUntag [id] = tagged;
```

Otherwise, this is either a cloud piv or a local piv with a cloud counterpart. In that case, we add the cloud piv to either `cloudPivsToTag` or `cloudPivsToUntag`.

```dart
         else {
            if (tagged == true) cloudPivsToTag.add (cloudId);
            else                cloudPivsToUntag.add (cloudId);
         }
```

A potential drawback with the above logic is that, for local pivs that have a cloud counterpart, if one or more of them have a cloud counterpart that was deleted, the entire tagging will fail. For this type of deletion to affect the tagging, it has to 1) have happened after the app was started (and the `pivMap` entries initialized); 2) through a different client. If this becomes an issue, the logic above will be refactored to distinguish cloud ids that are tagged vs local pivs with a cloud counterpart - if any of the latter fail, they can be re-uploaded and tagged.

This finishes the iteration over the `state` entries.

```dart
      });
```

If we have `cloudPivsToTag`, we iterate the `tags`.

```dart
      if (cloudPivsToTag.length > 0) for (var tag in tags) {
```

For each tag, we make a call to `POST /tag`. Note we pass the `autoOrganize` flag set to `true`, since we want the autoorganize behavior, which means that every tagged piv is marked as organized, and if a piv has no tags, then it will be marked as unorganized.

```dart
         var response = await ajax ('post', 'tag', {'tag': tag, 'ids': cloudPivsToTag, 'autoOrganize': true});
         if (response ['code'] != 200) return showSnackbar ('There was an error tagging your piv - CODE TAG:' + response ['code'].toString (), 'yellow');
      }
```

If we have `cloudPivsToUntag`, we will do the same as above, but untagging them. Note we also pass the `del` flag to indicate that we're untagging. We also pass the `autoOrganize` flag set to `true`, since we want the autoorganize behavior, which means that every tagged piv is marked as organized, and if a piv has no tags, then it will be marked as unorganized.

```dart
      if (cloudPivsToUntag.length > 0) for (var tag in tags) {
         var response = await ajax ('post', 'tag', {'tag': tag, 'ids': cloudPivsToUntag, 'del': true, 'autoOrganize': true});
         if (response ['code'] != 200) return showSnackbar ('There was an error tagging your piv - CODE TAG:' + response ['code'].toString (), 'yellow');
      }
```

If we tagged or untagged cloud pivs, we update the `orgMap:ID` entries for all the pivs we just tagged and untagged, since the organization status of the cloud pivs we just (un)tagged may have changed. Note we do not `await` for this call.

```dart
      if ((cloudPivsToTag + cloudPivsToUntag).length > 0) queryOrganizedIds (cloudPivsToTag + cloudPivsToUntag);
```

We get the list of hometags. If there are no hometags set yet, and we are tagging one or more cloud pivs, we add the first tag in `tags` to the hometags through `editHometags`. This allows us to "seed" the hometags with a first tag. Note we do not `await` for this call.

```dart
      var hometags = getList ('hometags');
      if (cloudPivsToTag.length > 0 && hometags.isEmpty) editHometags (tags [0], true);
```

If we tagged or untagged cloud pivs, we refresh the query. Note we do not `await` for this call, but rather let it run in the background.

```dart
      if ((cloudPivsToTag + cloudPivsToUntag).length > 0) queryPivs (true);
```

If there's no local pivs to tag or untag, there's nothing left to do, so we `return`.

```dart
      if (localPivsToTagUntag.keys.length == 0) return;
```

We will invoke `localPivsById` to obtain a map `localPivsById`, where each key is an id and each value is a local piv. This is simply to quickly be able to access a piv without going through the entire `localPivs` list.

```dart
      var localPivsById = PivService.instance.localPivsById ();
```

We iterate each local piv to tag/untag, which are stored in a map where the keys are ids and the values are `true` for pivs to tag and `false` for pivs to untag:

```dart
      for (var id in localPivsToTagUntag.keys) {
```

We determine whether we're untagging the piv or not.

```dart
         var untag = localPivsToTagUntag [id] == false;
```

We get the list of pending tags from `pendingTags:ID`.

```dart
         var pendingTags = getList ('pendingTags:' + id);
```

For each of the tags, if we're untagging, we will remove them from the list of pending tags for this piv. Otherwise, we will add them. Note that if we are tagging, we need to check if the tag is already in the list, to avoid adding it multiple times into `pendingTags`.

```dart
         tags.forEach ((tag) {
            if (untag)                             pendingTags.remove (tag);
            else if (! pendingTags.contains (tag)) pendingTags.add (tag);
         });
```

If `pendingTags` is now empty, we will remove the key outright from the store. Otherwise, we will update it.

```dart
         if (pendingTags.length > 0) store.set    ('pendingTags:' + id, pendingTags, 'disk');
         else                        store.remove ('pendingTags:' + id, 'disk');
```

If we are tagging the piv, all we have left to do is call the `queuePiv` function of the `PivService`.

```dart
         if (! untag) PivService.instance.queuePiv (localPivsById [id]);
```

Now for an interesting bit of logic. If we are untagging a local piv that hasn't been uploaded yet, and we happen to have removed the last tag in `pendingTags`, there should be no need to actually upload the piv at all! If the piv has been completely untagged before being uploaded, uploading it serves no purpose.

```dart
         if (pendingTags.length == 0) {
```

We first unset `pivMap:ID`, which was temporarily set to `true` when the piv was queued by a previous tagging operation.

```dart
            store.remove ('pivMap:' + id);
```

We will now find index of this piv in the `uploadQueue` of the PivService. Note we use `asMap` to be able to iterate the list and still get both its index and the piv itself at the same time.

```dart
            var uploadQueueIndex;
            PivService.instance.uploadQueue.asMap ().forEach ((index, queuedPiv) {
```

If the id of the queued piv is equal to `pivId`, we've found the piv, so we set `uploadQueueIndex`.

```dart
               if (queuedPiv.id == id) uploadQueueIndex = index;
            });
```

If the piv is in the upload queue, we it from the upload queue. We check whether `uploadQueueIndex` is `null`, because it may be the case that the piv in question is currently being uploaded, in which case it will no longer be in the queue.

This concludes the logic for untagging the last tag of a local piv in the upload queue.

```dart
            if (uploadQueueIndex != null) PivService.instance.uploadQueue.removeAt (uploadQueueIndex);
         }
```

This concludes the function.

```dart
      }
   }
```

We now define `getTaggedPivs`, the function that will determine which of the pivs (either local or uploaded) are tagged with a given piv. This is necessary when the user starts tagging them with a tag X: this function will let the UI know whether the piv is already tagged with taag X.

The function takes two arguments:
- `tags`: the list of tags that are being applied to pivs. This can be either one or two tags at the same time.
- `view`: can be either `local` or `uploaded`.

```dart
   getTaggedPivs (dynamic tags, String view) async {
```

This function accomplishes its goal by setting `tagMap:ID` entries (and removing old ones that might be left over from a previous tag operation).

Note: the `tagMap:ID` entries can either exist and be set to `true`, or not exist at all. They are a flag which, if present, means that a given piv is tagged from the perspective of the current tags being used to tag.

We create two arrays, one to hold all existing entries of `tagMap:ID` and another one to hold all the ids of the pivs that should have a `tagMap:ID` entry.

```dart
      var existing = [], New = [];
```

You might ask: why not remove all the existing `pivMap` entries and add new ones? The answer is: performance. There might be hundreds of pivs, each of them with a widget that depends on each of their flags; for that reason, most of this function is concerned with doing a "diff", and only adding the necesssary `tagMap` entries that are needed.

We will define a `tagMapPrefix` variable which will be either `tagMapLocal:` or `tagMapUploaded:`, depending on the `view`. This will be the prefix for `tagMap` keys, which indicate if a piv is tagged with `tags` or not.


```dart
      var tagMapPrefix = 'tagMap' + (view == 'local' ? 'Local' : 'Uploaded') + ':';
```

We iterate all the keys in the store.

```dart
      store.store.keys.toList ().forEach ((k) {
```

If we find a `tagMap` entry, we add the `ID` to `existing`.

```
         if (RegExp ('^' + tagMapPrefix).hasMatch (k)) existing.add (k.split (':') [1]);
```

Now, how do we know whether a piv's id should be included in `New`? There are three sources:
- For uploaded pivs, we will ask the server what are the ids of the pivs that already are tagged with `tags`.
- For local pivs, we will use the information from the server to see which of their uploaded counterparts have already these tags.
- For local pivs that are in the upload queue, we will see the `pendingTags:ID` entries; each of these pending tags are, in effect, the equivalent of a server tag.

We will do the latter first. If this is a `pendingTags` entry:

```dart
         if (RegExp ('^pendingTags:').hasMatch (k)) {
```

We will get the pending tags for this piv.

```dart
             var pendingTags = store.get (k);
```

We will now determine whether all of the `tags` are included inside `pendingTags`. If this is the case, we will consider this local piv to be tagged already with `tags`.

If one or more of the `tags` are not included in `pendingTags`, then the piv should not be considered as tagged, for the purposes of the current tagging operation.

```dart
             var tagsContained = true;
             tags.forEach ((tag) {
                if (! pendingTags.contains (tag)) tagsContained = false;
             });
```

If the piv is tagged with all of `tags`, we add its `id` to `New`.

```dart
             if (tagsContained) New.add (k.split (':') [1]);
         }
```

This concludes the iteration on store keys.

```dart
      });
```

Note that we compute the `pivMap` entries for local pivs even if `view` is uploaded. This is because of the local query functionality, which will add local pivs in the upload queue to the uploaded view, if those pivs are relevant to the query.

We will now query the server, to get all the uploaded pivs that are already tagged with `tags`. Note that we pass the `idsOnly`, just to get their ids; we also pass a very large number as `to`, to get all of them.

```dart
      var response = await ajax ('post', 'query', {
         'tags':    tags,
         'sort':    'newest',
         'from':    1,
         'to':      100000,
         'idsOnly': true
      });
```

First we will cover the case in which we obtained an error.

If we got an error code 0, we have no connection. If we got a 403, it is almost certainly because our session has expired. In both cases, the `ajax` function will print an error message. If, however, the error was neither a 0 nor a 403, we will report it with a code `TAGGED:CODE`.

```dart
      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error getting your tagged pivs - CODE TAGGED:' + response ['code'].toString (), 'yellow');
         return;
      }
```

If we're here, the query was successful!

If we are doing this for the uploaded view, we set a variable `queryIds` with all the ids of the last query result, to have a list of uploaded ids.

A very, very subtle point: if there are local pivs inside the pivs of the last query result, they will have `null` entries. Why? Because `v ['id']` will yield `null` for them, whereas `v.id` will yield their actual id. The deeper reason for this is some object oriented trickery which my personal programming paradigm blocks me from understanding. For practical purposes, those local pivs in this list will have a `null` entry, and effectively this means that we will ignore them, which is great, because we do not want to double count them - since we added them already above when we were iterating the `pendingTags` entries.

```dart
      var queryIds;
      if (view == 'uploaded') queryIds = store.get ('queryResult') ['pivs'].map ((v) => v ['id']);
```

We iterate the piv ids we got from the server.

```dart
      response ['body'].forEach ((v) {
```

If we are in the uploaded view, if the id is contained in `queryIds`, we add it to `New`.

```dart
         if (view == 'uploaded') {
            if (queryIds.contains (v)) New.add (v);
         }
```

If we are in the local view, we check whether the piv has a `rpivMap:ID` entry, which points from an uploaded piv to a local piv. If indeed that's the case, we add the id of the local piv to `New`.

```dart
         else {
            var id = store.get ('rpivMap:' + v);
            if (id != '') New.add (id);
         }
```

This concludes the iteration of piv ids we got from the server.

```dart
      });
```

We now have all the `existing` and `New` entries. Time for a diff!

For all the `New` entries:

```dart
      New.forEach ((id) {
```

If the new entry doesn't exist yet, we set `tagMap(Local|Uploaded):ID` to `true`. Otherwise, we remove it from the `existing` list.

```dart
        if (! existing.contains (id)) store.set (tagMapPrefix + id, true);
        else existing.remove (id);
      });
```

By now, all the entries in `existing` are stale, since if they weren't, they would have been removed by the iteration over `New` we just did. We simply remove all the `tagMap:ID` entries for those ids that are left in `existing`.

```dart
      existing.forEach ((id) {
        store.remove (tagMapPrefix + id);
      });
```

We are done! This concludes the function.

```dart
   }
```

We now define `selectAll`, the function that will select all pivs for the purpose of a tagging or deleting operation. The function takes three arguments:

- `view` (either `local` or `uploaded`).
- `operation` (either `tag` or `delete`).
- `select` (either `true` or `false`). If it is `true`, this means we want everything selected; if it is `false`, we want everything deselected.

```dart
   selectAll (String view, String operation, bool select) {
```

If we are (de)selecting local pivs:

```dart
      if (view == 'local') {
```

We get the current page of local pivs being shown and iterate its pivs.

```dart
         var currentPage = store.get ('localPage:' + store.get ('localPage').toString ());
         currentPage ['pivs'].forEach ((piv) {
```

If we are deleting pivs, we call `toggleDeletion`, passing the piv's id, the view (`local`) and the `select` flag set to `true`, to make sure the piv is added to the list of pivs to be deleted if it's not, and is left inside the list if it already is there.

```dart
            if (operation == 'delete') toggleDeletion (piv.id, 'local', select);
```

Likewise with the `tag` operation: we invoke `toggleTags` as well.

```dart
            if (operation == 'tag')    toggleTags (piv, 'local', select);
```

This concludes the case for local pivs.

```dart
         });
      }
```

If we are (de)selecting uploaded pivs:

```dart
      if (view == 'uploaded') {
```

We get all the pivs from the current query, which are stored in `queryResult`, and iterate them.

```dart
         var queryResult = store.get ('queryResult');
         queryResult ['pivs'].forEach ((piv) {
```

If this is a local piv (which will be the case if `piv.local` is `true`), inserted there by `localQuery` (which will be defined below), we do almost the same we did in the local block above, except that we pass different parameters.

- To `toggleDeletion`, we will pass the view `uploaded`.
- To `toggleTags`, we will pass the view `uploaded`.

```dart
            if (piv ['local'] == true) {
               if (operation == 'delete') toggleDeletion (piv ['piv'].id, 'uploaded', select);
               if (operation == 'tag')    toggleTags (piv ['piv'], 'uploaded', select);
            }
```

If this is a normal uploaded piv, we will invoke the same two functions we just did above.

```dart
            else {
               if (operation == 'delete') toggleDeletion (piv ['id'], 'uploaded', select);
               if (operation == 'tag')    toggleTags (piv, 'uploaded', select);
            }
```

This concludes the function.

```dart
         });
      }
   }
```

We now define `localQuery`, a function that will return a list of local pivs that have no cloud counterpart and which match the existing query.

The purpose of `localQuery` is to enrich `queryResult` by potentially adding local pivs, tags, increasing the total number of pivs and modifying the time header in the query.

The function takes two parameters:

- `tags`: the list of tags in the current query.
- `queryResult`: the result of an invocation to `queryPivs`, which will be precisely defined below. This data is returned by the server after a query.

```dart
   localQuery (tags, queryResult) {
```

If the current query includes a geotag, no local pivs can be included in the query, since we don't have the ability to get the geodata from a local piv, we cannot know whether it will actually match a geotag or not.

```dart
      var containsGeoTag = false;
      tags.forEach ((tag) {
         if (RegExp('^g::[A-Z]{2}').hasMatch(tag)) containsGeoTag = true;
      });
      if (containsGeoTag) return queryResult;
```

If `o::` is included in the list of tags, this won't exclude any local pivs queued for upload, since all of them will be organized.

We collect all the user tags (that is, the normal tags) into a local variable `usertags`.

```dart
      var usertags = tags.where ((tag) {
         return ! RegExp ('^[a-z]::').hasMatch (tag);
      }).toList ();
```

We define a couple of variables, `minDate` and `maxDate`, to determine the limits of what local queued pivs will go in the query. By default, they are set to values which will be fulfilled by any date.

```dart
      var minDate = 0;
      var maxDate = now ();
```

We also define variables to hold a month tag and a year tag; there can be at most one of each in our query.

```dart
      var monthTag, yearTag;
```

We iterate the local tags and if we find a month tag or a year tag, we set it in its corresponding variable.

```dart
      tags.forEach ((tag) {
         if (RegExp ('^d::[0-9]').hasMatch (tag)) yearTag = tag;
         if (RegExp ('^d::M').hasMatch (tag))     monthTag = tag;
      });
```

We transform `yearTag` and `monthTag` into numbers with the months they represent. For example, `d::2013` will become `2013` and `d::M4` will become `4`.

```dart
      if (yearTag  != null) yearTag  = int.parse (yearTag.substring (3));
      if (monthTag != null) monthTag = int.parse (monthTag.substring (4));
```

Concerning our date tags, there can be four options:
- If there is neither a year tag nor a month tag, there are no time restrictions. In this case, we don't have to do anything.
- If there is a month tag but not a year tag, we'll add some checks below, but not here.
- If there's a year tag but not a month tag, we'll set `minDate` and `maxDate` to cover the year specified by that tag.
- If there's a year tag and a month tag, we'll set `minDate` and `maxDate` to cover the month specified by that combination of tags.

In the case where `yearTag` is present but `monthTag` is not, we'll set the date range to cover that entire year.

```dart
      if (yearTag != null && monthTag == null) {
         minDate = DateTime.utc (yearTag,     1, 1).millisecondsSinceEpoch;
         maxDate = DateTime.utc (yearTag + 1, 1, 1).millisecondsSinceEpoch;
      }
```

In the case where `yearTag` is present and `monthTag` is also present, we'll set the date range to cover the specified month. Note that if the month is 12, we'll set `maxDate` to be the first day of the next year.

```dart
      if (yearTag != null && monthTag != null) {
         minDate = DateTime.utc (yearTag, monthTag, 1).millisecondsSinceEpoch;
         if (monthTag == 12) maxDate = DateTime.utc (yearTag + 1, 1,            1).millisecondsSinceEpoch;
         else                maxDate = DateTime.utc (yearTag,     monthTag + 1, 1).millisecondsSinceEpoch;
      }
```

We will invoke `localPivsById` to obtain a map `localPivsById`, where each key is an id and each value is a local piv. This is simply to quickly be able to access a piv without going through the entire `localPivs` list.

```dart
      var localPivsById = PivService.instance.localPivsById ();
```

We will create a list `localPivsToAdd`.

```dart
      var localPivsToAdd = [];
```

Now, for a subtle bit of logic. `localQuery` might be invoked several times while the app is loading page after page of local pivs. In these cases, it is essential to 1) add the newly loaded local pivs to the query, if applicable; 2) do not repeat them if they are already added.

For this reason, we will create a map the ids of the local pivs already present in `queryResult.pivs`. To know that they are local, we check the `local` property; these entries will be added by previous invocations to `localQuery` that were saved on the same `queryResult`.

```dart
      var localPivsAlreadyPresent = {};
      queryResult ['pivs'].forEach ((piv) {
         if (piv ['local'] == true) localPivsAlreadyPresent [piv ['piv'].id] = true;
      });
```

We will iterate all the local pivs for which we don't have a cloud counterpart. To do this, we simply get all local pivs, and then ignore those that have a `pivMap:ID` entry.

```dart
      PivService.instance.localPivs.forEach ((piv) {
         if (store.get ('pivMap:' + piv.id) != '') return;
```

If the piv is marked as hidden, we'll remove it from the query altogether.

```dart
         if (store.get ('hideMap:' + piv.id) != '') return;
```

We will get the pending tags for this piv.

```dart
         var pendingTags = getList ('pendingTags:' + piv.id);
```

We will also create a `dateTags` list.

```dart
         var dateTags = ['d::' + piv.createDateTime.toUtc ().year.toString (), 'd::M' + piv.createDateTime.toUtc ().month.toString ()];
```

If we are querying for organized pivs, and the piv has no `pendingTags`, we ignore the piv.

```dart
         if (tags.contains ('o::') && pendingTags.length == 0) return;
```

Likewise, if we are querying unorganized or untagged pivs, if this local piv has `pendingTags`, it is organized, therefore, it should be excluded from the query.

```dart
         if ((tags.contains ('u::') || tags.contains ('t::')) && pendingTags.length > 0) return;
```

If the date range doesn't match the date of the piv, we exclude it and merely `return`.

```dart
         if (minDate > ms (piv.createDateTime) || maxDate < ms (piv.createDateTime)) return;
```

For the case in which we have a month tag but no year tag, we will exclude any piv that doesn't have the same month as the `monthTag`.

```dart
         if (monthTag != null && yearTag == null && piv.createDateTime.toUtc ().month != monthTag) return;
```

We will now determine whether the query tags exclude the piv or not. We start by assuming that there is a match.

```dart
         var matchesQuery = true;
```

We iterate `usertags`. Note: if usertags is empty, then we will all pivs through.

```dart
         usertags.forEach ((tag) {
```

If the tag is not included in the `pendingTags` of the piv, we do not have a match; all the tags in usertags must also be included in `pendingTags`.

```dart
            if (! pendingTags.contains (tag)) matchesQuery = false;
         });
```

If there is no match, we exclude the piv.

```dart
         if (matchesQuery == false) return;
```

We increase the total of `queryResult` by 1.

```dart
         queryResult ['total'] += 1;
```

For each of the tags in `pendingTags` and `dateTags`, we increment each of its entries in `queryResult ['tags']`. If an entry does not exist, we initialize it to 0.

```dart
         (pendingTags + dateTags).forEach ((tag) {
            if (queryResult ['tags'] [tag] == null) queryResult ['tags'] [tag] = 0;
            queryResult ['tags'] [tag] += 1;
         });
```

We add the piv to `localPivsToAdd`. This concludes the iteration of all local pivs currently being uploaded.

```dart
         localPivsToAdd.add (piv);
      });
```

We include each of the `localPivsToAdd` into the list of pivs. We do this in a map that containas three properties:

- `date`, the date of the piv in ms. This is added to make the entry more like the entries returned by the server.
- `local`, a flag that states that the piv is local.
- `piv`, the local piv itself.

```dart
      localPivsToAdd.forEach ((piv) {
         queryResult ['pivs'].add ({'date': ms (piv.createDateTime), 'piv': piv, 'local': true});
      });
```

We are almost done. We simply sort the pivs inside queryResult, with the newest pivs first. Note that the date property is the same for both local and uploaded pivs, so we don't have to add special logic to sort them together.

```dart
      localPivsToAdd.forEach ((piv) {
         queryResult ['pivs'].add ({'date': ms (piv.createDateTime), 'piv': piv, 'local': true});
      }
```

We return `queryResult` and close the function.

```dart
      return queryResult;
   }
```

We now define `getLocalAchievements`, a function that will calculate the "score" view when a user is done tagging a local page. This function takes a single parameter, `pageIndex`, which is the page number for which the score will be calculated.

```dart
   getLocalAchievements (pageIndex) async {
```

We first determine in which key we will save the result of this function. It will be in `localAchievements:PAGEINDEX`. We store multiple stores in different keys so that we don't have to recompute it every time that the user swipes from local page to local page.

```dart
      var storageKey = 'localAchievements:' + page.toString ();
      var storageKey = 'localAchievements:' + pageIndex.toString ();
```

We get the current local page at index `pageIndex`.

```dart
      var page = store.get ('localPage:' + pageIndex.toString ());
```

If the page hasn't been computed yet (which will happen when the app has just been (re)started), we merely set an empty list as the result and `return`, since there's nothing else to do yet.

```dart
      if (page == '') return store.set (storageKey, []);
```

We call `POST /query` to get all the pivs within the time range of the page that are organized (we want to exclude pivs that are not organized, which likely could come from batch uploads through the web client). The time range of the page comes from the `from` and `to` fields, set by the function that computes local pages.

```dart
      var response = await ajax ('post', 'query', {
         'tags': ['o::'],
         'sort': 'newest',
         'mindate': page ['from'],
         'maxdate': page ['to'],
         'from': 1,
         'to': 1
      });
```

If we got an error when making the request, we will print an error in the snackbar (with code `ACHIEVEMENTS:CODE`). In this case, we will simply store an empty list as a result and `return`.

```dart
      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error getting your achievements - CODE ACHIEVEMENTS:' + response ['code'].toString (), 'yellow');
         return store.set (storageKey, []);
      }
```

Things get more interesting when we realize that we also have to show the score once the user has finished tagging/deleting all the pivs in the page, whether they have already been uploaded or not.

For this reason, we will invoke `localPivsById` to obtain a map `localPivsById`, where each key is an id and each value is a local piv. This is simply to quickly be able to access a piv without going through the entire `localPivs` list.

```dart
      var localPivsById = PivService.instance.localPivsById ();
```

We will count how many local pivs in the upload queue have each of the tags. We will also count the amount of local pivs in the upload queue that are in this page.

```dart
      var localCount = {}, localQueryTotal = 0;
```

We iterate all the `pendingTags:ID` keys, of which there will be one per piv in the upload queue.

```dart
      store.getKeys ('^pendingTags:').forEach ((key) {
```

We get the piv itself. If it has been deleted, we ignore this key.

```dart
         var piv = localPivsById [key.replaceAll ('pendingTags:', '')];
         if (piv == null) return;
```

If the piv is also not in the time range of the local page, we also ignore this piv.

```dart
         if (page ['from'] > ms (piv.createDateTime) || page ['to'] < ms (piv.createDateTime)) return;
```

If we're here, this local piv in the upload queue belongs to this page. We increment our count of local pivs in the upload queue that match this page.

```dart
         localQueryTotal++;
```

We get the list of pending tags for this piv.

```dart
         var pendingTags = getList (key);
```

We now iterate each of the tags with which this piv will be tagged when uploaded; for each tag, if there's no entry for it in `localCount`, we will initialize it to 0. We will then unconditonally increment it by 1.

```dart
         pendingTags.forEach ((tag) {
            if (localCount [tag] == null) localCount [tag] = 0;
            localCount [tag]++;
         });
```

This concludes the iteration over pivs in the upload queue.

```dart
      });
```

We create an `output` list to put our results.

```dart
      var output = [];
```

We iterate the tags returned by the query to the server.

```dart
      response ['body'] ['tags'].keys.forEach ((tag) {
```

If the tag is not a user tag (user tags are tags that do not start with a lowercase letter plus two colons), we ignore it.

```dart
         if (RegExp ('^[a-z]::').hasMatch (tag)) return;
```

We get the number of pivs in the query tagged with this tag.

```dart
         var value = response ['body'] ['tags'] [tag];
```

We add an entry on `output` of the form `[tag, value]` - this is a single row of the score. This concludes the iteration of the tags in the query.

```dart
         output.add ([tag, value]);
      });
```

We iterate the keys of `localCount`, to go over the tags on the local pivs that are still on the upload queue that correspond to this page.

```dart
      localCount.keys.forEach ((tag) {
```

In the existing `output`, we try to find a row where `tag` is present.

```dart
         var matchingRow = output.indexWhere ((row) => row [0] == tag);
```

If there's no such row, it means that this tag is not yet contained in any cloud piv that corresponds to this page. Therefore, we add a new entry to `output`.

```dart
         if (matchingRow == -1) output.add ([tag, localCount [tag]]);
```

Otherwise, we increment the second element of the row by the amount of local pivs in the upload queue that contain this tag.

This concludes the iteration over the tags on local pivs in the upload queue.

```dart
         else output [matchingRow] [1] += localCount [tag];
      });
```

We sort `output` to put the rows with the highest amount of pivs first.

```dart
      output.sort ((a, b) {
         return (b [1] as int).compareTo ((a [1] as int));
      });
```

If there are more than three tags, we remove the rest of the entries and just keep the top three.

```dart
      if (output.length > 3) output = output.sublist (0, 3);
```

We add a `Total` row with the total amount of pivs that belong to this page (cloud pivs + local pivs in the upload queue).

```dart
      output.add (['Total', response ['body'] ['total'] + localQueryTotal]);
```

We get the total number of all organized pivs, which should be in the `organized` key.

```dart
      var organized = store.get ('organized');
```

If the value is present, we set a score row for it in `output`. If the value is not set because it is still being loaded, we will not add it.

```dart
      if (organized != '') output.add (['All time organized', store.get ('organized') ['total']]);
```

We set `output` in its key and close the function.

```dart
      store.set (storageKey, output);
   }
```

We now define `queryPivs`, the function that will query pivs and their associated tags from the server.

This function takes a single argument:
- `refresh`: an optional flag, by default set to `false`, which indicates whether we should query the server with the same query we did on the last query.

This function will essentially get two pieces of information:
- The metainformation of the pivs that belong to the query.
- Other info belonging to the query, namely: tags, total amount of pivs, and the data for the time header.

We don't want to bring back all the information at once because 1) that takes significant processing time on the server; 2) it can potentially require a lot of bandwidth for the client; 3) both #1 and #2 will slow down the drawing of the grid. For this reason, this function is written with performance particularly in mind.

```dart
   queryPivs ([refresh = false]) async {
```

We get `queryTags` from the store. If it is not initialized yet, we set the local variable to an empty list.

```dart
      var tags = getList ('queryTags');
```

We sort the received tags, because we'll need to compare them to the tags of a previous query; since the order of the tags doesn't affect the result of the query, we need to compare sorted list of tags to determine if the two lists are the same or not.

```dart
      tags.sort ();
```

We will determine now whether we can avoid querying the server at all. To avoid querying the server at all, three things need to happen at the same time!

1. `queryResult`, the result of the last query, is not an empty string. If it is an empty string, we haven't yet performed the first query, so we definitely need to query the server. However, if `queryResult` is an empty string but there is a query in progress, this means that there's already a first query being done but not completed, so that's why we add the nested condition that if `queryResult` is an empty string but `queryInProgress` is `true`, the first query is already happening so we can skip the query if the other two parts also allow us to.
2. `refresh` is `false`, so we are not forced to refresh the query.
3. `tags` is equal to `queryTags`.

If all three conditions are true simultaneously, we will `return` since there's nothing else to do.

In practice, this only happens when switching between the query selector view and the cloud view, where the query is already done but the view doesn't know whether the existing query is fresh.

```dart
      if ((store.get ('queryResult') != '' || store.get ('queryInProgress') == true) && refresh == false && listEquals (tags, queryTags)) return;
```

We update `queryTags` to a copy of `tags`. We want to copy it because if we modify `tags`, those changes will also affect `queryTags`, and then we won't be able to know whether changes in `tags` took place when we compare it against `queryTags`.

This, by the way, is how `queryPivs` knows whether the query has changed. The `queryTags` entry in the store is always the latest one; the last list of `queryTags` to have been queried is at the `queryTags` property of the class.

```dart
      queryTags = List.from (tags);
```

In our first query, we will load up to 1000 pivs. This is because we want the query to be lighter in both execution time and network transfer time, so we can show pivs to the user as quickly as possible.

```dart
      var firstLoadSize = 1000;
```

Before we send the query, we set the `queryInProgress` store key to `true`. This is used by the QuerySelector view to give feedback to the user on how long a query takes to complete.

Note we do this inside Dart's equivalent of a `setTimeout`. If we don't do this, for some reason, the view will be redrawn but the value of `queryInProgress` will not be updated. The timeout solves the issue.

```dart
      Future.delayed (Duration (milliseconds: 1), () {
        store.set ('queryInProgress', true);
      });
```

We will ask the server to sort pivs by latest date first.

```dart
      var sort = 'newest';
```

We invoke `POST /query` in the server. We're going to pass the `tags` we received and the `sort` parameter.

```dart
      var response = await ajax ('post', 'query', {
         'tags': tags,
         'sort': sort,
         'from': 1,
         'to': firstLoadSize
      });
```

If we didn't get back a 200 code, we have encountered an error. If we experienced a 403, there's another error message already shown by the `ajax` function informing the user that their session has expired; if the error, however, is not a 403, we inform the user with an error code `QUERY:A:CODE`.

```dart
      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error getting your pivs - CODE QUERY:A:' + response ['code'].toString (), 'yellow');
```

Whatever the error is, we cannot continue executing the function, so we remove the `queryInProgress` key and return the code from the response.

```dart
         store.remove ('queryInProgress');
         return response ['code'];
      }
```

If the tags in the query changed in the meantime, we don't do anything else in this function execution, since there will be another instance of queryPivs being executed concurrently that will be in charge of updating `queryResult`. We do return a 409 to indicate that there was a conflict between this query and another one executed shortly afterwards.

This check is a great example of why we copied `tags` before setting it to `queryTags`, and why we hold `queryTags` as part of the class. Tagaway is very interactive and the queries can take over half a second, so it's perfectly possible for the user to trigger a new query before the results of the old query are available.

Note that in this case we do not remove the `queryInProgress` key since there will be another instance of `queryPivs` being executed, which will in turn set and unset this key.

```dart
      if (! listEquals (queryTags, tags)) return 409;
```

We return the result of the body in a local variable `queryResult`.

```dart
      var queryResult = response ['body'];
```

We modify `queryResult` by invoking `localQuery`. This function will update the query result adding local pivs, tags and potentially modifying the total and time header. We do this as soon as we get the `queryResult`, but after we set the `currentMonth`.

```dart
      queryResult = localQuery (tags, queryResult);
```

If we currently have tags in our query, and we got no pivs back, it may be the case that through an untagging operation, or a deletion, we have rendered the current query an empty one. Since we don't want to show an empty query to the user, in this case we will set `currentlyTaggingUploaded` to an empty string, to get the user out of "tagging mode" in the uploaded view. We will also set `showSelectAllButtonUploaded` to an empty string, to hide the select all button.

We will also reset the query by setting `queryTags` to an empty list. There will be listeners in the views which, when we update `queryTags`, invoke `queryPivs` again, so we don't need to perform a recursive invocation to the function here.

In this case, there is nothing else to do, so we `return`. As with the case where we responded 409, in this case we do not remove the `queryInProgress` key since the act of changing `queryTags` will trigger another instance of `queryPivs` being executed, which will in turn set and unset this key.

Note that if we have local pivs that match the query, they will already be in `queryResult`, so we won't consider this to be a ronin query.

```dart
      if (queryResult ['total'] == 0 && tags.length > 0) {
         store.remove ('currentlyTaggingUploaded');
         store.remove ('showSelectAllButtonUploaded');
         return store.set ('queryTags', []);
      }
```

We now check whether the returned pivs are organized or not. If the `'o::'` tag was inside `tags`, then we know that all the pivs returned by the query are organized, so we simply set an `orgMap:ID` entry to `true` for each of them.

Note that we exclude local pivs, since those should not have an `orgMap` entry.

```dart
      if (tags.contains ('o::')) {
         queryResult ['pivs'].forEach ((piv) {
            if (piv ['local'] == true) return;
            store.set ('orgMap:' + piv ['id'], true);
         });
      }
```

Otherwise, we don't know whether they are organized or not, so we ask the server through `queryOrganizedIds`. Note we don't `await` on purpose, since we don't want to wait for the end of this operation to do the next query to the server.

Also note that we exclude local pivs from the query.

```dart
      else queryOrganizedIds (queryResult ['pivs'].where ((v) => v ['local'] == null).map ((v) => v ['id']).toList ());
```

We update `queryResult` in its entirety, with a normal (non-mute) update. This will trigger a redraw of the views depending on `queryResult` and already show pivs.

```dart
      store.set ('queryResult', {
         'total':       queryResult ['total'],
         'tags':        queryResult ['tags'],
         'pivs':        queryResult ['pivs']
      });
```

We will now remove the `queryInProgress` key. While we might have to perform another query, the tags or the total will not be updated. Since the `queryInProgress` key is only used by the query selector to show the tags and total of the current query, we can safely remove that key now and avoid unnecessarily waiting for a further query that we might execute below.

```dart
      store.remove ('queryInProgress');
```

While we are at it, it's a good idea to refresh the list of tags. This is useful if some background uploads created tags in the meantime. Note we don't `await` for `getTags`, we simply run it in parallel as we did with `queryOrganizedIds`.

```dart
      getTags ();
```

If we're here, we need to get all the remaining pivs for the query. We do so by requesting all the pivs from `firstLoadSize + 1` to a large number.

```dart
      response = await ajax ('post', 'query', {
         'tags': tags,
         'sort': sort,
         'from': firstLoadSize + 1,
         'to':   100000
      });
```

Why did we get them all and not those after `firstLoadSize`? Or why didn't we get them using extra tags for the year and the month of the last month? Quite simply, because if there is an inconsistency created by the delay between the two queries (when, in the background, there are uploads/taggings or deletions/untaggings that affect the query), we want to glaze over it by showing still the same amount of pivs as in the first query.

There might be room for improvement here, but this is a good solution for the time being. We're choosing (client-side) performance over correctness. In the absence of updates between the first and second query, there will be no inconsistencies.

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
      store.set ('queryResult', {
         'total':       queryResult ['total'],
         'tags':        queryResult ['tags'],
         'pivs':        queryResult ['pivs'] + secondQueryResult ['pivs']
      }, '', 'mute');
```

As before, we check whether the returned pivs are organized or not. If the `'o::'` tag was inside `tags`, then we know that all the pivs returned by the query are organized, so we simply set an `orgMap:ID` entry to `true` for each of them. Note that we exclude local pivs.

```dart
      if (tags.contains ('o::')) {
         secondQueryResult ['pivs'].forEach ((piv) {
            if (piv ['local'] == true) return;
            store.set ('orgMap:' + piv ['id'], true);
         });
      }
```

Otherwise, we don't know whether they are organized or not, so we ask the server through `queryOrganizedIds`. Note that we exclude local pivs from the query.

```dart
      else queryOrganizedIds (secondQueryResult ['pivs'].where ((v) => v ['local'] == null).map ((v) => v ['id']).toList ());
```

We return a 200 to indicate success and close the function.

```dart
      return 200;
   }
```

TODO: add remaining annotated source code
