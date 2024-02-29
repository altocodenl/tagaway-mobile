import 'package:flutter/material.dart';

import '../ui_elements/constants.dart';

class HomeView extends StatefulWidget {
  static const String id = 'home';
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAltoBlack,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kAltoBlack,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/tag blue with white - 400x400.png',
              scale: 8,
            ),
            const Text('tagaway', style: kTagawayMain),
          ],
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverList.builder(
                itemCount: 10,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Container(
                      height: 100,
                      alignment: Alignment.center,
                      color: Colors.lightBlue,
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
