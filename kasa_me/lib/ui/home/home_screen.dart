import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/kasa_me_assistant_orb.dart';
import '../diagnostics/asr_diagnostics_screen.dart';
import '../settings/personalization_settings_screen.dart';
import 'home_communication_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeCommunicationProvider);
    final notifier = ref.read(homeCommunicationProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: const Icon(Icons.person, color: Color(0xFF007A78)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kasa Me', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(state.selectedLanguage, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Greeting Banner
              Text('Hi, ready to speak?', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 4),
              Text('Tap the assistant orb or hold the button below.', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 20),

              // Assistant Orb Visual
              Center(
                child: KasaMeAssistantOrb(
                  isListening: state.engineState == UiEngineState.listening,
                  isProcessing: state.engineState == UiEngineState.processing,
                  size: 130.0,
                ),
              ),
              const SizedBox(height: 20),

              // Primary Push-To-Talk Rounded Card
              SizedBox(
                height: 76,
                child: Listener(
                  onPointerDown: (_) => notifier.startPushToTalk(),
                  onPointerUp: (_) => notifier.stopPushToTalk(),
                  onPointerCancel: (_) => notifier.stopPushToTalk(),
                  child: Material(
                    color: state.engineState == UiEngineState.listening
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(24.0),
                    elevation: 3,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24.0),
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            state.engineState == UiEngineState.listening ? Icons.mic : Icons.mic_none_rounded,
                            size: 32,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            state.engineState == UiEngineState.listening
                                ? 'Listening... (Release)'
                                : state.engineState == UiEngineState.processing
                                    ? 'Understanding...'
                                    : 'Tap & Hold to Speak',
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

              const SizedBox(height: 24),

              // Quick Phrases Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Quick Phrases', style: theme.textTheme.titleLarge),
                  Text('Tap to speak', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 46,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.quickPhrases.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (ctx, idx) {
                    final phrase = state.quickPhrases[idx];
                    return ActionChip(
                      label: Text(phrase, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                      onPressed: () => notifier.selectQuickPhrase(phrase),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Recognition Result Display Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recognized Speech', style: theme.textTheme.titleMedium),
                          if (state.confidence != null)
                            Chip(
                              label: Text(
                                state.confidence! > 0.8 ? 'High Confidence' : 'Needs Confirmation',
                                style: TextStyle(
                                  color: state.confidence! > 0.8 ? Colors.teal.shade900 : Colors.orange.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: state.confidence! > 0.8
                                  ? Colors.teal.shade100
                                  : Colors.orange.shade100,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (state.personalizedTranscript.isEmpty && state.partialTranscript.isEmpty)
                        Text(
                          'Your recognized words will appear here naturally as you speak...',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade600,
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
                              borderRadius: BorderRadius.circular(6.0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                child: Text(
                                  word,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      if (state.partialTranscript.isNotEmpty) ...[
                        if (state.personalizedTranscript.isNotEmpty) const SizedBox(height: 8),
                        Text(
                          state.partialTranscript,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontSize: 22,
                            color: theme.colorScheme.primary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      if (state.personalizedTranscript.isNotEmpty) ...[
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.copy_rounded, size: 20),
                              label: const Text('Copy'),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: state.personalizedTranscript));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Copied transcript to clipboard')),
                                );
                              },
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.clear_rounded, size: 20),
                              label: const Text('Clear'),
                              onPressed: notifier.clearTranscript,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Personalization Status Summary Card
              Card(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        child: const Icon(Icons.auto_awesome, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your Kasa Me', style: theme.textTheme.titleMedium),
                            const Text('Active personal vocabulary, phrases & safety guard active.'),
                          ],
                        ),
                      ),
                    ],
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
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
            Text('Correct Word "$word"', style: Theme.of(context).textTheme.titleLarge),
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
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
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
