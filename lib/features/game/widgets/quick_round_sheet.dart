import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/game.dart';
import '../../../data/models/player.dart';
import '../../../data/models/round.dart';
import '../../../services/scoring_engine.dart';

class QuickRoundSheet extends StatefulWidget {
  final Game game;
  final Round? roundToEdit; // If editing existing round
  final Function(Round round) onSave;

  const QuickRoundSheet({
    super.key,
    required this.game,
    this.roundToEdit,
    required this.onSave,
  });

  @override
  State<QuickRoundSheet> createState() => _QuickRoundSheetState();
}

class _QuickRoundSheetState extends State<QuickRoundSheet> {
  final _uuid = const Uuid();

  late String _winnerId;
  String _resultType = RoundResultType.normal;

  // Loser state for Normal round
  final Map<String, int> _loserCards = {};
  final Map<String, bool> _loserCong = {};
  final Map<String, int> _thoi2Black = {};
  final Map<String, int> _thoi2Red = {};
  final Map<String, int> _thoiTuQuy = {};

  // For Đền Sâm
  late String _denSamCallerId;
  String? _blockerId;

  // Manual scores
  final Map<String, TextEditingController> _manualControllers = {};

  @override
  void initState() {
    super.initState();
    final players = widget.game.players;

    if (widget.roundToEdit != null) {
      final r = widget.roundToEdit!;
      _winnerId = r.winnerId;
      _resultType = r.resultType;
      _denSamCallerId = r.winnerId;

      for (final p in players) {
        _loserCards[p.id] = (r.detailData?['cards']?[p.id] as int?) ?? 1;
        _loserCong[p.id] = (r.detailData?['cong']?[p.id] as bool?) ?? false;
        _thoi2Black[p.id] = (r.detailData?['thoi2Black']?[p.id] as int?) ?? 0;
        _thoi2Red[p.id] = (r.detailData?['thoi2Red']?[p.id] as int?) ?? 0;
        _thoiTuQuy[p.id] = (r.detailData?['thoiTuQuy']?[p.id] as int?) ?? 0;
        _manualControllers[p.id] = TextEditingController(text: '${r.scores[p.id] ?? 0}');
      }
    } else {
      _winnerId = players.first.id;
      _denSamCallerId = players.first.id;
      for (final p in players) {
        _loserCards[p.id] = 1; // Default remaining cards
        _loserCong[p.id] = false;
        _thoi2Black[p.id] = 0;
        _thoi2Red[p.id] = 0;
        _thoiTuQuy[p.id] = 0;
        _manualControllers[p.id] = TextEditingController(text: '0');
      }
    }
  }

  @override
  void dispose() {
    for (final c in _manualControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, int> _computeCurrentScores() {
    final Map<String, int> manualMap = {};
    if (_resultType == RoundResultType.manual) {
      _manualControllers.forEach((k, v) {
        manualMap[k] = int.tryParse(v.text) ?? 0;
      });
    }

    return ScoringEngine.calculateScores(
      ScoreCalculationParams(
        winnerId: _winnerId,
        resultType: _resultType,
        players: widget.game.players,
        rules: widget.game.rules,
        loserRemainingCards: _loserCards,
        congPlayers: _loserCong,
        thoi2BlackCount: _thoi2Black,
        thoi2RedCount: _thoi2Red,
        thoiTuQuyCount: _thoiTuQuy,
        denSamPlayerId: _denSamCallerId,
        blockerPlayerId: _blockerId,
        manualScores: manualMap,
      ),
    );
  }

  void _saveRound() {
    final scores = _computeCurrentScores();
    final roundNumber = widget.roundToEdit?.roundNumber ?? (widget.game.rounds.length + 1);

    final round = Round(
      id: widget.roundToEdit?.id ?? _uuid.v4(),
      gameId: widget.game.id,
      roundNumber: roundNumber,
      winnerId: _resultType == RoundResultType.denSam ? (_blockerId ?? _winnerId) : _winnerId,
      resultType: _resultType,
      scores: scores,
      detailData: {
        'cards': _loserCards,
        'cong': _loserCong,
        'thoi2Black': _thoi2Black,
        'thoi2Red': _thoi2Red,
        'thoiTuQuy': _thoiTuQuy,
      },
      createdAt: widget.roundToEdit?.createdAt ?? DateTime.now(),
    );

    widget.onSave(round);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final players = widget.game.players;
    final roundNum = widget.roundToEdit?.roundNumber ?? (widget.game.rounds.length + 1);
    final previewScores = _computeCurrentScores();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkBg : AppTheme.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.roundToEdit != null ? 'SỬA VÁN $roundNum' : 'KẾT QUẢ VÁN $roundNum',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Chọn người thắng & nhập chi tiết nhanh',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Body
          Flexible(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              children: [
                // STEP 1: NGƯỜI THẮNG
                const Text(
                  'NGƯỜI THẮNG',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: AppTheme.accentGold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: players.map((p) {
                    final isSelected = _winnerId == p.id;
                    final color = AppConstants.playerColors[p.colorIndex % AppConstants.playerColors.length];
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              _winnerId = p.id;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryGreen
                                  : (isDark ? AppTheme.darkCard : AppTheme.lightCard),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryGreen
                                    : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 13,
                                  backgroundColor: isSelected ? Colors.white : color,
                                  child: Text(
                                    p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                                    style: TextStyle(
                                      color: isSelected ? AppTheme.primaryGreen : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  p.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? Colors.white : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // STEP 2: LOẠI KẾT QUẢ
                const Text(
                  'LOẠI KẾT QUẢ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: AppTheme.accentGold,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildResultTypeChip('Bình thường', RoundResultType.normal, Icons.check_circle_outline),
                    _buildResultTypeChip('Báo Sâm thắng', RoundResultType.samWin, Icons.campaign_rounded),
                    _buildResultTypeChip('Đền Sâm', RoundResultType.denSam, Icons.gavel_rounded),
                    _buildResultTypeChip('Ăn trắng', RoundResultType.anTrang, Icons.military_tech_rounded),
                    _buildResultTypeChip('Tùy chỉnh', RoundResultType.manual, Icons.edit_note_rounded),
                  ],
                ),

                const SizedBox(height: 20),

                // STEP 3: CHI TIẾT TÙY THEO LOẠI KẾT QUẢ
                if (_resultType == RoundResultType.normal) ...[
                  const Text(
                    'SỐ LÁ CÒN LẠI CỦA NGƯỜI THUA',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: AppTheme.accentGold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...players.where((p) => p.id != _winnerId).map((loser) {
                    return _buildLoserConfigRow(loser);
                  }),
                ] else if (_resultType == RoundResultType.samWin) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars_rounded, color: AppTheme.accentGold, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Báo Sâm thành công! Mỗi người thua đền ${widget.game.rules.samWinPerPlayer} điểm cho người thắng.',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_resultType == RoundResultType.denSam) ...[
                  _buildDenSamControls(players),
                ] else if (_resultType == RoundResultType.anTrang) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.military_tech_rounded, color: AppTheme.primaryGreen, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ăn trắng (Sảnh rồng, 5 đôi, tứ quý 2...)! Mỗi người thua mất ${widget.game.rules.anTrangPerPlayer} điểm.',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_resultType == RoundResultType.manual) ...[
                  ...players.map((p) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: _manualControllers[p.id],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Điểm'),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 20),

                // PREVIEW ĐIỂM VÁN NÀY
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.remove_red_eye_rounded, size: 16, color: AppTheme.accentGold),
                          SizedBox(width: 6),
                          Text(
                            'XEM TRƯỚC ĐIỂM VÁN NÀY',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: AppTheme.accentGold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: players.map((p) {
                          final score = previewScores[p.id] ?? 0;
                          final isPos = score > 0;
                          return Expanded(
                            child: Column(
                              children: [
                                Text(
                                  p.name,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isPos ? '+$score' : '$score',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: score == 0
                                        ? Colors.grey
                                        : isPos
                                            ? AppTheme.primaryGreen
                                            : AppTheme.dangerRed,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // Bottom Button Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _saveRound,
                icon: const Icon(Icons.check_circle_rounded),
                label: Text(
                  widget.roundToEdit != null ? 'CẬP NHẬT VÁN $roundNum' : 'TÍNH ĐIỂM & LƯU VÁN',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultTypeChip(String label, String type, IconData icon) {
    final isSelected = _resultType == type;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : AppTheme.accentGold,
      ),
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryGreen,
      backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
      labelStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: isSelected ? Colors.white : null,
      ),
      onSelected: (val) {
        if (val) {
          setState(() {
            _resultType = type;
          });
        }
      },
    );
  }

  Widget _buildLoserConfigRow(Player loser) {
    final isCong = _loserCong[loser.id] ?? false;
    final cards = _loserCards[loser.id] ?? 1;
    final thoi2Black = _thoi2Black[loser.id] ?? 0;
    final thoi2Red = _thoi2Red[loser.id] ?? 0;
    final thoiTuQuy = _thoiTuQuy[loser.id] ?? 0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCong
              ? AppTheme.dangerRed.withOpacity(0.5)
              : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loser.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  setState(() {
                    _loserCong[loser.id] = !isCong;
                    if (!isCong) {
                      _loserCards[loser.id] = 10;
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCong ? AppTheme.dangerRed : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 14,
                        color: isCong ? Colors.white : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'CÓNG',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isCong ? Colors.white : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Số lá còn lại
          Row(
            children: [
              const Text('Số lá: ', style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(10, (index) {
                      final cardNum = index + 1;
                      final isCardSelected = !isCong && cards == cardNum;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: isCong
                              ? null
                              : () {
                                  setState(() {
                                    _loserCards[loser.id] = cardNum;
                                  });
                                },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isCardSelected
                                  ? AppTheme.accentGold
                                  : (isCong ? Colors.transparent : Colors.black12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isCardSelected ? AppTheme.accentGold : Colors.white12,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$cardNum',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isCardSelected ? Colors.black : (isCong ? Colors.grey : null),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          // Thối 2 đen, 2 đỏ, tứ quý
          Row(
            children: [
              _buildPenaltyCounter(
                label: '2 đen',
                count: thoi2Black,
                onAdd: () => setState(() => _thoi2Black[loser.id] = thoi2Black + 1),
                onRemove: () => setState(() => _thoi2Black[loser.id] = (thoi2Black > 0 ? thoi2Black - 1 : 0)),
              ),
              const SizedBox(width: 8),
              _buildPenaltyCounter(
                label: '2 đỏ',
                count: thoi2Red,
                onAdd: () => setState(() => _thoi2Red[loser.id] = thoi2Red + 1),
                onRemove: () => setState(() => _thoi2Red[loser.id] = (thoi2Red > 0 ? thoi2Red - 1 : 0)),
              ),
              const SizedBox(width: 8),
              _buildPenaltyCounter(
                label: 'Tứ quý',
                count: thoiTuQuy,
                onAdd: () => setState(() => _thoiTuQuy[loser.id] = thoiTuQuy + 1),
                onRemove: () => setState(() => _thoiTuQuy[loser.id] = (thoiTuQuy > 0 ? thoiTuQuy - 1 : 0)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPenaltyCounter({
    required String label,
    required int count,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: count > 0 ? AppTheme.accentAmber.withOpacity(0.2) : Colors.black12,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: count > 0 ? AppTheme.accentAmber : Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: count > 0 ? AppTheme.accentAmber : Colors.grey,
            ),
          ),
          const SizedBox(width: 4),
          if (count > 0) ...[
            InkWell(
              onTap: onRemove,
              child: const Icon(Icons.remove, size: 14, color: AppTheme.accentAmber),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                '$count',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentAmber),
              ),
            ),
          ],
          InkWell(
            onTap: onAdd,
            child: Icon(
              Icons.add,
              size: 14,
              color: count > 0 ? AppTheme.accentAmber : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDenSamControls(List<Player> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ai báo Sâm thất bại (người đền)?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: players.map((p) {
            final isSelected = _denSamCallerId == p.id;
            return ChoiceChip(
              label: Text(p.name),
              selected: isSelected,
              selectedColor: AppTheme.dangerRed,
              onSelected: (val) {
                if (val) setState(() => _denSamCallerId = p.id);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        const Text(
          'Ai đã chặn Sâm? (Để trống nếu đền đều cả bàn)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Đền cả bàn'),
              selected: _blockerId == null,
              onSelected: (val) {
                if (val) setState(() => _blockerId = null);
              },
            ),
            ...players.where((p) => p.id != _denSamCallerId).map((p) {
              final isSelected = _blockerId == p.id;
              return ChoiceChip(
                label: Text(p.name),
                selected: isSelected,
                selectedColor: AppTheme.primaryGreen,
                onSelected: (val) {
                  if (val) setState(() => _blockerId = p.id);
                },
              );
            }),
          ],
        ),
      ],
    );
  }
}
