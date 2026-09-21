import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../ui/home/home_screen.dart';
import '../ui/home/home_communication_notifier.dart';
import '../ui/welcome/welcome_screen.dart';
import '../ui/language/language_selection_screen.dart';
import '../ui/settings/settings_screen.dart';
import '../ui/settings/personalization_settings_screen.dart';
import '../ui/onboarding/calibration_wizard_screen.dart';
import '../ui/phrasebook/phrasebook_screen.dart';
import '../ui/history/history_screen.dart';
import '../ui/diagnostics/asr_diagnostics_screen.dart';
import '../storage/database/app_database.dart';

/// Provides a [GoRouter] accessible from the widget tree.
/// The router includes a redirect guard: users who haven't completed
/// calibration (isCalibrated == false) are sent back to the welcome flow.
final routerProvider = Provider<GoRouter>((ref) => appRouter);

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/language_selection',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(
      path: '/calibration',
      builder: (context, state) => const CalibrationWizardScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/phrasebook',
      builder: (context, state) => const PhrasebookScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
      routes: [
        GoRoute(
          path: 'language',
          builder: (context, state) => const LanguageSelectionScreen(),
        ),
        GoRoute(
          path: 'personalization',
          builder: (context, state) => const PersonalizationSettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/diagnostics',
      builder: (context, state) => const AsrDiagnosticsScreen(),
    ),
  ],
);
