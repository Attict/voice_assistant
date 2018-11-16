# Voice Assistant

A flutter plugin that not only listens, but also speaks!  Convert text-to-speech and speech-to-text as needed with your voice assistant.

## Early Development

This plugin is in early stages of development, so there are only few options.  For now the basics are ready to be used.  _More coming soon..._

## Usage and Installation

Add to Info.plist (Inside of `ios/Runner/Info.plist`)
```
<key>NSMicrophoneUsageDescription</key>
<string>Your microphone will be used to record your speech when you press the "Start Recording" button.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Speech recognition will be used to determine which words you speak into this device's microphone.</string><Paste>
```

## Upcoming Additions

*Version x.x.0*
* TTS Utterance Rate
* Locale/Language Support
* Intents from outside application

