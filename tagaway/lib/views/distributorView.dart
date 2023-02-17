import 'package:flutter/cupertino.dart';

class Distributor extends StatefulWidget {
  static const String id = 'distributor';

  const Distributor({Key? key}) : super(key: key);

  @override
  State<Distributor> createState() => _DistributorState();
}

class _DistributorState extends State<Distributor> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder(
      child: Center(
        child: Text('Hello world'),
      ),
    );
  }
}
