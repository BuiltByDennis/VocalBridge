import 'package:flutter/material.dart';

/// A tap target a screen reader can find, name, and activate.
///
/// Kasa Me's custom buttons were plain [GestureDetector]s — TalkBack
/// and VoiceOver could not see most of them at all (no role, no name,
/// sometimes no tap action). Wrapping a control in [AccessibleTap]
/// gives it a proper button role, a spoken [label], an optional
/// [selected] state for radio-like cards (languages, providers), and
/// a semantics tap action, while the visual child and the physical
/// tap behaviour stay exactly as designed.
///
/// WCAG references: 4.1.3 / 2.1.1 (operable by assistive tech),
/// 4.1.2 (name, role, value), 2.5.3 (label in name).
class AccessibleTap extends StatelessWidget {
  /// What the screen reader announces, e.g. 'Open settings' or
  /// 'Speak: I need water'.
  final String label;

  /// Optional extra guidance, e.g. 'Double tap to correct this word'.
  final String? hint;

  /// For selectable cards: announces "selected" / "not selected".
  final bool? selected;

  /// Set false for disabled/coming-soon items so the reader reports
  /// the control as disabled and it cannot be activated.
  final bool enabled;

  final VoidCallback? onTap;
  final Widget child;

  const AccessibleTap({
    super.key,
    required this.label,
    this.hint,
    this.selected,
    this.enabled = true,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      hint: hint,
      selected: selected,
      enabled: enabled,
      onTap: enabled ? onTap : null,
      child: GestureDetector(
        // The whole control area is tappable, including any padding
        // or transparent parts of the child — a button should not
        // have dead zones.
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: child,
      ),
    );
  }
}
