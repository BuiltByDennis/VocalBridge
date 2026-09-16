import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'calibration_controller.dart';

class CalibrationScreen extends ConsumerWidget {
  const CalibrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calibrationProvider);
    final controller = ref.read(calibrationProvider.notifier);
    final theme = Theme.of(context);

    final currentPhrase = state.currentPhrase;
    final progress = (state.currentPhraseIndex + 1) / state.phrases.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Calibration'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                borderRadius: BorderRadius.circular(5.0),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Phrase ${state.currentPhraseIndex + 1} of ${state.phrases.length}',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Chip(
                    label: Text(currentPhrase.category.toUpperCase()),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: theme.colorScheme.primary, width: 2.0),
                  ),
                  child: Center(
                    child: Text(
                      '"${currentPhrase.phrase}"',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (state.statusMessage != null) ...[
                Text(
                  state.statusMessage!,
                  style: TextStyle(
                    color: state.status == CalibrationStatus.failed
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],

              if (state.status == CalibrationStatus.passed)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(70),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  ),
                  onPressed: controller.nextPhrase,
                  child: Text('Next Phrase', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                )
              else if (state.status == CalibrationStatus.completed)
                Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text('Calibration Complete!', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('${state.totalPassed} of ${state.totalRecorded} recordings passed quality checks.'),
                      ],
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 80,
                  child: Listener(
                    onPointerDown: (_) => controller.startRecording(),
                    onPointerUp: (_) => controller.stopRecordingAndValidate(),
                    child: Material(
                      color: state.status == CalibrationStatus.recording
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20.0),
                        onTap: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              state.status == CalibrationStatus.recording ? Icons.mic : Icons.mic_none,
                              size: 36,
                              color: theme.colorScheme.onPrimary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              state.status == CalibrationStatus.recording
                                  ? 'Recording... (Release)'
                                  : 'Hold to Record Phrase',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
