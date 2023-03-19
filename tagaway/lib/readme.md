# Tagaway Mobile

## TODO

- Signup
   - Make signup view call service (Mono)
   - Client-side validations for inputs (Mono)
      - Check repetitions for username, email and password (TOM DID IT)
      - Check valid username, email & password (TOM DID IT)
   - Handle errors with snackbar (Tom)
        - Errors (Tom's Notes):
          - usernames are too short or invalid for any other reason => NOT FINISHED
          - password is too short or is invalid for any other reason => NOT FINISHED
          - username already exists => 403 {error: 'username'}
          - email already registered => 403 {error: 'email'}
          - we have too many users. => ?

- Login
   -IN THEORY ALL DONE, NEEDS TESTING

- Delete account (Tom)
   - Test that it works

- Sidebar
   - Dynamize usage (get account & display usage) (Mono)

- Add home tags
   - Make it look better (Tom)
   - When clicking on a tag, send back to my home tags view (Tom)

- Home tags
   - When clicking on hometag, send to uploaded with that tag in the query (Mono)

- Local
   - Time header
      - Make service return semesters (Mono)
      - Create builder for semesters (Tom)
      - On scroll, change active month (Mono)
      - When clicking on month, jump to relevant scroll position (Mono)
   - When closing and re-opening phone, revive uploads that were not finished (Mono)

- Uploaded
   - Search view (copy the other one) (Tom) => I'll do it after finishing 'Add Tags' tasks, since most of that work will impact this view.
   - Dynamize *everything* (Mono)

- General
   - Redirect in the same way everywhere and use strings, not imported views at the top. Also rename view ids (on some views only) to keep things short
   - Move utility functions from constants to toolsService
