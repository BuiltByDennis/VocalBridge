import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../components/engine_status_banner.dart';
import 'home_communication_notifier.dart';

class TranscriptionScreen extends ConsumerStatefulWidget {
  const TranscriptionScreen({super.key});

  @override
  ConsumerState<TranscriptionScreen> createState() => _TranscriptionScreenState();
}

class _TranscriptionScreenState extends ConsumerState<TranscriptionScreen> {
  // Keep a session history of messages (raw, personalized pairs)
  final List<_Message> _messages = [];
  String? _lastRaw;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeCommunicationProvider);
    final notifier = ref.read(homeCommunicationProvider.notifier);

    // Add new final transcript to message history
    if (state.rawTranscript.isNotEmpty && state.rawTranscript != _lastRaw) {
      _lastRaw = state.rawTranscript;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _messages.add(_Message(
              raw: state.rawTranscript,
              personalized: state.personalizedTranscript.isNotEmpty
                  ? state.personalizedTranscript
                  : state.rawTranscript,
              confidence: state.confidence,
              timestamp: DateTime.now(),
            ));
          });
        }
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration:
                const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 16),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text('Voice Chat'),
        centerTitle: true,
        actions: [
          if (_messages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                  onPressed: () {
                    setState(() => _messages.clear());
                    notifier.clearTranscript();
                  },
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.mainBackgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              EngineStatusBanner(
                engineState: state.engineState,
                errorMessage: state.errorMessage,
              ),

              // High-impact safety banner
              if (state.isHighImpact && !state.hasConfirmedHighImpact)
                _HighImpactBanner(onConfirm: notifier.confirmHighImpact),

              Expanded(
                child: _messages.isEmpty && state.partialTranscript.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _messages.length +
                            (state.partialTranscript.isNotEmpty ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i < _messages.length) {
                            return _buildMessagePair(context, notifier, _messages[i], i);
                          }
                          // Partial transcript preview bubble
                          return _buildPartialBubble(state.partialTranscript);
                        },
                      ),
              ),

              // Bottom bar
              Padding(
                padding: const EdgeInsets.only(
                    left: 24.0, right: 24.0, bottom: 24.0, top: 8.0),
                child: _buildInputBar(context, state, notifier),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mic_none_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Tap the mic to start speaking',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPartialBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, left: 60),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.primaryPurple.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.2)),
        ),
        child: Text(
          text,
          style: const TextStyle(
              color: AppTheme.primaryPurple,
              fontSize: 15,
              fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget _buildMessagePair(
    BuildContext context,
    HomeCommunicationNotifier notifier,
    _Message msg,
    int index,
  ) {
    final hasDiff = msg.personalized != msg.raw;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // User message bubble
        Align(
          alignment: Alignment.centerRight,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(4),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75),
                margin: const EdgeInsets.only(bottom: 4, left: 60),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.15),
                  border:
                      Border.all(color: Colors.white.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(msg.personalized,
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 16)),
                    if (msg.confidence != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${(msg.confidence! * 100).toStringAsFixed(0)}% confidence',
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Show corrections if personalized differs from raw
        if (hasDiff)
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 8, bottom: 4),
            child: Text(
              'Corrected from: "${msg.raw}"',
              style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic),
              textAlign: TextAlign.right,
            ),
          ),
        // System confirmation + correction chips
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85),
            margin: const EdgeInsets.only(bottom: 4, right: 60),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'I heard: "${msg.personalized}" — correct?',
                  style:
                      const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                ),
                const SizedBox(height: 10),
                _buildCorrectionChips(context, notifier, msg, index),
                // Speak button
                const SizedBox(height: 10),
                Row(
                  children: [
                    _actionButton(
                      icon: Icons.volume_up_rounded,
                      label: 'Speak',
                      color: AppTheme.primaryPurple,
                      onTap: () => notifier.speakText(msg.personalized),
                    ),
                    const SizedBox(width: 10),
                    _actionButton(
                      icon: Icons.check_rounded,
                      label: 'Correct',
                      color: Colors.green.shade600,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCorrectionChips(
    BuildContext context,
    HomeCommunicationNotifier notifier,
    _Message msg,
    int index,
  ) {
    final words = msg.personalized.split(' ');
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: words.map((word) {
        return GestureDetector(
          onTap: () => _showCorrectionDialog(context, notifier, word, index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppTheme.primaryPurple.withOpacity(0.25)),
            ),
            child: Text(word,
                style: const TextStyle(
                    color: AppTheme.primaryPurple,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        );
      }).toList(),
    );
  }

  void _showCorrectionDialog(
    BuildContext context,
    HomeCommunicationNotifier notifier,
    String word,
    int messageIndex,
  ) {
    final controller = TextEditingController(text: word);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Correct this word'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Kasa Me heard: "$word"',
                style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'What did you actually say?',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final intended = controller.text.trim();
              if (intended.isNotEmpty && intended != word) {
                final msg = _messages[messageIndex];
                final newPersonalized = await notifier.applyWordCorrection(word, intended, msg.raw);
                
                if (mounted) {
                  setState(() {
                    _messages[messageIndex] = _Message(
                      raw: msg.raw,
                      personalized: newPersonalized,
                      confidence: msg.confidence,
                      timestamp: msg.timestamp,
                    );
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Correction saved: "$word" → "$intended"'),
                      backgroundColor: Colors.green.shade600,
                    ),
                  );
                  // Pronounce the corrected words with the rest of the sentence
                  notifier.speakText(newPersonalized);
                }
              }
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Save Correction'),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(
    BuildContext context,
    HomeCommunicationState state,
    HomeCommunicationNotifier notifier,
  ) {
    final isListening = state.engineState == UiEngineState.listening;
    final isReady = state.engineState == UiEngineState.ready;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome,
                color: AppTheme.textPrimary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isListening ? 'Listening…' : 'Tap mic to speak…',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 16),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (isListening) {
                  notifier.stopPushToTalk();
                } else if (isReady) {
                  notifier.startPushToTalk();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isListening ? Colors.redAccent : AppTheme.darkAccent,
                  shape: BoxShape.circle,
                  boxShadow: isListening
                      ? [
                          BoxShadow(
                              color: Colors.redAccent.withOpacity(0.4),
                              blurRadius: 16,
                              spreadRadius: 4)
                        ]
                      : [],
                ),
                child: Icon(
                  isListening ? Icons.stop_rounded : Icons.mic,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message {
  final String raw;
  final String personalized;
  final double? confidence;
  final DateTime timestamp;
  const _Message({
    required this.raw,
    required this.personalized,
    this.confidence,
    required this.timestamp,
  });
}

class _HighImpactBanner extends StatelessWidget {
  final VoidCallback onConfirm;
  const _HighImpactBanner({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This message contains high-impact content (money, medical, emergency). Please review before sending.',
              style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: onConfirm,
            child: const Text('Confirm',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
