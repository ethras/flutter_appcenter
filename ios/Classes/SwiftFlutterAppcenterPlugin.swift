import Flutter
import UIKit
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import AppCenterDistribute

class UploadStreamHandler: NSObject, FlutterStreamHandler, DistributeDelegate {
    private var eventSink: FlutterEventSink? = nil

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        Distribute.delegate = self
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    func distributeNoReleaseAvailable(_ distribute: Distribute) {
        eventSink?(nil)
      }
    
    func distribute(_ distribute: Distribute, releaseAvailableWith details: ReleaseDetails) -> Bool {
        let versionName = details.shortVersion
        let versionCode = details.version
        let releaseNotes = details.releaseNotes
        var map = [String: Any]()
        map["versionName"] = versionName
        map["versionCode"] = versionCode
        map["releaseNotes"] = releaseNotes
        eventSink?(map)
      return true;
    }
    
    
}

public class SwiftFlutterAppcenterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_appcenter", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterAppcenterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // Event channel
        let eventChannel = FlutterEventChannel(name: "flutter_appcenter/update", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(UploadStreamHandler())
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        debugPrint(call.method)
        switch call.method {
        case "start":
            guard let args:[String: Any] = (call.arguments as? [String: Any]) else {
                result(FlutterError(code: "400", message:  "Bad arguments", details: "iOS could not recognize flutter arguments in method: (start)") )
                return
            }

            let secret = args["secret"] as! String
            let usePrivateTrack = args["usePrivateTrack"] as! Bool
            if (usePrivateTrack) {
                Distribute.updateTrack = .private
            }

            AppCenter.start(withAppSecret: secret, services:[
                Analytics.self,
                Crashes.self,
                Distribute.self,
            ])
        case "notifyUpdateAction":
            let value = (call.arguments as! Int)
            let action = value == -1 ? UpdateAction.update : UpdateAction.postpone
            Distribute.notify(action)
            result(nil)
            return
        case "trackEvent":
            trackEvent(call: call, result: result)
            return
        case "isDistributeEnabled":
            result(Distribute.enabled)
            return
        case "getInstallId":
            result(AppCenter.installId.uuidString)
            return
        case "configureDistribute":
            Distribute.enabled = call.arguments as! Bool
        case "configureDistributeDebug":
            result(nil)
            return
        case "disableAutomaticCheckForUpdate":
            Distribute.disableAutomaticCheckForUpdate()
            return
        case "checkForUpdate":
            Distribute.checkForUpdate()
            return
        case "isCrashesEnabled":
            result(Crashes.enabled)
            return
        case "configureCrashes":
            Crashes.enabled = (call.arguments as! Bool)
        case "isAnalyticsEnabled":
            result(Analytics.enabled)
            return
        case "configureAnalytics":
            Analytics.enabled = (call.arguments as! Bool)
        default:
            result(FlutterMethodNotImplemented);
            return
        }
        
        result(nil);
    }
    
    private func trackEvent(call: FlutterMethodCall, result: FlutterResult) {
        guard let args:[String: Any] = (call.arguments as? [String: Any]) else {
            result(FlutterError(code: "400", message:  "Bad arguments", details: "iOS could not recognize flutter arguments in method: (trackEvent)") )
            return
        }
        
        let name = args["name"] as? String
        let properties = args["properties"] as? [String: String]
        if(name != nil) {
            Analytics.trackEvent(name!, withProperties: properties)
        }
        
        result(nil)
    }
}
