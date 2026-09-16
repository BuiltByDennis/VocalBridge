import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/calibration/calibration_screen.dart';
import '../ui/assistant/voice_assistant_screen.dart';
import '../ui/components/main_navigation_shell.dart';
import '../ui/conversations/conversations_screen.dart';
import '../ui/home/home_screen.dart';
import '../ui/language/language_selection_screen.dart';
import '../ui/settings/personalization_settings_screen.dart';
import '../ui/settings/settings_screen.dart';
import '../ui/welcome/welcome_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        int index = 0;
        final location = state.uri.path;
        if (location == '/home') index = 0;
        if (location == '/assistant') index = 1;
        if (location == '/conversations') index = 2;
        if (location == '/personalization') index = 3;

        return MainNavigationShell(
          currentIndex: index,
          onDestinationSelected: (i) {
            switch (i) {
              case 0:
                context.go('/home');
                break;
              case 1:
                context.go('/assistant');
                break;
              case 2:
                context.go('/conversations');
                break;
              case 3:
                context.go('/personalization');
                break;
            }
          },
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/assistant',
          builder: (context, state) => const VoiceAssistantScreen(),
        ),
        GoRoute(
          path: '/conversations',
          builder: (context, state) => const ConversationsScreen(),
        ),
        GoRoute(
          path: '/personalization',
          builder: (context, state) => const PersonalizationSettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/language_selection',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/calibration',
      builder: (context, state) => const CalibrationScreen(),
    ),
  ],
);
