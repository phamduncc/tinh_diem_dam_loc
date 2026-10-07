import '../data/models/player.dart';
import '../data/models/game_rules.dart';
import '../data/models/round.dart';

class ScoreCalculationParams {
  final String winnerId;
  final String resultType;
  final List<Player> players;
  final GameRules rules;
  
  // Specific data for Normal round
  final Map<String, int> loserRemainingCards; // playerId -> cards left (1-10)
  final Map<String, bool> congPlayers;        // playerId -> is cong
  final Map<String, int> thoi2BlackCount;     // playerId -> count
  final Map<String, int> thoi2RedCount;       // playerId -> count
  final Map<String, int> thoiTuQuyCount;      // playerId -> count

  // Specific for Đền Sâm
  final String? denSamPlayerId;               // Who called Sâm and failed
  final String? blockerPlayerId;              // Who blocked them

  // For manual
  final Map<String, int>? manualScores;

  const ScoreCalculationParams({
    required this.winnerId,
    required this.resultType,
    required this.players,
    required this.rules,
    this.loserRemainingCards = const {},
    this.congPlayers = const {},
    this.thoi2BlackCount = const {},
    this.thoi2RedCount = const {},
    this.thoiTuQuyCount = const {},
    this.denSamPlayerId,
    this.blockerPlayerId,
    this.manualScores,
  });
}

class ScoringEngine {
  /// Calculate scores for a round given parameters and rules
  static Map<String, int> calculateScores(ScoreCalculationParams params) {
    final Map<String, int> scores = {
      for (final p in params.players) p.id: 0,
    };

    switch (params.resultType) {
      case RoundResultType.samWin:
        _calculateSamWin(params, scores);
        break;

      case RoundResultType.denSam:
        _calculateDenSam(params, scores);
        break;

      case RoundResultType.anTrang:
        _calculateAnTrang(params, scores);
        break;

      case RoundResultType.manual:
        _calculateManual(params, scores);
        break;

      case RoundResultType.normal:
      default:
        _calculateNormal(params, scores);
        break;
    }

    return scores;
  }

  static void _calculateNormal(
    ScoreCalculationParams params,
    Map<String, int> scores,
  ) {
    int totalWinnerPoints = 0;

    for (final player in params.players) {
      if (player.id == params.winnerId) continue;

      int penaltyCards = 0;
      final bool isCong = params.congPlayers[player.id] ?? false;

      if (isCong) {
        // Cóng: Phạt theo số lá cóng quy định (mặc định 15)
        penaltyCards += params.rules.congCards;
      } else {
        // Bình thường: Phạt theo số lá còn lại trên tay
        final cards = params.loserRemainingCards[player.id] ?? 1;
        penaltyCards += cards;
      }

      // Cộng điểm thối heo đen
      final thoi2Black = params.thoi2BlackCount[player.id] ?? 0;
      penaltyCards += thoi2Black * params.rules.thoi2BlackCards;

      // Cộng điểm thối heo đỏ
      final thoi2Red = params.thoi2RedCount[player.id] ?? 0;
      penaltyCards += thoi2Red * params.rules.thoi2RedCards;

      // Cộng điểm thối tứ quý
      final thoiTuQuy = params.thoiTuQuyCount[player.id] ?? 0;
      penaltyCards += thoiTuQuy * params.rules.thoiTuQuyCards;

      final int playerPoints = penaltyCards * params.rules.basePointsPerCard;
      scores[player.id] = -playerPoints;
      totalWinnerPoints += playerPoints;
    }

    // Người thắng ăn toàn bộ điểm bị phạt của các người thua
    scores[params.winnerId] = totalWinnerPoints;
  }

  static void _calculateSamWin(
    ScoreCalculationParams params,
    Map<String, int> scores,
  ) {
    int totalWin = 0;
    for (final player in params.players) {
      if (player.id == params.winnerId) continue;

      final penalty = params.rules.samWinPerPlayer;
      scores[player.id] = -penalty;
      totalWin += penalty;
    }
    scores[params.winnerId] = totalWin;
  }

  static void _calculateDenSam(
    ScoreCalculationParams params,
    Map<String, int> scores,
  ) {
    final callerId = params.denSamPlayerId ?? params.winnerId;
    final blockerId = params.blockerPlayerId;

    if (blockerId != null && blockerId.isNotEmpty && blockerId != callerId) {
      // Luật đền cho người chặn: Người chặn ăn toàn bộ
      final penalty = params.rules.denSamPenalty * (params.players.length - 1);
      scores[callerId] = -penalty;
      scores[blockerId] = penalty;
    } else {
      // Luật đền cho cả bàn: Mỗi người khác nhận denSamPenalty
      int totalPenalty = 0;
      for (final player in params.players) {
        if (player.id == callerId) continue;
        scores[player.id] = params.rules.denSamPenalty;
        totalPenalty += params.rules.denSamPenalty;
      }
      scores[callerId] = -totalPenalty;
    }
  }

  static void _calculateAnTrang(
    ScoreCalculationParams params,
    Map<String, int> scores,
  ) {
    int totalWin = 0;
    for (final player in params.players) {
      if (player.id == params.winnerId) continue;

      final penalty = params.rules.anTrangPerPlayer;
      scores[player.id] = -penalty;
      totalWin += penalty;
    }
    scores[params.winnerId] = totalWin;
  }

  static void _calculateManual(
    ScoreCalculationParams params,
    Map<String, int> scores,
  ) {
    if (params.manualScores != null) {
      params.manualScores!.forEach((k, v) {
        if (scores.containsKey(k)) {
          scores[k] = v;
        }
      });
    }
  }
}
