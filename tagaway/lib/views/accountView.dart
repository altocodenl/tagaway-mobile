import 'package:flutter/material.dart';
import 'package:tagaway/services/authService.dart';
import 'package:tagaway/services/sizeService.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/offlineView.dart';

class AccountView extends StatefulWidget {
  static const String id = 'accountView';

  const AccountView({Key? key}) : super(key: key);

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _repeatNewPasswordController =
      TextEditingController();
  bool openChangePassword = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(color: kGreyDarker, size: 30),
          backgroundColor: Colors.grey[50],
          centerTitle: true,
          title: const Text('Settings', style: kSubPageAppBarTitle),
        ),
        body: SafeArea(
            child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20.0, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Geotagging',
                        style: SizeService.instance.screenWidth(context) < 380
                            ? kSnackBarText
                            : kTagListElementText,
                      ),
                      const GeotaggingSwitch(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Password',
                        style: SizeService.instance.screenWidth(context) < 380
                            ? kSnackBarText
                            : kTagListElementText,
                      ),
                      RoundedButton(
                          title: 'Change Password',
                          colour: kGreyDarker,
                          onPressed: () {
                            setState(() {
                              openChangePassword = !openChangePassword;
                            });
                          }),
                    ],
                  ),
                ),
                Visibility(
                  visible: openChangePassword,
                  child: Column(
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
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
                              if (value == 0) {
                                return Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => const OfflineView()));
                              }
                              if (value == 1) {
                                return SnackBarGlobal.buildSnackBar(
                                    context,
                                    'New password and repeat new password must be the same.',
                                    'yellow');
                              }
                              if (value == 403) {
                                return SnackBarGlobal.buildSnackBar(
                                    context, 'Incorrect password.', 'red');
                              }
                              if (value == 500) {
                                return SnackBarGlobal.buildSnackBar(
                                    context,
                                    'Something is wrong on our side. Sorry.',
                                    'red');
                              }
                              if (value == 200) {
                                _currentPasswordController.clear();
                                _newPasswordController.clear();
                                _repeatNewPasswordController.clear();
                                return SnackBarGlobal.buildSnackBar(context,
                                    'Change password successful!', 'green');
                              }
                            });
                          }),
                    ],
                  ),
                  replacement: Container(),
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }
}

class GeotaggingSwitch extends StatefulWidget {
  const GeotaggingSwitch({super.key});

  @override
  State<GeotaggingSwitch> createState() => _GeotaggingSwitchState();
}

class _GeotaggingSwitchState extends State<GeotaggingSwitch> {
  dynamic cancelListener;
  dynamic account = {'geo': false};

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance.listen(['account'], (v1) {
      setState(() {
        if (v1 != '') account = v1;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Transform.scale(
          scale: SizeService.instance.screenWidth(context) < 380 ? 1.2 : 1.5,
          child: Switch(
            activeTrackColor: kAltoBlue,
            activeColor: Colors.white,
            inactiveTrackColor: kGreyLight,
            value: account['geo'] != null,
            onChanged: (bool value) {
              setState(() {
                AuthService.instance.geotagging(value ? 'enable' : 'disable');
                // We do this to give instant feedback.
                account = {'geo': value};
              });
            },
          ),
        ),
      ],
    );
  }
}
