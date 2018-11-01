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
    //NSInteger rate = call.arguments[@"rate"];
    [self speakText:text];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (BOOL)initialize {
  NSLog(@"Init Voice Assistant");
  _synthesizer = [[AVSpeechSynthesizer alloc] init];
  return YES;
}

- (BOOL)dispose {
  NSLog(@"Dispose Voice Assistant");
  _synthesizer = nil;
  return YES;
}

- (void)speakText:(NSString *)text {
  NSLog(@"Speak Text %@", text);
  AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:text];
  [_synthesizer speakUtterance:utterance];
  utterance = nil;
  // if rate == 0;
}

- (void)startListening {}
- (void)stopListening {}

@end
