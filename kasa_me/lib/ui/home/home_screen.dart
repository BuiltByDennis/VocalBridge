import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_communication_notifier.dart';
import '../diagnostics/asr_diagnostics_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeCommunicationProvider);
    final notifier = ref.read(homeCommunicationProvider.notifier);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasa Me'),
        actions: [
          IconButton(
            icon: const Icon(IconData(0xe1d5, fontFamily: 'MaterialIcons')),
            tooltip: 'ASR Diagnostics',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AsrDiagnosticsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Language Indicator Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state.selectedLanguage,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.language),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Transcript Display Area
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: state.engineState == UiEngineState.listening
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      width: 2.0,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.finalTranscript.isEmpty && state.partialTranscript.isEmpty)
                          Text(
                            state.engineState == UiEngineState.loading
                                ? 'Initializing speech model...'
                                : 'Press and hold "Speak" to talk...',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        if (state.finalTranscript.isNotEmpty)
                          Text(
                            state.finalTranscript,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        if (state.partialTranscript.isNotEmpty) ...[
                          if (state.finalTranscript.isNotEmpty) const SizedBox(height: 12),
                          Text(
                            state.partialTranscript,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Metadata & Confidence display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.confidence != null
                        ? 'Confidence: ${(state.confidence! * 100).toStringAsFixed(0)}%'
                        : 'Confidence: Available',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (state.finalTranscript.isNotEmpty)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy),
                          tooltip: 'Copy Transcript',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: state.finalTranscript));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied to clipboard')),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear Text',
                          onPressed: notifier.clearTranscript,
                        ),
                        IconButton(
                          icon: const Icon(Icons.volume_up),
                          tooltip: 'Speak Aloud',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Speaking transcript...')),
                            );
                          },
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Error display if present
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    state.errorMessage!,
                    style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Large Push-to-Talk Primary Action Button
              SizedBox(
                height: 80,
                child: Listener(
                  onPointerDown: (_) => notifier.startPushToTalk(),
                  onPointerUp: (_) => notifier.stopPushToTalk(),
                  onPointerCancel: (_) => notifier.stopPushToTalk(),
                  child: Material(
                    color: state.engineState == UiEngineState.listening
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
                            state.engineState == UiEngineState.listening
                                ? Icons.mic
                                : Icons.mic_none,
                            size: 36,
                            color: theme.colorScheme.onPrimary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            state.engineState == UiEngineState.listening
                                ? 'Listening... (Release to Stop)'
                                : state.engineState == UiEngineState.processing
                                    ? 'Processing...'
                                    : 'Speak (Hold to Talk)',
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
