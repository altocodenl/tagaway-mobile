import 'package:flutter/material.dart';

import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';

import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List hometags = [];

   void initState () {
      super.initState ();
      StoreService.instance.updateStream.stream.listen ((value) async {
         if (value != 'hometags') return;
         dynamic Hometags = await StoreService.instance.get ('hometags');
         setState (() {
            hometags = Hometags;
         });
      });
      // TODO: handle error
      TagService.instance.getTags ();
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
            onTap: () {},
            textOnElement: 'Change password',
          ),
          UserMenuElementLightGrey(
              onTap: () {}, textOnElement: 'Go to hometag web'),
          UserMenuElementLightGrey(
              onTap: () {}, textOnElement: 'Delete My Account'),
          UserMenuElementDarkGrey(onTap: () {}, textOnElement: 'Log out'),
        ],
      )),
      body: SafeArea(
        child: hometags.length == 0 ? Padding(
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
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //       builder: (_) => const LoginView ()),
                        // );
                      },
                    ))
              ],
            ),
          ),
        ) : Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 7),
          child: ListView(
            addAutomaticKeepAlives: false,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: [
               for (var v in hometags) HomeCard (color: tagColor (v), title: v)
            ]
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: kAltoBlue,
        child: const Icon(Icons.create_rounded),
      ),
    );
  }
}