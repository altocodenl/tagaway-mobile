// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'package:tagaway/views/BottomNavigationBar.dart';
import 'package:tagaway/views/deleteAccountView.dart';
import 'package:tagaway/views/loginView.dart';

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
      home: const BottomNavigationView(),
      routes: {
        LoginView.id: (context) => const LoginView(),
        DeleteAccount.id: (context) => const DeleteAccount(),
      },
    );
  }
}
