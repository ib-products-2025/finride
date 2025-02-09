import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';

class VoiceProvider extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  Timer? _timer;

  bool get isListening => _isListening;
  String get lastWords => _lastWords;

  void startListening() {
    _speech.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        notifyListeners();
      },
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: 3),
      partialResults: true,
    );
    _isListening = true;
    notifyListeners();
  }

  void stopListening() {
    _speech.stop();
    _isListening = false;
    notifyListeners();
  }

  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}