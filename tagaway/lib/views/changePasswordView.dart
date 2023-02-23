import 'package:flutter/material.dart';
import 'package:tagaway/services/authService.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/offlineView.dart';

class ChangePasswordView extends StatefulWidget {
  static const String id = 'change_password';
  const ChangePasswordView({Key? key}) : super(key: key);

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _repeatNewPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kGreyDarker, size: 30),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Change your password', style: kSubPageAppBarTitle),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
            child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: _currentPasswordController,
                    autofocus: true,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: 'Enter your current password',
                      labelStyle: kPlainText,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: _newPasswordController,
                    autofocus: true,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: 'Enter your new password',
                      labelStyle: kPlainText,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 20),
                  child: TextField(
                    controller: _repeatNewPasswordController,
                    autofocus: true,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: 'Repeat your new password',
                      labelStyle: kPlainText,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                    ),
                  ),
                ),
                RoundedButton(
                    title: 'Save',
                    colour: kAltoBlue,
                    onPressed: () {
                      AuthService.instance
                          .changePassword(
                              _currentPasswordController.text,
                              _newPasswordController.text,
                              _repeatNewPasswordController.text)
                          .then((value) {
                        if (value == 0)
                          return Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const OfflineScreen()));
                        if (value == 1)
                          return SnackBarGlobal.buildSnackBar(
                              context,
                              'New password and repeat new password must be the same.',
                              'yellow');
                        if (value == 403)
                          return SnackBarGlobal.buildSnackBar(
                              context, 'Incorrect password.', 'red');
                        if (value == 500)
                          return SnackBarGlobal.buildSnackBar(context,
                              'Something is wrong on our side. Sorry.', 'red');
                        if (value == 200)
                          return SnackBarGlobal.buildSnackBar(
                              context, 'Change password successful!', 'green');
                      });
                    })
              ],
            ),
          ),
        )),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {},
      //   backgroundColor: kAltoBlue,
      //   label: const Text('Save', style: kSelectAllButton),
      // ),
    );
  }
}
