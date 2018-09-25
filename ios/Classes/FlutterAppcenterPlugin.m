#import "FlutterAppcenterPlugin.h"
#import <flutter_appcenter/flutter_appcenter-Swift.h>

@implementation FlutterAppcenterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterAppcenterPlugin registerWithRegistrar:registrar];
}
@end
