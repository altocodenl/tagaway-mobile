# Tagaway Mobile

## TODO

- Signup
   - Tighten up client-side validations for inputs (Mono)
   - Handle errors with snackbar (Tom)
        - Errors (Tom's Notes):
          - usernames are too short or invalid for any other reason => NOT FINISHED
          - password is too short or is invalid for any other reason => NOT FINISHED
          - username already exists => 403 {error: 'username'}
          - email already registered => 403 {error: 'email'}
          - we have too many users. => ?

- Sidebar
   - Dynamize usage (get account & display usage) (Mono)

- Time header (both LocalView & UploadedView)
   - Change year as you scroll
   - On scroll, change active month (Mono)
   - When clicking on month, jump to relevant scroll position (Mono)

- When closing and re-opening phone, revive uploads that were not finished (Mono)

- When untagging last tag of a piv, mark it as unorganized (also LocalView)

- Uploaded filter (Mono)

- General
   - Redirect in the same way everywhere and use strings, not imported views at the top. Also rename view ids (on some views only) to keep things short
   - Move utility functions from constants to toolsService

## Store structure

```
- cookie <str> [DISK]: cookie of current session, brought from server
- csrf <str> [DISK]: csrf token of current session, brought from server
- currentIndex <int>: 0 if on HomeView, 1 if on LocalView, 2 if on UploadedView
- currentlyTagging <str>: tag currently being tagged
- hometags [<str>, ...]: list of hometags, brought from the server
- localTimeHeader [<semester 1>, <semester 2>, ...]: information for UploadedView time header
   where <semester> is [<month 1>, <month 2>, ..., <month 6>]
   where <month> is [<year>, <month>, 'white|gray|green', <undefined>|<pivId of last piv in month>]
- newTag <str>: name of new tag being created in LocalView & UploadedView
- orgMap:<pivId> (bool): if set, it means that this uploaded piv is organized
- pendingTags:<assetId> [<str>, ...]: list of tags that should be applied to a local piv that hasn't been uploaded yet
- pivDate:<assetId> <int>: date of each local piv
- pivMap:<assetId> <str> [DISK]: maps the id of a local piv to the id of its uploaded counterpart
- recurringUser <bool> [DISK]: whether the user is new to the app or has already used it - to redirect to either signup or login
- queryResult {total: <int>, tags: {<tag>: <int>, ...}, pivs: [{...}, ...], timeHeader: {<year:month>: true|false, ...}}: result of query, brought from server
- queryTags [<string>, ...]: list of tags of the current query
- rpivMap:<pivId> <str> [DISK]: maps the id of an uploaded piv to the id of its local counterpart
- startTaggingModal (boolean): used to determine blue popup to start tagging on LocalView
- swiped (boolean): controls the swipable tag list on LocalView & UploadedView
- taggedPivCount (int): shows how many pivs are tagged with the current tag on LocalView & UploadedView
- tagMap:<assetId|pivId> (bool): if set, it means that this piv (whether local or uploaded) is tagged with the current tag
- tags [<string>, ...]: list of tags relevant to the current query, brought from the server
- uploadedTimeHeader [<semester 1>, <semester 2>, ...]: information for UploadedView time header
   where <semester> is [<month 1>, <month 2>, ..., <month 6>]
   where <month> is [<year>, <month>, 'white|gray|green', <undefined>|<pivId of last piv in month>]
- usertags [<string>, ...]: list of user tags, computed from the tags bruog
- userWasAskedPermission (boolean) [DISK]: whether the user was already asked for piv access permission once
```
