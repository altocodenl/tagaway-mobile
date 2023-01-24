// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
//IMPORT SERVICES
import 'package:tagaway/services/permissionCheckService.dart';
//IMPORT SCREENS

class LifeCycleManager extends StatefulWidget {
  final Widget child;
  final ValueChanged<bool> resumed;

  const LifeCycleManager(
      {required Key key, required this.child, required this.resumed})
      : super(key: key);

  @override
  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager>
    with WidgetsBindingObserver {
  bool resumed = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
    if (state == AppLifecycleState.resumed) {
      setState(() {
        resumed = true;
      });
      checkPermission(context).then((value) {
        if (resumed == true && value == 'granted') {
          // Navigator.of(context).push(
          //   MaterialPageRoute(builder: (_) => GridPage()),
          // );
        } else if (resumed == true && value == 'denied' ||
            value == 'limited' ||
            value == 'permanent') {
          Navigator.pushReplacementNamed(context, '/PhotoAccessNeeded',
              arguments: PermissionLevelFlag(permissionLevel: value));
        }
      });
      print('resumed $resumed');
    } else {
      resumed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }
}
