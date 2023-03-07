import 'package:flutter/cupertino.dart';
import 'package:tagaway/services/storeService.dart';

class Distributor extends StatefulWidget {
  static const String id = 'distributor';

  const Distributor({Key? key}) : super(key: key);

  @override
  State<Distributor> createState() => _DistributorState();
}

class _DistributorState extends State<Distributor> {
  bool recurringUserLocal = false;
  bool isCookieLoaded = false;
  String cookie = 'empty';

  @override
  void initState() {
    checkCookie();
    super.initState();
  }

  checkCookie() {
    setState(() {
      cookie = StoreService.instance.get('cookie');
      print(cookie);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder(
      child: Center(
        child: Text('Hello world'),
      ),
    );
  }
}
