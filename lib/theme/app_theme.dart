import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFFF3F5FC);
  static const headerBg = Color(0xFFEFF2FB);
  static const cardBg = Colors.white;

  static const mint = Color(0xFF6FE0B0);
  static const mintDark = Color(0xFF2FAE7F);
  static const mintSoft = Color(0xFFDFF7EC);

  static const blue = Color(0xFF7FB2F0);
  static const blueSoft = Color(0xFFDCE9FB);
  static const blueDeep = Color(0xFF4A79C9);

  static const tan = Color(0xFFE7DDB8);
  static const tanText = Color(0xFF8A7B3F);

  static const red = Color(0xFFF3B8B8);
  static const redText = Color(0xFFB5514F);

  static const textDark = Color(0xFF1E2433);
  static const textMuted = Color(0xFF6B7280);
  static const border = Color(0xFFE4E7F1);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.mintDark,
        primary: AppColors.mintDark,
        surface: AppColors.bg,
      ),
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.headerBg,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: AppColors.textDark,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardColor: AppColors.cardBg,
    );
  }
}

/// Reusable rounded card container used across screens.
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

/// Small rounded status pill, e.g. "Happy", "Tired", "Calm".
class MoodPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;

  const MoodPill({
    super.key,
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
  });

  /// Builds a pill from the backend's `current_state` string.
  factory MoodPill.fromState(String state) {
    switch (state) {
      case 'Happy':
        return MoodPill(
          label: 'Happy',
          icon: Icons.sentiment_satisfied_rounded,
          bg: AppColors.tan,
          fg: AppColors.tanText,
        );
      case 'Tired':
        return MoodPill(
          label: 'Tired',
          icon: Icons.sentiment_dissatisfied_rounded,
          bg: AppColors.red,
          fg: AppColors.redText,
        );
      case 'Sad':
        return MoodPill(
          label: 'Sad',
          icon: Icons.sentiment_very_dissatisfied_rounded,
          bg: AppColors.red,
          fg: AppColors.redText,
        );
      case 'Neutral':
      default:
        return MoodPill(
          label: 'Calm',
          icon: Icons.sentiment_neutral_rounded,
          bg: AppColors.blueSoft,
          fg: AppColors.blueDeep,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
