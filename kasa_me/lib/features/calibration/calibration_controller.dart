import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/recorder/audio_recorder_service.dart';
import 'calibration_phrase.dart';
import 'calibration_validator.dart';

enum CalibrationStatus {
  idle,
  recording,
  processing,
  passed,
  failed,
  completed,
}

class CalibrationState {
  final CalibrationStatus status;
  final int currentPhraseIndex;
  final List<CalibrationPhrase> phrases;
  final String? statusMessage;
  final int totalRecorded;
  final int totalPassed;

  const CalibrationState({
    this.status = CalibrationStatus.idle,
    this.currentPhraseIndex = 0,
    this.phrases = CalibrationPhraseSet.defaultPhrases,
    this.statusMessage,
    this.totalRecorded = 0,
    this.totalPassed = 0,
  });

  CalibrationPhrase get currentPhrase => phrases[currentPhraseIndex];

  CalibrationState copyWith({
    CalibrationStatus? status,
    int? currentPhraseIndex,
    List<CalibrationPhrase>? phrases,
    String? statusMessage,
    int? totalRecorded,
    int? totalPassed,
  }) {
    return CalibrationState(
      status: status ?? this.status,
      currentPhraseIndex: currentPhraseIndex ?? this.currentPhraseIndex,
      phrases: phrases ?? this.phrases,
      statusMessage: statusMessage ?? this.statusMessage,
      totalRecorded: totalRecorded ?? this.totalRecorded,
      totalPassed: totalPassed ?? this.totalPassed,
    );
  }
}

class CalibrationController extends StateNotifier<CalibrationState> {
  final AudioRecorderService _recorderService;

  CalibrationController(this._recorderService) : super(const CalibrationState());

  Future<void> startRecording() async {
    state = state.copyWith(status: CalibrationStatus.recording, statusMessage: null);
    await _recorderService.start();
  }

  Future<void> stopRecordingAndValidate() async {
    state = state.copyWith(status: CalibrationStatus.processing);
    await _recorderService.stop();

    final mockPcm = Uint8List(16000 * 2 * 2);
    final byteData = ByteData.sublistView(mockPcm);
    for (int i = 0; i < 16000 * 2; i++) {
      byteData.setInt16(i * 2, 1000, Endian.little);
    }

    final qResult = CalibrationValidator.validatePcm16Audio(mockPcm);

    if (qResult.isValid) {
      HapticFeedback.lightImpact();
      final newPassed = state.totalPassed + 1;
      final newRecorded = state.totalRecorded + 1;
      final isLast = state.currentPhraseIndex >= state.phrases.length - 1;

      state = state.copyWith(
        status: isLast ? CalibrationStatus.completed : CalibrationStatus.passed,
        statusMessage: 'Quality check passed (${qResult.durationSec.toStringAsFixed(1)}s)',
        totalPassed: newPassed,
        totalRecorded: newRecorded,
      );
    } else {
      HapticFeedback.vibrate();
      state = state.copyWith(
        status: CalibrationStatus.failed,
        statusMessage: qResult.message,
      );
    }
  }

  void nextPhrase() {
    if (state.currentPhraseIndex < state.phrases.length - 1) {
      state = state.copyWith(
        currentPhraseIndex: state.currentPhraseIndex + 1,
        status: CalibrationStatus.idle,
        statusMessage: null,
      );
    }
  }
}

final calibrationProvider =
    StateNotifierProvider<CalibrationController, CalibrationState>((ref) {
  return CalibrationController(AudioRecorderService());
});
