import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/game.dart';
import '../data/models/player.dart';
import '../data/models/round.dart';
import '../data/models/game_rules.dart';
import '../data/database/local_storage.dart';

class GameProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  Game? _activeGame;
  List<Game> _gameHistory = [];
  GameRules _savedRules = GameRules.defaultRules;
  ThemeMode _themeMode = ThemeMode.dark;
  bool _isLoading = true;

  // Undo support
  Round? _lastAddedRound;
  DateTime? _lastActionTime;

  Game? get activeGame => _activeGame;
  List<Game> get gameHistory => _gameHistory;
  GameRules get savedRules => _savedRules;
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  bool get hasActiveGame => _activeGame != null && _activeGame!.isInProgress;
  Round? get lastAddedRound => _lastAddedRound;
  bool get canUndo =>
      _activeGame != null &&
      _activeGame!.rounds.isNotEmpty &&
      _lastAddedRound != null &&
      _lastActionTime != null &&
      DateTime.now().difference(_lastActionTime!).inMinutes < 5;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await LocalStorage.init();
    _activeGame = await LocalStorage.getActiveGame();
    _gameHistory = await LocalStorage.getGameHistory();
    _savedRules = await LocalStorage.getSavedRules();

    final themeStr = await LocalStorage.getThemeMode();
    _themeMode = themeStr == 'light' ? ThemeMode.light : ThemeMode.dark;

    _isLoading = false;
    notifyListeners();
  }

  void toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await LocalStorage.saveThemeMode(_themeMode == ThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }

  // Create & Start New Game
  Future<Game> createGame({
    required List<String> playerNames,
    GameRules? rules,
    String? title,
  }) async {
    final effectiveRules = rules ?? _savedRules;
    final players = <Player>[];

    for (int i = 0; i < playerNames.length; i++) {
      players.add(
        Player(
          id: 'player_${i + 1}',
          name: playerNames[i].trim().isEmpty ? 'Người chơi ${i + 1}' : playerNames[i].trim(),
          colorIndex: i % 6,
        ),
      );
    }

    final newGame = Game(
      id: _uuid.v4(),
      title: title ?? 'Bàn Sâm ${DateTime.now().day}/${DateTime.now().month} #${_gameHistory.length + 1}',
      createdAt: DateTime.now(),
      status: GameStatus.inProgress,
      players: players,
      rules: effectiveRules,
      rounds: [],
    );

    _activeGame = newGame;
    _lastAddedRound = null;
    await LocalStorage.saveActiveGame(newGame);
    notifyListeners();
    return newGame;
  }

  // Add Round
  Future<void> addRound(Round round) async {
    if (_activeGame == null) return;

    final updatedRounds = List<Round>.from(_activeGame!.rounds)..add(round);
    _activeGame = _activeGame!.copyWith(rounds: updatedRounds);
    _lastAddedRound = round;
    _lastActionTime = DateTime.now();

    await LocalStorage.saveActiveGame(_activeGame!);
    notifyListeners();
  }

  // Undo last added round
  Future<bool> undoLastRound() async {
    if (_activeGame == null || _activeGame!.rounds.isEmpty) return false;

    final updatedRounds = List<Round>.from(_activeGame!.rounds);
    updatedRounds.removeLast();

    _activeGame = _activeGame!.copyWith(rounds: updatedRounds);
    _lastAddedRound = null;
    _lastActionTime = null;

    await LocalStorage.saveActiveGame(_activeGame!);
    notifyListeners();
    return true;
  }

  // Update specific round (after edit)
  Future<void> updateRound(Round updatedRound) async {
    if (_activeGame == null) return;

    final updatedRounds = _activeGame!.rounds.map((r) {
      return r.id == updatedRound.id ? updatedRound : r;
    }).toList();

    _activeGame = _activeGame!.copyWith(rounds: updatedRounds);
    await LocalStorage.saveActiveGame(_activeGame!);
    notifyListeners();
  }

  // Delete round
  Future<void> deleteRound(String roundId) async {
    if (_activeGame == null) return;

    final updatedRounds = _activeGame!.rounds.where((r) => r.id != roundId).toList();
    // Re-index round numbers
    final reindexedRounds = <Round>[];
    for (int i = 0; i < updatedRounds.length; i++) {
      reindexedRounds.add(updatedRounds[i].copyWith(roundNumber: i + 1));
    }

    _activeGame = _activeGame!.copyWith(rounds: reindexedRounds);
    await LocalStorage.saveActiveGame(_activeGame!);
    notifyListeners();
  }

  // Complete and save game to history
  Future<void> finishGame() async {
    if (_activeGame == null) return;

    final finished = _activeGame!.copyWith(
      status: GameStatus.completed,
      finishedAt: DateTime.now(),
    );

    await LocalStorage.saveCompletedGame(finished);
    await LocalStorage.clearActiveGame();

    _gameHistory = await LocalStorage.getGameHistory();
    _activeGame = null;
    _lastAddedRound = null;
    notifyListeners();
  }

  // Rematch: Start fresh game with same players
  Future<Game?> rematchGame(Game sourceGame) async {
    final playerNames = sourceGame.players.map((p) => p.name).toList();
    return createGame(
      playerNames: playerNames,
      rules: sourceGame.rules,
      title: 'Tái đấu: ${sourceGame.title}',
    );
  }

  // History management
  Future<void> deleteHistoryGame(String gameId) async {
    await LocalStorage.deleteGameFromHistory(gameId);
    _gameHistory = await LocalStorage.getGameHistory();
    notifyListeners();
  }

  Future<void> clearAllHistory() async {
    await LocalStorage.clearAllHistory();
    _gameHistory = [];
    notifyListeners();
  }

  // Save rules
  Future<void> updateSavedRules(GameRules rules) async {
    _savedRules = rules;
    await LocalStorage.saveRules(rules);
    notifyListeners();
  }
}
