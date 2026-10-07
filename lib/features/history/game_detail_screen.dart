import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/game.dart';
import '../../data/models/round.dart';
import '../../services/game_provider.dart';
import '../game/game_screen.dart';

class GameDetailScreen extends StatelessWidget {
  final Game game;

  const GameDetailScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final rankedPlayers = game.rankedPlayers;
    final totals = game.totalScores;
    final winCounts = game.winCounts;
    final samCounts = game.samCounts;

    return Scaffold(
      appBar: AppBar(
        title: Text(game.title),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Game Info Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoColumn('Số ván', '${game.roundCount} ván'),
                      _buildInfoColumn('Thời gian chơi', game.durationFormatted),
                      _buildInfoColumn('Số người', '${game.playerCount} người'),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        'Ngày tạo: ${game.createdAt.day}/${game.createdAt.month}/${game.createdAt.year} ${game.createdAt.hour.toString().padLeft(2, '0')}:${game.createdAt.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Leaderboard / Final Results
            const Text(
              '🏆 KẾT QUẢ CHUNG CUỘC',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: AppTheme.accentGold,
              ),
            ),
            const SizedBox(height: 10),

            ...rankedPlayers.asMap().entries.map((entry) {
              final index = entry.key;
              final player = entry.value;
              final score = totals[player.id] ?? 0;
              final wins = winCounts[player.id] ?? 0;
              final sams = samCounts[player.id] ?? 0;
              final color = AppConstants.playerColors[player.colorIndex % AppConstants.playerColors.length];

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: index == 0
                      ? AppTheme.accentGold.withOpacity(0.12)
                      : (isDark ? AppTheme.darkCard : AppTheme.lightCard),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: index == 0
                        ? AppTheme.accentGold.withOpacity(0.4)
                        : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                  ),
                ),
                child: Row(
                  children: [
                    Text(_getMedal(index + 1), style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: color,
                      child: Text(
                        player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(
                            'Thắng $wins ván ${sams > 0 ? "• Sâm $sams" : ""}',
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 20,
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
            }),

            const SizedBox(height: 20),

            // Rematch button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  final provider = context.read<GameProvider>();
                  await provider.rematchGame(game);
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    );
                  }
                },
                icon: const Icon(Icons.replay_rounded),
                label: const Text(
                  'TÁI ĐẤU (CHƠI LẠI VỚI BÀN NÀY)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Full Rounds List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CHI TIẾT TỪNG VÁN',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: AppTheme.accentGold,
                  ),
                ),
                Text(
                  '${game.roundCount} ván',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ...game.rounds.map((round) {
              final winner = game.getPlayerById(round.winnerId);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ván ${round.roundNumber} - ${RoundResultType.getLabel(round.resultType)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        if (winner != null)
                          Text(
                            '${winner.name} thắng',
                            style: const TextStyle(
                              color: AppTheme.accentGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: game.players.map((p) {
                        final s = round.scores[p.id] ?? 0;
                        return Text(
                          '${p.name}: ${s > 0 ? "+$s" : "$s"}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: s != 0 ? FontWeight.bold : FontWeight.normal,
                            color: s > 0
                                ? AppTheme.primaryGreen
                                : s < 0
                                    ? AppTheme.dangerRed
                                    : Colors.grey,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),
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

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
