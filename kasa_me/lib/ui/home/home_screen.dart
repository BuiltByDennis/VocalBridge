import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_communication_notifier.dart';
import '../diagnostics/asr_diagnostics_screen.dart';
import '../settings/personalization_settings_screen.dart';

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
            icon: const Icon(Icons.tune),
            tooltip: 'Personalization Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PersonalizationSettingsScreen()),
              );
            },
          ),
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
              // Language Header
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
              const SizedBox(height: 12),

              // Quick Phrase Access Bar
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.quickPhrases.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, idx) {
                    final phrase = state.quickPhrases[idx];
                    return ActionChip(
                      label: Text(phrase, style: const TextStyle(fontWeight: FontWeight.bold)),
                      backgroundColor: theme.colorScheme.primaryContainer,
                      onPressed: () => notifier.selectQuickPhrase(phrase),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

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
                        if (state.personalizedTranscript.isEmpty && state.partialTranscript.isEmpty)
                          Text(
                            state.engineState == UiEngineState.loading
                                ? 'Initializing speech model...'
                                : 'Press and hold "Speak" to talk...',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        if (state.personalizedTranscript.isNotEmpty)
                          Wrap(
                            spacing: 6.0,
                            runSpacing: 4.0,
                            children: state.personalizedTranscript.split(' ').map((word) {
                              return InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  _showWordCorrectionModal(context, notifier, word);
                                },
                                borderRadius: BorderRadius.circular(4.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                  child: Text(
                                    word,
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        if (state.partialTranscript.isNotEmpty) ...[
                          if (state.personalizedTranscript.isNotEmpty) const SizedBox(height: 12),
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

              // Confidence & Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.confidence != null
                        ? state.confidence! > 0.8
                            ? 'High Confidence (${(state.confidence! * 100).toStringAsFixed(0)}%)'
                            : 'Needs Confirmation (${(state.confidence! * 100).toStringAsFixed(0)}%)'
                        : 'Confidence: Available',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: state.confidence != null && state.confidence! <= 0.8
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (state.personalizedTranscript.isNotEmpty)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy),
                          tooltip: 'Copy Transcript',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: state.personalizedTranscript));
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
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 16),

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

  void _showWordCorrectionModal(BuildContext context, HomeCommunicationNotifier notifier, String word) {
    final controller = TextEditingController(text: word);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 20.0,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Correct Word "$word"', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Intended Word',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: () {
                if (controller.text.trim().isNotEmpty && controller.text.trim() != word) {
                  notifier.applyWordCorrection(word, controller.text.trim());
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save Correction'),
            ),
          ],
        ),
      ),
    );
  }
}
