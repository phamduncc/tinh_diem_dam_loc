class GameRules {
  final String id;
  final String name;
  final bool isCustom;
  
  // Point configurations
  final int basePointsPerCard; // Điểm cơ bản mỗi lá còn lại (default 1)
  final int congCards;         // Số lá phạt khi Cóng (default 15)
  final int samWinPerPlayer;   // Điểm mỗi người đền khi Báo Sâm thành công (default 20)
  final int denSamPenalty;     // Điểm người đền Sâm phải trả mỗi người chơi khác (default 20)
  final int thoi2BlackCards;   // Phạt thối heo đen (default 10)
  final int thoi2RedCards;     // Phạt thối heo đỏ (default 15)
  final int thoiTuQuyCards;    // Phạt thối tứ quý (default 15)
  final int anTrangPerPlayer;  // Ăn trắng (default 20)
  final bool autoZeroSum;      // Tự động cân bằng tổng điểm bàn = 0 (default true)

  const GameRules({
    this.id = 'default',
    this.name = 'Luật tiêu chuẩn Sâm Lốc',
    this.isCustom = false,
    this.basePointsPerCard = 1,
    this.congCards = 15,
    this.samWinPerPlayer = 20,
    this.denSamPenalty = 20,
    this.thoi2BlackCards = 10,
    this.thoi2RedCards = 15,
    this.thoiTuQuyCards = 15,
    this.anTrangPerPlayer = 20,
    this.autoZeroSum = true,
  });

  static const GameRules defaultRules = GameRules();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isCustom': isCustom,
        'basePointsPerCard': basePointsPerCard,
        'congCards': congCards,
        'samWinPerPlayer': samWinPerPlayer,
        'denSamPenalty': denSamPenalty,
        'thoi2BlackCards': thoi2BlackCards,
        'thoi2RedCards': thoi2RedCards,
        'thoiTuQuyCards': thoiTuQuyCards,
        'anTrangPerPlayer': anTrangPerPlayer,
        'autoZeroSum': autoZeroSum,
      };

  factory GameRules.fromJson(Map<String, dynamic> json) => GameRules(
        id: (json['id'] as String?) ?? 'default',
        name: (json['name'] as String?) ?? 'Luật tiêu chuẩn Sâm Lốc',
        isCustom: (json['isCustom'] as bool?) ?? false,
        basePointsPerCard: (json['basePointsPerCard'] as int?) ?? 1,
        congCards: (json['congCards'] as int?) ?? 15,
        samWinPerPlayer: (json['samWinPerPlayer'] as int?) ?? 20,
        denSamPenalty: (json['denSamPenalty'] as int?) ?? 20,
        thoi2BlackCards: (json['thoi2BlackCards'] as int?) ?? 10,
        thoi2RedCards: (json['thoi2RedCards'] as int?) ?? 15,
        thoiTuQuyCards: (json['thoiTuQuyCards'] as int?) ?? 15,
        anTrangPerPlayer: (json['anTrangPerPlayer'] as int?) ?? 20,
        autoZeroSum: (json['autoZeroSum'] as bool?) ?? true,
      );

  GameRules copyWith({
    String? id,
    String? name,
    bool? isCustom,
    int? basePointsPerCard,
    int? congCards,
    int? samWinPerPlayer,
    int? denSamPenalty,
    int? thoi2BlackCards,
    int? thoi2RedCards,
    int? thoiTuQuyCards,
    int? anTrangPerPlayer,
    bool? autoZeroSum,
  }) {
    return GameRules(
      id: id ?? this.id,
      name: name ?? this.name,
      isCustom: isCustom ?? this.isCustom,
      basePointsPerCard: basePointsPerCard ?? this.basePointsPerCard,
      congCards: congCards ?? this.congCards,
      samWinPerPlayer: samWinPerPlayer ?? this.samWinPerPlayer,
      denSamPenalty: denSamPenalty ?? this.denSamPenalty,
      thoi2BlackCards: thoi2BlackCards ?? this.thoi2BlackCards,
      thoi2RedCards: thoi2RedCards ?? this.thoi2RedCards,
      thoiTuQuyCards: thoiTuQuyCards ?? this.thoiTuQuyCards,
      anTrangPerPlayer: anTrangPerPlayer ?? this.anTrangPerPlayer,
      autoZeroSum: autoZeroSum ?? this.autoZeroSum,
    );
  }
}
