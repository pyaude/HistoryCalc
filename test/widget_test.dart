import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:historycalc/core/storage/history_storage.dart';
import 'package:historycalc/core/providers/calculator_provider.dart';
import 'package:historycalc/main.dart';

void main() {
  testWidgets('App renders calculator screen', (WidgetTester tester) async {
    // Initialize Hive with a temp path for testing
    await Hive.initFlutter('test_hive');
    final storage = HistoryStorage();
    await storage.init();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyStorageProvider.overrideWithValue(storage),
        ],
        child: const HistoryCalcApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify key UI elements are present
    expect(find.text('历史记录'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    expect(find.text('='), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    // Clean up
    await Hive.deleteFromDisk();
  });
}
