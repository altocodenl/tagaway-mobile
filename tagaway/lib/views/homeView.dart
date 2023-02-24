import 'dart:core';

import 'package:flutter/material.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/changePasswordView.dart';
import 'package:tagaway/views/deleteAccountView.dart';
import 'package:tagaway/views/yourHometagsView.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeView extends StatefulWidget {
  static const String id = 'how_view';
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  dynamic cancelListener;

  List hometags = [];

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance.listen(['hometags'], (v) {
      setState(() => hometags = v == '' ? [] : v);
    });

    // TODO: handle error
    TagService.instance.getTags();
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
  }

  _launchUrl() async {
    if (!await launchUrl(Uri.parse(kTagawayHomeURL),
        mode: LaunchMode.externalApplication)) {
      throw "cannot launch url";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: kAltoBlue),
        leading: Image.asset(
          'images/tag blue with white - 400x400.png',
          scale: 8,
        ),
        title: Row(
          children: const [
            Expanded(flex: 2, child: Text('tagaway', style: kAcpicMain)),
            Padding(
              padding: EdgeInsets.only(top: 1.0),
              child: Text(
                'username',
                style: kPlainText,
              ),
            ),
          ],
        ),
        centerTitle: false,
        titleSpacing: 0.0,
      ),
      endDrawer: Drawer(
          child: ListView(
        // padding: const EdgeInsets.all(8),
        children: <Widget>[
          const SizedBox(
            height: 64,
            child: DrawerHeader(
              child: Text('Username', style: kSubPageAppBarTitle),
            ),
          ),
          const UserMenuElementTransparent(
              textOnElement: 'Your usage: 4GB of your free 5GB'),
          UserMenuElementLightGrey(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return const ChangePasswordView();
              }));
            },
            textOnElement: 'Change password',
          ),
          UserMenuElementLightGrey(
              onTap: () {
                _launchUrl();
              },
              textOnElement: 'Go to tagaway web'),
          UserMenuElementLightGrey(
              onTap: () {
                Navigator.pushReplacementNamed(context, DeleteAccount.id);
              },
              textOnElement: 'Delete My Account'),
          UserMenuElementDarkGrey(onTap: () {}, textOnElement: 'Log out'),
        ],
      )),
      body: SafeArea(
        child: hometags.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kAltoBlue),
                ),
              )
            /*
        Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Image.asset(
                              'images/tag blue with white - 400x400.png',
                              scale: 2,
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Your tags’ shortcuts will be here. Start tagging and get your first shortcut!',
                          style: kHomeEmptyText,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: RoundedButton(
                            title: 'Get started',
                            colour: kAltoBlue,
                            onPressed: () {
                              StoreService.instance.set('currentIndex', 1);
                            },
                          ))
                    ],
                  ),
                ),
              )

     */
            : Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 7),
                child: ListView(
                    addAutomaticKeepAlives: false,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: [
                      for (var v in hometags)
                        HomeCard(color: tagColor(v), title: v)
                    ]),
              ),
      ),
      floatingActionButton: Visibility(
        visible: hometags.isNotEmpty,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return const YourHometagsView();
            }));
          },
          backgroundColor: kAltoBlue,
          child: const Icon(Icons.create_rounded),
        ),
      ),
    );
  }
}
