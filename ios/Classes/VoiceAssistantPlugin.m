#import "VoiceAssistantPlugin.h"

@implementation VoiceAssistantPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"voice_assistant"
            binaryMessenger:[registrar messenger]];
  VoiceAssistantPlugin* instance = [[VoiceAssistantPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"init" isEqualToString:call.method]) {
    BOOL success = [self initialize];
    result(@{@"success" : @(success)});
  } else if ([@"dispose" isEqualToString:call.method]) {
    BOOL success = [self dispose];
    result(@{@"success" : @(success)});
  } else if ([@"speakText" isEqualToString:call.method]) {
    NSString *text = call.arguments[@"text"];
    [self speakText:text];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (BOOL)initialize {
  NSLog(@"Init Voice Assistant");
  return YES;
}

- (BOOL)dispose {
  NSLog(@"Dispose Voice Assistant");
  return YES;
}

- (void)speakText:(NSString *)text {
  NSLog(@"Speak Text %@", text);
}

- (void)startListening {}
- (void)stopListening {}

@end
