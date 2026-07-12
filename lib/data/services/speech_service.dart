import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _speechEnabled = false;

  bool get isAvailable => _speechEnabled;
  bool get isListening => _speech.isListening;

  Future<bool> initSpeech() async {
    if (_speechEnabled) return true;
    try {
      _speechEnabled = await _speech.initialize(
        onError: (val) => debugPrint('Speech Error: $val'),
        onStatus: (val) => debugPrint('Speech Status: $val'),
      );
    } catch (e) {
      _speechEnabled = false;
      debugPrint('Speech Init Exception: $e');
    }
    return _speechEnabled;
  }

  Future<void> startListening({
    required Function(String) onResult,
    Function(double)? onSoundLevelChanged,
  }) async {
    final hasSpeech = await initSpeech();
    if (!hasSpeech) {
      debugPrint('Speech recognition not available on this device');
      return;
    }

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      cancelOnError: true,
      listenMode: ListenMode.dictation,
      onSoundLevelChange: onSoundLevelChanged,
    );
  }

  Future<void> stopListening() async {
    if (isListening) {
      await _speech.stop();
    }
  }

  Future<void> cancelListening() async {
    if (isListening) {
      await _speech.cancel();
    }
  }
}
