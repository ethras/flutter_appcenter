import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UpdateAction {
  static int UPDATE = -1;
  static int POSTONE = -2;
}

class AppCenterUpdate {
  final String versionName;
  final String versionCode;
  final String releaseNotes;

  AppCenterUpdate(
      {required this.versionName,
      required this.versionCode,
      required this.releaseNotes});
}

class FlutterAppCenter {
  static const MethodChannel _methodChannel =
      const MethodChannel('flutter_appcenter');

  static const EventChannel _eventChannel =
      const EventChannel('flutter_appcenter/update');

  static Stream<AppCenterUpdate?> listenForUpdates({String? packageName}) {
    return _eventChannel.receiveBroadcastStream(packageName).map((update) {
      if (update == null) {
        return null;
      }
      final map = Map<String, dynamic>.from(update);
      return AppCenterUpdate(
          versionName: map['versionName'],
          versionCode: map['versionCode'].toString(),
          releaseNotes: map['releaseNotes']);
    });
  }

  /// Start appcenter functionalities
  static Future startAsync({
    required String appSecretAndroid,
    required String appSecretIOS,
    enableAnalytics = true,
    enableCrashes = true,
    enableDistribute = false,
    usePrivateDistributeTrack = false,
    disableAutomaticCheckForUpdate = false,
  }) async {
    String appsecret;
    if (Platform.isAndroid) {
      appsecret = appSecretAndroid;
    } else if (Platform.isIOS) {
      appsecret = appSecretIOS;
    } else {
      throw UnsupportedError('Current platform is not supported.');
    }

    if (appsecret.isEmpty) {
      return;
    }

    WidgetsFlutterBinding.ensureInitialized();

    if (disableAutomaticCheckForUpdate) {
      await _disableAutomaticCheckForUpdateAsync();
    }

    await configureAnalyticsAsync(enabled: enableAnalytics);
    await configureCrashesAsync(enabled: enableCrashes);
    await configureDistributeAsync(enabled: enableDistribute);

    await _methodChannel.invokeMethod('start', <String, dynamic>{
      'secret': appsecret.trim(),
      'usePrivateTrack': usePrivateDistributeTrack,
    });
  }

  /// Track events
  static Future trackEventAsync(String name,
      [Map<String, String>? properties]) async {
    await _methodChannel.invokeMethod('trackEvent', <String, dynamic>{
      'name': name,
      'properties': properties ?? <String, String>{},
    });
  }

  /// Check whether analytics is enalbed
  static Future<bool?> isAnalyticsEnabledAsync() async {
    return await _methodChannel.invokeMethod('isAnalyticsEnabled');
  }

  /// Get appcenter installation id
  static Future<String> getInstallIdAsync() async {
    return await _methodChannel
        .invokeMethod('getInstallId')
        .then((r) => r as String);
  }

  static Future notifyUpdateAction(int action) async {
    await _methodChannel.invokeMethod('notifyUpdateAction', action);
  }

  /// Enable or disable analytics
  static Future configureAnalyticsAsync({required enabled}) async {
    await _methodChannel.invokeMethod('configureAnalytics', enabled);
  }

  /// Check whether crashes is enabled
  static Future<bool?> isCrashesEnabledAsync() async {
    return await _methodChannel.invokeMethod('isCrashesEnabled');
  }

  /// Enable or disable appcenter crash reports
  static Future configureCrashesAsync({required enabled}) async {
    await _methodChannel.invokeMethod('configureCrashes', enabled);
  }

  /// Check whether appcenter distribution is enabled
  static Future<bool?> isDistributeEnabledAsync() async {
    return await _methodChannel.invokeMethod('isDistributeEnabled');
  }

  /// Enable or disable appcenter distribution
  static Future configureDistributeAsync({required enabled}) async {
    await _methodChannel.invokeMethod('configureDistribute', enabled);
  }

  /// Enable or disable appcenter distribution for debug build (Android only)
  static Future configureDistributeDebugAsync({required enabled}) async {
    await _methodChannel.invokeMethod('configureDistributeDebug', enabled);
  }

  /// Disable automatic check for app updates
  static Future _disableAutomaticCheckForUpdateAsync() async {
    await _methodChannel.invokeMethod('disableAutomaticCheckForUpdate');
  }

  /// Manually check for app updates
  static Future checkForUpdateAsync({bool force = false}) async {
    if (force) {
      await configureDistributeAsync(enabled: false);
      await configureDistributeAsync(enabled: true);
    }
    await _methodChannel.invokeMethod('checkForUpdate');
  }
}
