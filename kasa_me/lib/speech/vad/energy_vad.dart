import 'dart:math';
import 'dart:typed_data';

enum VadState {
  silence,
  speech,
}

class EnergyVad {
  final int sampleRate;
  final double thresholdRms;
  final int maxSilenceFrames;

  VadState _currentState = VadState.silence;
  int _consecutiveSilenceFrames = 0;

  EnergyVad({
    this.sampleRate = 16000,
    this.thresholdRms = 250.0,
    this.maxSilenceFrames = 15,
  });

  VadState get currentState => _currentState;

  double calculateRms(Uint8List pcm16) {
    if (pcm16.isEmpty) return 0.0;
    final sampleCount = pcm16.length ~/ 2;
    final byteData = ByteData.sublistView(pcm16);
    double sumSquares = 0.0;

    for (int i = 0; i < sampleCount; i++) {
      final sample = byteData.getInt16(i * 2, Endian.little).toDouble();
      sumSquares += sample * sample;
    }

    return sqrt(sumSquares / sampleCount);
  }

  VadState processFrame(Uint8List pcm16) {
    final rms = calculateRms(pcm16);
    if (rms >= thresholdRms) {
      _currentState = VadState.speech;
      _consecutiveSilenceFrames = 0;
    } else {
      _consecutiveSilenceFrames++;
      if (_consecutiveSilenceFrames >= maxSilenceFrames) {
        _currentState = VadState.silence;
      }
    }
    return _currentState;
  }

  void reset() {
    _currentState = VadState.silence;
    _consecutiveSilenceFrames = 0;
  }
}
