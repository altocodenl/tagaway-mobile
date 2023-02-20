import 'package:flutter/material.dart';

// GLOBAL VIEWS
import 'package:tagaway/views/BottomNavigationBar.dart';

// AUTH VIEWS
import 'package:tagaway/views/loginView.dart';
import 'package:tagaway/views/changePasswordView.dart';
import 'package:tagaway/views/deleteAccountView.dart';

// HOME VIEWS
import 'package:tagaway/views/addHomeTagsView.dart';
import 'package:tagaway/views/editHomeTagsView.dart';
import 'package:tagaway/views/yourHomeTagsView.dart';
import 'package:tagaway/views/homeView.dart';

// LOCAL VIEW
import 'package:tagaway/views/localView.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: const BottomNavigationView(),

      // AUTH VIEWS
      // home: const LoginView (),
      // home: const ChangePasswordView (),
      // home: const DeleteAccountView (),

      // HOME VIEWS
      // home: const HomeView (),
      // home: const YourHomeTagsView (),
      // home: const AddHomeTagsView (),
      // home: const EditHomeTagsView (),

      // LOCAL VIEW
      home: const LocalView (),

      routes: {
        LoginView.id: (context) => const LoginView(),
        DeleteAccount.id: (context) => const DeleteAccount(),
      },
    );
  }
}
