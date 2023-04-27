# Tagaway Mobile

## TODO

- Fix ronin queries after untagging/deleting
- Dynamize "you're looking at" (more than two tags)
- When loading local pivs, check for existence and remove stale entries from pivMap
- On scroll, change selected months in time header
- When clicking on month on time header, jump to relevant scroll position
- Performance
   - Load pivs incrementally: to get all uploaded pivs in the query without having to get them all at the beginning: get the first 100. Put an array with N empty objects on the store key. Then get the rest of the pivs and implement a mute update that doesn't redraw the view. Then let the builder reference the piv itself by index.
   - Do not default to "everything"
   - Test hoop from US: check latency, then check if we can do HTTPS with two IPs to the same domain. Also check whether that IP would be normally preferred on the Americas.
- Signup
  - Check email flow says 'Tagaway'
  - Tighten up client-side validations for inputs
  - Handle errors with snackbar
      - usernames are too short or invalid for any other reason => NOT FINISHED
      - password is too short or is invalid for any other reason => NOT FINISHED
      - username already exists => 403 {error: 'username'}
      - email already registered => 403 {error: 'email'}
      - we have too many users. => ?
- General
   - Redirect in the same way everywhere and use strings, not imported views at the top. Also rename view ids (on some views only) to keep things short
   - Move utility functions from constants to toolsService
- Compute hashes on client and use this to query the server to create pivMap entries for pivs with no pivMap entry

- Calculate viewport dynamically and make views use its proportions (Tom)
  - Carrousel > Photo display
- Delete piv mode (uploaded) (Tom)
- Delete piv mode (local): if deleting something being uploaded, defer the deletion. (Tom)
- No separate modal for new tag, just create or select (Tom)
- Figure out mechanism for showing recent tags on top: pinning tags, keep last n tags used, or both? (Tom)
- Investigate why sometimes local items that are uploaded are not being shown as organized (is it lack of a pivMap entry? Or is it not being displayed?) (Tom)
- Publish to both stores (Tom)
- Add login flow with Google, Apple and Facebook (Tom)

## Store structure

```
- account: {username: STRING, email: STRING, type: STRING, created: INTEGER, usage: {limit: INTEGER, byfs: INTEGER, bys3: INTEGER}, geo: true|UNDEFINED , geoInProgress: true|UNDEFINED, suggestGeotagging: true|UNDEFINED, suggestSelection: true|UNDEFINED}
- cookie <str> [DISK]: cookie of current session, brought from server
- csrf <str> [DISK]: csrf token of current session, brought from server
- currentIndex <int>: 0 if on HomeView, 1 if on LocalView, 2 if on UploadedView
- currentlyTagging(Local|Uploaded) <str>: tag currently being tagged In LocalView/UploadedView
- hometags [<str>, ...]: list of hometags, brought from the server
- initialScrollableSize <float>: the percentage of the screen height that the unexpanded scrollable sheets should take.
- localYear <str>: displayed year in LocalView time header
- localTimeHeader [<semester 1>, <semester 2>, ...]: information for UploadedView time header
   where <semester> is [<month 1>, <month 2>, ..., <month 6>]
   where <month> is [<year>, <month>, 'white|gray|green', <undefined>|<pivId of last piv in month>]
- newTag(Local|Uploaded) <str>: name of new tag being created in LocalView/UploadedView
- orgMap:<pivId> (bool): if set, it means that this uploaded piv is organized
- pendingTags:<assetId> [<str>, ...]: list of tags that should be applied to a local piv that hasn't been uploaded yet
- pivDate:<assetId> <int>: date of each local piv
- pivMap:<assetId> <str> [DISK]: maps the id of a local piv to the id of its uploaded counterpart
- recurringUser <bool> [DISK]: whether the user is new to the app or has already used it - to redirect to either signup or login
- queryResult: {total: <int>, tags: {<tag>: <int>, ...}, pivs: [{...}, ...], timeHeader: {<year:month>: true|false, ...}}: result of query, brought from server
- queryTags: [<string>, ...]: list of tags of the current query
- rpivMap:<pivId> <str> [DISK]: maps the id of an uploaded piv to the id of its local counterpart
- startTaggingModal (boolean): used to determine blue popup to start tagging on LocalView
- swiped(Local|Uploaded) (boolean): controls the swipable tag list on LocalView/UploadedView
- taggedPivCount(Local|Uploaded) (int): shows how many pivs are tagged with the current tag on LocalView/UploadedView
- tagMap:<assetId|pivId> (bool): if set, it means that this piv (whether local or uploaded) is tagged with the current tag
- tags [<string>, ...]: list of tags relevant to the current query, brought from the server
- uploadQueue [<string>, ...] [DISK]: list of ids of pivs that are going to be uploaded.
- uploadedTimeHeader [<semester 1>, <semester 2>, ...]: information for UploadedView time header
   where <semester> is [<month 1>, <month 2>, ..., <month 6>]
   where <month> is [<year>, <month>, 'white|gray|green', <undefined>|<pivId of last piv in month>]
- uploadedYear <str>: displayed year in UploadedView time header
- usertags [<string>, ...]: list of user tags, computed from the tags bruog
- userWasAskedPermission (boolean) [DISK]: whether the user was already asked for piv access permission once
```

### Creating a build

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
