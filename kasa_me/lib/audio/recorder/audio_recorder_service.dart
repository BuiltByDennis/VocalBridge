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
      AppLogger.log('Audio', 'Starting audio stream. Configuration: 16000Hz, Mono, PCM16');
      
      final stream = await _record.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );
      
      _audioStreamSubscription = stream.listen((data) {
        // AppLogger.log('Audio', 'Received ${data.length} bytes'); // Too noisy
        _audioStreamController.add(data);
      });
    } else {
      AppLogger.error('Audio', 'Microphone permission denied');
      throw Exception('Microphone permission denied');
    }
  }

  Future<void> stop() async {
    AppLogger.log('Audio', 'Stopping audio stream');
    await _record.stop();
    await _audioStreamSubscription?.cancel();
  }
}
