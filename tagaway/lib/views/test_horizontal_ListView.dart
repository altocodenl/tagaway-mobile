import 'package:flutter/material.dart';

class HorizontalListView extends StatelessWidget {
  const HorizontalListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 260.0, bottom: 200),
      child: SizedBox(
        height: 100,
        width: double.infinity,
        child: ListView(
          // This next line does the trick.
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            Container(
              width: 160.0,
              color: Colors.red,
              child: Column(
                children: [
                  Container(
                    color: Colors.black,
                    width: 20,
                    height: 20,
                  )
                ],
              ),
            ),
            Container(
              width: 160.0,
              color: Colors.blue,
            ),
            Container(
              width: 160.0,
              color: Colors.green,
            ),
            Container(
              width: 160.0,
              color: Colors.yellow,
            ),
            Container(
              width: 160.0,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

// Padding(
// padding: const EdgeInsets.only(top: 15, left: 12),
// child: Row(
// children: [
// Padding(
// padding: const EdgeInsets.only(right: 24),
// child: Column(
// children: const [
// FaIcon(
// FontAwesomeIcons.solidCircleCheck,
// color: kAltoOrganized,
// size: 18,
// ),
// Padding(
// padding: EdgeInsets.only(top: 8.0),
// child: Text(
// 'Oct',
// style: TextStyle(
// fontFamily: 'Montserrat',
// fontSize: 16,
// fontWeight: FontWeight.bold,
// color: kGreyDarker,
// ),
// ),
// ),
// FaIcon(
// FontAwesomeIcons.minus,
// color: Colors.white,
// ),
// ],
// ),
// ),
// Padding(
// padding: const EdgeInsets.only(right: 24),
// child: Column(
// children: const [
// FaIcon(
// FontAwesomeIcons.circle,
// color: kGreyDarker,
// size: 18,
// ),
// Padding(
// padding: EdgeInsets.only(top: 8.0),
// child: Text(
// 'Nov',
// style: TextStyle(
// fontFamily: 'Montserrat',
// fontSize: 16,
// fontWeight: FontWeight.bold,
// color: kGreyDarker,
// ),
// ),
// ),
// FaIcon(
// FontAwesomeIcons.minus,
// color: Colors.white,
// ),
// ],
// ),
// ),
// Padding(
// padding: const EdgeInsets.only(right: 24),
// child: Column(
// children: const [
// FaIcon(
// FontAwesomeIcons.solidCircle,
// color: kGreyDarker,
// size: 18,
// ),
// Padding(
// padding: EdgeInsets.only(top: 8.0),
// child: Text(
// 'Dec',
// style: TextStyle(
// fontFamily: 'Montserrat',
// fontSize: 16,
// fontWeight: FontWeight.bold,
// color: kAltoBlue,
// ),
// ),
// ),
// FaIcon(
// FontAwesomeIcons.minus,
// color: kAltoBlue,
// ),
// ],
// ),
// ),
// ],
// ),
// )
