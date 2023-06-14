# Tagaway Mobile

## TODO

- Hashes
   - Compute hashes on client-side on startup
   - Add them to map
   - Check for existence and remove stale entries from pivMap
   - Endpoint to get ids of pivs for list of hashes.
   - Move to isolate
- Hide pivs that are organized in Local
- Redesign Phone view using Today/This Week/This Month/...
- Delete piv mode (Tom):
   - Local (must ask for permissions) - note: if deleting something being uploaded, defer the deletion
   - Uploaded

- Try out putting last 3 used tags on top of list
- Bug: in Phone, when untagging a piv that is on the queue to be uploaded, remove it from the queue.
- Bug: if user is logged out, do not revive uploads. Or perhaps better, clear almost all keys on logout.
- When clicking on month on time header, jump to relevant scroll position.
- Signup
  - Email validation process.
  - Welcome email and communication with user
  - Make sure it says tagaway in all emails to user
  - Tighten up client-side validations for inputs
- Handle errors with snackbar
   - signup
      - usernames are too short or invalid for any other reason => NOT FINISHED
      - password is too short or is invalid for any other reason => NOT FINISHED
      - username already exists => 403 {error: 'username'}
      - email already registered => 403 {error: 'email'}
      - we have too many users. => ?
   - Go through other services and notify with snackbar when there's an error
- Design distinctive icon for app (Tom)
- Design manage tags view (rename, delete) (Tom)
- Tutorial (Tom)
- Fix zoom-in zoom-out when opening piv (Tom/Mono)
- Add login flow with Google, Apple and Facebook (Tom)

## Store structure

```
- account: {username: STRING, email: STRING, type: STRING, created: INTEGER, usage: {limit: INTEGER, byfs: INTEGER, bys3: INTEGER}, geo: true|UNDEFINED , geoInProgress: true|UNDEFINED, suggestGeotagging: true|UNDEFINED, suggestSelection: true|UNDEFINED}
- cookie <str> [DISK]: cookie of current session, brought from server
- count(Local|Uploaded) <str>: count of pivs shown in bottom navigation icon for that view
- csrf <str> [DISK]: csrf token of current session, brought from server
- currentIndex <int>: 0 if on HomeView, 1 if on LocalView, 2 if on UploadedView
- currentlyTagging(Local|Uploaded) <str>: tag currently being tagged In LocalView/UploadedView
- hometags [<str>, ...]: list of hometags, brought from the server
- initialScrollableSize <float>: the percentage of the screen height that the unexpanded scrollable sheets should take.
- localYear <str>: displayed year in LocalView time header
- localTimeHeader [<semester 1>, <semester 2>, ...]: information for UploadedView time header
   where <semester> is [<month 1>, <month 2>, ..., <month 6>]
   where <month> is [<year>, <month>, 'white|gray|green', <undefined>|<pivId of last piv in month>]
- localTimeHeaderController <page controller>: controller that drives the localTimeHeader
- localTimeHeaderPage <int>: page in localTimeHeader currently displayed.
- orgMap:<pivId> (bool): if set, it means that this uploaded piv is organized
- pendingTags:<assetId> [<str>, ...]: list of tags that should be applied to a local piv that hasn't been uploaded yet
- pivDate:<assetId> <int>: date of each local piv
- pivMap:<assetId> <str> [DISK]: maps the id of a local piv to the id of its uploaded counterpart
- previousError <object> [DISK]: stores the last error experienced by the application, if any
- recurringUser <bool> [DISK]: whether the user is new to the app or has already used it - to redirect to either signup or login
- queryFilter <str>: contains the filter (if any) used to filter out tags in the query/search view
- queryResult: {total: <int>, tags: {<tag>: <int>, ...}, pivs: [{...}, ...], timeHeader: {<year:month>: true|false, ...}}: result of query, brought from server
- queryTags: [<string>, ...]: list of tags of the current query
- rpivMap:<pivId> <str> [DISK]: maps the id of an uploaded piv to the id of its local counterpart
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

### `tagService.js`

TODO: add annotated source code from the beginning of the file.

```javascript
   getTaggedPivs (String tag, String type) async {
      var existing = [], New = [];
      StoreService.instance.store.keys.toList ().forEach ((k) {
         if (RegExp ('^tagMap:').hasMatch (k)) existing.add (k.split (':') [1]);
         if (type == 'local') {
            if (RegExp ('^pendingTags:').hasMatch (k)) {
               if (StoreService.instance.get (k).contains (tag)) New.add (k.split (':') [1]);
            }
         }
      });
      var response = await ajax ('post', 'query', {
         'tags':    [tag],
         'sort':    'newest',
         'from':    1,
         'to':      100000,
         'idsOnly': true
      });
      var queryIds;
      if (type == 'uploaded') queryIds = StoreService.instance.get ('queryResult') ['pivs'].map ((v) => v ['id']);
      response ['body'].forEach ((v) {
         if (type == 'uploaded') {
            if (queryIds.contains (v)) New.add (v);
         }
         else {
            var id = StoreService.instance.get ('rpivMap:' + v);
            if (id != '') New.add (id);
         }
      });
      New.forEach ((id) {
        if (! existing.contains (id)) StoreService.instance.set ('tagMap:' + id, true);
        else existing.remove (id);
      });
      existing.forEach ((id) {
        StoreService.instance.set ('tagMap:' + id, '');
      });

      StoreService.instance.set ('taggedPivCount' + (type == 'local' ? 'Local' : 'Uploaded'), New.length);
   }
```

TODO: add annotated source code until the end of the file.
