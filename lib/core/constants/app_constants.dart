import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Điểm Sâm';
  static const String appSubtitle = 'Sổ điểm Sâm lốc Offline';
  static const String appVersion = 'v1.0.0';

  // Default player colors for avatars
  static const List<Color> playerColors = [
    Color(0xFF10B981), // Green (Bình)
    Color(0xFFEF4444), // Red (Cường)
    Color(0xFF3B82F6), // Blue (Dũng)
    Color(0xFFF59E0B), // Gold / Yellow (Nam)
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
  ];

  static const List<String> defaultPlayerNames = [
    'Bình',
    'Cường',
    'Dũng',
    'Nam',
    'Hải',
  ];

  // Storage keys
  static const String keyActiveGame = 'sam_loc_active_game';
  static const String keyGameHistory = 'sam_loc_game_history';
  static const String keySavedRules = 'sam_loc_saved_rules';
  static const String keyRecentPlayerNames = 'sam_loc_recent_players';
  static const String keyThemeMode = 'sam_loc_theme_mode';
}
