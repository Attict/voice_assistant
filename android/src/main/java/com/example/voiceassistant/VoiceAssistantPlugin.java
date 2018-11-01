package com.example.voiceassistant;

import android.app.Activity;
import android.speech.tts.TextToSpeech;
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

  /**
   * Constructor
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
    synthesizer = new TextToSpeech(activity, ttsListener);
    return true;
  }

  private boolean dispose() {
    System.out.println("Dispose Voice Assistant");
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
}
