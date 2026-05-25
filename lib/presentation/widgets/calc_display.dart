import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// The top display area showing the expression and current input.
class CalcDisplay extends StatelessWidget {
  final String expression;
  final String currentInput;
  final bool hasResult;

  const CalcDisplay({
    super.key,
    required this.expression,
    required this.currentInput,
    required this.hasResult,
  });

  @override
  Widget build(BuildContext context) {
    final isError = currentInput == 'Error';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Expression (scrollable)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 56),
            child: SingleChildScrollView(
              reverse: true,
              child: Text(
                expression,
                style: TextStyle(
                  fontSize: 22,
                  color: isError
                      ? AppColors.redApproval.withValues(alpha: 0.7)
                      : hasResult
                          ? AppColors.accentGreen.withValues(alpha: 0.7)
                          : AppColors.textSecondary,
                  fontFamily: 'Inter',
                  height: 1.3,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Current input / result
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              currentInput,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w600,
                color: isError
                    ? AppColors.redApproval
                    : hasResult
                        ? AppColors.accentGreen
                        : AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
