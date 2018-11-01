import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:voice_assistant/voice_assistant.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final VoiceAssistant voice = new VoiceAssistant();
  bool voiceReady = false;

  @override
  void initState() {
    super.initState();
    voice.init().then((_) {
      voiceReady = true;
    });
  }

  @override
  void dispose() {
    voice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: new Container(
            child: new RaisedButton(child: const Text('Speak Something'), onPressed: () {
              if (voiceReady) {
                voice.speakText('This is a test to see if I can speak to you the user.');
              }
            })
          )
        ),
      ),
    );
  }
}
