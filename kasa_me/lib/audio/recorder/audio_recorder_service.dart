import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import '../../core/logging/app_logger.dart';

// Kasa Me privacy requirement:
// raw speech audio must not be persisted by default.
// The AudioRecorderService streams audio directly into memory and 
// passes it to the speech engine without writing to the disk.

class AudioRecorderService {
  final AudioRecorder _record = AudioRecorder();
  StreamSubscription<RecordState>? _stateSubscription;
  StreamSubscription<Uint8List>? _audioStreamSubscription;

  /// Microphone pre-amplification gain multiplier.
  /// 1.0 = no gain (default). 2.0 = 2x louder. Max 4.0.
  double micGainMultiplier = 1.0;

  final _audioStreamController = StreamController<Uint8List>.broadcast();
  Stream<Uint8List> get audioStream => _audioStreamController.stream;

  Future<void> initialize() async {
    _stateSubscription = _record.onStateChanged().listen((state) {
      AppLogger.log('Audio', 'Recorder state changed: $state');
    });
  }

  Future<void> dispose() async {
    await stop();
    await _stateSubscription?.cancel();
    await _record.dispose();
    await _audioStreamController.close();
  }

  Future<bool> hasPermission() async {
    return await _record.hasPermission();
  }

  Future<void> start() async {
    if (await _record.hasPermission()) {
      AppLogger.log('Audio', 'Starting audio stream. Configuration: 16000Hz, Mono, PCM16. Gain: ${micGainMultiplier}x');
      
      final stream = await _record.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );
      
      _audioStreamSubscription = stream.listen((data) {
        // Apply microphone gain amplification if needed
        final processed = micGainMultiplier != 1.0 ? _applyGain(data, micGainMultiplier) : data;
        _audioStreamController.add(processed);
      });
    } else {
      AppLogger.error('Audio', 'Microphone permission denied');
      throw Exception('Microphone permission denied');
    }
  }

  /// Amplifies PCM-16 audio samples by [gain].
  /// Clamps each sample to avoid integer overflow / clipping artifacts.
  Uint8List _applyGain(Uint8List pcm16, double gain) {
    final bytes = ByteData.sublistView(pcm16);
    final output = ByteData(pcm16.length);
    final sampleCount = pcm16.length ~/ 2;

    for (int i = 0; i < sampleCount; i++) {
      final sample = bytes.getInt16(i * 2, Endian.little);
      final amplified = (sample * gain).clamp(-32768.0, 32767.0).toInt();
      output.setInt16(i * 2, amplified, Endian.little);
    }

    return output.buffer.asUint8List();
  }

  Future<void> stop() async {
    AppLogger.log('Audio', 'Stopping audio stream');
    await _record.stop();
    await _audioStreamSubscription?.cancel();
  }
}
