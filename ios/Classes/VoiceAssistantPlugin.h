#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>
#import <Speech/Speech.h>

API_AVAILABLE(ios(10.0))
@interface VoiceAssistantListener : NSObject<FlutterPlugin, FlutterStreamHandler>
@property(nonatomic) FlutterEventChannel *eventChannel;
@property(nonatomic) FlutterEventSink eventSink;
@property(strong, nonatomic) NSString *text;
@property(strong, nonatomic) SFSpeechRecognizer *recognizer;
@property(strong, nonatomic) SFSpeechAudioBufferRecognitionRequest *request;
@property(strong, nonatomic) SFSpeechRecognitionTask *task;
@property(strong, nonatomic) AVAudioEngine *audioEngine;

- (instancetype)init;
- (void)dispose;
- (void)requestPermission;
- (void)startListening;
- (void)updateText:(NSString *)text;
- (NSString *)stopListening;
@end

@interface VoiceAssistantPlugin : NSObject<FlutterPlugin>

@property(strong, nonatomic) VoiceAssistantListener *listener;
@property(strong, nonatomic) AVSpeechSynthesizer *synthesizer;
@property(readonly, nonatomic) NSObject<FlutterPluginRegistrar> *registrar;
@property(readonly, nonatomic) NSObject<FlutterBinaryMessenger> *messenger;

@end
