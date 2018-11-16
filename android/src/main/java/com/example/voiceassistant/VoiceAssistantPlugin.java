package com.example.voiceassistant;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.speech.RecognizerIntent;
import android.speech.RecognitionListener;
import android.speech.SpeechRecognizer;
import android.speech.tts.TextToSpeech;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterView;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

/** VoiceAssistantPlugin */
public class VoiceAssistantPlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "voice_assistant");
    channel.setMethodCallHandler(new VoiceAssistantPlugin(registrar)); 
  }

  private final FlutterView view;
  private Registrar registrar;
  private Activity activity;
  private TextToSpeech synthesizer;
  private boolean synthesizerReady = false;
  private VoiceAssistantListener listener;

  /**
   * Constructor
   *
   */
  private VoiceAssistantPlugin(Registrar registrar) {
    this.registrar = registrar;
    this.view = registrar.view();
    this.activity = registrar.activity();
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("init")) {
      final Map<String, Boolean> reply = new HashMap<String, Boolean>();
      reply.put("success", init());
      result.success(reply);
    } else if (call.method.equals("dispose")) {
      final Map<String, Boolean> reply = new HashMap<String, Boolean>();
      reply.put("success", dispose());
      result.success(reply);
    } else if (call.method.equals("speakText")) {
      String text = call.argument("text");
      speakText(text);
      result.success(null);
    } else if (call.method.equals("startListening")) {
      startListening();
      result.success(null);
    } else if (call.method.equals("stopListening")) {
      stopListening();
      result.success(null);
    } else {
      result.notImplemented();
    }
  }

  private TextToSpeech.OnInitListener ttsListener = new TextToSpeech.OnInitListener() {
    @Override
    public void onInit(int status) {
      if (status == TextToSpeech.SUCCESS) {
        /// TODO: Set this as an option
        synthesizer.setLanguage(Locale.US);
        synthesizerReady = true;
      }
    }
  };

  private boolean init() {
    System.out.println("Init Voice Assistant");
    listener = new VoiceAssistantListener();
    synthesizer = new TextToSpeech(activity, ttsListener);
    
    EventChannel channel = new EventChannel(registrar.messenger(), "voice_assistant/listener");
    channel.setStreamHandler(listener);
    listener.setChannel(channel);
    return true;
  }

  private boolean dispose() {
    System.out.println("Dispose Voice Assistant");
    if (listener != null) {
      listener.dispose();
    }
    listener = null;
    if (synthesizer != null) {
      /// TODO: Stop speaking
      synthesizer.shutdown();
    }
    synthesizer = null;
    return true;
  }

  private void speakText(String text) {
    System.out.format("Speak Text %s%n", text);
    /// TODO: QUEUE_ADD, QUEUE_FLUSH, etc.
    synthesizer.speak(text, TextToSpeech.QUEUE_FLUSH, null);
  }

  private void startListening() {
    listener.startListening();
  }

  private void stopListening() {
    listener.stopListening();
  }

  /**
   * Listener
   *
   * Uses a flutter event stream to stream the text back to flutter.
   */
  private class VoiceAssistantListener implements EventChannel.StreamHandler, RecognitionListener {
    private EventChannel eventChannel;
    private EventChannel.EventSink eventSink;
    private String text;



    public VoiceAssistantListener() {
      System.out.println("Listener -> Init");
    }

    public void dispose() {
      System.out.println("Listener -> Dispose");
    }

    @Override
    public void onListen(Object arguments, final EventChannel.EventSink eventSink) {
      this.eventSink = eventSink;
    }

    @Override
    public void onCancel(Object arguments) {
      eventSink = null;
    }

    public void setChannel(EventChannel channel) {
      this.eventChannel = channel;
    }

    public void startListening() {
      System.out.println("Listener -> Start Listening"); 
      Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
      intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL,
          RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
      //intent.putExtra(EXTRA_LANGUAGE, Locale.getDefault());
      SpeechRecognizer speech = SpeechRecognizer.createSpeechRecognizer(activity);
      speech.setRecognitionListener(this);
      speech.startListening(intent);
    }

    public void stopListening() {
      System.out.println("Listener -> Stop Listening");
    }

    private void updateText(String text) {
      this.text = text; 
      eventSink.success(text);
    }

    public void onReadyForSpeech(Bundle params) {}
    public void onBeginningOfSpeech() {}
    public void onRmsChanged(float rmsdB) {}
    public void onBufferReceived(byte[] buffer) {}
    public void onEndOfSpeech() {}
    public void onError(int error) {}
    public void onResults(Bundle results) {
      String str = new String();
      System.out.println("Some data: " + results);
    }
    public void onPartialResults(Bundle partialResults) {}
    public void onEvent(int eventType, Bundle params) {}
  }
}
