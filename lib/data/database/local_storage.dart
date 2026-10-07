import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game.dart';
import '../models/game_rules.dart';
import '../../core/constants/app_constants.dart';

class LocalStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Active Game
  static Future<void> saveActiveGame(Game game) async {
    await init();
    final jsonStr = jsonEncode(game.toJson());
    await _prefs!.setString(AppConstants.keyActiveGame, jsonStr);
  }

  static Future<Game?> getActiveGame() async {
    await init();
    final jsonStr = _prefs!.getString(AppConstants.keyActiveGame);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Game.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearActiveGame() async {
    await init();
    await _prefs!.remove(AppConstants.keyActiveGame);
  }

  // Game History
  static Future<List<Game>> getGameHistory() async {
    await init();
    final jsonListStr = _prefs!.getStringList(AppConstants.keyGameHistory) ?? [];
    final List<Game> history = [];
    for (final item in jsonListStr) {
      try {
        final jsonMap = jsonDecode(item) as Map<String, dynamic>;
        history.add(Game.fromJson(jsonMap));
      } catch (_) {}
    }
    // Sort newest first
    history.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return history;
  }

  static Future<void> saveCompletedGame(Game game) async {
    await init();
    final currentHistory = await getGameHistory();
    // Remove if already exists (update)
    currentHistory.removeWhere((g) => g.id == game.id);
    currentHistory.insert(0, game);

    final encodedList = currentHistory.map((g) => jsonEncode(g.toJson())).toList();
    await _prefs!.setStringList(AppConstants.keyGameHistory, encodedList);

    // Save recent player names
    await saveRecentPlayerNames(game.players.map((p) => p.name).toList());
  }

  static Future<void> deleteGameFromHistory(String gameId) async {
    await init();
    final currentHistory = await getGameHistory();
    currentHistory.removeWhere((g) => g.id == gameId);
    final encodedList = currentHistory.map((g) => jsonEncode(g.toJson())).toList();
    await _prefs!.setStringList(AppConstants.keyGameHistory, encodedList);
  }

  static Future<void> clearAllHistory() async {
    await init();
    await _prefs!.remove(AppConstants.keyGameHistory);
  }

  // Custom Rules
  static Future<void> saveRules(GameRules rules) async {
    await init();
    final jsonStr = jsonEncode(rules.toJson());
    await _prefs!.setString(AppConstants.keySavedRules, jsonStr);
  }

  static Future<GameRules> getSavedRules() async {
    await init();
    final jsonStr = _prefs!.getString(AppConstants.keySavedRules);
    if (jsonStr == null || jsonStr.isEmpty) {
      return GameRules.defaultRules;
    }
    try {
      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      return GameRules.fromJson(jsonMap);
    } catch (_) {
      return GameRules.defaultRules;
    }
  }

  // Recent Player Names
  static Future<List<String>> getRecentPlayerNames() async {
    await init();
    final names = _prefs!.getStringList(AppConstants.keyRecentPlayerNames);
    if (names == null || names.isEmpty) {
      return AppConstants.defaultPlayerNames;
    }
    return names;
  }

  static Future<void> saveRecentPlayerNames(List<String> newNames) async {
    await init();
    final existing = await getRecentPlayerNames();
    final set = <String>{...newNames, ...existing};
    await _prefs!.setStringList(AppConstants.keyRecentPlayerNames, set.take(12).toList());
  }

  // Theme mode
  static Future<String> getThemeMode() async {
    await init();
    return _prefs!.getString(AppConstants.keyThemeMode) ?? 'dark';
  }

  static Future<void> saveThemeMode(String mode) async {
    await init();
    await _prefs!.setString(AppConstants.keyThemeMode, mode);
  }
}
