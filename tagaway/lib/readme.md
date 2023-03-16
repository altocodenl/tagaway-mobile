# Tagaway Mobile

## TODO

- Signup
   - Make signup call service
   - Client-side validations for inputs
      - Check repetitions for username, email and password
      - Check valid username, email & password
   - Handle errors with snackbar:
      - Username repeated
      - Email repeated
      - Too many users
   - On 200 (success)
      - With a materialbanner let user know they have to validate account through email link
      - Redirect to login

- Login
   - On error, snackbar:
      - Need validation
      - Wrong username/email/password combination
   - Send to distributor on success

- Recover/reset
   - Move password recovery service to auth and check that it works
   - On 200
      - Check that delay is enough to lower keyboard
      - Send to distributor
      - See snackbar success message

- Delete account
   - Test that it works

- Sidebar
   - Dynamize usage (get account & display usage)

- Add home tags
   - Make it look better
   - When clicking on a tag, send back to my home tags view

- Edit home tags
   - Comment out drag icon

- General
   - Autoindent all *views* (not the services or ui_constants)
   - Redirect in the same way everywhere and use strings, not imported views at the top. Also rename view ids (on some views only) to keep things short.
