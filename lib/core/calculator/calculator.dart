/// A standard calculator engine that evaluates expressions
/// in input order (no operator precedence).
///
/// Supports: +, -, ×, ÷, √, x², %, ±, ., C, AC, ⌫, =
class Calculator {
  // --- Display state ---
  String _expression = '';
  String _currentInput = '0';
  double? _firstOperand;
  String? _operator;
  bool _waitingForSecondOperand = false;

  // --- Evaluation result tracking ---
  bool _justEvaluated = false;
  String _lastExpression = '';
  double? _lastResult;

  // --- Getters for UI ---
  String get expression => _expression.isEmpty ? _currentInput : _expression;
  String get currentInput => _currentInput;
  bool get hasResult => _lastResult != null && _justEvaluated;

  /// The last completed expression + result, for history storage.
  /// Returns null if no evaluation has happened yet.
  ({String expression, double result})? get lastEvaluation {
    if (_lastExpression.isNotEmpty && _lastResult != null) {
      return (expression: _lastExpression, result: _lastResult!);
    }
    return null;
  }

  // ============================================================
  // PUBLIC API
  // ============================================================

  /// Main entry point. [key] is one of:
  /// digits '0'-'9', operators '+','-','×','÷',
  /// '.', '=', '√', '²', '%', '±', 'C', '⌫'
  void input(String key) {
    switch (key) {
      case '0': case '1': case '2': case '3': case '4':
      case '5': case '6': case '7': case '8': case '9':
        _onDigit(key);
        break;
      case '+': case '-': case '×': case '÷':
        _onOperator(key);
        break;
      case '.':
        _onDecimal();
        break;
      case '=':
        _onEquals();
        break;
      case '√':
        _onSquareRoot();
        break;
      case '²':
        _onSquare();
        break;
      case '%':
        _onPercent();
        break;
      case '±':
        _onNegate();
        break;
      case 'C':
        _onClear();
        break;
      case '⌫':
        _onBackspace();
        break;
      default:
        break; // ignore unknown
    }
  }

  /// Insert a numeric result from history into the current expression.
  ///
  /// Behavior depends on context:
  /// - If an operator is pending (e.g. user typed "12 + "), the result
  ///   becomes the second operand → **participates in current calculation**.
  /// - If no operator is pending, the result replaces the current input
  ///   → **starts a fresh calculation**.
  void insertResult(double value) {
    final str = _formatNumber(value);

    if (_operator != null) {
      // Mid-calculation: insert as second operand
      _currentInput = str;
      _waitingForSecondOperand = false;
      _justEvaluated = false;
      _updateExpressionWithCurrent();
    } else {
      // No pending operator: start fresh
      _reset();
      _currentInput = str;
      _expression = str;
    }
  }

  /// Reset the calculator to initial state.
  void reset() {
    _reset();
  }

  // ============================================================
  // PRIVATE HANDLERS
  // ============================================================

  void _onDigit(String digit) {
    if (_justEvaluated) {
      _reset();
    }

    if (_waitingForSecondOperand) {
      _currentInput = digit;
      _waitingForSecondOperand = false;
    } else {
      if (_currentInput == '0') {
        _currentInput = digit;
      } else {
        _currentInput += digit;
      }
    }
    _updateExpressionWithCurrent();
  }

  void _onOperator(String op) {
    if (_justEvaluated) {
      // Continue from last result
      _firstOperand = _lastResult;
      _expression = '${_formatNumber(_lastResult!)} $op ';
      _currentInput = '0';
      _operator = op;
      _waitingForSecondOperand = true;
      _justEvaluated = false;
      _lastResult = null;
      _lastExpression = '';
      return;
    }

    if (_operator != null && !_waitingForSecondOperand) {
      // Chain: calculate intermediate result
      final second = double.tryParse(_currentInput) ?? 0;
      final result = _compute(_firstOperand ?? 0, second, _operator!);
      _firstOperand = result;
      _expression = '${_formatNumber(result)} $op ';
      _currentInput = _formatNumber(result);
    } else {
      _firstOperand = double.tryParse(_currentInput) ?? 0;
      _expression = '$_currentInput $op ';
    }

    _operator = op;
    _waitingForSecondOperand = true;
    _justEvaluated = false;
  }

  void _onDecimal() {
    if (_justEvaluated) {
      _reset();
    }
    if (_waitingForSecondOperand) {
      _currentInput = '0.';
      _waitingForSecondOperand = false;
    } else if (!_currentInput.contains('.')) {
      _currentInput += '.';
    }
    _updateExpressionWithCurrent();
  }

  void _onEquals() {
    if (_operator == null) {
      // Nothing to compute
      return;
    }

    double second;
    if (_waitingForSecondOperand) {
      // User pressed = without entering second operand, use first
      second = _firstOperand ?? 0;
    } else {
      second = double.tryParse(_currentInput) ?? 0;
    }

    final first = _firstOperand ?? 0;
    final result = _compute(first, second, _operator!);

    // Display: full equation (e.g. "12 + 5 = 17")
    _expression = '${_formatNumber(first)} ${_operator!} ${_formatNumber(second)} = ${_formatNumber(result)}';
    // History: formula only (e.g. "12 + 5") — not a "finished sentence"
    _lastExpression = '${_formatNumber(first)} ${_operator!} ${_formatNumber(second)}';
    _lastResult = result;
    _currentInput = _formatNumber(result);
    _firstOperand = null;
    _operator = null;
    _waitingForSecondOperand = false;
    _justEvaluated = true;
  }

  void _onSquareRoot() {
    final value = double.tryParse(_currentInput) ?? 0;
    if (value < 0) {
      _currentInput = 'Error';
      _expression = 'Error';
      _firstOperand = null;
      _operator = null;
      _waitingForSecondOperand = false;
      _justEvaluated = false;
      _lastExpression = '';
      _lastResult = null;
      return;
    }
    final result = _sqrt(value);
    // Display: full equation ("√(16) = 4")
    _expression = '√($value) = ${_formatNumber(result)}';
    // History: formula only ("√(16)")
    _lastExpression = '√($value)';
    _lastResult = result;
    _currentInput = _formatNumber(result);
    _justEvaluated = true;
    _firstOperand = null;
    _operator = null;
    _waitingForSecondOperand = false;
  }

  void _onSquare() {
    final value = double.tryParse(_currentInput) ?? 0;
    final result = value * value;
    // Display: full equation ("(4)² = 16")
    _expression = '($value)² = ${_formatNumber(result)}';
    // History: formula only ("(4)²")
    _lastExpression = '($value)²';
    _lastResult = result;
    _currentInput = _formatNumber(result);
    _justEvaluated = true;
    _firstOperand = null;
    _operator = null;
    _waitingForSecondOperand = false;
  }

  void _onPercent() {
    // Standard calculator %: express current input as percentage of first operand
    if (_operator != null && _firstOperand != null) {
      final current = double.tryParse(_currentInput) ?? 0;
      final percentValue = _firstOperand! * (current / 100);
      _currentInput = _formatNumber(percentValue);
      _waitingForSecondOperand = false;
      _updateExpressionWithCurrent();
    } else {
      // No pending operation: just convert to decimal
      final value = double.tryParse(_currentInput) ?? 0;
      _currentInput = _formatNumber(value / 100);
      _expression = _currentInput;
      _justEvaluated = false;
    }
  }

  void _onNegate() {
    if (_currentInput == '0' || _currentInput.isEmpty) return;
    if (_currentInput.startsWith('-')) {
      _currentInput = _currentInput.substring(1);
    } else {
      _currentInput = '-$_currentInput';
    }
    _updateExpressionWithCurrent();
  }

  void _onClear() {
    if (_justEvaluated || _currentInput == '0') {
      // AC: full reset when already at 0 or after evaluation
      _reset();
      return;
    }
    // C: clear current input only
    _currentInput = '0';
    _updateExpressionWithCurrent();
  }

  void _onBackspace() {
    if (_justEvaluated) {
      _reset();
      return;
    }
    if (_waitingForSecondOperand) return; // can't delete operator

    if (_currentInput.length == 1 || 
        (_currentInput.length == 2 && _currentInput.startsWith('-'))) {
      _currentInput = '0';
    } else {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
    }
    _updateExpressionWithCurrent();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  void _updateExpressionWithCurrent() {
    if (_operator != null && _firstOperand != null) {
      _expression = '${_formatNumber(_firstOperand!)} $_operator $_currentInput';
    } else {
      _expression = _currentInput;
    }
  }

  double _compute(double a, double b, String op) {
    switch (op) {
      case '+': return a + b;
      case '-': return a - b;
      case '×': return a * b;
      case '÷': return b == 0 ? double.nan : a / b;
      default: return b;
    }
  }

  double _sqrt(double value) {
    // Simple Newton's method for square root
    if (value == 0) return 0;
    double guess = value / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + value / guess) / 2;
    }
    return guess;
  }

  String _formatNumber(double value) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return 'Error';
    // Remove trailing .0 for whole numbers
    if (value == value.truncateToDouble() && value.isFinite) {
      return value.toInt().toString();
    }
    // Trim unnecessary trailing zeros
    String str = value.toStringAsFixed(10);
    str = str.replaceAll(RegExp(r'0+$'), '');
    if (str.endsWith('.')) str = str.substring(0, str.length - 1);
    return str;
  }

  void _reset() {
    _expression = '';
    _currentInput = '0';
    _firstOperand = null;
    _operator = null;
    _waitingForSecondOperand = false;
    _justEvaluated = false;
    _lastExpression = '';
    _lastResult = null;
  }
}
