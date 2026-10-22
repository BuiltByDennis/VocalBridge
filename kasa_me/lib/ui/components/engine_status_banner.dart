import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../home/home_communication_notifier.dart';

/// Reusable engine status banner — shown at the top of any screen that
/// interacts with the speech engine.
class EngineStatusBanner extends ConsumerWidget {
  final UiEngineState engineState;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const EngineStatusBanner({
    super.key,
    required this.engineState,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (engineState) {
      case UiEngineState.notLoaded:
      case UiEngineState.loading:
        return _banner(
          color: Colors.amber.shade50,
          borderColor: Colors.amber.shade300,
          icon: Icons.hourglass_top_rounded,
          iconColor: Colors.amber.shade700,
          label: 'Loading speech model…',
          trailing: const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );

      case UiEngineState.ready:
        return _banner(
          color: Colors.green.shade50,
          borderColor: Colors.green.shade200,
          icon: Icons.check_circle_outline_rounded,
          iconColor: Colors.green.shade700,
          label: 'Ready',
        );

      case UiEngineState.listening:
        return _ListeningBanner();

      case UiEngineState.processing:
        return _banner(
          color: Colors.blue.shade50,
          borderColor: Colors.blue.shade200,
          icon: Icons.sync_rounded,
          iconColor: Colors.blue.shade700,
          label: 'Processing…',
          trailing: const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );

      case UiEngineState.error:
        return _banner(
          color: Colors.red.shade50,
          borderColor: Colors.red.shade200,
          icon: Icons.error_outline_rounded,
          iconColor: Colors.red.shade700,
          label: errorMessage ?? 'An error occurred',
          trailing: onRetry != null
              ? GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Retry',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.redAccent)),
                  ),
                )
              : null,
        );
    }
  }

  Widget _banner({
    required Color color,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required String label,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: iconColor,
                    fontWeight: FontWeight.w500)),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}

/// Animated listening banner with a pulsing dot
class _ListeningBanner extends StatefulWidget {
  @override
  State<_ListeningBanner> createState() => _ListeningBannerState();
}

class _ListeningBannerState extends State<_ListeningBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Opacity(
              opacity: _anim.value,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                    color: AppTheme.primaryPurple, shape: BoxShape.circle),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text('Listening…',
              style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
