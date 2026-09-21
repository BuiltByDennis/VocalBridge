import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/repositories/profile_repository.dart';
import '../../speech/personalization/personalization_repository.dart';
import '../../storage/database/app_database.dart';
import '../home/home_communication_notifier.dart' show databaseProvider;
import '../theme/app_theme.dart';

class PersonalizationSettingsScreen extends ConsumerStatefulWidget {
  const PersonalizationSettingsScreen({super.key});

  @override
  ConsumerState<PersonalizationSettingsScreen> createState() =>
      _PersonalizationSettingsScreenState();
}

class _PersonalizationSettingsScreenState
    extends ConsumerState<PersonalizationSettingsScreen> {
  PersonalProfileEntity? _profile;
  List<WordCorrectionEntity> _corrections = [];
  bool _loading = true;

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

    if (mounted) {
      setState(() {
        _profile = profile;
        _corrections = corrections;
        _loading = false;
      });
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.mainBackgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    GestureDetector(
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

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
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
              await db.delete(db.wordCorrections).go();
              await db.delete(db.phraseCorrections).go();
              Navigator.pop(context);
              await _load();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
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
