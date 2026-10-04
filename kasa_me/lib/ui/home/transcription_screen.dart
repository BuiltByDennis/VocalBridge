import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../components/engine_status_banner.dart';
import '../../core/accessibility/accessibility_settings.dart';
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

  // Dwell control state — managed by _DwellMicButton, not here
  Timer? _dwellTimer;

  @override
  void dispose() {
    _dwellTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeCommunicationProvider);
    final notifier = ref.read(homeCommunicationProvider.notifier);
    final accessibility = ref.watch(accessibilitySettingsProvider);
    final isHC = accessibility.highContrastMode;

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
              translation: state.translation,
              translationSourceLabel: state.translationSourceLabel,
              translationTargetLabel: state.translationTargetLabel,
              translationTargetCode: state.translationTargetCode,
            ));
          });
        }
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: isHC ? AppTheme.hcBackground : null,
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
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient(highContrast: isHC),
        ),
        child: SafeArea(
          child: Column(
            children: [
              EngineStatusBanner(
                engineState: state.engineState,
                errorMessage: state.errorMessage,
                providerLabel: state.providerLabel,
              ),

              // High-impact safety banner
              if (state.isHighImpact && !state.hasConfirmedHighImpact)
                _HighImpactBanner(onConfirm: notifier.confirmHighImpact),

              Expanded(
                child: _messages.isEmpty && state.partialTranscript.isEmpty
                    ? _buildEmptyState(isHC)
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _messages.length +
                            (state.partialTranscript.isNotEmpty ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i < _messages.length) {
            return _buildMessagePair(context, notifier, _messages[i], i, isHC: isHC);
                          }
                          // Partial transcript preview bubble
                          return _buildPartialBubble(state.partialTranscript, isHC);
                        },
                      ),
              ),

              // Phrase prediction row
              if (state.quickPhrases.isNotEmpty && !accessibility.simplifiedUiMode)
                _PhraseBar(
                  phrases: state.quickPhrases
                      .take(4)
                      .map((p) => p.phrase)
                      .toList(),
                  isHighContrast: isHC,
                  onSelected: (phrase) => notifier.speakText(phrase),
                ),

              // Bottom bar
              Padding(
                padding: const EdgeInsets.only(
                    left: 24.0, right: 24.0, bottom: 24.0, top: 8.0),
                child: _buildInputBar(context, state, notifier, accessibility),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState([bool isHC = false]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mic_none_rounded, size: 64, color: isHC ? AppTheme.hcTextSecondary : Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Tap the mic to start speaking',
            style: TextStyle(color: isHC ? AppTheme.hcTextSecondary : Colors.grey.shade400, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPartialBubble(String text, [bool isHC = false]) {
    final bubbleColor = isHC ? AppTheme.hcSurface : AppTheme.primaryPurple.withOpacity(0.08);
    final textStyle = TextStyle(
      color: isHC ? AppTheme.hcAccent : AppTheme.primaryPurple,
      fontSize: 15 * MediaQuery.textScalerOf(context).scale(1.0),
      fontStyle: FontStyle.italic,
    );
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, left: 60),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: (isHC ? AppTheme.hcAccent : AppTheme.primaryPurple).withOpacity(0.2)),
        ),
        child: Text(text, style: textStyle),
      ),
    );
  }

  Widget _buildMessagePair(
    BuildContext context,
    HomeCommunicationNotifier notifier,
    _Message msg,
    int index, {
    bool isHC = false,
  }) {
    final textScaler = MediaQuery.textScalerOf(context);
    final scaledFontSize = textScaler.scale(16.0).clamp(12.8, 28.8);
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
                  color: isHC
                      ? AppTheme.hcSurface
                      : AppTheme.primaryPurple.withOpacity(0.15),
                  border: Border.all(
                    color: isHC
                        ? AppTheme.hcAccent
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      msg.personalized,
                      style: TextStyle(
                        color: isHC ? AppTheme.hcTextPrimary : AppTheme.textPrimary,
                        fontSize: scaledFontSize,
                      ),
                    ),
                    if (msg.confidence != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${(msg.confidence! * 100).toStringAsFixed(0)}% confidence',
                          style: TextStyle(
                            fontSize: 11,
                            color: isHC ? AppTheme.hcTextSecondary : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // ── Bidirectional translation card (Twi ↔ English) ──
        // The completed task, made visible: what was said, side by side with
        // what it means for the other person. Each side speaks aloud in its
        // own language.
        _buildTranslationCard(context, notifier, msg, isHC: isHC),
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

  /// Side-by-side translation card: the original utterance next to its
  /// translation, each with its own speak-aloud button. This is the
  /// end-to-end task made visible — a Twi speaker's words, readable and
  /// hearable in English by the nurse, and vice versa.
  Widget _buildTranslationCard(
    BuildContext context,
    HomeCommunicationNotifier notifier,
    _Message msg, {
    bool isHC = false,
  }) {
    // Only for language pairs the app can translate (currently Twi ↔ English).
    if (msg.translationTargetLabel.isEmpty) return const SizedBox.shrink();

    final textScaler = MediaQuery.textScalerOf(context);
    final scaledFontSize = textScaler.scale(15.0).clamp(12.0, 26.0);
    final hasTranslation =
        msg.translation != null && msg.translation!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHC ? AppTheme.hcSurface : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHC
              ? AppTheme.hcAccent
              : AppTheme.primaryPurple.withOpacity(0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.translate_rounded,
                  size: 16, color: AppTheme.primaryPurple),
              const SizedBox(width: 6),
              Text(
                'Translation · ${msg.translationSourceLabel} → ${msg.translationTargetLabel}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isHC
                      ? AppTheme.hcTextPrimary
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (hasTranslation)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _translationPanel(
                    context,
                    label: msg.translationSourceLabel.toUpperCase(),
                    text: msg.personalized,
                    fontSize: scaledFontSize,
                    isHC: isHC,
                    onSpeak: () =>
                        notifier.speakOriginalText(msg.personalized),
                  ),
                ),
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: AppTheme.textSecondary.withOpacity(0.25),
                ),
                Expanded(
                  child: _translationPanel(
                    context,
                    label: msg.translationTargetLabel.toUpperCase(),
                    text: msg.translation!,
                    fontSize: scaledFontSize,
                    isHC: isHC,
                    onSpeak: () =>
                        notifier.speakTranslationText(msg.translation!),
                  ),
                ),
              ],
            )
          else
            Text(
              'No ${msg.translationTargetLabel} gloss for this phrase yet — the care phrasebook is growing.',
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppTheme.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _translationPanel(
    BuildContext context, {
    required String label,
    required String text,
    required double fontSize,
    required bool isHC,
    required VoidCallback onSpeak,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppTheme.primaryPurple,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: isHC ? AppTheme.hcTextPrimary : AppTheme.textPrimary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: onSpeak,
            icon: const Icon(Icons.volume_up_rounded),
            color: AppTheme.primaryPurple,
            tooltip: 'Read aloud in $label',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
        ),
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
                      translation: notifier.translateFor(newPersonalized),
                      translationSourceLabel: notifier.translationSourceLabel,
                      translationTargetLabel: notifier.translationTargetLabel,
                      translationTargetCode: notifier.translationTargetCode,
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
    AccessibilitySettings accessibility,
  ) {
    final isListening = state.engineState == UiEngineState.listening;
    final isReady = state.engineState == UiEngineState.ready;
    final isHC = accessibility.highContrastMode;

    return Container(
      decoration: BoxDecoration(
        color: isHC ? AppTheme.hcSurface : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: isHC ? Border.all(color: AppTheme.hcAccent, width: 1.5) : null,
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
            Icon(Icons.auto_awesome,
                color: isHC ? AppTheme.hcAccent : AppTheme.textPrimary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isListening ? 'Listening…' : 'Tap mic to speak…',
                style: TextStyle(
                  color: isHC ? AppTheme.hcTextSecondary : AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
            // ── Dwell-control mic button ──
            _DwellMicButton(
              isListening: isListening,
              isReady: isReady,
              dwellEnabled: accessibility.dwellControlEnabled,
              dwellDelaySeconds: accessibility.dwellDelaySeconds,
              isHighContrast: isHC,
              onStart: notifier.startPushToTalk,
              onStop: notifier.stopPushToTalk,
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
  // Bidirectional translation display (Twi ↔ English).
  final String? translation;
  final String translationSourceLabel;
  final String translationTargetLabel;
  final String translationTargetCode;
  const _Message({
    required this.raw,
    required this.personalized,
    this.confidence,
    required this.timestamp,
    this.translation,
    this.translationSourceLabel = '',
    this.translationTargetLabel = '',
    this.translationTargetCode = '',
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

/// ─────────────────────────────────────────────────────────────────────
/// Dwell-control mic button (3.1 Motor Accessibility)
/// ─────────────────────────────────────────────────────────────────────
class _DwellMicButton extends StatefulWidget {
  final bool isListening;
  final bool isReady;
  final bool dwellEnabled;
  final double dwellDelaySeconds;
  final bool isHighContrast;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const _DwellMicButton({
    required this.isListening,
    required this.isReady,
    required this.dwellEnabled,
    required this.dwellDelaySeconds,
    required this.isHighContrast,
    required this.onStart,
    required this.onStop,
  });

  @override
  State<_DwellMicButton> createState() => _DwellMicButtonState();
}

class _DwellMicButtonState extends State<_DwellMicButton>
    with SingleTickerProviderStateMixin {
  Timer? _dwellTimer;
  double _dwellProgress = 0.0;
  static const int _tickMs = 50;

  void _startDwell() {
    if (!widget.dwellEnabled || !widget.isReady) return;
    _dwellProgress = 0.0;
    final totalTicks = (widget.dwellDelaySeconds * 1000 / _tickMs).ceil();
    int ticks = 0;

    _dwellTimer = Timer.periodic(const Duration(milliseconds: _tickMs), (t) {
      ticks++;
      setState(() => _dwellProgress = ticks / totalTicks);
      if (ticks >= totalTicks) {
        t.cancel();
        setState(() => _dwellProgress = 0.0);
        widget.onStart();
      }
    });
  }

  void _cancelDwell() {
    _dwellTimer?.cancel();
    setState(() => _dwellProgress = 0.0);
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor =
        widget.isHighContrast ? AppTheme.hcAccent : Colors.redAccent;
    final idleColor =
        widget.isHighContrast ? AppTheme.hcAccent : AppTheme.darkAccent;
    final buttonColor = widget.isListening ? activeColor : idleColor;

    // Minimum 56×56dp touch target (exceeds WCAG 48dp minimum)
    return Listener(
      onPointerDown: (_) {
        if (widget.dwellEnabled) {
          _startDwell();
        } else {
          if (widget.isListening) {
            widget.onStop();
          } else if (widget.isReady) {
            widget.onStart();
          }
        }
      },
      onPointerUp: (_) {
        if (widget.dwellEnabled) {
          _cancelDwell();
        } else if (widget.isListening) {
          widget.onStop();
        }
      },
      child: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Dwell progress ring
            if (widget.dwellEnabled && _dwellProgress > 0)
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  value: _dwellProgress,
                  strokeWidth: 3,
                  color: idleColor,
                  backgroundColor: idleColor.withOpacity(0.2),
                ),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: buttonColor,
                shape: BoxShape.circle,
                boxShadow: widget.isListening
                    ? [
                        BoxShadow(
                          color: activeColor.withOpacity(0.4),
                          blurRadius: 16,
                          spreadRadius: 4,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                widget.isListening ? Icons.stop_rounded : Icons.mic,
                color: widget.isHighContrast ? AppTheme.hcBackground : Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────
/// Phrase prediction bar (3.3 Cognitive Accessibility)
/// Shows the top quick-phrases as tappable chips above the mic bar.
/// ─────────────────────────────────────────────────────────────────────
class _PhraseBar extends StatelessWidget {
  final List<String> phrases;
  final bool isHighContrast;
  final ValueChanged<String> onSelected;

  const _PhraseBar({
    required this.phrases,
    required this.isHighContrast,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (phrases.isEmpty) return const SizedBox.shrink();

    final chipColor =
        isHighContrast ? AppTheme.hcSurface : Colors.white.withOpacity(0.85);
    final textColor =
        isHighContrast ? AppTheme.hcAccent : AppTheme.primaryPurple;
    final borderColor =
        isHighContrast ? AppTheme.hcAccent : AppTheme.primaryPurple.withOpacity(0.3);

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: phrases.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () => onSelected(phrases[i]),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: chipColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
              ),
              child: Text(
                phrases[i],
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
