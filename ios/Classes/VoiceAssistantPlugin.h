#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>

@interface VoiceAssistantPlugin : NSObject<FlutterPlugin>

@property(strong, nonatomic) AVSpeechSynthesizer *synthesizer;

@end
