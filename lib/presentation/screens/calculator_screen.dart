import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/calculator_provider.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/calc_display.dart';
import '../widgets/calc_button.dart';
import '../widgets/history_drawer.dart';

class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  // Button layout: each row is [label, type]
  static const _buttonRows = [
    [
      ['C', CalcButtonType.clear],
      ['⌫', CalcButtonType.function],
      ['%', CalcButtonType.function],
      ['÷', CalcButtonType.operator],
    ],
    [
      ['7', CalcButtonType.number],
      ['8', CalcButtonType.number],
      ['9', CalcButtonType.number],
      ['×', CalcButtonType.operator],
    ],
    [
      ['4', CalcButtonType.number],
      ['5', CalcButtonType.number],
      ['6', CalcButtonType.number],
      ['-', CalcButtonType.operator],
    ],
    [
      ['1', CalcButtonType.number],
      ['2', CalcButtonType.number],
      ['3', CalcButtonType.number],
      ['+', CalcButtonType.operator],
    ],
    [
      ['±', CalcButtonType.function],
      ['0', CalcButtonType.number],
      ['.', CalcButtonType.number],
      ['=', CalcButtonType.equals],
    ],
  ];

  static const _functionBar = ['√', '²'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // --- Display ---
            CalcDisplay(
              expression: state.expression,
              currentInput: state.currentInput,
              hasResult: state.hasResult,
            ),

            const SizedBox(height: 4),

            // --- Function bar (√, ²) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  for (final label in _functionBar)
                    CalcButton(
                      label: label,
                      type: CalcButtonType.function,
                      onTap: () => notifier.input(label),
                    ),
                  const Spacer(flex: 2),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // --- Main button grid ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: _buttonRows.map((row) {
                    return Expanded(
                      child: Row(
                        children: row.map((btn) {
                          return CalcButton(
                            label: btn[0] as String,
                            type: btn[1] as CalcButtonType,
                            onTap: () => notifier.input(btn[0] as String),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // --- Bottom bar: History trigger ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: Material(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: () => _openHistory(context, ref),
                    borderRadius: BorderRadius.circular(14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 20,
                          color: AppColors.accentGreen.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '历史记录',
                          style: TextStyle(
                            color: AppColors.accentGreen.withValues(alpha: 0.8),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                        Text(
                          ' · v2',
                          style: TextStyle(
                            color: AppColors.accentGreen.withValues(alpha: 0.4),
                            fontSize: 11,
                            fontFamily: 'Inter',
                          ),
                        ),
                        if (state.history.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${state.history.length}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentGreen,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openHistory(BuildContext context, WidgetRef ref) {
    final state = ref.read(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);

    showHistoryDrawer(
      context: context,
      history: state.history,
      onEntryTap: (index) => notifier.insertFromHistory(index),
      onClearAll: () => notifier.clearHistory(),
    );
  }
}
