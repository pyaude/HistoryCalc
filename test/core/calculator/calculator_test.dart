import 'package:flutter_test/flutter_test.dart';
import 'package:historycalc/core/calculator/calculator.dart';

void main() {
  late Calculator calc;

  setUp(() {
    calc = Calculator();
  });

  group('基本数字输入', () {
    test('初始状态显示 0', () {
      expect(calc.currentInput, '0');
      expect(calc.expression, '0');
    });

    test('输入单个数字替换 0', () {
      calc.input('5');
      expect(calc.currentInput, '5');
      expect(calc.expression, '5');
    });

    test('连续输入多个数字', () {
      calc.input('1');
      calc.input('2');
      calc.input('3');
      expect(calc.currentInput, '123');
    });

    test('多位数输入', () {
      calc.input('9');
      calc.input('9');
      calc.input('9');
      expect(calc.currentInput, '999');
    });
  });

  group('小数点', () {
    test('输入小数点', () {
      calc.input('5');
      calc.input('.');
      calc.input('2');
      expect(calc.currentInput, '5.2');
    });

    test('以小数点开头', () {
      calc.input('.');
      expect(calc.currentInput, '0.');
    });

    test('不能输入两个小数点', () {
      calc.input('1');
      calc.input('.');
      calc.input('2');
      calc.input('.');
      expect(calc.currentInput, '1.2');
    });
  });

  group('基本四则运算', () {
    test('加法', () {
      calc.input('2');
      calc.input('+');
      calc.input('3');
      calc.input('=');
      expect(calc.currentInput, '5');
      expect(calc.expression.contains('2 + 3 = 5'), true);
    });

    test('减法', () {
      calc.input('1');
      calc.input('0');
      calc.input('-');
      calc.input('4');
      calc.input('=');
      expect(calc.currentInput, '6');
    });

    test('乘法', () {
      calc.input('6');
      calc.input('×');
      calc.input('7');
      calc.input('=');
      expect(calc.currentInput, '42');
    });

    test('除法', () {
      calc.input('1');
      calc.input('0');
      calc.input('÷');
      calc.input('2');
      calc.input('=');
      expect(calc.currentInput, '5');
    });

    test('除以零返回 Error', () {
      calc.input('5');
      calc.input('÷');
      calc.input('0');
      calc.input('=');
      expect(calc.currentInput, 'Error');
    });
  });

  group('连续运算（按输入顺序，无优先级）', () {
    test('2 + 3 × 4 = 20 (非 14)', () {
      calc.input('2');
      calc.input('+');
      calc.input('3');
      calc.input('×');
      calc.input('4');
      calc.input('=');
      // (2+3) × 4 = 20
      expect(calc.currentInput, '20');
    });

    test('10 - 2 ÷ 4 = 2', () {
      calc.input('1');
      calc.input('0');
      calc.input('-');
      calc.input('2');
      calc.input('÷');
      calc.input('4');
      calc.input('=');
      // (10-2) ÷ 4 = 2
      expect(calc.currentInput, '2');
    });

    test('多次链式运算', () {
      calc.input('1');
      calc.input('+');
      calc.input('2');
      calc.input('+');
      calc.input('3');
      calc.input('+');
      calc.input('4');
      calc.input('=');
      expect(calc.currentInput, '10');
    });
  });

  group('平方根 √', () {
    test('√9 = 3', () {
      calc.input('9');
      calc.input('√');
      expect(calc.currentInput, '3');
    });

    test('√0 = 0', () {
      calc.input('0');
      calc.input('√');
      expect(calc.currentInput, '0');
    });

    test('负数平方根报错', () {
      calc.input('9');
      calc.input('±');
      calc.input('√');
      expect(calc.currentInput, 'Error');
    });
  });

  group('平方 x²', () {
    test('5² = 25', () {
      calc.input('5');
      calc.input('²');
      expect(calc.currentInput, '25');
    });

    test('0² = 0', () {
      calc.input('0');
      calc.input('²');
      expect(calc.currentInput, '0');
    });

    test('负数平方', () {
      calc.input('3');
      calc.input('±');
      calc.input('²');
      expect(calc.currentInput, '9');
    });
  });

  group('百分比 %', () {
    test('200 + 10% = 220', () {
      calc.input('2');
      calc.input('0');
      calc.input('0');
      calc.input('+');
      calc.input('1');
      calc.input('0');
      calc.input('%');
      // 10% of 200 = 20, currentInput becomes 20
      calc.input('=');
      expect(calc.currentInput, '220');
    });

    test('无待定运算时 % 转为小数', () {
      calc.input('5');
      calc.input('0');
      calc.input('%');
      expect(calc.currentInput, '0.5');
    });
  });

  group('正负号切换 ±', () {
    test('正数变负数', () {
      calc.input('4');
      calc.input('2');
      calc.input('±');
      expect(calc.currentInput, '-42');
    });

    test('负数变正数', () {
      calc.input('7');
      calc.input('±');
      calc.input('±');
      expect(calc.currentInput, '7');
    });

    test('0 不切换', () {
      calc.input('±');
      expect(calc.currentInput, '0');
    });
  });

  group('清除 C / AC', () {
    test('C 清除当前输入', () {
      calc.input('5');
      calc.input('+');
      calc.input('3');
      calc.input('C');
      expect(calc.currentInput, '0');
    });

    test('再次按 C 触发 AC 全部重置', () {
      calc.input('5');
      calc.input('+');
      calc.input('3');
      calc.input('C'); // clear input → "5 + 0"
      calc.input('C'); // AC: full reset
      expect(calc.expression, '0');
      expect(calc.currentInput, '0');
    });

    test('= 后按 C 直接 AC', () {
      calc.input('5');
      calc.input('+');
      calc.input('3');
      calc.input('=');
      calc.input('C'); // AC: 全部重置
      expect(calc.expression, '0');
      expect(calc.currentInput, '0');
    });
  });

  group('退格 ⌫', () {
    test('删除最后一位', () {
      calc.input('1');
      calc.input('2');
      calc.input('3');
      calc.input('⌫');
      expect(calc.currentInput, '12');
    });

    test('删到只剩一位变 0', () {
      calc.input('5');
      calc.input('⌫');
      expect(calc.currentInput, '0');
    });

    test('等号后按退格重置', () {
      calc.input('1');
      calc.input('+');
      calc.input('1');
      calc.input('=');
      calc.input('⌫');
      expect(calc.currentInput, '0');
      expect(calc.expression, '0');
    });
  });

  group('等号后续行为', () {
    test('= 后输入数字重新开始', () {
      calc.input('2');
      calc.input('+');
      calc.input('3');
      calc.input('=');
      calc.input('7');
      expect(calc.expression, '7');
      expect(calc.currentInput, '7');
    });

    test('= 后输入运算符延续结果', () {
      calc.input('2');
      calc.input('+');
      calc.input('3');
      calc.input('=');
      calc.input('+');
      calc.input('4');
      calc.input('=');
      expect(calc.currentInput, '9');
    });
  });

  group('历史记录 - lastEvaluation', () {
    test('计算后返回正确的表达式和结果', () {
      calc.input('1');
      calc.input('2');
      calc.input('+');
      calc.input('5');
      calc.input('=');
      final eval = calc.lastEvaluation;
      expect(eval, isNotNull);
      expect(eval!.expression, '12 + 5');
      expect(eval.result, 17);
    });

    test('无计算时返回 null', () {
      expect(calc.lastEvaluation, isNull);
    });

    test('平方根产生记录', () {
      calc.input('1');
      calc.input('6');
      calc.input('√');
      final eval = calc.lastEvaluation;
      expect(eval, isNotNull);
      expect(eval!.result, 4);
    });
  });

  group('历史记录 - insertResult', () {
    test('无运算符时插入 → 开始新计算', () {
      calc.insertResult(42);
      expect(calc.currentInput, '42');
      expect(calc.expression, '42');
    });

    test('有运算符时插入 → 参与当前计算', () {
      calc.input('5');
      calc.input('+');
      calc.insertResult(10);
      expect(calc.currentInput, '10');
      expect(calc.expression, '5 + 10');
      calc.input('=');
      expect(calc.currentInput, '15');
    });

    test('刚计算完后插入 → 无运算符 → 开始新计算', () {
      calc.input('1');
      calc.input('+');
      calc.input('1');
      calc.input('=');       // _operator = null
      calc.insertResult(99);
      expect(calc.currentInput, '99');
      expect(calc.expression, '99');
    });

    test('= 后按运算符再插入 → 有运算符 → 参与计算', () {
      calc.input('2');
      calc.input('+');
      calc.input('3');
      calc.input('=');       // result = 5, _operator = null
      calc.input('+');       // _operator = '+', continues from 5
      calc.insertResult(7);
      expect(calc.expression, '5 + 7');
      calc.input('=');
      expect(calc.currentInput, '12');
    });

    test('输入数字后无运算符插入 → 替换当前输入', () {
      calc.input('9');
      calc.input('9');
      calc.insertResult(1);
      expect(calc.currentInput, '1');
      expect(calc.expression, '1');
    });
  });

  group('reset', () {
    test('reset 恢复初始状态', () {
      calc.input('9');
      calc.input('+');
      calc.input('1');
      calc.input('=');
      calc.reset();
      expect(calc.currentInput, '0');
      expect(calc.expression, '0');
      expect(calc.lastEvaluation, isNull);
    });
  });

  group('综合场景', () {
    test('真实场景: 购物累加', () {
      calc.input('1');
      calc.input('9');
      calc.input('.');
      calc.input('9');
      calc.input('+');
      calc.input('3');
      calc.input('0');
      calc.input('=');
      // 19.9 + 30 = 49.9
      expect(calc.currentInput, '49.9');
      calc.input('+');
      calc.input('1');
      calc.input('5');
      calc.input('=');
      // 49.9 + 15 = 64.9
      expect(calc.currentInput, '64.9');
    });

    test('真实场景: 使用历史复用', () {
      // First calculation
      calc.input('1');
      calc.input('0');
      calc.input('0');
      calc.input('×');
      calc.input('0');
      calc.input('.');
      calc.input('0');
      calc.input('8');
      calc.input('=');
      expect(calc.currentInput, '8'); // 100 × 0.08 = 8

      // Start new calculation and insert previous result
      calc.input('5');
      calc.input('0');
      calc.input('0');
      calc.input('+');
      calc.insertResult(8);
      calc.input('=');
      expect(calc.currentInput, '508');
    });
  });
}
