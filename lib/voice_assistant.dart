import 'dart:async';

import 'package:flutter/services.dart';

class VoiceAssistant {
  static const int disposed = 0;
  static const int ready = 1;
  static const int speaking = 2;
  static const int listening = 3;
  static const int busy = 9;

  /// Channel
  static const MethodChannel _channel = const MethodChannel('voice_assistant');

  /// The state of [VoiceAssistant]
  int _state = disposed; 

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

  Future<Null> startListening() async {}

  Future<String> stopListening() async {
    return null; 
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
