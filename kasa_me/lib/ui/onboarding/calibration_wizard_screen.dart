import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../speech/calibration/calibration_service.dart';
import '../../speech/personalization/personalization_pipeline.dart';
import '../../profile/repositories/profile_repository.dart';
import '../../storage/database/app_database.dart';
import '../home/home_screen.dart';

// Create providers for dependency injection
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());
final profileRepositoryProvider = Provider<ProfileRepository>((ref) => ProfileRepository(ref.watch(databaseProvider)));
final personalizationPipelineProvider = Provider<PersonalizationPipeline>((ref) => PersonalizationPipeline());

final calibrationServiceProvider = Provider.autoDispose<CalibrationService>((ref) {
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
  bool _isProcessing = false;
  
  late final CalibrationService _calibrationService;
  StreamSubscription? _resultSub;

  @override
  void initState() {
    super.initState();
    _calibrationService = ref.read(calibrationServiceProvider);
    
    _resultSub = _calibrationService.onResult.listen((result) {
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _isProcessing = false;
        _lastRecognized = result.recognizedPhrase;
      });
      
      // Briefly show result then move to next
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        _moveToNextStep();
      });
    });
  }

  @override
  void dispose() {
    _resultSub?.cancel();
    super.dispose();
  }

  void _moveToNextStep() async {
    if (_currentStepIndex < CalibrationService.calibrationPhrases.length - 1) {
      setState(() {
        _currentStepIndex++;
        _lastRecognized = null;
      });
    } else {
      // Completed all steps
      final profileRepo = ref.read(profileRepositoryProvider);
      // Hardcoding default profile id from seed
      await profileRepo.updateSettings(profileId: 'test-profile-1', isCalibrated: true); // Adjust ID as needed based on how profiles are loaded
      
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _lastRecognized = null;
    });
    final target = CalibrationService.calibrationPhrases[_currentStepIndex];
    _calibrationService.startRecordingForPhrase(target);
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });
    _calibrationService.stopRecording();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSteps = CalibrationService.calibrationPhrases.length;
    final currentPhrase = CalibrationService.calibrationPhrases[_currentStepIndex];

    return Scaffold(
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
              GestureDetector(
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
              const SizedBox(height: 16),
              
              // Skip button
              TextButton(
                onPressed: _isRecording ? null : _moveToNextStep,
                child: const Text('Skip this phrase'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
