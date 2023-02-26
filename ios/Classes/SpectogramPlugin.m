#import "SpectogramPlugin.h"
#if __has_include(<spectogram/spectogram-Swift.h>)
#import <spectogram/spectogram-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "spectogram-Swift.h"
#endif

@implementation SpectogramPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSpectogramPlugin registerWithRegistrar:registrar];
}
@end
