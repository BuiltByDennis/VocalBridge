import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../speech/calibration/calibration_service.dart';
import '../../speech/personalization/personalization_pipeline.dart';
import '../../profile/repositories/profile_repository.dart';
import '../../core/permissions/permission_service.dart';
import '../home/home_communication_notifier.dart'
    show personalizationRepositoryProvider, speechConfigRevisionProvider;


/// The calibration pipeline is backed by the real personalization
/// repository — corrections seeded here are SAVED and keep working in
/// everyday recognition. (A pipeline without the repository would learn
/// into thin air and forget everything when the wizard closes.)
final personalizationPipelineProvider = Provider<PersonalizationPipeline>(
    (ref) => PersonalizationPipeline(
        repository: ref.watch(personalizationRepositoryProvider)));

final calibrationServiceProvider = Provider<CalibrationService>((ref) {
  final service = CalibrationService(
    personalizationPipeline: ref.watch(personalizationPipelineProvider),
  );
  
  // We need to initialize it properly. For simplicity in this synchronous provider,
  // we can trigger initialization, though Riverpod has better patterns (FutureProvider/AsyncValue).
  service.initialize();
  
  ref.onDispose(() => service.dispose());
  return service;
});

class CalibrationWizardScreen extends ConsumerStatefulWidget {
  const CalibrationWizardScreen({super.key});

  @override
  ConsumerState<CalibrationWizardScreen> createState() => _CalibrationWizardScreenState();
}

class _CalibrationWizardScreenState extends ConsumerState<CalibrationWizardScreen> {
  int _currentStepIndex = 0;
  bool _isRecording = false;
  String? _lastRecognized;
  bool _lastWasVerified = true;
  bool _isProcessing = false;
  String _language = 'en_GH';

  List<String> get _phrases =>
      CalibrationService.phrasesForLanguage(_language);
  bool get _isGhanaian => _language == 'twi' || _language == 'ewe';
  String get _languageName =>
      _language == 'twi' ? 'Twi' : (_language == 'ewe' ? 'Ewe' : 'English');

  StreamSubscription? _resultSub;

  @override
  void initState() {
    super.initState();
    
    // Defer listening to the stream until after the first frame to safely use ref.read
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(calibrationServiceProvider).setLanguage(_language);
      _resultSub = ref.read(calibrationServiceProvider).onResult.listen((result) {
        if (!mounted) return;
        setState(() {
          _isRecording = false;
          _isProcessing = false;
          _lastRecognized = result.recognizedPhrase;
          _lastWasVerified = result.wasVerified;
        });
        
        // Briefly show result then move to next
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (!mounted) return;
          _moveToNextStep();
        });
      });
    });
  }

  @override
  void dispose() {
    _resultSub?.cancel();
    super.dispose();
  }

  void _moveToNextStep() async {
    if (_currentStepIndex < _phrases.length - 1) {
      setState(() {
        _currentStepIndex++;
        _lastRecognized = null;
      });
    } else {
      // Completed all steps — mark as calibrated and go to home
      final profileRepo = ref.read(profileRepositoryProvider);
      await profileRepo.updateSettings(
        profileId: 'default_user',
        isCalibrated: true,
      );
      // Nudge the home screen to rebuild its engines/pipeline with the
      // freshly trained data — no app restart needed.
      ref.read(speechConfigRevisionProvider.notifier).state++;

      if (!mounted) return;
      context.go('/home');
    }
  }

  void _setLanguage(String code) {
    if (code == _language || _isRecording) return;
    setState(() {
      _language = code;
      _currentStepIndex = 0;
      _lastRecognized = null;
    });
    ref.read(calibrationServiceProvider).setLanguage(code);
  }

  void _startRecording() async {
    final hasPermission = await PermissionService.requestMicrophonePermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required.')),
        );
      }
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() {
      _isRecording = true;
      _lastRecognized = null;
    });
    final target = _phrases[_currentStepIndex];
    try {
      await ref.read(calibrationServiceProvider).startRecordingForPhrase(target);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _stopRecording() async {
    if (!_isRecording) return;
    
    HapticFeedback.heavyImpact();
    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });
    
    try {
      await ref.read(calibrationServiceProvider).stopRecording();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error processing audio: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSteps = _phrases.length;
    final currentPhrase = _phrases[_currentStepIndex];

    // The back button must never close the app from here. When this
    // page was reached by go() (the old language-screen flow) it is
    // the whole stack — back used to exit the app entirely.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Voice Calibration'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Language toggle — English phrases are checked by the
              // on-device recognizer; Ghanaian phrases (Twi, Ewe) are
              // recorded as voice samples (no cloud recognition quota
              // is spent).
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('English'),
                    selected: _language == 'en_GH',
                    onSelected: (_) => _setLanguage('en_GH'),
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Twi'),
                    selected: _language == 'twi',
                    onSelected: (_) => _setLanguage('twi'),
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Ewe'),
                    selected: _language == 'ewe',
                    onSelected: (_) => _setLanguage('ewe'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isGhanaian)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_languageName calibration saves your voice samples on this phone and teaches Kasa Me your $_languageName phrases. It does not use your cloud recognition quota.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              if (_isGhanaian) const SizedBox(height: 16),
              // Progress Indicator
              Text(
                'Step ${_currentStepIndex + 1} of $totalSteps',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_currentStepIndex + 1) / totalSteps,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Please read the following phrase aloud:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              
              // Target Phrase Card
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isRecording ? theme.colorScheme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  currentPhrase,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Result display
              if (_isProcessing)
                const Center(child: CircularProgressIndicator())
              else if (_lastRecognized != null && !_lastWasVerified)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Voice sample saved. Kasa Me is learning how you say this phrase.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                )
              else if (_lastRecognized != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'We heard:',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        _lastRecognized!.isEmpty ? '(Silence)' : _lastRecognized!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ),
              
              const Spacer(),
              
              // Push to Talk Button
              Semantics(
                button: true,
                label: 'Push to talk button. Hold down to record, release to stop.',
                child: GestureDetector(
                  onTapDown: (_) => _startRecording(),
                  onTapUp: (_) => _stopRecording(),
                  onTapCancel: () => _stopRecording(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 100,
                    decoration: BoxDecoration(
                      color: _isRecording ? theme.colorScheme.error : theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: _isRecording
                          ? [BoxShadow(color: theme.colorScheme.error.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)]
                          : [],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isRecording ? Icons.mic : Icons.mic_none,
                            color: theme.colorScheme.onPrimary,
                            size: 40,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _isRecording ? 'Listening...' : 'Hold to Speak',
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
              const SizedBox(height: 16),
              
              // Skip button
              Semantics(
                button: true,
                label: 'Skip this phrase',
                child: TextButton(
                  onPressed: _isRecording ? null : _moveToNextStep,
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: const Text('Skip this phrase'),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
