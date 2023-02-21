import 'package:flutter/material.dart';
// GLOBAL VIEWS
import 'package:tagaway/views/BottomNavigationBar.dart';
import 'package:tagaway/views/deleteAccountView.dart';
// AUTH VIEWS
import 'package:tagaway/views/loginView.dart';

import 'package:tagaway/views/localView.dart';

import 'package:tagaway/services/storeService.dart';

void main() {
  runApp(const MyApp());
  StoreService.instance.load ();
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
      home: const BottomNavigationView(),

      // AUTH VIEWS
      // home: const LoginView (),
      // home: const ChangePasswordView (),
      // home: const DeleteAccountView (),

      // HOME VIEWS
      // home: const HomeView (),
      // home: const YourHometagsView (),
      // home: const AddHometagsView (),
      // home: const EditHometagsView (),

      // LOCAL VIEW
      // home: const LocalView (),

      routes: {
        LoginView.id: (context) => const LoginView(),
        DeleteAccount.id: (context) => const DeleteAccount(),
      },
    );
  }
}
