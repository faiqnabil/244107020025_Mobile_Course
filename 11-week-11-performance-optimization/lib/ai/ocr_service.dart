import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

/// Service for Optical Character Recognition using Google ML Kit.
class OcrService {
  final TextRecognizer _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Recognizes text from the given [imageFile] and returns the extracted string.
  /// Throws an [Exception] if processing fails.
  Future<String> recognizeText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final RecognizedText recognizedText = await _recognizer.processImage(inputImage);
      final buffer = StringBuffer();
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          buffer.writeln(line.text);
        }
      }
      return buffer.toString().trim();
    } catch (e) {
      throw Exception('Failed to recognize text: $e');
    }
  }

  /// Dispose the recognizer when no longer needed.
  void dispose() {
    _recognizer.close();
  }
}
