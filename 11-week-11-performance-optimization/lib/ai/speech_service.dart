import 'dart:async';
import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

/// Service for Speech-to-Text using the speech_to_text package.
class SpeechService {
  final SpeechToText _speech = SpeechToText();
  final _controller = StreamController<String>.broadcast();

  /// Initialize the speech recognizer. Returns true if successful.
  Future<bool> init() async {
    return await _speech.initialize(
      onStatus: (status) => debugPrint('Speech status: $status'),
      onError: (error) => debugPrint('Speech error: $error'),
    );
  }

  /// Starts listening and returns a stream of recognized words.
  /// The caller should listen to the returned stream for updates.
  Stream<String> listen() async* {
    final available = await init();
    if (!available) {
      throw Exception('Speech recognition unavailable.');
    }
    _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        _controller.add(result.recognizedWords);
      },
    );
    yield* _controller.stream;
  }

  /// Stop listening and close the internal stream.
  void stop() {
    _speech.stop();
    _controller.close();
  }
}
