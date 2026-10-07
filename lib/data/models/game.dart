import 'player.dart';
import 'round.dart';
import 'game_rules.dart';

class GameStatus {
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
}

class Game {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime? finishedAt;
  final String status;
  final List<Player> players;
  final GameRules rules;
  final List<Round> rounds;

  const Game({
    required this.id,
    required this.title,
    required this.createdAt,
    this.finishedAt,
    this.status = GameStatus.inProgress,
    required this.players,
    this.rules = GameRules.defaultRules,
    this.rounds = const [],
  });

  bool get isInProgress => status == GameStatus.inProgress;
  bool get isCompleted => status == GameStatus.completed;

  // Compute total accumulated score for each player
  Map<String, int> get totalScores {
    final Map<String, int> totals = {
      for (final p in players) p.id: 0,
    };

    for (final round in rounds) {
      round.scores.forEach((playerId, score) {
        if (totals.containsKey(playerId)) {
          totals[playerId] = (totals[playerId] ?? 0) + score;
        }
      });
    }

    return totals;
  }

  // Get score delta of the most recent round
  Map<String, int> get lastRoundScores {
    if (rounds.isEmpty) {
      return {for (final p in players) p.id: 0};
    }
    return rounds.last.scores;
  }

  // Players sorted by total score descending (Rankings)
  List<Player> get rankedPlayers {
    final totals = totalScores;
    final list = List<Player>.from(players);
    list.sort((a, b) => (totals[b.id] ?? 0).compareTo(totals[a.id] ?? 0));
    return list;
  }

  // Player count
  int get playerCount => players.length;

  // Round count
  int get roundCount => rounds.length;

  // Stats
  Map<String, int> get winCounts {
    final Map<String, int> counts = {for (final p in players) p.id: 0};
    for (final r in rounds) {
      if (counts.containsKey(r.winnerId)) {
        counts[r.winnerId] = (counts[r.winnerId] ?? 0) + 1;
      }
    }
    return counts;
  }

  Map<String, int> get samCounts {
    final Map<String, int> counts = {for (final p in players) p.id: 0};
    for (final r in rounds) {
      if (r.resultType == RoundResultType.samWin && counts.containsKey(r.winnerId)) {
        counts[r.winnerId] = (counts[r.winnerId] ?? 0) + 1;
      }
    }
    return counts;
  }

  String get durationFormatted {
    final end = finishedAt ?? DateTime.now();
    final diff = end.difference(createdAt);
    if (diff.inHours > 0) {
      return '${diff.inHours} giờ ${diff.inMinutes % 60} phút';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} phút';
    } else {
      return '${diff.inSeconds} giây';
    }
  }

  Player? getPlayerById(String id) {
    try {
      return players.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'finishedAt': finishedAt?.toIso8601String(),
        'status': status,
        'players': players.map((p) => p.toJson()).toList(),
        'rules': rules.toJson(),
        'rounds': rounds.map((r) => r.toJson()).toList(),
      };

  factory Game.fromJson(Map<String, dynamic> json) => Game(
        id: json['id'] as String,
        title: json['title'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        finishedAt: json['finishedAt'] != null
            ? DateTime.parse(json['finishedAt'] as String)
            : null,
        status: (json['status'] as String?) ?? GameStatus.inProgress,
        players: (json['players'] as List)
            .map((p) => Player.fromJson(p as Map<String, dynamic>))
            .toList(),
        rules: json['rules'] != null
            ? GameRules.fromJson(json['rules'] as Map<String, dynamic>)
            : GameRules.defaultRules,
        rounds: json['rounds'] != null
            ? (json['rounds'] as List)
                .map((r) => Round.fromJson(r as Map<String, dynamic>))
                .toList()
            : [],
      );

  Game copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? finishedAt,
    String? status,
    List<Player>? players,
    GameRules? rules,
    List<Round>? rounds,
  }) {
    return Game(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      finishedAt: finishedAt ?? this.finishedAt,
      status: status ?? this.status,
      players: players ?? this.players,
      rules: rules ?? this.rules,
      rounds: rounds ?? this.rounds,
    );
  }
}
