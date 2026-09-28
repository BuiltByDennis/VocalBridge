import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../../core/accessibility/accessibility_settings.dart';

class AccessibilitySettingsScreen extends ConsumerStatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  ConsumerState<AccessibilitySettingsScreen> createState() => _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState extends ConsumerState<AccessibilitySettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(accessibilitySettingsProvider);
    final notifier = ref.read(accessibilitySettingsProvider.notifier);
    final isHC = settings.highContrastMode;

    final bgGradient = AppTheme.backgroundGradient(highContrast: isHC);
    final cardColor = isHC ? AppTheme.hcSurface : Colors.white.withOpacity(0.9);
    final textColor = isHC ? AppTheme.hcTextPrimary : AppTheme.textPrimary;
    final accentColor = isHC ? AppTheme.hcAccent : AppTheme.primaryPurple;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isHC ? AppTheme.hcSurface : Colors.white,
                          shape: BoxShape.circle,
                          border: isHC ? Border.all(color: AppTheme.hcAccent) : null,
                        ),
                        child: Icon(Icons.arrow_back_ios_new,
                            size: 16, color: isHC ? AppTheme.hcAccent : AppTheme.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Accessibility',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    // ──────── 3.1 Motor Accessibility ────────
                    _sectionHeader('Motor Accessibility', accentColor),

                    _switchTile(
                      cardColor: cardColor,
                      textColor: textColor,
                      icon: Icons.record_voice_over,
                      iconColor: accentColor,
                      title: 'Auto-Speak on Transcription',
                      subtitle: 'Automatically reads out the transcript '
                          'as soon as speech is recognised — '
                          'no second button press needed.',
                      value: settings.autoSpeakOnTranscription,
                      onChanged: notifier.setAutoSpeak,
                    ),

                    _switchTile(
                      cardColor: cardColor,
                      textColor: textColor,
                      icon: Icons.touch_app,
                      iconColor: accentColor,
                      title: 'Dwell Control',
                      subtitle: 'Hold your finger over the mic button '
                          'to activate it — no precise tap required.',
                      value: settings.dwellControlEnabled,
                      onChanged: notifier.setDwellControl,
                    ),

                    if (settings.dwellControlEnabled)
                      _sliderTile(
                        cardColor: cardColor,
                        textColor: textColor,
                        icon: Icons.timer_outlined,
                        iconColor: accentColor,
                        title: 'Dwell Delay',
                        subtitle: '${settings.dwellDelaySeconds.toStringAsFixed(1)}s — '
                            'hold this long to activate',
                        value: settings.dwellDelaySeconds,
                        min: 0.5,
                        max: 3.0,
                        divisions: 10,
                        onChanged: notifier.setDwellDelay,
                      ),

                    const SizedBox(height: 16),

                    // ──────── 3.2 Visual Accessibility ────────
                    _sectionHeader('Visual Accessibility', accentColor),

                    _switchTile(
                      cardColor: cardColor,
                      textColor: textColor,
                      icon: Icons.contrast,
                      iconColor: accentColor,
                      title: 'High-Contrast Mode',
                      subtitle: 'Switches to a bold black-and-yellow '
                          'colour palette for maximum readability.',
                      value: settings.highContrastMode,
                      onChanged: notifier.setHighContrast,
                    ),

                    const SizedBox(height: 16),

                    // ──────── 3.3 Cognitive Accessibility ────────
                    _sectionHeader('Cognitive Accessibility', accentColor),

                    _switchTile(
                      cardColor: cardColor,
                      textColor: textColor,
                      icon: Icons.view_compact_alt,
                      iconColor: accentColor,
                      title: 'Simplified Interface',
                      subtitle: 'Hides history, diagnostics and statistics '
                          'screens — shows only the core Push-to-Talk interface.',
                      value: settings.simplifiedUiMode,
                      onChanged: notifier.setSimplifiedUi,
                    ),

                    const SizedBox(height: 16),

                    // ──────── 3.4 Acoustic Accessibility ────────
                    _sectionHeader('Acoustic Accessibility', accentColor),

                    _sliderTile(
                      cardColor: cardColor,
                      textColor: textColor,
                      icon: Icons.mic_rounded,
                      iconColor: accentColor,
                      title: 'Microphone Gain',
                      subtitle: _gainLabel(settings.micGainMultiplier),
                      value: settings.micGainMultiplier,
                      min: 1.0,
                      max: 4.0,
                      divisions: 6,
                      onChanged: notifier.setMicGain,
                    ),

                    _sliderTile(
                      cardColor: cardColor,
                      textColor: textColor,
                      icon: Icons.noise_control_off,
                      iconColor: accentColor,
                      title: 'Noise Filter Sensitivity',
                      subtitle: _vadLabel(settings.vadSensitivity),
                      value: settings.vadSensitivity,
                      min: 0.1,
                      max: 0.9,
                      divisions: 8,
                      onChanged: notifier.setVadSensitivity,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _gainLabel(double gain) {
    if (gain <= 1.0) return 'Off — no amplification applied';
    return '${gain.toStringAsFixed(1)}× — boosts quiet voices';
  }

  String _vadLabel(double v) {
    if (v < 0.35) return 'Loose — best for noisy environments';
    if (v < 0.65) return 'Balanced (default)';
    return 'Strict — best for quiet environments';
  }

  Widget _sectionHeader(String title, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: accent,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  Widget _switchTile({
    required Color cardColor,
    required Color textColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: textColor)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12, color: textColor.withOpacity(0.6))),
              ],
            ),
          ),
          // Large touch target for the switch (48x48 minimum)
          SizedBox(
            width: 56,
            height: 48,
            child: FittedBox(
              alignment: Alignment.centerRight,
              fit: BoxFit.scaleDown,
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeColor: iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sliderTile({
    required Color cardColor,
    required Color textColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: textColor)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12,
                            color: textColor.withOpacity(0.6))),
                  ],
                ),
              ),
            ],
          ),
          // Slider with 48dp tall hit area
          SizedBox(
            height: 44,
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              activeColor: iconColor,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
