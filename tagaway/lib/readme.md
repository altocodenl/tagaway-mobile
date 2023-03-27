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

- Local
   - Time header
      - On scroll, change active month (Mono)
      - When clicking on month, jump to relevant scroll position (Mono)
   - When closing and re-opening phone, revive uploads that were not finished (Mono)

- Uploaded
   - Dynamize *everything* (Mono)
      - Refresh uploaded when local uploads something
      - Tagging
         - Show green/gray icon on pivs (toggle itself).
         - Requery after done.
      - Time header
      - Filter

- General
   - Redirect in the same way everywhere and use strings, not imported views at the top. Also rename view ids (on some views only) to keep things short
   - Move utility functions from constants to toolsService
