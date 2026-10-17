import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/accessibility/accessibility_settings.dart';
import '../../speech/khaya/khaya_config.dart';
import '../../speech/ug_hci_lab/lab_api_error.dart';
import '../../speech/ug_hci_lab/lab_diagnostics_store.dart';
import '../../speech/ug_hci_lab/ug_hci_lab_config.dart';
import '../theme/app_theme.dart';

/// Settings screen for choosing the speech backend and entering the
/// University of Ghana HCI Lab API credentials.
///
/// Ghanaian languages run through the Lab APIs: without a configured
/// API key, they cannot run in the app.
class SpeechProviderScreen extends ConsumerStatefulWidget {
  const SpeechProviderScreen({super.key});

  @override
  ConsumerState<SpeechProviderScreen> createState() =>
      _SpeechProviderScreenState();
}

class _SpeechProviderScreenState extends ConsumerState<SpeechProviderScreen> {
  late final TextEditingController _baseUrlController;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _asrPathController;
  late final TextEditingController _ttsPathController;
  late final TextEditingController _khayaKeyController;
  bool _showAdvanced = false;
  bool _testing = false;
  String? _testResult;
  bool _testOk = false;
  bool _khayaTesting = false;
  String? _khayaTestResult;
  bool _khayaTestOk = false;
  String _khayaSpeaker = '';

  @override
  void initState() {
    super.initState();
    final s = ref.read(ugHciLabSettingsProvider);
    _baseUrlController = TextEditingController(text: s.baseUrl);
    _apiKeyController = TextEditingController(text: s.apiKey);
    _asrPathController = TextEditingController(text: s.asrPath);
    _ttsPathController = TextEditingController(text: s.ttsPath);
    final k = ref.read(khayaSettingsProvider);
    _khayaKeyController = TextEditingController(text: k.apiKey);
    _khayaSpeaker = k.speakerId;
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _asrPathController.dispose();
    _ttsPathController.dispose();
    _khayaKeyController.dispose();
    super.dispose();
  }

  Future<void> _save({bool showConfirmation = true}) async {
    final current = ref.read(ugHciLabSettingsProvider);
    final updated = current.copyWith(
      baseUrl: _baseUrlController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      asrPath: _asrPathController.text.trim().isEmpty
          ? UgHciLabSettings.defaultAsrPath
          : _asrPathController.text.trim(),
      ttsPath: _ttsPathController.text.trim().isEmpty
          ? UgHciLabSettings.defaultTtsPath
          : _ttsPathController.text.trim(),
    );
    await ref.read(ugHciLabSettingsProvider.notifier).update(updated);
    if (showConfirmation && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech provider saved — applied immediately.')),
      );
    }
  }

  Future<void> _setProvider(SpeechProvider provider) async {
    final current = ref.read(ugHciLabSettingsProvider);
    await ref
        .read(ugHciLabSettingsProvider.notifier)
        .update(current.copyWith(provider: provider));
    setState(() {});
  }

  /// Real end-to-end probe: asks the Lab TTS endpoint to synthesize one
  /// word ("Akwaaba"). That is the only way to know the key, the path,
  /// and the voice all work. It costs 1 of the day's 15 TTS requests, so
  /// it only runs when the user taps the button.
  Future<void> _testConnection() async {
    final base = _baseUrlController.text.trim();
    final key = _apiKeyController.text.trim();
    if (base.isEmpty || key.isEmpty) {
      setState(() {
        _testResult = 'Enter the API base URL and API key first.';
        _testOk = false;
      });
      return;
    }
    setState(() {
      _testing = true;
      _testResult = null;
    });
    // Persist first: the app runs on what is SAVED, so test exactly
    // that. A key typed but never saved used to pass tests here
    // while the app itself kept running without it.
    await _save(showConfirmation: false);
    try {
      final normalized =
          base.endsWith('/') ? base.substring(0, base.length - 1) : base;
      final ttsPath = _ttsPathController.text.trim().isEmpty
          ? UgHciLabSettings.defaultTtsPath
          : _ttsPathController.text.trim();
      final stopwatch = Stopwatch()..start();
      final response = await http
          .post(
            Uri.parse('$normalized$ttsPath'),
            headers: {
              'Authorization': 'Bearer $key',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(
                {'text': 'Akwaaba', 'model_type': 'ss', 'speaker': 'PT'}),
          )
          // The Lab can take well over 20 s to synthesize when it is
          // busy (requests sit "In Progress" on its dashboard) — a
          // shorter cap reported a healthy key as unreachable.
          .timeout(const Duration(seconds: 60));
      final code = response.statusCode;
      final contentType =
          response.headers['content-type']?.toLowerCase() ?? '';
      // The response is audio if the header says so OR the bytes are
      // a WAV (RIFF) — the header alone has proven unreliable.
      final bytes = response.bodyBytes;
      final isWavBytes = bytes.length >= 4 &&
          bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46;
      await LabDiagnosticsStore.recordTts(
        statusCode: code,
        contentType: contentType,
        byteCount: bytes.length,
        detectedFormat: isWavBytes ? 'wav' : 'unknown',
        elapsed: stopwatch.elapsed,
      );
      if (code >= 200 &&
          code < 300 &&
          (contentType.contains('audio') || isWavBytes)) {
        _testResult = 'Connected ✓ — the Lab accepted your key and returned '
            'speech audio. (This test used 1 of today\'s 15 TTS requests.)';
        _testOk = true;
      } else if (code == 401 || code == 403) {
        _testResult = 'Server reachable — but the API key was rejected '
            '(HTTP $code). Check the key.';
        _testOk = false;
      } else {
        final labError = LabApiException.tryParse(response.body, code);
        if (labError != null && labError.isQuota) {
          _testResult = 'Your key works ✓ — but the Lab TTS quota is used '
              'up right now. It resets on the Lab\'s daily/weekly schedule.';
          _testOk = true;
        } else if (labError != null && labError.isUnavailable) {
          _testResult = 'The Lab\'s TTS service is temporarily unavailable '
              'right now — that is on the Lab\'s side, not your key or your '
              'phone. Wait a minute and test again. In the app, speech '
              'requests now retry automatically when this happens.';
          _testOk = false;
        } else if (labError != null) {
          _testResult = 'The Lab said: ${labError.serverMessage}';
          _testOk = false;
        } else {
          _testResult = 'Server reachable (HTTP $code). If speech does not '
              'work in the app, check the endpoint paths under Advanced.';
          _testOk = code >= 200 && code < 300;
        }
      }
    } on TimeoutException {
      _testResult = 'The Lab did not answer within 60 seconds — its '
          'service is slow right now (requests sit "In Progress" on '
          'the Lab dashboard when this happens). Your key may still '
          'be fine; wait a moment and test again.';
      _testOk = false;
    } catch (e) {
      _testResult = 'Could not reach the server: $e';
      _testOk = false;
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _saveKhaya({bool showConfirmation = true}) async {
    final current = ref.read(khayaSettingsProvider);
    await ref.read(khayaSettingsProvider.notifier).update(current.copyWith(
          apiKey: _khayaKeyController.text.trim(),
          speakerId: _khayaSpeaker,
        ));
    if (showConfirmation && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khaya settings saved — applied immediately.')),
      );
    }
  }

  /// Validates the Khaya key against GET /asr/v3/languages — this
  /// costs NO speech requests, unlike a synthesis probe.
  Future<void> _testKhaya() async {
    final key = _khayaKeyController.text.trim();
    if (key.isEmpty) {
      setState(() {
        _khayaTestResult = 'Enter your Khaya subscription key first.';
        _khayaTestOk = false;
      });
      return;
    }
    setState(() {
      _khayaTesting = true;
      _khayaTestResult = null;
    });
    // Persist first — the app runs on what is SAVED, so test exactly
    // that (same trap as the Lab key: typed-but-unsaved tested fine
    // here while the app kept running without it).
    await _saveKhaya(showConfirmation: false);
    try {
      final probe = KhayaSettings(apiKey: key);
      final response = await http
          .get(probe.languagesUri(), headers: probe.authHeaders())
          // A first call to Khaya's gateway can be slow (cold start,
          // mobile data) — 20 s reported a working key as broken.
          .timeout(const Duration(seconds: 45));
      final code = response.statusCode;
      if (code >= 200 && code < 300) {
        var count = 0;
        final codes = <String>{};
        try {
          final decoded = jsonDecode(response.body);
          final langs = decoded is Map ? decoded['languages'] : null;
          if (langs is List) {
            count = langs.length;
            for (final l in langs) {
              if (l is Map && l['code'] != null) {
                codes.add(l['code'].toString());
              }
            }
          }
        } catch (_) {}
        final ghanaian = ['twi', 'ewe', 'dag']
            .where(codes.contains)
            .map((c) => switch (c) {
                  'twi' => 'Twi',
                  'ewe' => 'Ewe',
                  _ => 'Dagbani',
                })
            .join(', ');
        _khayaTestResult = 'Connected ✓ — your key works. Khaya lists '
            '$count languages${ghanaian.isNotEmpty ? ', including $ghanaian' : ''}. '
            '(This check used no speech requests.)';
        _khayaTestOk = true;
      } else if (code == 401 || code == 403) {
        _khayaTestResult = 'Server reachable — but the Khaya key was '
            'rejected (HTTP $code). Check the key.';
        _khayaTestOk = false;
      } else {
        _khayaTestResult =
            'Server reachable (HTTP $code). If speech does not work in the app, check the key.';
        _khayaTestOk = false;
      }
    } on TimeoutException {
      _khayaTestResult = 'Khaya did not answer within 45 seconds. '
          'Their gateway can be slow on a first call, or your '
          'connection is slow right now — the key may still be fine. '
          'Wait a moment and test again.';
      _khayaTestOk = false;
    } catch (e) {
      _khayaTestResult = 'Could not reach Khaya: $e';
      _khayaTestOk = false;
    } finally {
      if (mounted) setState(() => _khayaTesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(ugHciLabSettingsProvider);
    final khayaSettings = ref.watch(khayaSettingsProvider);
    final isLab = settings.provider == SpeechProvider.ugHciLab;
    final isKhaya = settings.provider == SpeechProvider.khaya;
    final isHC =
        ref.watch(accessibilitySettingsProvider).highContrastMode;

    return Scaffold(
      body: Container(
        decoration:
            BoxDecoration(gradient: AppTheme.backgroundGradient(highContrast: isHC)),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  children: [
                    const SizedBox(height: 16),
                    _providerCard(
                      title: 'On-device (offline)',
                      subtitle: 'Sherpa-ONNX / Whisper · English only · works without internet',
                      icon: Icons.smartphone_outlined,
                      selected: settings.provider == SpeechProvider.offline,
                      onTap: () => _setProvider(SpeechProvider.offline),
                    ),
                    _providerCard(
                      title: 'UG HCI Lab API',
                      subtitle: 'UG HCI Lab speech services · required for Twi, Ewe, Dagbani',
                      icon: Icons.cloud_outlined,
                      selected: isLab,
                      onTap: () => _setProvider(SpeechProvider.ugHciLab),
                    ),
                    _providerCard(
                      title: 'Khaya AI (Ghana NLP)',
                      subtitle: 'Khaya speech services · Twi, Ewe, Dagbani · you pick the language',
                      icon: Icons.language_outlined,
                      selected: isKhaya,
                      onTap: () => _setProvider(SpeechProvider.khaya),
                    ),
                    if (isLab) ...[
                      const SizedBox(height: 16),
                      _textField(
                        controller: _baseUrlController,
                        label: 'API base URL',
                        hint: 'https://…',
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 12),
                      _textField(
                        controller: _apiKeyController,
                        label: 'API key',
                        hint: 'Paste the key from the Lab',
                        obscure: true,
                      ),
                      const SizedBox(height: 8),
                      _statusRow(settings),
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _showAdvanced = !_showAdvanced),
                        icon: Icon(_showAdvanced
                            ? Icons.expand_less
                            : Icons.expand_more),
                        label: const Text('Advanced: endpoint paths'),
                      ),
                      if (_showAdvanced) ...[
                        _textField(
                          controller: _asrPathController,
                          label: 'ASR path',
                          hint: '/api/v1/asr',
                        ),
                        const SizedBox(height: 12),
                        _textField(
                          controller: _ttsPathController,
                          label: 'TTS path',
                          hint: '/api/v1/tts',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'These are the Lab\'s published paths. Change them only if the Lab moves its gateway.',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.pageTextSecondary(highContrast: isHC)),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _save(),
                              child: const Text('Save'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _testing ? null : _testConnection,
                              child: _testing
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Test connection'),
                            ),
                          ),
                        ],
                      ),
                      if (_testResult != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (_testOk ? Colors.green : Colors.amber)
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _testResult!,
                            style: TextStyle(
                              fontSize: 13,
                              color: _testOk
                                  ? Colors.green.shade800
                                  : Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ],
                    if (isKhaya) ...[
                      const SizedBox(height: 16),
                      _textField(
                        controller: _khayaKeyController,
                        label: 'Khaya API key',
                        hint: 'Paste your Khaya subscription key',
                        obscure: true,
                      ),
                      const SizedBox(height: 8),
                      _khayaStatusRow(khayaSettings),
                      const SizedBox(height: 12),
                      _khayaSpeakerRow(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _saveKhaya(),
                              child: const Text('Save'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _khayaTesting ? null : _testKhaya,
                              child: _khayaTesting
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Test connection'),
                            ),
                          ),
                        ],
                      ),
                      if (_khayaTestResult != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (_khayaTestOk ? Colors.green : Colors.amber)
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _khayaTestResult!,
                            style: TextStyle(
                              fontSize: 13,
                              color: _khayaTestOk
                                  ? Colors.green.shade800
                                  : Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 16),
                    _labDiagnosticsCard(),
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

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration:
                  const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 16, color: AppTheme.textPrimary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text('Speech Provider',
                style: Theme.of(context).textTheme.displayMedium),
          ),
        ],
      ),
    );
  }


  Widget _providerCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryPurple.withOpacity(0.1)
              : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppTheme.primaryPurple : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 26, color: AppTheme.primaryPurple),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: selected
                  ? AppTheme.primaryPurple
                  : AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(UgHciLabSettings settings) {
    final ok = settings.isConfigured;
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: (ok ? Colors.green : Colors.amber).withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            size: 18,
            color: ok ? Colors.green.shade700 : Colors.amber.shade800,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ok
                  ? 'API key saved — Twi is ready to use.'
                  : 'No API key yet — save one to unlock Twi.',
              style: TextStyle(
                fontSize: 13,
                color: ok ? Colors.green.shade800 : Colors.amber.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _khayaStatusRow(KhayaSettings settings) {
    final ok = settings.isConfigured;
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: (ok ? Colors.green : Colors.amber).withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            size: 18,
            color: ok ? Colors.green.shade700 : Colors.amber.shade800,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ok
                  ? 'Khaya key saved — Twi, Ewe and Dagbani ready via Khaya.'
                  : 'No Khaya key yet — subscribe at translation.ghananlp.org and paste the key here.',
              style: TextStyle(
                fontSize: 13,
                color: ok ? Colors.green.shade800 : Colors.amber.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _khayaSpeakerRow() {
    const labels = {
      '': 'Default voice (per language)',
      'male_low': 'Male — low',
      'male_high': 'Male — high',
      'female': 'Female',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Voice',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButton<String>(
            value: _khayaSpeaker,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: labels.entries
                .map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value, style: const TextStyle(fontSize: 14)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _khayaSpeaker = v ?? ''),
          ),
        ),
      ],
    );
  }

  /// What the speech API actually sent back on the most recent
  /// ASR/TTS calls — the evidence support needs when a request
  /// "succeeds" on the provider's dashboard but the app shows an
  /// empty transcript or stays silent. Data comes from
  /// [LabDiagnosticsStore], written by the speech engines on every
  /// call (each record names its provider).
  Widget _labDiagnosticsCard() {
    return FutureBuilder<LabDiagnosticsSnapshot>(
      future: LabDiagnosticsStore.load(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null || data.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Last API responses',
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 2),
              const Text(
                'What the speech API sent back most recently. If speech '
                'comes back empty or silent, share this with support.',
                style:
                    TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              if (data.asr != null) ...[
                const SizedBox(height: 10),
                Text(
                  'ASR · ${data.asr!['provider'] ?? 'UG HCI Lab'} — '
                  'HTTP ${data.asr!['statusCode']} · '
                  '${data.asr!['elapsedMs']} ms',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  (data.asr!['body'] ?? '').toString(),
                  style:
                      const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                ),
              ],
              if (data.tts != null) ...[
                const SizedBox(height: 10),
                Text(
                  'TTS · ${data.tts!['provider'] ?? 'UG HCI Lab'} — '
                  'HTTP ${data.tts!['statusCode']} · '
                  '${data.tts!['elapsedMs']} ms',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.tts!['byteCount']} bytes · '
                  '${data.tts!['contentType']} · '
                  'detected format: ${data.tts!['detectedFormat']}',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
