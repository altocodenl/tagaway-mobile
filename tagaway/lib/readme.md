# Tagaway Mobile

## TODO

- Rename and delete tag from tag list.
   - Remove edit & delete buttons after cancel

- Hide pivs that are organized in Local
- Redesign Phone view using Today/This Week/This Month/...
- Delete piv mode (Tom):
   - Local (must ask for permissions) - note: if deleting something being uploaded, defer the deletion
   - Uploaded
- Remove localTimeHeader functionality completely

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
- cookie <str> [DISK]: cookie of current session, brought from server
- count(Local|Uploaded) <str>: count of pivs shown in bottom navigation icon for that view
- csrf <str> [DISK]: csrf token of current session, brought from server
- currentIndex <int>: 0 if on HomeView, 1 if on LocalView, 2 if on UploadedView
- currentlyTagging(Local|Uploaded) <str>: tag currently being tagged In LocalView/UploadedView
- deleteTag(Local|Uploaded) <str>: tag currently being deleted in LocalView/UploadedView
- renameTag(Local|Uploaded) <str>: tag currently being renamed in LocalView/UploadedView
- hashMap:<id> [DISK]: maps the id of a local piv to a hash.
- hometags [<str>, ...]: list of hometags, brought from the server
- initialScrollableSize <float>: the percentage of the screen height that the unexpanded scrollable sheets should take.
- lastNTags [<str>, ...]: list of the last N tags used to tag or untag, either on local or uploaded.
- localYear <str>: displayed year in LocalView time header
- localTimeHeader [<semester 1>, <semester 2>, ...]: information for UploadedView time header
   where <semester> is [<month 1>, <month 2>, ..., <month 6>]
   where <month> is [<year>, <month>, 'white|gray|green', <undefined>|<pivId of last piv in month>]
- localTimeHeaderController <page controller>: controller that drives the localTimeHeader
- localTimeHeaderPage <int>: page in localTimeHeader currently displayed.
- orgMap:<pivId> (bool): if set, it means that this uploaded piv is organized
- pendingTags:<assetId> [<str>, ...] [DISK]: list of tags that should be applied to a local piv that hasn't been uploaded yet
- pivDate:<assetId> <int>: date of each local piv
- pivMap:<assetId> <str>: maps the id of a local piv to the id of its uploaded counterpart - the converse of `rpivMap`. They are temporarily set to `true` for pivs on the upload queue.
- previousError <object> [DISK]: stores the last error experienced by the application, if any
- recurringUser <bool> [DISK]: whether the user is new to the app or has already used it - to redirect to either signup or login
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
- uploadQueue [<string>, ...] [DISK]: list of ids of pivs that are going to be uploaded.
- uploadedScrollController <scroll controller>: controller that drives the scroll of the uploaded grid
- uploadedTimeHeader [<semester 1>, <semester 2>, ...]: information for UploadedView time header
   where <semester> is [<month 1>, <month 2>, ..., <month 6>]
   where <month> is [<year>, <month>, 'white|gray|green', <undefined>|<pivId of last piv in month>]
- uploadedTimeHeaderController <page controller>: controller that drives the uploadedTimeHeader
- uploadedTimeHeaderPage <int>: page in uploadedTimeHeader currently displayed.
- uploadedYear <str>: displayed year in UploadedView time header
- usertags [<string>, ...]: list of user tags, computed from the tags bruog
- userWasAskedPermission (boolean) [DISK]: whether the user was already asked for piv access permission once
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
