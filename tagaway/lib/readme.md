# Tagaway Mobile

## TODO

- Update orgMap when untagging by checking against server.
- Handle >= 400 errors with snackbar on tagService and uploadService
- Open local pivs (Tom/Mono)
- Go back home button on top left of cloud grid (Tom)
- Create settings view with Change Password and enabled/disable geotagging (Tom)
- Home: add query selector search button, big one, on the bottom
- Home: Make uploaded grid only accessible through clicking on a tag in home or the query selector. Liberate space on bottom navigation, put icon, put "coming soon!"
- Write a QA script (Tom)
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
- Remove edit & delete tag buttons after cancel or when tapping anywhere else
- Home: add tabs for pinned vs recent, remove add hometags button if not on pinned
- Home: display tags in a different way, including the last piv
- Design distinctive icon for app (Tom)
- Draggable selection (Tom)
- Tutorial (Tom)
- Add login flow with Google, Apple and Facebook (Tom)

## Store structure

```
- account: {username: STRING, email: STRING, type: STRING, created: INTEGER, usage: {limit: INTEGER, byfs: INTEGER, bys3: INTEGER}, geo: true|UNDEFINED, geoInProgress: true|UNDEFINED, suggestGeotagging: true|UNDEFINED, suggestSelection: true|UNDEFINED}
- context: a reference to the context of a Flutter widget, which comes useful for services that want to draw widgets into views.
- cookie <str> [DISK]: cookie of current session, brought from server - deleted on logout.
- count(Local|Uploaded) <str>: count of pivs shown in bottom navigation icon for that view
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
- lastNTags [<str>, ...]: list of the last N tags used to tag or untag, either on local or uploaded.
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

The function `computeLocalPages` will create each of the "pages" of the local view. Each page represents a time period and contains zero or more local pivs.

The function takes no arguments, since it gets all its info from the store. While the function is synchronous, it will set up a couple of asynchronous operation the first time is executed.

```dart
   computeLocalPages () {
```

This function is not that cheap to execute; we will see later that there's a timer that periodically checks the `recomputeLocalPages` flag to see if it's necessary to compute the local pages again. If we are here, it means that `recomputeLocalPages` is set to `true`, so we will make `computeLocalPages` set it to `false` to indicate that the local pages will be updated now.

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

We iterate the pages, noting both the page itself and its index.

```dart
      pages.asMap ().forEach ((index, page) {
```

We first get the existing page at the `index` position, which is stored at `localPage:INDEX`.

```dart
         var existingPage = StoreService.instance.get ('localPage:' + index.toString ());
```

If the page does not exist yet (and the store therefore returns an empty string), or if the old page is not exactly the same as the new page, we then update `localPage:INDEX` with the new page.

```dart
         if (existingPage == '' || ! DeepCollectionEquality ().equals (existingPage, page)) {
            StoreService.instance.set ('localPage:' + index.toString (), page);
         }
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
         Timer.periodic(Duration(milliseconds: 200), (timer) {
            if (recomputeLocalPages == true) computeLocalPages ();
         });
```

This concludes the initialization logic and the function itself.

```dart
      }
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

We invoke the `tagPivById` function, passing the `cloud`Id`, the `tag` itself and the `untag` flag. This function will be the one making the call to the server. We store the code returned by the call in a variable `code`.

```dart
         var code = await tagPivById (cloudId, tag, untag);
```

If we are tagging a local piv, we can expect either a 200 (success) or a 404. The latter will happen if the cloud counterpart of the local piv we are tagging was removed from another tagaway client (for example, a web browser).

If we are tagging a cloud piv, a 404 is considerably more unlikely, because the piv had to be queried recently in order to be shown now to the user - otherwise, the user could not initiate its tagging. Unless the user is concurrently using two tagaway clients (and deleting uploaded pivs on one of them), this should not happen. For all of this, we only expect a 200 for tagging/untagging cloud pivs.

```dart
         var unexpectedError = type == 'local' ? (code != 200 && code != 404) : code != 200;
```

If there was an unexpected error, we invoke the `showSnackbar` function with an error message indicating the erorr code. The error code will be `TAG:L:CODE` (for local pivs) and `TAG:C:CODE` for cloud pivs.

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
