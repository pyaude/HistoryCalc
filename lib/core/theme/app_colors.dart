import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0D0D12); // Deep dark background
  static const Color card = Color(0xFF1C1C24); // Card background
  static const Color accentGreen = Color(0xFF00E676); // Cyberpunk green
  static const Color accentBlue = Color(0xFF2979FF); // Electric blue
  static const Color redApproval = Color(0xFFFF3D00); // For ForgeView
  static const Color greenApproval = Color(0xFF00E676);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);
  
  static BoxShadow get softDarkShadow => BoxShadow(
    color: Colors.black.withValues(alpha: 0.6),
    blurRadius: 16,
    offset: const Offset(0, 8),
  );
}
