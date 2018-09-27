import Flutter
import UIKit
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import AppCenterDistribute

public class SwiftFlutterAppcenterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_appcenter", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterAppcenterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = call.method
        let arguments = call.arguments as? [String: Any]
        
        switch (method) {
        case "start":
            if let appSecret = arguments?["appSecret"] as? String {
                if let services = arguments?["services"] as? [String] {
                    result(nil)
                    start(appSecret: appSecret, services: services)
                }
                else {
                    result(FlutterError(code: "services missing", message: nil, details: nil))
                }
                
            } else {
                result(FlutterError(code: "appSecret missing", message: nil, details: nil))
            }
        case "trackEvent":
            NSLog("Track event")
            if let eventName = arguments?["eventName"] as? String {
                let properties = arguments?["properties"] as? [String: String]
                trackEvent(eventName: eventName, properties: properties)
                result(nil)
            } else {
                result(FlutterError(code: "eventName missing", message: nil, details: nil))
            }
            
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func start(appSecret: String, services: [String]) {
        var servicesList = [MSServiceAbstract.Type]()
        if (services.contains("analytics")) {
            servicesList.append(MSAnalytics.self)
        }
        if (services.contains("crashes")) {
            servicesList.append(MSCrashes.self)
        }
        if (services.contains("distribute")) {
            servicesList.append(MSDistribute.self)
        }
        MSAppCenter.start(appSecret, withServices: servicesList)
    }
    
    private func trackEvent(eventName: String, properties: [String: String]?) {
        MSAnalytics.trackEvent(eventName, withProperties: properties)
    }
}
