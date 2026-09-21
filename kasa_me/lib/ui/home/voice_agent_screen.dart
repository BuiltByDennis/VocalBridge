import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import 'home_communication_notifier.dart';
import '../components/engine_status_banner.dart';
import 'package:go_router/go_router.dart';
import 'transcription_screen.dart';

class VoiceAgentScreen extends ConsumerStatefulWidget {
  const VoiceAgentScreen({super.key});

  @override
  ConsumerState<VoiceAgentScreen> createState() => _VoiceAgentScreenState();
}

class _VoiceAgentScreenState extends ConsumerState<VoiceAgentScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim =
        Tween<double>(begin: 1.0, end: 1.12).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeCommunicationProvider);
    final notifier = ref.read(homeCommunicationProvider.notifier);
    final isListening = state.engineState == UiEngineState.listening;

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
        title: const Text('Kasa Me Agent'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.history, size: 18),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TranscriptionScreen()),
                ),
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
              // Engine status banner
              EngineStatusBanner(
                engineState: state.engineState,
                errorMessage: state.errorMessage,
                onRetry: () => notifier.startPushToTalk(),
              ),
              const Spacer(flex: 2),
              // Pulsing avatar
              Center(
                child: AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (context, child) {
                    final scale = isListening ? _pulseAnim.value : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Hero(
                    tag: 'voice_avatar',
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isListening
                                ? AppTheme.primaryPurple.withOpacity(0.5)
                                : AppTheme.primaryCyan.withOpacity(0.35),
                            blurRadius: isListening ? 60 : 50,
                            spreadRadius: isListening ? 16 : 10,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset('assets/images/voice_avatar.jpg',
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Status text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _statusLabel(state.engineState),
                  key: ValueKey(state.engineState),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        height: 1.2,
                        fontSize: 24,
                        color: AppTheme.textSecondary,
                      ),
                ),
              ),
              if (state.partialTranscript.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  child: Text(
                    state.partialTranscript,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryPurple,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
              const Spacer(flex: 3),
              // Action chips
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionChip('Practice Phrases', Icons.bookmark_border,
                      () => context.mounted ? context.push('/phrasebook') : null),
                  const SizedBox(width: 12),
                  _buildActionChip('View Transcript', Icons.chat_bubble_outline,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TranscriptionScreen()))),
                ],
              ),
              const SizedBox(height: 16),
              // Input bar with real mic button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: _buildInputBar(context, state, notifier),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(UiEngineState s) {
    switch (s) {
      case UiEngineState.notLoaded:
      case UiEngineState.loading:
        return 'Loading model…';
      case UiEngineState.ready:
        return 'What would you\nlike to say today?';
      case UiEngineState.listening:
        return 'Listening…';
      case UiEngineState.processing:
        return 'Processing…';
      case UiEngineState.error:
        return 'Something went wrong';
    }
  }

  Widget _buildActionChip(String label, IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Powered by Sherpa-ONNX',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text('Offline Mode',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome,
                    color: AppTheme.textPrimary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isListening
                        ? (state.partialTranscript.isNotEmpty
                            ? state.partialTranscript
                            : 'Listening…')
                        : 'Tap microphone to speak…',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                GestureDetector(
                  // Hold-to-speak: press and hold to record, release to process
                  onLongPressStart: (_) {
                    if (isReady) notifier.startPushToTalk();
                  },
                  onLongPressEnd: (_) {
                    if (isListening) notifier.stopPushToTalk();
                  },
                  // Tap also works as a toggle for accessibility
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
                                spreadRadius: 4,
                              )
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
        ],
      ),
    );
  }
}
