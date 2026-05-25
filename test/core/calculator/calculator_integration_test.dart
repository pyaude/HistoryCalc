import 'package:flutter_test/flutter_test.dart';
import 'package:historycalc/core/calculator/calculator.dart';

/// Integration tests for the full calculator engine.
/// These test real-world usage scenarios.
void main() {
  late Calculator calc;

  setUp(() {
    calc = Calculator();
  });

  group('完整使用场景', () {
    test('场景: 购物累加 + 历史复用', () {
      // First: 19.9 + 30 = 49.9
      calc.input('1');
      calc.input('9');
      calc.input('.');
      calc.input('9');
      calc.input('+');
      calc.input('3');
      calc.input('0');
      calc.input('=');

      final first = calc.lastEvaluation;
      expect(first, isNotNull);
      expect(first!.result, 49.9);
      expect(first.expression, '19.9 + 30');

      // Second: continue from result
      calc.input('+');
      calc.input('1');
      calc.input('0');
      calc.input('0');
      calc.input('=');

      // 49.9 + 100 = 149.9
      expect(calc.currentInput, '149.9');
    });

    test('场景: 计算折扣价', () {
      // 200 - 15% = 170
      calc.input('2');
      calc.input('0');
      calc.input('0');
      calc.input('-');
      calc.input('1');
      calc.input('5');
      calc.input('%'); // 15% of 200 = 30
      expect(calc.currentInput, '30');
      calc.input('=');
      expect(calc.currentInput, '170');
    });

    test('场景: 连续运算 + 错误恢复', () {
      // 5 ÷ 0 = Error
      calc.input('5');
      calc.input('÷');
      calc.input('0');
      calc.input('=');
      expect(calc.currentInput, 'Error');

      // Press C to reset
      calc.input('C');
      expect(calc.currentInput, '0');
      expect(calc.expression, '0');

      // New calculation: 7 + 3 = 10
      calc.input('7');
      calc.input('+');
      calc.input('3');
      calc.input('=');
      expect(calc.currentInput, '10');
    });

    test('场景: 平方根 + 平方链', () {
      // √16 = 4, then ² = 16
      calc.input('1');
      calc.input('6');
      calc.input('√');
      expect(calc.currentInput, '4');

      // Continue from result
      calc.input('²');
      expect(calc.currentInput, '16');
    });

    test('场景: 退格修正输入', () {
      calc.input('1');
      calc.input('2');
      calc.input('3');
      calc.input('⌫');
      expect(calc.currentInput, '12');

      calc.input('⌫');
      expect(calc.currentInput, '1');

      calc.input('4');
      expect(calc.currentInput, '14');

      calc.input('+');
      calc.input('6');
      calc.input('=');
      expect(calc.currentInput, '20');
    });

    test('场景: insertResult 在表达式中间', () {
      calc.input('1');
      calc.input('0');
      calc.input('+');
      calc.insertResult(5);
      expect(calc.currentInput, '5');
      expect(calc.expression, '10 + 5');

      calc.input('=');
      expect(calc.currentInput, '15');
    });

    test('场景: = 后继续运算', () {
      calc.input('3');
      calc.input('+');
      calc.input('4');
      calc.input('=');
      expect(calc.currentInput, '7');

      // Continue: + 2 = 9
      calc.input('+');
      calc.input('2');
      calc.input('=');
      expect(calc.currentInput, '9');

      // Continue: × 3 = 27
      calc.input('×');
      calc.input('3');
      calc.input('=');
      expect(calc.currentInput, '27');
    });
  });

  group('边界情况', () {
    test('初始按 = 不发生崩溃', () {
      calc.input('=');
      expect(calc.currentInput, '0');
      expect(calc.lastEvaluation, isNull);
    });

    test('连续输入多个运算符取最后一个', () {
      calc.input('5');
      calc.input('+');
      calc.input('-');
      calc.input('3');
      calc.input('=');
      // 5 - 3 = 2
      expect(calc.currentInput, '2');
    });

    test('结果后按数字开始新计算', () {
      calc.input('1');
      calc.input('+');
      calc.input('1');
      calc.input('=');
      calc.input('9');
      expect(calc.expression, '9');
      expect(calc.currentInput, '9');
    });

    test('小数精度', () {
      calc.input('0');
      calc.input('.');
      calc.input('1');
      calc.input('+');
      calc.input('0');
      calc.input('.');
      calc.input('2');
      calc.input('=');
      expect(calc.currentInput, '0.3');
    });

    test('负数平方根', () {
      calc.input('4');
      calc.input('±');
      calc.input('√');
      expect(calc.currentInput, 'Error');
      // Should not have generated a history entry
    });

    test('insertResult 替换刚计算的结果', () {
      calc.input('1');
      calc.input('+');
      calc.input('1');
      calc.input('=');
      calc.insertResult(99);
      expect(calc.currentInput, '99');
      expect(calc.expression, '99');
    });

    test('= 后按运算符再插历史 → 参与计算', () {
      calc.input('2');
      calc.input('+');
      calc.input('3');
      calc.input('=');        // 5
      calc.input('×');        // 延续: 5 × ...
      calc.insertResult(4);
      expect(calc.expression, '5 × 4');
      calc.input('=');
      expect(calc.currentInput, '20');
    });
  });
}
