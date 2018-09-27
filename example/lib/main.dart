import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_appcenter/flutter_appcenter.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String androidAppId = "4e969c6c-d969-43ff-85b0-84a0bab0d62f";
    String iOsAppId = "0eadeea1-ef17-455d-baa7-64c5c165713c";
    String appId = "";

  @override
  void initState() {
    super.initState();
    initPlatformState();
     appId = Platform.isIOS ? iOsAppId : androidAppId;

  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterAppcenter.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Text('Running on: $_platformVersion\n'),
              Text('App Id : $appId'),
              RaisedButton(
                child: Text("Start"),
                onPressed: _start,
              ),
              RaisedButton(
                child: Text("Track test event"),
                onPressed: _trackTestEvent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _start() async {
    // TODO pick services

    await FlutterAppcenter.start(appId, [
      AppCenterService.Crashes,
      AppCenterService.Analytics,
      AppCenterService.Distribute
    ]);
  }

  _trackTestEvent() async {
    await FlutterAppcenter.trackEvent(
        "testEvent", <String, String>{"hello": "world"});
  }
}
