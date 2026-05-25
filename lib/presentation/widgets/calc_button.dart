import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

/// Button types for styling.
enum CalcButtonType { number, operator, function, equals, clear }

/// A single calculator key with haptic feedback and press animation.
class CalcButton extends StatefulWidget {
  final String label;
  final CalcButtonType type;
  final VoidCallback onTap;
  final int flex;

  const CalcButton({
    super.key,
    required this.label,
    required this.onTap,
    this.type = CalcButtonType.number,
    this.flex = 1,
  });

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _bgColor {
    switch (widget.type) {
      case CalcButtonType.number:
        return AppColors.card;
      case CalcButtonType.operator:
        return AppColors.accentBlue.withValues(alpha: 0.25);
      case CalcButtonType.function:
        return AppColors.card.withValues(alpha: 0.7);
      case CalcButtonType.equals:
        return AppColors.accentGreen;
      case CalcButtonType.clear:
        return AppColors.redApproval.withValues(alpha: 0.3);
    }
  }

  Color get _fgColor {
    switch (widget.type) {
      case CalcButtonType.number:
        return AppColors.textPrimary;
      case CalcButtonType.operator:
        return AppColors.accentBlue;
      case CalcButtonType.function:
        return AppColors.accentGreen;
      case CalcButtonType.equals:
        return AppColors.background;
      case CalcButtonType.clear:
        return AppColors.redApproval;
    }
  }

  void _onTapDown(TapDownDetails _) {
    _isPressed = true;
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    _isPressed = false;
    _controller.reverse();
  }

  void _onTapCancel() {
    _isPressed = false;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: AnimatedBuilder(
          animation: _scale,
          builder: (context, child) => Transform.scale(
            scale: _scale.value,
            child: child,
          ),
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap,
            child: Material(
              color: _bgColor,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: null, // handled by GestureDetector
                borderRadius: BorderRadius.circular(16),
                splashColor: _fgColor.withValues(alpha: 0.12),
                highlightColor: _fgColor.withValues(alpha: 0.06),
                child: Center(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize:
                          widget.type == CalcButtonType.equals ? 28 : 22,
                      fontWeight: widget.type == CalcButtonType.equals
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: _fgColor,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
