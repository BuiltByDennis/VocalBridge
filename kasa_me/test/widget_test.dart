import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasa_me/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: KasaMeApp()));

    // Verify that the app builds without crashing.
    expect(find.byType(KasaMeApp), findsOneWidget);
  });
}
