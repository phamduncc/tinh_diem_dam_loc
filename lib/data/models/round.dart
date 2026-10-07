class RoundResultType {
  static const String normal = 'normal';
  static const String samWin = 'sam_win';
  static const String denSam = 'den_sam';
  static const String anTrang = 'an_trang';
  static const String manual = 'manual';

  static String getLabel(String type) {
    switch (type) {
      case samWin:
        return 'Báo Sâm thắng';
      case denSam:
        return 'Đền Sâm';
      case anTrang:
        return 'Ăn trắng';
      case manual:
        return 'Tùy chỉnh';
      case normal:
      default:
        return 'Bình thường';
    }
  }
}

class Round {
  final String id;
  final String gameId;
  final int roundNumber;
  final String winnerId;
  final String resultType;
  final Map<String, int> scores; // playerId -> score change in this round (+ or -)
  final Map<String, dynamic>? detailData; // Breakdown: card count, thối 2, cóng
  final DateTime createdAt;

  const Round({
    required this.id,
    required this.gameId,
    required this.roundNumber,
    required this.winnerId,
    required this.resultType,
    required this.scores,
    this.detailData,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'gameId': gameId,
        'roundNumber': roundNumber,
        'winnerId': winnerId,
        'resultType': resultType,
        'scores': scores,
        'detailData': detailData,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Round.fromJson(Map<String, dynamic> json) => Round(
        id: json['id'] as String,
        gameId: json['gameId'] as String,
        roundNumber: json['roundNumber'] as int,
        winnerId: json['winnerId'] as String,
        resultType: (json['resultType'] as String?) ?? RoundResultType.normal,
        scores: Map<String, int>.from(
          (json['scores'] as Map).map(
            (k, v) => MapEntry(k.toString(), (v as num).toInt()),
          ),
        ),
        detailData: json['detailData'] != null
            ? Map<String, dynamic>.from(json['detailData'] as Map)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Round copyWith({
    String? id,
    String? gameId,
    int? roundNumber,
    String? winnerId,
    String? resultType,
    Map<String, int>? scores,
    Map<String, dynamic>? detailData,
    DateTime? createdAt,
  }) {
    return Round(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      roundNumber: roundNumber ?? this.roundNumber,
      winnerId: winnerId ?? this.winnerId,
      resultType: resultType ?? this.resultType,
      scores: scores ?? this.scores,
      detailData: detailData ?? this.detailData,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
