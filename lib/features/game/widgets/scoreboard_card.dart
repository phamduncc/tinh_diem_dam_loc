import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/player.dart';

class ScoreboardCard extends StatelessWidget {
  final Player player;
  final int totalScore;
  final int lastRoundScore;
  final int rank;
  final int winsCount;
  final int samCount;
  final bool isWinnerOfLastRound;

  const ScoreboardCard({
    super.key,
    required this.player,
    required this.totalScore,
    required this.lastRoundScore,
    required this.rank,
    this.winsCount = 0,
    this.samCount = 0,
    this.isWinnerOfLastRound = false,
  });

  String get _rankBadge {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = AppConstants.playerColors[player.colorIndex % AppConstants.playerColors.length];

    final isPositiveTotal = totalScore > 0;
    final isNegativeTotal = totalScore < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isWinnerOfLastRound
              ? AppTheme.accentGold
              : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
          width: isWinnerOfLastRound ? 2 : 1,
        ),
        boxShadow: isWinnerOfLastRound
            ? [
                BoxShadow(
                  color: AppTheme.accentGold.withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Avatar & Rank badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: color,
                  child: Text(
                    player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkBg : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      _rankBadge,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Player Name & Mini Stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          player.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isWinnerOfLastRound) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Thắng ván',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentGold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Thắng: $winsCount',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      if (samCount > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Sâm: $samCount',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentGold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Last Round Delta (+8, -5)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (lastRoundScore > 0
                        ? AppTheme.primaryGreen
                        : lastRoundScore < 0
                            ? AppTheme.dangerRed
                            : Colors.grey)
                    .withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                lastRoundScore > 0
                    ? '+$lastRoundScore'
                    : '$lastRoundScore',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: lastRoundScore > 0
                      ? AppTheme.primaryGreen
                      : lastRoundScore < 0
                          ? AppTheme.dangerRed
                          : Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // TOTAL SCORE (RẤT TO, THE CENTRAL FOCUS)
            SizedBox(
              width: 70,
              child: Text(
                '$totalScore',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isPositiveTotal
                      ? AppTheme.primaryGreen
                      : isNegativeTotal
                          ? AppTheme.dangerRed
                          : (isDark ? Colors.white70 : Colors.black87),
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
