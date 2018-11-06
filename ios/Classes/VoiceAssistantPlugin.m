#import "VoiceAssistantPlugin.h"

@implementation VoiceAssistantListener

- (instancetype)init {
  self = [super init];
  _recognizer = [[SFSpeechRecognizer alloc] initWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
  _recognizer.delegate = self;
  if (@available(iOS 10.0, *)) {
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
      switch (status) {
        case SFSpeechRecognizerAuthorizationStatusAuthorized:
          NSLog(@"Authorized");
          break;
        case SFSpeechRecognizerAuthorizationStatusDenied:
          NSLog(@"Denied");
          break;
        case SFSpeechRecognizerAuthorizationStatusNotDetermined:
          NSLog(@"Not Determined");
          break;
        case SFSpeechRecognizerAuthorizationStatusRestricted:
          NSLog(@"Restricted");
          break;
        default:
          break;
      }
    }];
  } else {
    // Fallback on earlier versions
  }
  return self;
}

- (void)dispose {
  _text = nil;
  _task = nil;
  _request = nil;
  _recognizer = nil;
  _audioEngine = nil;
  _eventChannel = nil;
  _eventSink = nil;
}

- (void)requestPermission {
}

- (void)startListening {
    // Initialize the AVAudioEngine
    _audioEngine = [[AVAudioEngine alloc] init];

    // Make sure there's not a recognition task already running
    if (_task) {
        [_task cancel];
        _task = nil;
    }

    // Starts an AVAudio Session
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];

    // Starts a recognition process, in the block it logs the input or stops the audio
    // process if there's an error.
    _request = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    AVAudioInputNode *inputNode = _audioEngine.inputNode;
    _request.shouldReportPartialResults = YES;
    _task = [_recognizer recognitionTaskWithRequest:_request resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        BOOL isFinal = NO;
        if (result) {
            // Whatever you say in the microphone after pressing the button should be being logged
            // in the console.
            NSString *text = result.bestTranscription.formattedString;
            [self updateText:text];
            isFinal = !result.isFinal;
        }
        if (error) {
            [self->_audioEngine stop];
            [inputNode removeTapOnBus:0];
            self->_request = nil;
            self->_task = nil;
        }
    }];

    // Sets the recording format
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self->_request appendAudioPCMBuffer:buffer];
    }];

    // Starts the audio engine, i.e. it starts listening.
    [_audioEngine prepare];
    [_audioEngine startAndReturnError:&error];
    NSLog(@"Say Something, I'm listening"); 
}

- (void)updateText:(NSString *)text {
  _text = text;
  _eventSink(text);
}

- (NSString *)stopListening {
  [_audioEngine stop];
  [_request endAudio];
  _audioEngine = nil;
  return _text;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
  _eventSink = nil;
  return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
  _eventSink = events;
  return nil;
}

@end


@implementation VoiceAssistantPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {

  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"voice_assistant"
            binaryMessenger:[registrar messenger]];
  VoiceAssistantPlugin* instance = [[VoiceAssistantPlugin alloc] initWithRegistrar:registrar];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  self = [super init];
  _registrar = registrar;
  _messenger = [registrar messenger];
  return self;
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
    result(nil);
  } else if ([@"startListening" isEqualToString:call.method]) {
    [self startListening];
    result(nil);
  } else if ([@"stopListening" isEqualToString:call.method]) {
    [self stopListening];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (BOOL)initialize {
  NSLog(@"Init Voice Assistant");
  _listener = [[VoiceAssistantListener alloc] init];
  _synthesizer = [[AVSpeechSynthesizer alloc] init];

  FlutterEventChannel *channel = [FlutterEventChannel
        eventChannelWithName:@"voice_assistant/listener"
             binaryMessenger:_messenger];
  [channel setStreamHandler:_listener];
    _listener.eventChannel = channel;

  return YES;
}

- (BOOL)dispose {
  NSLog(@"Dispose Voice Assistant");
  _synthesizer = nil;
    [_listener dispose];
    _listener = nil;
  return YES;
}

- (void)speakText:(NSString *)text {
  NSLog(@"Speak Text %@", text);
  if (_synthesizer == nil) {
    NSLog(@"Synth is nil");
  }
  AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:text];
  [_synthesizer speakUtterance:utterance];
  utterance = nil;
  // if rate == 0;
}

- (void)startListening {
  NSLog(@"iOS started listening");
  [_listener startListening];
}

- (void)stopListening {
  NSLog(@"iOS stopped listening");
  [_listener stopListening];
}

@end
