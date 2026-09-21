import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../storage/database/app_database.dart';
import '../../speech/tts/offline_tts_engine.dart';
import '../../speech/tts/tts_engine.dart';
import '../home/home_communication_notifier.dart' show databaseProvider;
import '../theme/app_theme.dart';

final _phrasebookProvider = StreamProvider<List<PhrasebookEntry>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.phrasebookEntries)
        ..orderBy([
          (t) => drift.OrderingTerm(
              expression: t.usageCount, mode: drift.OrderingMode.desc),
        ]))
      .watch();
});

class PhrasebookScreen extends ConsumerStatefulWidget {
  const PhrasebookScreen({super.key});

  @override
  ConsumerState<PhrasebookScreen> createState() => _PhrasebookScreenState();
}

class _PhrasebookScreenState extends ConsumerState<PhrasebookScreen> {
  final TtsEngine _tts = OfflineTtsEngine();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tts.initialize();
  }

  @override
  void dispose() {
    _tts.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phrasesAsync = ref.watch(_phrasebookProvider);

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
                    Text('Phrasebook',
                        style: Theme.of(context).textTheme.displayMedium),
                  ],
                ),
              ),
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search phrases…',
                    prefixIcon: const Icon(Icons.search),
                    fillColor: Colors.white.withOpacity(0.85),
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: phrasesAsync.when(
                  data: (phrases) {
                    final filtered = _searchQuery.isEmpty
                        ? phrases
                        : phrases
                            .where((p) =>
                                p.phrase
                                    .toLowerCase()
                                    .contains(_searchQuery) ||
                                (p.category ?? '')
                                    .toLowerCase()
                                    .contains(_searchQuery))
                            .toList();

                    if (filtered.isEmpty) {
                      return const Center(
                          child: Text('No phrases found.',
                              style: TextStyle(color: AppTheme.textSecondary)));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _buildPhraseCard(filtered[i]),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPhraseDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Phrase'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildPhraseCard(PhrasebookEntry entry) {
    return Dismissible(
      key: Key('phrase_${entry.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.redAccent),
      ),
      onDismissed: (_) => _deletePhrase(entry),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.phrase,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500)),
                  if (entry.category != null && entry.category!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(entry.category!,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.primaryPurple,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  if (entry.usageCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Used ${entry.usageCount}×',
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textSecondary)),
                    ),
                ],
              ),
            ),
            // Speak button
            GestureDetector(
              onTap: () => _tts.speak(entry.phrase),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.volume_up_rounded,
                    color: AppTheme.primaryPurple, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePhrase(PhrasebookEntry entry) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.phrasebookEntries)
          ..where((t) => t.id.equals(entry.id)))
        .go();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${entry.phrase}" deleted'),
          action: SnackBarAction(label: 'Undo', onPressed: () async {
            await db.into(db.phrasebookEntries).insert(
              PhrasebookEntriesCompanion.insert(
                profileId: entry.profileId,
                phrase: entry.phrase,
                category: drift.Value(entry.category),
              ),
            );
          }),
        ),
      );
    }
  }

  void _showAddPhraseDialog(BuildContext context) {
    final phraseCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Phrase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phraseCtrl,
              decoration: const InputDecoration(labelText: 'Phrase'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoryCtrl,
              decoration: const InputDecoration(
                  labelText: 'Category (optional)',
                  hintText: 'e.g. Healthcare, Banking'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final phrase = phraseCtrl.text.trim();
              if (phrase.isEmpty) return;
              final db = ref.read(databaseProvider);
              final profile = await (db.select(db.profiles)
                    ..limit(1))
                  .getSingleOrNull();
              if (profile == null) return;
              await db.into(db.phrasebookEntries).insert(
                PhrasebookEntriesCompanion.insert(
                  profileId: profile.id,
                  phrase: phrase,
                  category: drift.Value(categoryCtrl.text.trim()),
                ),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
