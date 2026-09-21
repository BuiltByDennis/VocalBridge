import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'app/router.dart';
import 'ui/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the sherpa-onnx native bindings BEFORE any recognizer is created.
  // Without this, all sherpa API calls throw "Please initialize sherpa-onnx first".
  sherpa.initBindings();

  // Pre-cache Google Fonts config so the font is applied synchronously on first render.
  GoogleFonts.config.allowRuntimeFetching = true;
  runApp(const ProviderScope(child: KasaMeApp()));
}

class KasaMeApp extends StatelessWidget {
  const KasaMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kasa Me',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
