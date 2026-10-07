import 'package:flutter_test/flutter_test.dart';
import 'package:tinh_diem_sam_loc/data/models/player.dart';
import 'package:tinh_diem_sam_loc/data/models/game_rules.dart';
import 'package:tinh_diem_sam_loc/data/models/round.dart';
import 'package:tinh_diem_sam_loc/data/models/game.dart';
import 'package:tinh_diem_sam_loc/services/scoring_engine.dart';

void main() {
  group('Sâm Lốc ScoringEngine Tests', () {
    final players = [
      const Player(id: 'p1', name: 'Bình'),
      const Player(id: 'p2', name: 'Cường'),
      const Player(id: 'p3', name: 'Dũng'),
      const Player(id: 'p4', name: 'Nam'),
    ];

    test('Normal Round: Losers lose remaining cards, Winner gets total sum', () {
      final scores = ScoringEngine.calculateScores(
        ScoreCalculationParams(
          winnerId: 'p1',
          resultType: RoundResultType.normal,
          players: players,
          rules: GameRules.defaultRules,
          loserRemainingCards: {'p2': 3, 'p3': 4, 'p4': 1},
        ),
      );

      expect(scores['p1'], equals(8));  // 3 + 4 + 1
      expect(scores['p2'], equals(-3));
      expect(scores['p3'], equals(-4));
      expect(scores['p4'], equals(-1));

      // Zero-sum check
      final sum = scores.values.fold(0, (a, b) => a + b);
      expect(sum, equals(0));
    });

    test('Cóng & Thối heo: adds 15 cards for Cóng + 10 for heo đen', () {
      final scores = ScoringEngine.calculateScores(
        ScoreCalculationParams(
          winnerId: 'p1',
          resultType: RoundResultType.normal,
          players: players,
          rules: GameRules.defaultRules,
          loserRemainingCards: {'p2': 2, 'p3': 10, 'p4': 5},
          congPlayers: {'p3': true}, // p3 bị cóng: 15 lá
          thoi2BlackCount: {'p2': 1}, // p2 thối 1 heo đen: +10 lá => 2 + 10 = 12
        ),
      );

      expect(scores['p2'], equals(-12)); // 2 + 10
      expect(scores['p3'], equals(-15)); // Cóng 15 lá
      expect(scores['p4'], equals(-5));
      expect(scores['p1'], equals(32));  // 12 + 15 + 5 = 32

      final sum = scores.values.fold(0, (a, b) => a + b);
      expect(sum, equals(0));
    });

    test('Báo Sâm thắng: Each loser pays 20, Winner gets 60', () {
      final scores = ScoringEngine.calculateScores(
        ScoreCalculationParams(
          winnerId: 'p1',
          resultType: RoundResultType.samWin,
          players: players,
          rules: GameRules.defaultRules,
        ),
      );

      expect(scores['p1'], equals(60));
      expect(scores['p2'], equals(-20));
      expect(scores['p3'], equals(-20));
      expect(scores['p4'], equals(-20));

      final sum = scores.values.fold(0, (a, b) => a + b);
      expect(sum, equals(0));
    });

    test('Đền Sâm: Caller pays all players when no specific blocker', () {
      final scores = ScoringEngine.calculateScores(
        ScoreCalculationParams(
          winnerId: 'p2',
          denSamPlayerId: 'p2',
          resultType: RoundResultType.denSam,
          players: players,
          rules: GameRules.defaultRules,
        ),
      );

      expect(scores['p2'], equals(-60));
      expect(scores['p1'], equals(20));
      expect(scores['p3'], equals(20));
      expect(scores['p4'], equals(20));
    });

    test('Game total scores calculation and rankings', () {
      final r1 = Round(
        id: 'r1',
        gameId: 'g1',
        roundNumber: 1,
        winnerId: 'p1',
        resultType: RoundResultType.normal,
        scores: {'p1': 8, 'p2': -3, 'p3': -4, 'p4': -1},
        createdAt: DateTime.now(),
      );

      final r2 = Round(
        id: 'r2',
        gameId: 'g1',
        roundNumber: 2,
        winnerId: 'p2',
        resultType: RoundResultType.normal,
        scores: {'p1': -5, 'p2': 10, 'p3': -3, 'p4': -2},
        createdAt: DateTime.now(),
      );

      final game = Game(
        id: 'g1',
        title: 'Bàn Test',
        createdAt: DateTime.now(),
        players: players,
        rounds: [r1, r2],
      );

      expect(game.totalScores['p1'], equals(3));  // 8 - 5 = 3
      expect(game.totalScores['p2'], equals(7));  // -3 + 10 = 7
      expect(game.totalScores['p3'], equals(-7)); // -4 - 3 = -7
      expect(game.totalScores['p4'], equals(-3)); // -1 - 2 = -3

      final rankings = game.rankedPlayers;
      expect(rankings[0].id, equals('p2')); // 7
      expect(rankings[1].id, equals('p1')); // 3
      expect(rankings[2].id, equals('p4')); // -3
      expect(rankings[3].id, equals('p3')); // -7
    });

    test('5 Players: Báo Sâm and Normal Round with 5 players', () {
      final fivePlayers = [
        const Player(id: 'p1', name: 'Bình'),
        const Player(id: 'p2', name: 'Cường'),
        const Player(id: 'p3', name: 'Dũng'),
        const Player(id: 'p4', name: 'Nam'),
        const Player(id: 'p5', name: 'Hải'),
      ];

      // Báo Sâm with 5 players: 4 losers pay 20 each => Winner gets 80
      final samScores = ScoringEngine.calculateScores(
        ScoreCalculationParams(
          winnerId: 'p1',
          resultType: RoundResultType.samWin,
          players: fivePlayers,
          rules: GameRules.defaultRules,
        ),
      );

      expect(samScores['p1'], equals(80));
      expect(samScores['p2'], equals(-20));
      expect(samScores['p3'], equals(-20));
      expect(samScores['p4'], equals(-20));
      expect(samScores['p5'], equals(-20));

      final samSum = samScores.values.fold(0, (a, b) => a + b);
      expect(samSum, equals(0));

      // Normal round with 5 players
      final normalScores = ScoringEngine.calculateScores(
        ScoreCalculationParams(
          winnerId: 'p5',
          resultType: RoundResultType.normal,
          players: fivePlayers,
          rules: GameRules.defaultRules,
          loserRemainingCards: {'p1': 3, 'p2': 4, 'p3': 2, 'p4': 1},
        ),
      );

      expect(normalScores['p5'], equals(10)); // 3 + 4 + 2 + 1
      expect(normalScores['p1'], equals(-3));
      expect(normalScores['p2'], equals(-4));
      expect(normalScores['p3'], equals(-2));
      expect(normalScores['p4'], equals(-1));

      final normalSum = normalScores.values.fold(0, (a, b) => a + b);
      expect(normalSum, equals(0));
    });
  });
}
