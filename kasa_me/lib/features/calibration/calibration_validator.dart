import 'dart:math';
import 'dart:typed_data';

class CalibrationQualityResult {
  final bool isValid;
  final String message;
  final double durationSec;
  final double rms;
  final double clipRatio;

  const CalibrationQualityResult({
    required this.isValid,
    required this.message,
    required this.durationSec,
    required this.rms,
    required this.clipRatio,
  });
}

class CalibrationValidator {
  static CalibrationQualityResult validatePcm16Audio(Uint8List pcm16, {int sampleRate = 16000}) {
    if (pcm16.isEmpty) {
      return const CalibrationQualityResult(
        isValid: false,
        message: 'Empty audio buffer',
        durationSec: 0.0,
        rms: 0.0,
        clipRatio: 0.0,
      );
    }

    final sampleCount = pcm16.length ~/ 2;
    final durationSec = sampleCount / sampleRate;

    if (durationSec < 0.3) {
      return CalibrationQualityResult(
        isValid: false,
        message: 'Recording too short (< 0.3s)',
        durationSec: durationSec,
        rms: 0.0,
        clipRatio: 0.0,
      );
    }

    final byteData = ByteData.sublistView(pcm16);
    double sumSquares = 0.0;
    int clippedSamples = 0;

    for (int i = 0; i < sampleCount; i++) {
      final sample = byteData.getInt16(i * 2, Endian.little).toDouble();
      if (sample.abs() >= 32700) {
        clippedSamples++;
      }
      sumSquares += sample * sample;
    }

    final rms = sqrt(sumSquares / sampleCount);
    final clipRatio = clippedSamples / sampleCount;

    if (clipRatio > 0.05) {
      return CalibrationQualityResult(
        isValid: false,
        message: 'Excessive clipping detected. Speak slightly further from mic.',
        durationSec: durationSec,
        rms: rms,
        clipRatio: clipRatio,
      );
    }

    if (rms < 10.0) {
      return CalibrationQualityResult(
        isValid: false,
        message: 'Audio energy too low. Please speak clearer.',
        durationSec: durationSec,
        rms: rms,
        clipRatio: clipRatio,
      );
    }

    return CalibrationQualityResult(
      isValid: true,
      message: 'Quality check passed',
      durationSec: durationSec,
      rms: rms,
      clipRatio: clipRatio,
    );
  }
}
