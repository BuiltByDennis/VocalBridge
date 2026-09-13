import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'ui/theme/accessible_theme.dart';

void main() {
  runApp(const ProviderScope(child: KasaMeApp()));
}

class KasaMeApp extends StatelessWidget {
  const KasaMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kasa Me',
      theme: AccessibleTheme.lightTheme,
      darkTheme: AccessibleTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
