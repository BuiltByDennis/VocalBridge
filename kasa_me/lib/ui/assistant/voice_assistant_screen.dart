import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/kasa_me_assistant_orb.dart';
import '../home/home_communication_notifier.dart';

class VoiceAssistantScreen extends ConsumerWidget {
  const VoiceAssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeCommunicationProvider);
    final notifier = ref.read(homeCommunicationProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Kasa Me Voice Assistant'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Prominent Assistant Heading
              Text(
                'How can I help you speak?',
                style: theme.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Hold the microphone button and speak naturally.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Prominent Assistant Orb Center Visual
              KasaMeAssistantOrb(
                isListening: state.engineState == UiEngineState.listening,
                isProcessing: state.engineState == UiEngineState.processing,
                size: 160.0,
              ),

              const Spacer(),

              // Recognized Transcript Banner
              if (state.personalizedTranscript.isNotEmpty || state.partialTranscript.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          state.personalizedTranscript.isNotEmpty
                              ? state.personalizedTranscript
                              : state.partialTranscript,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (state.confidence != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            state.confidence! > 0.8 ? 'High Confidence' : 'Needs Confirmation',
                            style: TextStyle(
                              color: state.confidence! > 0.8 ? Colors.teal.shade900 : Colors.orange.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Large Interactive Primary Voice Button
              SizedBox(
                height: 80,
                child: Listener(
                  onPointerDown: (_) {
                    HapticFeedback.heavyImpact();
                    notifier.startPushToTalk();
                  },
                  onPointerUp: (_) {
                    HapticFeedback.lightImpact();
                    notifier.stopPushToTalk();
                  },
                  onPointerCancel: (_) => notifier.stopPushToTalk(),
                  child: Material(
                    color: state.engineState == UiEngineState.listening
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(24.0),
                    elevation: 4,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24.0),
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            state.engineState == UiEngineState.listening ? Icons.mic : Icons.mic_none_rounded,
                            size: 36,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            state.engineState == UiEngineState.listening
                                ? 'Listening...'
                                : state.engineState == UiEngineState.processing
                                    ? 'Understanding...'
                                    : 'Hold to Speak',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
