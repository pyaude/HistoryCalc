import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/history_storage.dart';
import 'core/providers/calculator_provider.dart';
import 'presentation/screens/calculator_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for history persistence
  final historyStorage = HistoryStorage();
  await historyStorage.init();

  runApp(
    ProviderScope(
      overrides: [
        historyStorageProvider.overrideWithValue(historyStorage),
      ],
      child: const HistoryCalcApp(),
    ),
  );
}

class HistoryCalcApp extends ConsumerWidget {
  const HistoryCalcApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'HistoryCalc v2',
      theme: AppTheme.darkTheme,
      home: const CalculatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

