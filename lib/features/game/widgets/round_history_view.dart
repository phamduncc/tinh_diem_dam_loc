import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/game.dart';
import '../../../data/models/round.dart';
import 'quick_round_sheet.dart';

class RoundHistoryView extends StatelessWidget {
  final Game game;
  final Function(Round round) onUpdateRound;
  final Function(String roundId) onDeleteRound;

  const RoundHistoryView({
    super.key,
    required this.game,
    required this.onUpdateRound,
    required this.onDeleteRound,
  });

  void _showRoundActions(BuildContext context, Round round) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkBg : AppTheme.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'TÙY CHỌN VÁN ${round.roundNumber}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: AppTheme.infoBlue),
                title: const Text('Sửa ván này'),
                subtitle: const Text('Thay đổi người thắng hoặc số điểm, hệ thống tự tính lại điểm'),
                onTap: () {
                  Navigator.pop(ctx);
                  _editRound(context, round);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever_rounded, color: AppTheme.dangerRed),
                title: const Text('Xóa ván này'),
                subtitle: const Text('Xóa kết quả ván này khỏi bảng điểm'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (alertCtx) => AlertDialog(
                      title: Text('Xóa ván ${round.roundNumber}?'),
                      content: const Text('Điểm số của tất cả người chơi sẽ tự động tính lại sau khi xóa.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(alertCtx, false),
                          child: const Text('Hủy'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
                          onPressed: () => Navigator.pop(alertCtx, true),
                          child: const Text('Xóa ván'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    onDeleteRound(round.id);
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _editRound(BuildContext context, Round round) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuickRoundSheet(
        game: game,
        roundToEdit: round,
        onSave: onUpdateRound,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (game.rounds.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.style_outlined, size: 48, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 12),
            const Text(
              'Chưa có ván nào được ghi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Bấm "+ NHẬP KẾT QUẢ VÁN" để ghi ván đầu tiên!',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      );
    }

    // Newest round on top
    final reversedRounds = game.rounds.reversed.toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reversedRounds.length,
      itemBuilder: (context, index) {
        final round = reversedRounds[index];
        final winner = game.getPlayerById(round.winnerId);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showRoundActions(context, round),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Ván ${round.roundNumber}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppTheme.accentGold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _getTypeBadgeColor(round.resultType).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                RoundResultType.getLabel(round.resultType),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _getTypeBadgeColor(round.resultType),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (winner != null) ...[
                              const Icon(Icons.emoji_events_rounded, size: 14, color: AppTheme.accentGold),
                              const SizedBox(width: 4),
                              Text(
                                '${winner.name} thắng',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                            const SizedBox(width: 4),
                            const Icon(Icons.more_vert_rounded, size: 18, color: Colors.grey),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Scores per player row
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: game.players.map((p) {
                        final score = round.scores[p.id] ?? 0;
                        final isPos = score > 0;
                        final isWinner = p.id == round.winnerId;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isWinner ? AppTheme.accentGold.withOpacity(0.5) : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${p.name}: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                              Text(
                                isPos ? '+$score' : '$score',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
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
            ),
          ),
        );
      },
    );
  }

  Color _getTypeBadgeColor(String type) {
    switch (type) {
      case RoundResultType.samWin:
        return AppTheme.accentGold;
      case RoundResultType.denSam:
        return AppTheme.dangerRed;
      case RoundResultType.anTrang:
        return AppTheme.primaryGreen;
      case RoundResultType.manual:
        return AppTheme.purpleCard;
      default:
        return AppTheme.infoBlue;
    }
  }
}
