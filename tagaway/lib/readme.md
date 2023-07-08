# Tagaway Mobile

## TODO

- Message and icon when page is empty (You're all done here!) (Tom)
- Rename uploadService to pivService
- Remove edit & delete buttons after cancel or when tapping anywhere else
- When untagging a piv on the upload queue (after checking that it has no other tags yet), remove it from the upload queue
- Handle >= 400 errors with snackbar on tagService and uploadService
- When clicking on month on time header, jump to relevant scroll position.
- Design distinctive icon for app (Tom)
- Draggable selection (Tom)
- Tutorial (Tom)
- Add login flow with Google, Apple and Facebook (Tom)

## Store structure

```
- account: {username: STRING, email: STRING, type: STRING, created: INTEGER, usage: {limit: INTEGER, byfs: INTEGER, bys3: INTEGER}, geo: true|UNDEFINED , geoInProgress: true|UNDEFINED, suggestGeotagging: true|UNDEFINED, suggestSelection: true|UNDEFINED}
- cookie <str> [DISK]: cookie of current session, brought from server - deleted on logout.
- count(Local|Uploaded) <str>: count of pivs shown in bottom navigation icon for that view
- csrf <str> [DISK]: csrf token of current session, brought from server - deleted on logout.
- currentIndex <int>: 0 if on HomeView, 1 if on LocalView, 2 if on UploadedView
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
- localPages <list>: `[{name: STRING: pivs: [<asset>, ...], total: INTEGER, from: INTEGER, to: INTEGER}, ...]` - contains all the pages of local pivs to be shown, one per grid.
- localPagesListener <listener>: listener that triggers the function to compute the local pages.
- localYear <str>: displayed year in LocalView time header
- orgMap:<pivId> (bool): if set, it means that this uploaded piv is organized
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
- startTaggingModal (boolean): used to determine blue popup to start tagging on LocalView
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
- Select APK + next
- Create new key/use existing
- Check on box for remember password
- Use release & create
- When it's done, it will appear in Android folder
- Build will be in android + app + release

## Annotated source code

For now, we only have annotated fragments of the code. This might be expanded comprehensively later.
