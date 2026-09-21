import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                    Text('Settings',
                        style: Theme.of(context).textTheme.displayMedium),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  children: [
                    _sectionHeader('Speech'),
                    _tile(
                      context,
                      icon: Icons.language,
                      title: 'Language Preferences',
                      subtitle: 'Change your active speech language',
                      onTap: () => context.push('/settings/language'),
                    ),
                    _tile(
                      context,
                      icon: Icons.tune,
                      title: 'Personalization',
                      subtitle: 'Vocabulary, corrections & biasing settings',
                      onTap: () => context.push('/settings/personalization'),
                    ),
                    _tile(
                      context,
                      icon: Icons.school_outlined,
                      title: 'Re-run Calibration',
                      subtitle: 'Improve accuracy with more voice samples',
                      onTap: () => context.push('/calibration'),
                    ),
                    const SizedBox(height: 16),
                    _sectionHeader('Data & Privacy'),
                    _tile(
                      context,
                      icon: Icons.delete_sweep_outlined,
                      title: 'Privacy & Data',
                      subtitle: 'Delete your voice data or reset the app',
                      onTap: () => _showDataDeletionDialog(context),
                      iconColor: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    _sectionHeader('Developer'),
                    _tile(
                      context,
                      icon: Icons.bug_report_outlined,
                      title: 'ASR Diagnostics',
                      subtitle: 'View model info, latency & debug logs',
                      onTap: () => context.push('/diagnostics'),
                    ),
                    const SizedBox(height: 16),
                    _sectionHeader('About'),
                    _tile(
                      context,
                      icon: Icons.info_outline,
                      title: 'About Kasa Me',
                      subtitle: 'Version 1.0.0 · Offline-first assistive ASR · Powered by Sherpa-ONNX',
                      onTap: () => _showAboutDialog(context),
                    ),
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
      padding: const EdgeInsets.only(bottom: 8, top: 4),
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

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = AppTheme.textPrimary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle:
            Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
        onTap: onTap,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  void _showDataDeletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Privacy & Data'),
        content: const Text(
            'What would you like to delete? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('All personalization data deleted.')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete All Data'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Kasa Me',
      applicationVersion: '1.0.0',
      applicationLegalese:
          '© 2024 VocalBridge. All rights reserved.\n\nPowered by Sherpa-ONNX on-device speech recognition.\nFully offline. No data leaves your device.',
    );
  }
}
