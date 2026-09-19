import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_communication_notifier.dart';
import '../theme/app_theme.dart';

class TranscriptionScreen extends ConsumerWidget {
  const TranscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeCommunicationProvider);
    final notifier = ref.read(homeCommunicationProvider.notifier);
    
    // Convert Kasa Me transcription into a chat format
    // In a real app we'd keep a list of messages. For this UI mockup, 
    // we use the current transcript as the user message, and a dummy system response.
    final userMessage = state.partialTranscript.isNotEmpty 
        ? state.partialTranscript 
        : (state.personalizedTranscript.isNotEmpty ? state.personalizedTranscript : "Listening...");
        
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 16),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text('Voice Chat'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.more_vert, size: 16),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildUserMessage(userMessage),
                    const SizedBox(height: 24),
                    if (state.personalizedTranscript.isNotEmpty)
                       _buildSystemMessage("I heard: ${state.personalizedTranscript}. Did I get that right?"),
                    if (state.personalizedTranscript.isNotEmpty)
                      _buildSuggestionsCard(),
                  ],
                ),
              ),
              // Bottom Input Bar
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0, top: 8.0),
                child: _buildInputBar(state, notifier),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserMessage(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.15),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 12,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const CircleAvatar(
            radius: 12,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage('assets/images/voice_avatar.jpg'),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    border: Border.all(color: Colors.white.withOpacity(0.8)),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsCard() {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0, top: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Showing alternative word suggestions based on your personal voice profile.',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildCardItem('Alternative 1', 'Confirm'),
                const SizedBox(width: 8),
                _buildCardItem('Alternative 2', 'Confirm'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem(String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppTheme.primaryPurple, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(HomeCommunicationState state, HomeCommunicationNotifier notifier) {
    final isListening = state.engineState == UiEngineState.listening;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, color: AppTheme.textPrimary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isListening ? 'Listening...' : 'Tap mic to start...',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
            GestureDetector(
              onTap: isListening ? notifier.stopListening : notifier.startListening,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isListening ? Colors.redAccent : AppTheme.darkAccent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isListening ? Icons.stop : Icons.mic, 
                  color: Colors.white
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
