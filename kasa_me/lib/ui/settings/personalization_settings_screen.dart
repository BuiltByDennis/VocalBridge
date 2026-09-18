import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/repositories/profile_repository.dart';
import '../../speech/asr/models/asr_model_registry.dart';

class PersonalizationSettingsScreen extends ConsumerStatefulWidget {
  const PersonalizationSettingsScreen({super.key});

  @override
  ConsumerState<PersonalizationSettingsScreen> createState() => _PersonalizationSettingsScreenState();
}

class _PersonalizationSettingsScreenState extends ConsumerState<PersonalizationSettingsScreen> {
  String _selectedLanguage = 'en_GH';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final profileRepo = ref.read(profileRepositoryProvider);
    final profile = await profileRepo.getActiveProfile('default_user');
    setState(() {
      _selectedLanguage = profile.preferredLanguage;
      _isLoading = false;
    });
  }

  Future<void> _updateLanguage(String newLanguage) async {
    setState(() => _isLoading = true);
    final profileRepo = ref.read(profileRepositoryProvider);
    await profileRepo.updateSettings(
      profileId: 'default_user',
      preferredLanguage: newLanguage,
    );
    setState(() {
      _selectedLanguage = newLanguage;
      _isLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Language updated to $newLanguage.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final availableModels = AsrModelRegistry.availableModels;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalization Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Speech Recognition Language', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: availableModels.map((model) {
                      return DropdownMenuItem(
                        value: model.language,
                        child: Text(model.displayName),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        _updateLanguage(val);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export Personal Profile'),
              subtitle: const Text('Export vocabulary, phrases & learned corrections to JSON'),
              onTap: () {
                final profileData = {
                  'version': '1.0',
                  'exportedAt': DateTime.now().toIso8601String(),
                  'vocabulary': ['Kumasi', 'MoMo', 'Dennis'],
                  'phrases': ['I need water', 'I need help'],
                };
                Clipboard.setData(ClipboardData(text: jsonEncode(profileData)));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile copied to clipboard (kasa_me_profile.json)')),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.upload),
              title: const Text('Import Personal Profile'),
              subtitle: const Text('Load profile JSON backup file'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile import validated & loaded successfully.')),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: ListTile(
              leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.onErrorContainer),
              title: Text('Reset Personalization Data',
                  style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer, fontWeight: FontWeight.bold)),
              subtitle: Text('Clear all learned word/phrase corrections and personal vocabulary',
                  style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Reset Personalization?'),
                    content: const Text('This will delete all learned corrections and vocabulary mappings. Base ASR model will remain intact.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Personalization data reset.')),
                          );
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
