import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../speech/asr/models/asr_model_registry.dart';
import '../../profile/repositories/profile_repository.dart';
import '../../ui/home/home_communication_notifier.dart' show databaseProvider;
import '../theme/app_theme.dart';

// Languages available in the app — mark unsupported ones as comingSoon
class _LanguageOption {
  final String name;
  final String code;
  final String flag;
  final bool comingSoon;
  const _LanguageOption(this.name, this.code, this.flag, {this.comingSoon = false});
}

const _languages = [
  _LanguageOption('English (Ghana)', 'en_GH', '🇬🇭'),
  _LanguageOption('Twi', 'twi', '🇬🇭', comingSoon: true),
  _LanguageOption('Ewe', 'ewe', '🇬🇭', comingSoon: true),
  _LanguageOption('Dagbani', 'dagbani', '🇬🇭', comingSoon: true),
];

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends ConsumerState<LanguageSelectionScreen> {
  String _selected = 'en_GH';
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final repo = ProfileRepository(ref.read(databaseProvider));
    await repo.updateSettings(
      profileId: 'default_user',
      preferredLanguage: _selected,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    // Navigate to calibration (first run) — returning users can skip via welcome screen
    context.go('/calibration');
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
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Choose your language',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kasa Me will be optimised for your selected language. More languages coming soon.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Language list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  children: _languages.map((lang) => _buildCard(lang)).toList(),
                ),
              ),
              // Continue button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Continue'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(_LanguageOption lang) {
    final isSelected = _selected == lang.code;
    return GestureDetector(
      onTap: lang.comingSoon ? null : () => setState(() => _selected = lang.code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryPurple.withOpacity(0.1)
              : Colors.white.withOpacity(lang.comingSoon ? 0.4 : 0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(lang.flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: lang.comingSoon ? AppTheme.textSecondary : AppTheme.textPrimary,
                    ),
                  ),
                  if (lang.comingSoon)
                    const Text(
                      'Coming soon',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppTheme.primaryPurple, size: 24)
            else if (!lang.comingSoon)
              const Icon(Icons.radio_button_unchecked, color: AppTheme.textSecondary, size: 24),
          ],
        ),
      ),
    );
  }
}
