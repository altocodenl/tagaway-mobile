import 'package:flutter/material.dart';

class LifeCycleManager extends StatefulWidget {
  final Widget child;
  const LifeCycleManager({Key key, this.child}) : super(key: key);

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
      resumed = true;
      print('resumed $resumed');
    } else {
      resumed = false;
      print('resumed $resumed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }
}
