import 'dart:core';

import 'package:flutter/material.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:tagaway/main.dart';
import 'package:tagaway/services/authService.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/pivService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/services/tools.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/accountView.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeView extends StatefulWidget {
  static const String id = 'home';

  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  dynamic cancelListener;

  dynamic hometags = '';
  dynamic tags = '';
  dynamic account = {
    'username': '',
    'usage': {'byfs': 0}
  };

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance
        .listen(['hometags', 'tags', 'account'], (v1, v2, v3) {
      setState(() {
        hometags = v1;
        tags = v2;
        if (v3 != '') account = v3;
      });
    });

    AuthService.instance.getAccount();
    TagService.instance.getTags().then((statusCode) {
      if (statusCode == 403)
        Navigator.pushReplacementNamed(context, 'distributor');
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
  }

  _launchUrl() async {
    if (!await launchUrl(Uri.parse(kTagawayURL),
        mode: LaunchMode.externalApplication)) {
      throw "cannot launch url";
    }
  }

  mailto() async {
    EmailContent email = EmailContent(
      to: [
        'info@altocode.nl',
      ],
      subject: 'Tagaway Feedback!',
      body: 'What needs to be improved in Tagaway is:',
    );

    OpenMailAppResult result = await OpenMailApp.composeNewEmailInMailApp(
        nativePickerTitle: 'Select email app to compose', emailContent: email);
    if (!result.didOpen && !result.canOpen) {
      showNoMailAppsDialog(context);
    } else if (!result.didOpen && result.canOpen) {
      showDialog(
        context: context,
        builder: (_) => MailAppPickerDialog(
          mailApps: result.options,
          emailContent: email,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[50],
        iconTheme: const IconThemeData(color: kAltoBlue),
        leading: Image.asset(
          'images/tag blue with white - 400x400.png',
          scale: 8,
        ),
        title: Row(
          children: [
            const Expanded(flex: 2, child: Text('tagaway', style: kAcpicMain)),
            Padding(
              padding: const EdgeInsets.only(top: 1.0),
              child: Text(
                account['username'],
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
          SizedBox(
            height: 64,
            child: DrawerHeader(
              child: Text(account['username'], style: kSubPageAppBarTitle),
            ),
          ),
          UserMenuElementTransparent(
              textOnElement: 'Your usage: ' +
                  (account['usage']['byfs'] / (1000 * 1000 * 1000))
                      .round()
                      .toString() +
                  'GB of your free 5GB'),
          UserMenuElementLightGrey(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return const AccountView();
              }));
            },
            textOnElement: 'Account',
          ),
          UserMenuElementLightGrey(
              onTap: () {
                _launchUrl();
              },
              textOnElement: 'Go to tagaway web'),
          UserMenuElementLightGrey(
              onTap: () {
                mailto();
              },
              textOnElement: 'Send Us Feedback'),
          UserMenuElementLightGrey(
              onTap: () {
                Navigator.pushReplacementNamed(context, 'deleteAccount');
              },
              textOnElement: 'Delete My Account'),
          UserMenuElementKBlue(
            onTap: () {
              // TODO: open view
              getAvailableStorage();
              PivService.instance.deletePivsByRange ('3m');
              PivService.instance.deletePivsByRange ('all');
              TagawaySpaceCleanerModal1(scaffoldKey.currentContext!);
            },
            textOnElement: 'Clear Up Space',
          ),
          UserMenuElementDarkGrey(
              onTap: () {
                // We need to wrap this in another function, otherwise it gets executed on view draw. Madness.
                return () {
                  AuthService.instance.logout().then((value) {
                    if (value == 200)
                      return Navigator.pushReplacementNamed(
                          context, 'distributor');
                    SnackBarGlobal.buildSnackBar(context,
                        'Something is wrong on our side. Sorry.', 'red');
                  });
                };
              },
              textOnElement: 'Log out'),
        ],
      )),
      body: SafeArea(
        child: hometags == ''
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kAltoBlue),
                ),
              )
            : (hometags.isEmpty
                ? Padding(
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
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              tags.isEmpty
                                  ? 'Your tags’ shortcuts will be here. Start tagging and get your first shortcut!'
                                  : 'Start adding your shortcuts!',
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
                                  if (tags.isEmpty)
                                    StoreService.instance
                                        .set('currentIndex', 1);
                                  else
                                    Navigator.pushReplacementNamed(
                                        context, 'addHomeTags');
                                },
                              ))
                        ],
                      ),
                    ),
                  )
                : Stack(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 12, right: 12, top: 7),
                          child: ListView(
                              addAutomaticKeepAlives: false,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              children: [
                                for (var v in hometags)
                                  GestureDetector(
                                      onTap: () {
                                        StoreService.instance
                                            .set('queryTags', [v]);
                                        StoreService.instance
                                            .set('currentIndex', 2);
                                      },
                                      child: HomeCard(
                                          color: tagColor(v), title: v))
                              ])),
                      Align(
                        alignment: const Alignment(0, .9),
                        child: FloatingActionButton.extended(
                            extendedPadding:
                                const EdgeInsets.only(left: 20, right: 20),
                            backgroundColor: kAltoBlue,
                            elevation: 20,
                            label: const Icon(
                              kSearchIcon,
                              color: Colors.white,
                              size: 15,
                            ),
                            icon: const Text('Search', style: kButtonText),
                            key: const Key('homeFabQuerySelector'),
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, 'querySelector');
                            }),
                      )
                    ],
                  )),
      ),
      floatingActionButton: Visibility(
        visible: hometags.isNotEmpty,
        child: FloatingActionButton(
          heroTag: null,
          onPressed: () {
            Navigator.pushReplacementNamed(context, 'editHomeTags');
          },
          backgroundColor: kAltoBlue,
          child: const Icon(Icons.create_rounded),
        ),
      ),
    );
  }

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Open Mail App"),
          content: const Text("No mail apps installed"),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}
