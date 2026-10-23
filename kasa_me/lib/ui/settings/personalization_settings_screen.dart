import 'package:flutter/material.dart';
import '../components/accessible_tap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:go_router/go_router.dart';
import '../../core/accessibility/accessibility_settings.dart';
import '../../profile/repositories/profile_repository.dart';
import '../../speech/personalization/personalization_repository.dart';
import '../../speech/personalization/speech_behavior.dart';
import '../../speech/personalization/speech_profile_settings.dart';
import '../../storage/database/app_database.dart';
import '../home/home_communication_notifier.dart'
    show databaseProvider, speechConfigRevisionProvider;
import '../theme/app_theme.dart';

class PersonalizationSettingsScreen extends ConsumerStatefulWidget {
  const PersonalizationSettingsScreen({super.key});

  @override
  ConsumerState<PersonalizationSettingsScreen> createState() =>
      _PersonalizationSettingsScreenState();
}

class _PersonalizationSettingsScreenState
    extends ConsumerState<PersonalizationSettingsScreen> {
  bool _isHC = false;

  PersonalProfileEntity? _profile;
  List<WordCorrectionEntity> _corrections = [];
  int _phraseCorrectionCount = 0;
  int _calibrationAttempts = 0;
  int _calibrationSamples = 0;
  bool _loading = true;

  String _conditionKey = 'typical';

  SpeechCondition get _condition => SpeechCondition.fromKey(_conditionKey);
  SpeechBehavior get _behavior => SpeechBehavior.forCondition(_condition);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final repo = ProfileRepository(db);
    final personRepo = PersonalizationRepository(db);

    final profile = await repo.getActiveProfile('default_user');
    final corrections = await personRepo.getWordCorrections('default_user');
    final phraseCorrections = await db.select(db.phraseCorrections).get();
    final calibEvents = await (db.select(db.recognitionEvents)
          ..where((t) => t.context.like('calibration%')))
        .get();

    if (mounted) {
      setState(() {
        _profile = profile;
        _corrections = corrections;
        _phraseCorrectionCount = phraseCorrections.length;
        _calibrationAttempts =
            calibEvents.where((e) => e.context == 'calibration').length;
        _calibrationSamples =
            calibEvents.where((e) => e.context == 'calibration_recorded').length;
        _loading = false;
      });
    }
  }

  /// The heart of per-person training: choosing a speech profile changes
  /// how recognition behaves for this user (see SpeechBehavior), applies
  /// the matching listening presets, and refreshes the home engines live.
  Future<void> _setCondition(SpeechCondition condition) async {
    if (condition == _condition) return;
    await ref.read(speechProfileProvider.notifier).setCondition(condition);
    final behavior = SpeechBehavior.forCondition(condition);
    final a11y = ref.read(accessibilitySettingsProvider.notifier);
    await a11y.setVadSensitivity(behavior.vadSensitivity);
    await a11y.setMicGain(behavior.micGain);
    ref.read(speechConfigRevisionProvider.notifier).state++;
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Speech profile set to ${condition.label}. Kasa Me has adapted to you.')),
      );
    }
  }

  Future<void> _updateSetting({
    bool? enablePersonalVocabulary,
    bool? enablePhraseBiasing,
    bool? enableCorrectionMemory,
  }) async {
    final db = ref.read(databaseProvider);
    final repo = ProfileRepository(db);
    await repo.updateSettings(
      profileId: 'default_user',
      enablePersonalVocabulary: enablePersonalVocabulary,
      enablePhraseBiasing: enablePhraseBiasing,
      enableCorrectionMemory: enableCorrectionMemory,
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    _isHC = ref.watch(accessibilitySettingsProvider).highContrastMode;
    _conditionKey = ref.watch(speechProfileProvider).conditionKey;
    return Scaffold(
      body: Container(
        decoration:
            BoxDecoration(gradient: AppTheme.backgroundGradient(highContrast: _isHC)),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    AccessibleTap(
                      label: 'Back',
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back_ios_new,
                            size: 16, color: AppTheme.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('Personalization',
                        style: Theme.of(context).textTheme.displayMedium),
                  ],
                ),
              ),
              if (_loading)
                const Expanded(
                    child: Center(child: CircularProgressIndicator()))
              else
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    children: [
                      _sectionHeader('Your Speech Profile'),
                      ...SpeechCondition.values.map(_conditionTile),
                      const SizedBox(height: 8),
                      _whatChangesCard(),
                      const SizedBox(height: 20),
                      _sectionHeader('Your Training'),
                      _trainingSummaryCard(context),
                      const SizedBox(height: 20),
                      _sectionHeader('Features'),
                      _switchTile(
                        title: 'Personal Vocabulary',
                        subtitle: 'Apply your learned word corrections',
                        value: _profile?.enablePersonalVocabulary ?? true,
                        onChanged: (v) =>
                            _updateSetting(enablePersonalVocabulary: v),
                      ),
                      _switchTile(
                        title: 'Phrase Biasing',
                        subtitle:
                            'Prioritize frequently used phrases in recognition',
                        value: _profile?.enablePhraseBiasing ?? true,
                        onChanged: (v) =>
                            _updateSetting(enablePhraseBiasing: v),
                      ),
                      _switchTile(
                        title: 'Correction Memory',
                        subtitle:
                            'Remember and auto-apply your word corrections',
                        value: _profile?.enableCorrectionMemory ?? true,
                        onChanged: (v) =>
                            _updateSetting(enableCorrectionMemory: v),
                      ),
                      const SizedBox(height: 20),
                      _sectionHeader('Learned Corrections (${_corrections.length})'),
                      if (_corrections.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'No corrections yet. Tap a word in the Voice Chat screen to correct it.',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 14),
                          ),
                        )
                      else
                        ..._corrections.map((c) => _correctionTile(c)),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: () => _showResetDialog(context),
                        icon: const Icon(Icons.refresh, color: Colors.redAccent),
                        label: const Text('Reset All Personalization',
                            style: TextStyle(color: Colors.redAccent)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _conditionTile(SpeechCondition condition) {
    final selected = condition == _condition;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(selected ? 0.95 : 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? AppTheme.primaryPurple : Colors.transparent,
          width: 2,
        ),
      ),
      child: RadioListTile<SpeechCondition>(
        value: condition,
        groupValue: _condition,
        onChanged: (v) => v != null ? _setCondition(v) : null,
        title: Text(condition.label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(condition.description,
            style: const TextStyle(fontSize: 12)),
        activeColor: AppTheme.primaryPurple,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  Widget _whatChangesCard() {
    final b = _behavior;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What changes for you',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),
          ...b.changes.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  '),
                    Expanded(
                        child: Text(c,
                            style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )),
          const SizedBox(height: 4),
          Text(
            'Listening presets applied: microphone gain ×${b.micGain.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')}, pause patience ${_patienceLabel(b.vadSensitivity)}. Fine-tune them any time in Accessibility settings.',
            style: TextStyle(
                fontSize: 12,
                color: AppTheme.pageTextSecondary(highContrast: _isHC)),
          ),
        ],
      ),
    );
  }

  String _patienceLabel(double vad) =>
      vad <= 0.3 ? 'high' : (vad <= 0.45 ? 'medium-high' : 'standard');

  Widget _trainingSummaryCard(BuildContext context) {
    final calibrated = _profile?.isCalibrated ?? false;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryRow('Voice calibration',
              calibrated ? 'Completed' : 'Not done yet'),
          _summaryRow('Calibration attempts checked', '$_calibrationAttempts'),
          _summaryRow('Twi voice samples recorded', '$_calibrationSamples'),
          _summaryRow('Learned word corrections', '${_corrections.length}'),
          _summaryRow('Learned phrase corrections', '$_phraseCorrectionCount'),
          const SizedBox(height: 8),
          const Text(
            'All of this training stays on this phone. Your Accuracy Score on the home screen is calculated from these training sessions and how well recognition performs for you afterwards.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/calibration'),
              icon: const Icon(Icons.school_outlined, size: 18),
              label: const Text('Open Voice Calibration'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.pageTextSecondary(highContrast: _isHC),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
      ),
      child: SwitchListTile(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(subtitle),
        value: value,
        activeColor: AppTheme.primaryPurple,
        onChanged: onChanged,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  Widget _correctionTile(WordCorrectionEntity c) {
    return Dismissible(
      key: Key('correction_${c.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.redAccent),
      ),
      onDismissed: (_) async {
        final db = ref.read(databaseProvider);
        await PersonalizationRepository(db).deleteWordCorrection(c.id);
        setState(() => _corrections.removeWhere((e) => e.id == c.id));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                  children: [
                    TextSpan(
                        text: '"${c.observed}"',
                        style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: AppTheme.textSecondary)),
                    const TextSpan(text: ' → '),
                    TextSpan(
                        text: '"${c.intended}"',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('×${c.frequency}',
                  style: const TextStyle(
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Personalization?'),
        content: const Text(
            'This will delete all learned word corrections and pronunciation patterns. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final db = ref.read(databaseProvider);
              // Capture scaffoldMessenger before async gap
              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(context);
              await db.delete(db.wordCorrections).go();
              await db.delete(db.phraseCorrections).go();
              nav.pop();
              await _load();
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(
                      content: Text('Personalization data reset.')),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
