import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../calculator/calculator.dart';
import '../storage/history_entry.dart';
import '../storage/history_storage.dart';

// --- State ---

class CalculatorState {
  final String expression;
  final String currentInput;
  final bool hasResult;
  final List<HistoryEntry> history;

  const CalculatorState({
    this.expression = '0',
    this.currentInput = '0',
    this.hasResult = false,
    this.history = const [],
  });

  CalculatorState copyWith({
    String? expression,
    String? currentInput,
    bool? hasResult,
    List<HistoryEntry>? history,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      currentInput: currentInput ?? this.currentInput,
      hasResult: hasResult ?? this.hasResult,
      history: history ?? this.history,
    );
  }
}

// --- Notifier ---

class CalculatorNotifier extends StateNotifier<CalculatorState> {
  final Calculator _calc = Calculator();
  final HistoryStorage _storage;

  CalculatorNotifier(this._storage) : super(const CalculatorState()) {
    _loadHistory();
  }

  // ---- Public actions ----

  void input(String key) {
    _calc.input(key);
    _syncFromEngine();

    // If an evaluation just completed, save to history
    if (key == '=' || key == '√' || key == '²') {
      _maybeSaveHistory();
    }
  }

  /// Insert the result of a history entry into the current expression.
  void insertFromHistory(int index) {
    if (index < 0 || index >= state.history.length) return;
    final entry = state.history[index];
    _calc.insertResult(entry.result);
    _syncFromEngine();
  }

  /// Clear all history from storage and state.
  Future<void> clearHistory() async {
    await _storage.clear();
    state = state.copyWith(history: []);
  }

  // ---- Internal ----

  void _syncFromEngine() {
    state = state.copyWith(
      expression: _calc.expression,
      currentInput: _calc.currentInput,
      hasResult: _calc.hasResult,
    );
  }

  void _loadHistory() {
    final entries = _storage.load();
    state = state.copyWith(history: entries);
  }

  void _maybeSaveHistory() {
    final eval = _calc.lastEvaluation;
    if (eval == null) return;

    // Avoid duplicate: skip if same as most recent entry
    if (state.history.isNotEmpty) {
      final last = state.history.first;
      if (last.expression == eval.expression && last.result == eval.result) {
        return;
      }
    }

    final entry = HistoryEntry(
      expression: eval.expression,
      result: eval.result,
    );

    _storage.save(entry).then((_) {
      _loadHistory(); // refresh list
    });
  }
}

// --- Providers ---

/// Singleton HistoryStorage — initialized once in main().
final historyStorageProvider = Provider<HistoryStorage>((ref) {
  // Will be overridden after init; this should not be called before init.
  throw UnimplementedError('HistoryStorage must be overridden after init');
});

/// The main calculator state notifier.
final calculatorProvider =
    StateNotifierProvider<CalculatorNotifier, CalculatorState>((ref) {
  final storage = ref.watch(historyStorageProvider);
  return CalculatorNotifier(storage);
});
