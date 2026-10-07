import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/game.dart';

class GameLeaderboardDialog extends StatelessWidget {
  final Game game;
  final bool isFinishMode; // If true, shows finish table actions [LƯU BÀN] [CHƠI BÀN MỚI]
  final VoidCallback? onFinishAndSave;
  final VoidCallback? onRematch;

  const GameLeaderboardDialog({
    super.key,
    required this.game,
    this.isFinishMode = false,
    this.onFinishAndSave,
    this.onRematch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final rankedPlayers = game.rankedPlayers;
    final totals = game.totalScores;
    final winCounts = game.winCounts;
    final samCounts = game.samCounts;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkBg : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentGold.withOpacity(0.2),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        '🏆 ',
                        style: TextStyle(fontSize: 24),
                      ),
                      Text(
                        isFinishMode ? 'KẾT THÚC BÀN CHƠI' : 'BẢNG XẾP HẠNG',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
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

            // Overview bar (Rounds, Time)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetaItem('Số ván', '${game.roundCount} ván'),
                  Container(height: 18, width: 1, color: Colors.white12),
                  _buildMetaItem('Thời gian', game.durationFormatted),
                  Container(height: 18, width: 1, color: Colors.white12),
                  _buildMetaItem('Số người', '${game.playerCount} người'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ranking List
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: rankedPlayers.length,
                itemBuilder: (context, index) {
                  final player = rankedPlayers[index];
                  final score = totals[player.id] ?? 0;
                  final wins = winCounts[player.id] ?? 0;
                  final sams = samCounts[player.id] ?? 0;
                  final color = AppConstants.playerColors[player.colorIndex % AppConstants.playerColors.length];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: index == 0
                          ? AppTheme.accentGold.withOpacity(0.12)
                          : (isDark ? AppTheme.darkCard : AppTheme.lightCard),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: index == 0
                            ? AppTheme.accentGold.withOpacity(0.5)
                            : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                        width: index == 0 ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Medal badge
                        Text(
                          _getMedal(index + 1),
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(width: 12),

                        // Avatar
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: color,
                          child: Text(
                            player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Player Name & stats
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                player.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Thắng $wins ván ${sams > 0 ? "• Sâm $sams lần" : ""}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Score
                        Text(
                          '$score',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: score > 0
                                ? AppTheme.primaryGreen
                                : score < 0
                                    ? AppTheme.dangerRed
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: isFinishMode
                  ? Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: onFinishAndSave,
                            icon: const Icon(Icons.archive_rounded),
                            label: const Text(
                              'LƯU BÀN VÀO LỊCH SỬ',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: onRematch,
                            icon: const Icon(Icons.replay_rounded),
                            label: const Text(
                              'CHƠI TIẾP VỚI CÙNG NGƯỜI CHƠI',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('ĐÓNG'),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static String _getMedal(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }

  Widget _buildMetaItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
      ],
    );
  }
}
