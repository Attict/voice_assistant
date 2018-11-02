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
  final TextEditingController inputController = new TextEditingController();

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
            child: new Column(
              children: <Widget> [
                new TextField(controller: inputController, maxLines: 5),
                new RaisedButton(child: const Text('Text-to-Speech'), onPressed: () {
                  if (voiceReady) {
                    voice.speakText(inputController.text);
                  }
                }),
                new RaisedButton(child: const Text('Speech-to-Text'), onPressed: () {
                  if (voiceReady) {
                    if (voice.state == VoiceAssistant.listening) {
                      voice.stopListening().then((result) {
                        inputController.text = result;
                      });
                    } else {
                      voice.startListening();
                    }
                  }
                }),
              ]
            )
          )
        ),
      ),
    );
  }
}
