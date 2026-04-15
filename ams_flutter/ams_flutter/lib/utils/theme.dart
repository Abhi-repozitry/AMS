// lib/utils/theme.dart
import 'package:flutter/material.dart';
import '../models/attendance_record.dart';

const kIndigo = Color(0xFF4F46E5);
const kIndigoDark = Color(0xFF6366F1);

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: kIndigo,
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF9FAFB),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF111827),
    elevation: 0,
    scrolledUnderElevation: 1,
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: kIndigo.withOpacity(0.12),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: kIndigoDark,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF111827),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF111827),
    foregroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 1,
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: const Color(0xFF1F2937),
    indicatorColor: kIndigoDark.withOpacity(0.2),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF1F2937),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFF374151)),
    ),
  ),
);

// Status colors
Color statusColor(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return const Color(0xFF22C55E);
    case AttendanceStatus.absent:
      return const Color(0xFFF87171);
    case AttendanceStatus.late:
      return const Color(0xFFFB923C);
    case AttendanceStatus.leave:
      return const Color(0xFF60A5FA);
  }
}

Color statusBgColor(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return const Color(0xFFF0FDF4);
    case AttendanceStatus.absent:
      return const Color(0xFFFEF2F2);
    case AttendanceStatus.late:
      return const Color(0xFFFFF7ED);
    case AttendanceStatus.leave:
      return const Color(0xFFEFF6FF);
  }
}

Color statusTextColor(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return const Color(0xFF16A34A);
    case AttendanceStatus.absent:
      return const Color(0xFFDC2626);
    case AttendanceStatus.late:
      return const Color(0xFFEA580C);
    case AttendanceStatus.leave:
      return const Color(0xFF2563EB);
  }
}

IconData statusIcon(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return Icons.check_circle_rounded;
    case AttendanceStatus.absent:
      return Icons.cancel_rounded;
    case AttendanceStatus.late:
      return Icons.access_time_rounded;
    case AttendanceStatus.leave:
      return Icons.coffee_rounded;
  }
}

const List<Color> avatarColors = [
  Color(0xFF6366F1), // indigo
  Color(0xFFA855F7), // purple
  Color(0xFFEC4899), // pink
  Color(0xFF14B8A6), // teal
  Color(0xFFF59E0B), // amber
  Color(0xFF06B6D4), // cyan
  Color(0xFFF43F5E), // rose
  Color(0xFF65A30D), // lime
];

Color avatarColor(int index) => avatarColors[index % avatarColors.length];
