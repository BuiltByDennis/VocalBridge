import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'app/router.dart';
import 'core/accessibility/accessibility_settings.dart';
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

class KasaMeApp extends ConsumerWidget {
  const KasaMeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibility = ref.watch(accessibilitySettingsProvider);
    final theme = AppTheme.themeFor(highContrast: accessibility.highContrastMode);

    return MaterialApp.router(
      title: 'Kasa Me',
      theme: theme,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Text magnification for low vision (WCAG 1.4.4): the
        // in-app factor MULTIPLIES the system text size — it never
        // replaces or caps it — so a user can combine both.
        final media = MediaQuery.of(context);
        final systemFactor = media.textScaler.scale(1000) / 1000;
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(
                systemFactor * accessibility.textScaleFactor),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
