import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tools.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/views/BottomNavigationBar.dart';
import 'package:tagaway/views/accountView.dart';
import 'package:tagaway/views/addHometagsView.dart';
import 'package:tagaway/views/deleteAccountView.dart';
import 'package:tagaway/views/distributorView.dart';
import 'package:tagaway/views/editHometagsView.dart';
import 'package:tagaway/views/homeView.dart';
import 'package:tagaway/views/localView.dart';
import 'package:tagaway/views/loginView.dart';
import 'package:tagaway/views/manageTagsView.dart';
import 'package:tagaway/views/offlineView.dart';
import 'package:tagaway/views/photoAccessNeededView.dart';
import 'package:tagaway/views/querySelectorView.dart';
import 'package:tagaway/views/recoverPasswordView.dart';
import 'package:tagaway/views/requestPermissionView.dart';
import 'package:tagaway/views/shareView.dart';
import 'package:tagaway/views/signupFormView.dart';
import 'package:tagaway/views/signupView.dart';
import 'package:tagaway/views/uploadedView.dart';

int initT = DateTime.now().millisecondsSinceEpoch;

// Used to access content in the service
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

void reportError(exception, stacktrace, context) {
  // Ignore this annoying dev error.
  if (exception.toString().contains(
      'A KeyUpEvent is dispatched, but the state shows that the physical key is not pressed.'))
    return;

  var error = {
    'errorTime': now(),
    'exception': exception,
    'stackTrace': stacktrace,
    'context': context,
    'version': version
  };
  debug(['CAUGHT ERROR', error]);
  // Save the error to disk in case we lose connectivity
  StoreService.instance.set('previousError', error, 'disk');
  // Submit the error to the server
  ajax('post', 'error', error);
}

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    reportError(details.exception.toString(), details.stack.toString(),
        details.context.toString());
  };

  Isolate.current.addErrorListener(RawReceivePort((dynamic pair) {
    reportError(pair[0].toString(), pair[1].toString(), '');
  }).sendPort);

  runZonedGuarded(() {
    runApp(const Tagaway());
    // Reload store
    StoreService.instance.load();
    // Submit previous error if any
    StoreService.instance.reportPreviousError();
  }, (error, stacktrace) {
    reportError(error.toString(), stacktrace.toString(), '');
  });
}

class Tagaway extends StatelessWidget {
  const Tagaway({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Distributor(),
      routes: {
        'accountView': (context) => const AccountView(),
        'addHomeTags': (context) => const AddHometagsView(),
        'bottomNavigation': (context) => const BottomNavigationView(),
        'deleteAccount': (context) => const DeleteAccount(),
        'distributor': (context) => const Distributor(),
        'editHomeTags': (context) => const EditHometagsView(),
        'home': (context) => const HomeView(),
        'local': (context) => const LocalView(),
        'login': (context) => const LoginView(),
        'offline': (context) => const OfflineView(),
        'photoAccessNeeded': (context) => const PhotoAccessNeededView(),
        'querySelector': (context) => const QuerySelectorView(),
        'recoverPassword': (context) => const RecoverPasswordView(),
        'requestPermission': (context) => const RequestPermissionView(),
        'share': (context) => const ShareView(),
        'signup': (context) => const SignUpView(),
        'manageTags': (context) => const ManageTagsView(),
        'signupForm': (context) => const SignUpFormView(),
        'uploaded': (context) => const UploadedView(),
      },
    );
  }
}
