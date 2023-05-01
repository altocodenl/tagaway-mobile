import 'package:flutter/material.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/uploadService.dart';
import 'package:tagaway/views/BottomNavigationBar.dart';
import 'package:tagaway/views/addHometagsView.dart';
import 'package:tagaway/views/changePasswordView.dart';
import 'package:tagaway/views/deleteAccountView.dart';
import 'package:tagaway/views/distributorView.dart';
import 'package:tagaway/views/editHometagsView.dart';
import 'package:tagaway/views/homeView.dart';
import 'package:tagaway/views/localView.dart';
// AUTH VIEWS
import 'package:tagaway/views/loginView.dart';
import 'package:tagaway/views/photoAccessNeededView.dart';
import 'package:tagaway/views/querySelectorView.dart';
import 'package:tagaway/views/recoverPasswordView.dart';
import 'package:tagaway/views/requestPermissionView.dart';
import 'package:tagaway/views/searchTagsView.dart';
import 'package:tagaway/views/signUpFormView.dart';
import 'package:tagaway/views/signupView.dart';
import 'package:tagaway/views/uploadedView.dart';
import 'package:tagaway/views/yourHometagsView.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    // Ignore this annoying dev error.
    if (details.exception.toString ().contains ('A KeyUpEvent is dispatched, but the state shows that the physical key is not pressed.')) return;
    ajax ('post', 'error', {'exception': details.exception.toString(), 'stackTrace': details.stack.toString(), 'library': details.library, 'context': details.context.toString()});
  };
  runApp(const Tagaway());
  // Reload store
  StoreService.instance.load();
  // Check if we have uploads we should revive
  UploadService.instance.reviveUploads();
}

class Tagaway extends StatelessWidget {
  const Tagaway({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Distributor(),
      routes: {
        SignUpFormView.id: (context) => const SignUpFormView(),
        SignUpView.id: (context) => const SignUpView(),
        Distributor.id: (context) => const Distributor(),
        UploadedView.id: (context) => const UploadedView(),
        LoginView.id: (context) => const LoginView(),
        HomeView.id: (context) => const HomeView(),
        DeleteAccount.id: (context) => const DeleteAccount(),
        YourHometagsView.id: (context) => const YourHometagsView(),
        AddHometagsView.id: (context) => const AddHometagsView(),
        EditHometagsView.id: (context) => const EditHometagsView(),
        ChangePasswordView.id: (context) => const ChangePasswordView(),
        RecoverPasswordView.id: (context) => const RecoverPasswordView(),
        QuerySelectorView.id: (context) => const QuerySelectorView(),
        SearchTagsView.id: (context) => const SearchTagsView(),
        BottomNavigationView.id: (context) => const BottomNavigationView(),
        RequestPermissionView.id: (context) => const RequestPermissionView(),
        LocalView.id: (context) => const LocalView(),
        PhotoAccessNeededView.id: (context) => const PhotoAccessNeededView()
      },
    );
  }
}
