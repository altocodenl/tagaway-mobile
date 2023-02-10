// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
// IMPORT UI ELEMENTS
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool tagsEmpty = false;

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
        child: Padding(
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
        ),
        // child: Padding(
        //   padding: const EdgeInsets.only(left: 12, right: 12, top: 7),
        //   child: ListView(
        //     addAutomaticKeepAlives: false,
        //     scrollDirection: Axis.vertical,
        //     shrinkWrap: true,
        //     children: const [
        //       HomeCard(
        //         color: kTagColor1,
        //         title: 'Vacations',
        //       ),
        //       HomeCard(
        //         color: kTagColor2,
        //         title: 'Vacations',
        //       ),
        //       HomeCard(
        //         color: kTagColor3,
        //         title: 'Vacations',
        //       ),
        //       HomeCard(
        //         color: kTagColor4,
        //         title: 'Vacations',
        //       ),
        //       HomeCard(
        //         color: kTagColor5,
        //         title: 'Vacations',
        //       ),
        //       HomeCard(
        //         color: kTagColor6,
        //         title: 'Vacations',
        //       ),
        //       HomeCard(
        //         color: kTagColor1,
        //         title: 'Vacations',
        //       ),
        //       HomeCard(
        //         color: kTagColor2,
        //         title: 'Vacations',
        //       ),
        //     ],
        //   ),
        // ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: kAltoBlue,
        child: const Icon(Icons.create_rounded),
      ),
    );
  }
}
