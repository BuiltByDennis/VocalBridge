import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../home/home_communication_notifier.dart';
import '../../speech/diagnostics/repositories/diagnostics_repository.dart';

class AsrDiagnosticsScreen extends ConsumerWidget {
  const AsrDiagnosticsScreen({super.key});

  Future<void> _exportMetrics(BuildContext context, WidgetRef ref) async {
    try {
      final repo = ref.read(diagnosticsRepositoryProvider);
      final events = await repo.getEventsForProfile('default_user');
      
      final appDir = await getApplicationDocumentsDirectory();
      final metricsDir = Directory('${appDir.path}/metrics');
      if (!await metricsDir.exists()) {
        await metricsDir.create(recursive: true);
      }
      
      final file = File('${metricsDir.path}/asr_metrics_${DateTime.now().millisecondsSinceEpoch}.csv');
      final sink = file.openWrite();
      
      // Header
      sink.writeln('Timestamp,RawTranscript,PersonalizedTranscript,Confidence,WasCorrected,Context');
      
      // Rows
      for (final event in events) {
        final timestamp = event.timestamp.toIso8601String();
        // Escape CSV strings
        final raw = '"${event.rawTranscript.replaceAll('"', '""')}"';
        final personalized = '"${event.personalizedTranscript.replaceAll('"', '""')}"';
        final confidence = event.confidence?.toStringAsFixed(3) ?? '';
        final wasCorrected = event.wasCorrected ? '1' : '0';
        final contextField = '"${event.context.replaceAll('"', '""')}"';
        
        sink.writeln('$timestamp,$raw,$personalized,$confidence,$wasCorrected,$contextField');
      }
      
      await sink.flush();
      await sink.close();

      if (context.mounted) {
        Clipboard.setData(ClipboardData(text: file.path));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Metrics saved to: ${file.path} (Path copied to clipboard)')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export metrics: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeCommunicationProvider);
    final model = state.activeModel;

    double rtf = 0.0;
    if (state.lastAudioDuration != null &&
        state.lastInferenceTime != null &&
        state.lastAudioDuration!.inMilliseconds > 0) {
      rtf = state.lastInferenceTime!.inMilliseconds / state.lastAudioDuration!.inMilliseconds;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ASR Diagnostics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export CSV',
            onPressed: () => _exportMetrics(context, ref),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMetricCard(
            context,
            title: 'ASR Engine & Model',
            items: [
              _MetricItem('Engine Runtime', 'Sherpa-ONNX'),
              _MetricItem('Model ID', model.id),
              _MetricItem('Model Name', model.displayName),
              _MetricItem('Language', state.selectedLanguage),
              _MetricItem('Sample Rate', '${model.sampleRate} Hz'),
              _MetricItem('Streaming Support', model.streaming ? 'YES' : 'NO'),
              _MetricItem('Est. Model Size', '${model.estimatedSizeMb} MB'),
            ],
          ),
          const SizedBox(height: 16),
          _buildMetricCard(
            context,
            title: 'Lifecycle & Performance',
            items: [
              _MetricItem('Model Loaded', state.engineState != UiEngineState.notLoaded && state.engineState != UiEngineState.loading ? 'YES' : 'NO'),
              _MetricItem('Model Load Time', state.modelLoadDuration != null ? '${state.modelLoadDuration!.inMilliseconds} ms' : 'N/A'),
              _MetricItem('Current State', state.engineState.name.toUpperCase()),
              _MetricItem('Last Audio Duration', state.lastAudioDuration != null ? '${(state.lastAudioDuration!.inMilliseconds / 1000).toStringAsFixed(2)} sec' : 'N/A'),
              _MetricItem('Inference Time', state.lastInferenceTime != null ? '${state.lastInferenceTime!.inMilliseconds} ms' : 'N/A'),
              _MetricItem('Real-Time Factor (RTF)', rtf > 0 ? rtf.toStringAsFixed(3) : 'N/A'),
              _MetricItem('Confidence', state.confidence != null ? '${(state.confidence! * 100).toStringAsFixed(1)}%' : 'N/A'),
            ],
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Error',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, {required String title, required List<_MetricItem> items}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.label, style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text(item.value, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _MetricItem {
  final String label;
  final String value;

  _MetricItem(this.label, this.value);
}
