import 'dart:convert';

/// A single historical calculation entry.
class HistoryEntry {
  final String expression; // e.g. "12 + 5 = 17"
  final double result;
  final DateTime timestamp;

  HistoryEntry({
    required this.expression,
    required this.result,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // --- JSON serialization (for Hive storage) ---

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      expression: json['expression'] as String,
      result: (json['result'] as num).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expression': expression,
      'result': result,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  /// Encode to a JSON string for Hive list storage.
  String encode() => jsonEncode(toJson());

  /// Decode from a JSON string.
  factory HistoryEntry.decode(String raw) {
    return HistoryEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  String toString() => expression;
}
