import 'package:hive_flutter/hive_flutter.dart';
import 'history_entry.dart';

/// Manages persistent storage of calculation history using Hive.
/// Keeps at most [maxEntries] (default 10), FIFO eviction.
class HistoryStorage {
  static const String _boxName = 'history';
  static const int maxEntries = 10;

  late Box<String> _box;

  /// Initialize Hive and open the history box.
  /// Must be called once before any other method — typically in main().
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  /// Load all history entries (most recent first).
  List<HistoryEntry> load() {
    final entries = <HistoryEntry>[];
    // Stored in insertion order; reverse for most-recent-first
    for (int i = _box.length - 1; i >= 0; i--) {
      final raw = _box.getAt(i);
      if (raw != null) {
        entries.add(HistoryEntry.decode(raw));
      }
    }
    return entries;
  }

  /// Save a new history entry. Enforces the 10-entry FIFO limit.
  Future<void> save(HistoryEntry entry) async {
    // Evict oldest if at capacity
    while (_box.length >= maxEntries) {
      await _box.deleteAt(0);
    }
    await _box.add(entry.encode());
  }

  /// Clear all history.
  Future<void> clear() async {
    await _box.clear();
  }

  /// Number of stored entries.
  int get length => _box.length;
}
