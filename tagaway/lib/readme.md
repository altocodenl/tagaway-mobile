# Tagaway Mobile

## TODO

- **Fix 404s when tagging with piv with no id**
- Delete single piv from carrousel
- Delete piv mode (uploaded)
- Delete piv mode (local): if deleting something being uploaded, defer the deletion.
- Check if piv.vid is 'pending' or 'error' and warn the user, rather than trying to load the video anyway
- Fix 400 when querying with o:: double
- Fix how carrousel looks when an image is rotated
- Carrousel: when zooming into image, make the image take the entire screen (Tom)
- Fix ronin queries after untagging/deleting

- Calculate viewport dynamically and make views use its proportions
- Fix amount of tags shown on top bar of uploaded, based on tag length
- Show number of pivs to be still uploaded
- Performance
   - Lower amount of pivs
   - Do not default to "everything"
   - Test hoop from US
- Publish to both stores
- On scroll, change selected months in time header
- When loading local pivs, check for existence and remove stale entries from pivMap
- Dynamize "you're looking at" (more than two tags)
- When clicking on month on time header, jump to relevant scroll position
- When closing and re-opening phone, revive uploads that were not finished
- Signup
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
- Add login flow with Google and Facebook

## Store structure

```
- account: {username: STRING, email: STRING, type: STRING, created: INTEGER, usage: {limit: INTEGER, byfs: INTEGER, bys3: INTEGER}, geo: true|UNDEFINED , geoInProgress: true|UNDEFINED, suggestGeotagging: true|UNDEFINED, suggestSelection: true|UNDEFINED}
- cookie <str> [DISK]: cookie of current session, brought from server
- csrf <str> [DISK]: csrf token of current session, brought from server
- currentIndex <int>: 0 if on HomeView, 1 if on LocalView, 2 if on UploadedView
- currentlyTagging(Local|Uploaded) <str>: tag currently being tagged In LocalView/UploadedView
- hometags [<str>, ...]: list of hometags, brought from the server
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
- uploadedTimeHeader [<semester 1>, <semester 2>, ...]: information for UploadedView time header
   where <semester> is [<month 1>, <month 2>, ..., <month 6>]
   where <month> is [<year>, <month>, 'white|gray|green', <undefined>|<pivId of last piv in month>]
- uploadedYear <str>: displayed year in UploadedView time header
- usertags [<string>, ...]: list of user tags, computed from the tags bruog
- userWasAskedPermission (boolean) [DISK]: whether the user was already asked for piv access permission once
```
