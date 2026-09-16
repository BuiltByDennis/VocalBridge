import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home/home_communication_notifier.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeCommunicationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Conversations'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  children: [
                    if (state.personalizedTranscript.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text('No conversations recorded yet', style: theme.textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Text('Speak on the Home or Voice Assistant screen to see speech conversation logs.', style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      // User Audio Bubble
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                              bottomLeft: Radius.circular(20.0),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.mic, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text('User Speech Recording', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),

                      // Kasa Me Recognition Output Bubble
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          padding: const EdgeInsets.all(18.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                              bottomRight: Radius.circular(20.0),
                            ),
                            border: Border.all(color: Colors.grey.shade300, width: 1.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: theme.colorScheme.primaryContainer,
                                    child: const Icon(Icons.graphic_eq, size: 14, color: Color(0xFF007A78)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Kasa Me', style: theme.textTheme.titleMedium?.copyWith(fontSize: 15)),
                                  const SizedBox(width: 12),
                                  if (state.confidence != null)
                                    Chip(
                                      label: Text(
                                        state.confidence! > 0.8 ? 'High Confidence' : 'Needs Confirmation',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: state.confidence! > 0.8 ? Colors.teal.shade900 : Colors.orange.shade900,
                                        ),
                                      ),
                                      backgroundColor: state.confidence! > 0.8 ? Colors.teal.shade100 : Colors.orange.shade100,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                state.personalizedTranscript,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.copy_rounded, size: 18),
                                    label: const Text('Copy'),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: state.personalizedTranscript));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Copied transcript to clipboard')),
                                      );
                                    },
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(Icons.volume_up_rounded, size: 18),
                                    label: const Text('Play'),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Playing transcript aloud...')),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
