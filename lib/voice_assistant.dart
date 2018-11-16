import 'dart:async';

import 'package:flutter/services.dart';

class VoiceAssistant {
  static const int disposed = 0;
  static const int ready = 1;
  static const int busy = 2;
  static const int speaking = 10;
  static const int speaking_paused = 11;
  static const int listening = 20;

  /// Channel
  static const MethodChannel _channel = const MethodChannel('voice_assistant');

  /// The state of [VoiceAssistant]
  int _state = disposed; 
  int get state => _state;



  /// Speech-to-Text Subscription
  Stream<dynamic> _sttStream;
  //StreamSubscription<dynamic> _sttSubscription;

  /// Initialize VoiceAssistant
  Future<Null> init() async {
    if (_state == disposed) {
      try {
        final Map<dynamic, dynamic> reply = await _channel.invokeMethod('init');
        if (reply['success']) {
          _state = ready;
        } else {
          throw new VoiceAssistantException('Voice Initialization', 'Voice could not be initialized'); 
        }
      } on PlatformException catch (e) {
        throw new VoiceAssistantException(e.code, e.message);
      }
    }
  }

  /// Dispose of VoiceAssistant
  Future<Null> dispose() async {
    if (_state == ready) {
      try {
        final Map<String, dynamic> reply = await _channel.invokeMethod('dispose');
        if (reply['success']) {
          _state = disposed;
        } else {
          throw new VoiceAssistantException('Voice Dispose', 'Voice could not be disposed');
        }
      } on PlatformException catch (e) {
        throw new VoiceAssistantException(e.code, e.message);
      }
    }
  }


  /// TODO: Both speakText and listening will need to be streamed
  /// to allow flutter to know when speaking is finished
  /// and what text is coming back from listening.

  /// TODO: Initialize only listener or speech rather than both?


  Future<Null> speakText(String text) async {
    if (_state == ready) {
      try {
        await _channel.invokeMethod('speakText', <String, dynamic> {
          'text': text
        });
      } on PlatformException catch (e) {
        throw new VoiceAssistantException(e.code, e.message);
      }
    }
  }

  Future<Null> pauseSpeaking() async {}

  Future<Null> continueSpeaking() async {}

  Future<Null> stopSpeaking() async {}

  Future<Null> startListening() async {
    if (_state == ready) {
      await _channel.invokeMethod('startListening');
      _sttStream = new EventChannel('voice_assistant/listener')
        .receiveBroadcastStream();
      _state = listening;
      print(_state);
    }
  }

  Future<String> stopListening() async {
    if (state == listening) {
      String result = await _channel.invokeMethod('stopListening');
      _state = ready;
      return result;
    }
    return null;
  }

  Stream<String> get listeningStream {
    return _sttStream.map((dynamic result) {
      if (result != null) {
        return result as String;
      }
      return '';
    });
  }

  /// TODO: Intents

}

class VoiceAssistantException implements Exception {
  final String code;
  final String description;

  VoiceAssistantException(this.code, this.description);

  @override
  String toString() => '$runtimeType($code, $description)';
}
