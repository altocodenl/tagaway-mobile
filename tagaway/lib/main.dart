import 'package:flutter/material.dart';
import 'package:tagaway/services/storeService.dart';
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
  runApp(const Tagaway());
  StoreService.instance.load();
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
      // home: const BottomNavigationView(),
      // home: const PhotoAccessNeededView(),

      // AUTH VIEWS
      // home: const SignUpView(),
      // home: const LoginView(),
      // home: const ChangePasswordView(),
      // home: const DeleteAccountView (),
      // home: const RecoverPasswordView(),
      // HOME VIEWS
      // home: const HomeView (),
      // home: const YourHometagsView (),
      // home: const AddHometagsView (),
      // home: const EditHometagsView (),

      // LOCAL VIEW
      // home: const LocalView(),

      // OTHER VIEWS
      // home: const RequestPermissionView(),

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
