import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildLanguageOption(context, 'English (Ghana)', 'en_GH'),
          _buildLanguageOption(context, 'Twi', 'twi'),
          _buildLanguageOption(context, 'Ewe', 'ewe'),
          _buildLanguageOption(context, 'Dagbani', 'dagbani'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/home'),
        label: const Text('Continue'),
        icon: const Icon(Icons.arrow_forward),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String name, String code) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(name, style: Theme.of(context).textTheme.bodyLarge),
        subtitle: Text('Code: $code'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Save language preference
          context.go('/home');
        },
      ),
    );
  }
}
