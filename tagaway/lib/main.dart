import 'package:flutter/material.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/services/tools.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/views/BottomNavigationBar.dart';
import 'package:tagaway/views/addHometagsView.dart';
import 'package:tagaway/views/changePasswordView.dart';
import 'package:tagaway/views/deleteAccountView.dart';
import 'package:tagaway/views/distributorView.dart';
import 'package:tagaway/views/editHometagsView.dart';
import 'package:tagaway/views/homeView.dart';
import 'package:tagaway/views/localView.dart';
import 'package:tagaway/views/loginView.dart';
import 'package:tagaway/views/photoAccessNeededView.dart';
import 'package:tagaway/views/querySelectorView.dart';
import 'package:tagaway/views/recoverPasswordView.dart';
import 'package:tagaway/views/requestPermissionView.dart';
import 'package:tagaway/views/signupFormView.dart';
import 'package:tagaway/views/signupView.dart';
import 'package:tagaway/views/uploadedView.dart';

int initT = DateTime.now().millisecondsSinceEpoch;

// Used to access content in the service
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    // Ignore this annoying dev error.
    if (details.exception.toString().contains(
        'A KeyUpEvent is dispatched, but the state shows that the physical key is not pressed.'))
      return;

    var error = {
      'errorTime': now(),
      'exception': details.exception.toString(),
      'stackTrace': details.stack.toString(),
      'library': details.library,
      'context': details.context.toString(),
      'version': version
    };
    debug(['CAUGHT ERROR', error]);
    // Save the error to disk in case we lose connectivity
    StoreService.instance.set('previousError', error, 'disk');
    // Submit the error to the server
    ajax('post', 'error', error);
  };
  runApp(const Tagaway());
  // Reload store
  StoreService.instance.load();
  // Submit previous error if any
  StoreService.instance.reportPreviousError();
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
        'distributor': (context) => const Distributor(),
        'signup': (context) => const SignUpView(),
        'signupForm': (context) => const SignUpFormView(),
        'login': (context) => const LoginView(),
        'recoverPassword': (context) => const RecoverPasswordView(),
        'requestPermission': (context) => const RequestPermissionView(),
        'photoAccessNeeded': (context) => const PhotoAccessNeededView(),
        'bottomNavigation': (context) => const BottomNavigationView(),
        'home': (context) => const HomeView(),
        'changePassword': (context) => const ChangePasswordView(),
        'deleteAccount': (context) => const DeleteAccount(),
        'addHomeTags': (context) => const AddHometagsView(),
        'editHomeTags': (context) => const EditHometagsView(),
        'local': (context) => const LocalView(),
        'uploaded': (context) => const UploadedView(),
        'querySelector': (context) => const QuerySelectorView(),
      },
    );
  }
}
