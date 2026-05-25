import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/storage/history_entry.dart';

/// Bottom sheet that displays calculation history.
/// Tapping an entry inserts its result into the current expression.
class HistoryDrawer extends StatelessWidget {
  final List<HistoryEntry> history;
  final void Function(int index) onEntryTap;
  final VoidCallback onClearAll;

  const HistoryDrawer({
    super.key,
    required this.history,
    required this.onEntryTap,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '历史记录',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (history.isNotEmpty)
                      TextButton(
                        onPressed: onClearAll,
                        child: Text(
                          '清空',
                          style: TextStyle(
                            color: AppColors.redApproval.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        size: 22,
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                      splashRadius: 20,
                      tooltip: '关闭',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // List
          history.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    '暂无历史记录',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Hint
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '点击结果将其插入当前计算',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: history.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
                      itemBuilder: (context, index) {
                        final entry = history[index];
                        return InkWell(
                          onTap: () => onEntryTap(index),
                          borderRadius: BorderRadius.circular(12),
                          splashColor: AppColors.accentGreen.withValues(alpha: 0.1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            child: Row(
                              children: [
                                // Result — prominent, actionable
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentGreen.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatResult(entry.result),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.accentGreen,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.add_circle_outline,
                                        size: 18,
                                        color: AppColors.accentGreen.withValues(alpha: 0.6),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Expression — secondary info
                                Expanded(
                                  child: Text(
                                    entry.expression,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                                      fontFamily: 'Inter',
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
          // Bottom safe padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  String _formatResult(double value) {
    if (value == value.truncateToDouble() && value.isFinite) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}

/// Shows the history drawer as a modal bottom sheet.
void showHistoryDrawer({
  required BuildContext context,
  required List<HistoryEntry> history,
  required void Function(int) onEntryTap,
  required VoidCallback onClearAll,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.2,
      maxChildSize: 0.75,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: HistoryDrawer(
          history: history,
          onEntryTap: (index) {
            onEntryTap(index);
            Navigator.pop(context); // auto-close after tap
          },
          onClearAll: onClearAll,
        ),
      ),
    ),
  );
}
