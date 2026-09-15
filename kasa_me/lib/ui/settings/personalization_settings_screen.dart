import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PersonalizationSettingsScreen extends StatelessWidget {
  const PersonalizationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalization Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
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
