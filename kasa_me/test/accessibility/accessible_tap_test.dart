import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasa_me/ui/components/accessible_tap.dart';

/// Every custom button in Kasa Me goes through AccessibleTap (or an
/// equivalent Semantics wrap): a screen reader must be able to find
/// it, hear its name, know its state, and activate it.
void main() {
  testWidgets('AccessibleTap exposes a named, tappable button',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AccessibleTap(
          label: 'Open settings',
          onTap: () => taps++,
          child: const SizedBox(width: 48, height: 48),
        ),
      ),
    ));
    final semantics = tester.getSemantics(find.byType(AccessibleTap));
    expect(
      semantics,
      matchesSemantics(
          label: 'Open settings',
          isButton: true,
          hasTapAction: true,
          hasEnabledState: true,
          isEnabled: true),
    );
    await tester.tap(find.byType(AccessibleTap));
    expect(taps, 1);
  });

  testWidgets('a selectable card announces its selected state',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AccessibleTap(
          label: 'Twi',
          selected: true,
          onTap: () {},
          child: const SizedBox(width: 48, height: 48),
        ),
      ),
    ));
    expect(
      tester.getSemantics(find.byType(AccessibleTap)),
      matchesSemantics(
          label: 'Twi',
          isButton: true,
          hasTapAction: true,
          hasEnabledState: true,
          isEnabled: true,
          hasSelectedState: true,
          isSelected: true),
    );
  });

  testWidgets('a disabled item reports disabled and does not fire',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AccessibleTap(
          label: 'Dagbani, coming soon',
          enabled: false,
          onTap: () => taps++,
          child: const SizedBox(width: 48, height: 48),
        ),
      ),
    ));
    expect(
      tester.getSemantics(find.byType(AccessibleTap)),
      matchesSemantics(
          label: 'Dagbani, coming soon',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false),
    );
    await tester.tap(find.byType(AccessibleTap));
    expect(taps, 0);
  });
}
