#import "BankedPlugin.h"
#if __has_include(<banked/banked-Swift.h>)
#import <banked/banked-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "banked-Swift.h"
#endif

@implementation BankedPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [BankedPlugin registerWithRegistrar:registrar];
}
@end
