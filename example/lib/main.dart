import 'package:flutter/material.dart';

import 'package:package_info/package_info.dart';
import 'package:flutter_appcenter/flutter_appcenter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterAppCenter.startAsync(
    appSecretAndroid: '4e969c6c-d969-43ff-85b0-84a0bab0d62f',
    appSecretIOS: '0eadeea1-ef17-455d-baa7-64c5c165713c',
    enableDistribute: false,
  );
  await FlutterAppCenter.configureDistributeDebugAsync(enabled: false);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PackageInfo _packageInfo;
  bool _isCrashesEnabled;
  bool _isAnalyticsEnabled;
  bool _isDistributeEnabled;

  @override
  void initState() {
    super.initState();
    FlutterAppCenter.trackEventAsync('_MyAppState.initState');
    PackageInfo.fromPlatform().then((v) {
      setState(() {
        _packageInfo = v;
      });
    });
    FlutterAppCenter.isCrashesEnabledAsync().then((v) {
      setState(() {
        _isCrashesEnabled = v;
      });
    });
    FlutterAppCenter.isAnalyticsEnabledAsync().then((v) {
      setState(() {
        _isAnalyticsEnabled = v;
      });
    });
    FlutterAppCenter.isDistributeEnabledAsync().then((v) {
      setState(() {
        _isDistributeEnabled = v;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
            padding: EdgeInsets.all(20),
            child: _packageInfo == null
                ? RefreshProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('App name:\n${_packageInfo.appName}'),
                      Text(''),
                      Text('Package name:\n${_packageInfo.packageName}'),
                      Text(''),
                      Text('Version:\n${_packageInfo.version}'),
                      Text(''),
                      Text('Build:\n${_packageInfo.buildNumber}'),
                      Text(''),
                      Text('IsCrashesEnabled: $_isCrashesEnabled'),
                      Text('IsAnalyticsEnabled: $_isAnalyticsEnabled'),
                      Text('IsDistributeEnabled: $_isDistributeEnabled'),
                    ],
                  )),
      ),
    );
  }
}
