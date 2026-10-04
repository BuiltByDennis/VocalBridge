import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../speech/ug_hci_lab/ug_hci_lab_config.dart';
import '../theme/app_theme.dart';

/// Settings screen for choosing the speech backend and entering the
/// University of Ghana HCI Lab API credentials.
///
/// This is the screen that makes the hackathon's ASR/TTS rule actionable:
/// without a configured API key, Ghanaian languages cannot run in the app.
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
  bool _showAdvanced = false;
  bool _testing = false;
  String? _testResult;
  bool _testOk = false;

  @override
  void initState() {
    super.initState();
    final s = ref.read(ugHciLabSettingsProvider);
    _baseUrlController = TextEditingController(text: s.baseUrl);
    _apiKeyController = TextEditingController(text: s.apiKey);
    _asrPathController = TextEditingController(text: s.asrPath);
    _ttsPathController = TextEditingController(text: s.ttsPath);
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _asrPathController.dispose();
    _ttsPathController.dispose();
    super.dispose();
  }

  Future<void> _save({bool showConfirmation = true}) async {
    final current = ref.read(ugHciLabSettingsProvider);
    final updated = current.copyWith(
      baseUrl: _baseUrlController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      asrPath: _asrPathController.text.trim().isEmpty
          ? '/asr'
          : _asrPathController.text.trim(),
      ttsPath: _ttsPathController.text.trim().isEmpty
          ? '/tts'
          : _ttsPathController.text.trim(),
    );
    await ref.read(ugHciLabSettingsProvider.notifier).update(updated);
    if (showConfirmation && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech provider settings saved. Restart the conversation screen to apply.')),
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

  /// Best-effort reachability check. A 401/403 means the server is reachable
  /// but the key was rejected — still useful signal. Exact endpoint paths
  /// are confirmed when Lab API access is granted.
  Future<void> _testConnection() async {
    final base = _baseUrlController.text.trim();
    if (base.isEmpty) {
      setState(() {
        _testResult = 'Enter the API base URL first.';
        _testOk = false;
      });
      return;
    }
    setState(() {
      _testing = true;
      _testResult = null;
    });
    try {
      final normalized = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
      final response = await http
          .get(Uri.parse(normalized),
              headers: {'Authorization': 'Bearer ${_apiKeyController.text.trim()}'})
          .timeout(const Duration(seconds: 15));
      final code = response.statusCode;
      if (code == 401 || code == 403) {
        _testResult = 'Server reachable (HTTP $code) — API key was rejected. Check the key.';
        _testOk = false;
      } else {
        _testResult = 'Server reachable (HTTP $code). Confirm the ASR/TTS paths below match the Lab docs.';
        _testOk = true;
      }
    } catch (e) {
      _testResult = 'Could not reach the server: $e';
      _testOk = false;
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(ugHciLabSettingsProvider);
    final isLab = settings.provider == SpeechProvider.ugHciLab;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.mainBackgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  children: [
                    _infoCard(),
                    const SizedBox(height: 16),
                    _providerCard(
                      title: 'On-device (offline)',
                      subtitle: 'Sherpa-ONNX / Whisper · English only · works without internet',
                      icon: Icons.smartphone_outlined,
                      selected: !isLab,
                      onTap: () => _setProvider(SpeechProvider.offline),
                    ),
                    _providerCard(
                      title: 'UG HCI Lab API',
                      subtitle: 'Required for Twi, Ewe, Dagbani · hackathon-compliant',
                      icon: Icons.cloud_outlined,
                      selected: isLab,
                      onTap: () => _setProvider(SpeechProvider.ugHciLab),
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
                          hint: '/asr',
                        ),
                        const SizedBox(height: 12),
                        _textField(
                          controller: _ttsPathController,
                          label: 'TTS path',
                          hint: '/tts',
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Verify these paths against the Lab API docs — update them here, no code changes needed.',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
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

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: AppTheme.textPrimary),
              SizedBox(width: 8),
              Text('Hackathon requirement',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'ASR and TTS must run through the University of Ghana HCI Lab APIs. '
            'Complete the Lab consent form to request API access, then paste your key below. '
            'Until then, the app runs on the offline English engine.',
            style: TextStyle(fontSize: 13, height: 1.5, color: AppTheme.textSecondary),
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
