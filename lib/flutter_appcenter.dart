import 'dart:async';

import 'package:flutter/services.dart';

class FlutterAppcenter {
  static const MethodChannel _channel =
      const MethodChannel('flutter_appcenter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future start(String appSecret, List<AppCenterService> services) async {
    List<String> servicesString =
        services.map((service) => serviceToString(service)).toList();
    await _channel
        .invokeMethod("start", <String, dynamic>{"services": servicesString, "appSecret": appSecret});
  }

  static Future trackEvent(String eventName,
      [Map<String, String> properties]) async {
    await _channel.invokeMethod("trackEvent", <String, dynamic>{
      "eventName": eventName,
      "properties": properties ?? <String, String>{}
    });
  }
}

enum AppCenterService { Distribute, Crashes, Analytics }

String serviceToString(AppCenterService service) {
  switch (service) {
    case AppCenterService.Distribute:
      return "distribute";
    case AppCenterService.Analytics:
      return "analytics";
    case AppCenterService.Crashes:
      return "crashes";
  }
  return "";
}
