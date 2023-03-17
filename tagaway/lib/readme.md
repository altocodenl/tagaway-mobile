# Tagaway Mobile

## TODO

- Signup
   - Make signup view call service (Mono)
   - Client-side validations for inputs (Mono)
      - Check repetitions for username, email and password
      - Check valid username, email & password
   - Handle errors with snackbar (Tom)
      - Username repeated
      - Email repeated
      - Too many users
   - On success (Tom)
      - With a materialbanner let user know they have to validate account through email link
      - Redirect to login

- Login
   - On error, snackbar (Tom)
      - Need validation
      - Wrong username/email/password combination
   - Send to distributor on success (Tom)

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
   - Search view (copy the other one) (Tom)
   - Dynamize *everything* (Mono)

- General
   - Redirect in the same way everywhere and use strings, not imported views at the top. Also rename view ids (on some views only) to keep things short
