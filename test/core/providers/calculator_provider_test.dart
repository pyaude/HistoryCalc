import 'package:flutter_test/flutter_test.dart';
import 'package:historycalc/core/providers/calculator_provider.dart';
import 'package:historycalc/core/storage/history_entry.dart';

void main() {
  group('CalculatorState', () {
    test('初始状态', () {
      const state = CalculatorState();
      expect(state.expression, '0');
      expect(state.currentInput, '0');
      expect(state.hasResult, false);
      expect(state.history, isEmpty);
    });

    test('copyWith 部分更新', () {
      const state = CalculatorState();
      final updated = state.copyWith(expression: '12 + 5');
      expect(updated.expression, '12 + 5');
      expect(updated.currentInput, '0'); // unchanged
      expect(updated.hasResult, false);
    });

    test('copyWith 全部更新', () {
      const state = CalculatorState();
      final updated = state.copyWith(
        expression: '5 + 3 = 8',
        currentInput: '8',
        hasResult: true,
        history: [HistoryEntry(expression: '1 + 1 = 2', result: 2)],
      );
      expect(updated.expression, '5 + 3 = 8');
      expect(updated.currentInput, '8');
      expect(updated.hasResult, true);
      expect(updated.history.length, 1);
    });
  });

  group('HistoryEntry', () {
    test('JSON 序列化往返', () {
      final entry = HistoryEntry(expression: '99 + 1 = 100', result: 100);
      final encoded = entry.encode();
      final decoded = HistoryEntry.decode(encoded);
      expect(decoded.expression, '99 + 1 = 100');
      expect(decoded.result, 100);
    });

    test('fromJson / toJson', () {
      final entry = HistoryEntry(expression: '5 × 5 = 25', result: 25);
      final json = entry.toJson();
      expect(json['expression'], '5 × 5 = 25');
      expect(json['result'], 25);
      expect(json['timestamp'], isA<int>());

      final restored = HistoryEntry.fromJson(json);
      expect(restored.expression, entry.expression);
      expect(restored.result, entry.result);
    });

    test('timestamp 自动生成', () {
      final before = DateTime.now();
      final entry = HistoryEntry(expression: 'test', result: 0);
      final after = DateTime.now();
      expect(
        entry.timestamp.isAfter(before.subtract(const Duration(seconds: 1))),
        true,
      );
      expect(
        entry.timestamp.isBefore(after.add(const Duration(seconds: 1))),
        true,
      );
    });
  });
}
