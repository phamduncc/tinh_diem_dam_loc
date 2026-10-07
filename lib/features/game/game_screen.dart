import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/game.dart';
import '../../data/models/round.dart';
import '../../services/game_provider.dart';
import 'widgets/scoreboard_card.dart';
import 'widgets/quick_round_sheet.dart';
import 'widgets/round_history_view.dart';
import 'widgets/game_leaderboard_dialog.dart';
import '../settings/rules_config_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  void _openQuickRoundSheet(BuildContext context, Game game) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuickRoundSheet(
        game: game,
        onSave: (round) async {
          final provider = context.read<GameProvider>();
          await provider.addRound(round);
          if (mounted) {
            _showUndoSnackBar(round.roundNumber);
          }
        },
      ),
    );
  }

  void _showUndoSnackBar(int roundNumber) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ Đã lưu ván $roundNumber'),
        backgroundColor: AppTheme.darkCard,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'HOÀN TÁC',
          textColor: AppTheme.accentGold,
          onPressed: () async {
            final undone = await context.read<GameProvider>().undoLastRound();
            if (undone && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('↩ Đã hoàn tác ván vừa rồi!'),
                  backgroundColor: AppTheme.infoBlue,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _showLeaderboard(BuildContext context, Game game, {bool isFinish = false}) {
    showDialog(
      context: context,
      builder: (ctx) => GameLeaderboardDialog(
        game: game,
        isFinishMode: isFinish,
        onFinishAndSave: () async {
          Navigator.pop(ctx);
          final nav = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);
          await context.read<GameProvider>().finishGame();
          nav.pop(); // Go back home
          messenger.showSnackBar(
            const SnackBar(
              content: Text('✓ Đã kết thúc và lưu bàn vào lịch sử!'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        },
        onRematch: () async {
          Navigator.pop(ctx);
          final messenger = ScaffoldMessenger.of(context);
          final provider = context.read<GameProvider>();
          await provider.finishGame();
          await provider.rematchGame(game);
          messenger.showSnackBar(
            const SnackBar(
              content: Text('✓ Đã tạo bàn tái đấu mới cùng người chơi!'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gameProvider = context.watch<GameProvider>();
    final game = gameProvider.activeGame;

    if (game == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('BÀN SÂM')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.table_restaurant_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Không có bàn chơi nào đang mở'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('QUAY VỀ TRANG CHỦ'),
              ),
            ],
          ),
        ),
      );
    }

    final totalScores = game.totalScores;
    final lastScores = game.lastRoundScores;
    final rankedPlayers = game.rankedPlayers;
    final winCounts = game.winCounts;
    final samCounts = game.samCounts;
    final lastRound = game.rounds.isNotEmpty ? game.rounds.last : null;

    // Check sum of scores
    int tableTotal = 0;
    totalScores.forEach((_, s) => tableTotal += s);

    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 800;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              game.title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              'Ván ${game.roundCount} • ${game.playerCount} người',
              style: const TextStyle(fontSize: 12, color: AppTheme.accentGold),
            ),
          ],
        ),
        actions: [
          // Quick Undo Button if available
          if (game.rounds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.undo_rounded),
              tooltip: 'Hoàn tác ván trước',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hoàn tác ván vừa rồi?'),
                    content: Text(
                      'Bạn có chắc muốn xóa kết quả ván ${game.roundCount} và tính lại điểm không?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Không'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.infoBlue),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Hoàn tác'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await gameProvider.undoLastRound();
                }
              },
            ),

          IconButton(
            icon: const Icon(Icons.emoji_events_rounded, color: AppTheme.accentGold),
            tooltip: 'Xếp hạng',
            onPressed: () => _showLeaderboard(context, game),
          ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (val) {
              switch (val) {
                case 'rank':
                  _showLeaderboard(context, game);
                  break;
                case 'undo':
                  gameProvider.undoLastRound();
                  break;
                case 'finish':
                  _showLeaderboard(context, game, isFinish: true);
                  break;
                case 'rules':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RulesConfigScreen()),
                  );
                  break;
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'rank',
                child: Row(
                  children: [
                    Icon(Icons.emoji_events_rounded, color: AppTheme.accentGold),
                    SizedBox(width: 10),
                    Text('Bảng xếp hạng'),
                  ],
                ),
              ),
              if (game.rounds.isNotEmpty)
                const PopupMenuItem(
                  value: 'undo',
                  child: Row(
                    children: [
                      Icon(Icons.undo_rounded, color: AppTheme.infoBlue),
                      SizedBox(width: 10),
                      Text('Hoàn tác ván vừa rồi'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'rules',
                child: Row(
                  children: [
                    Icon(Icons.gavel_rounded),
                    SizedBox(width: 10),
                    Text('Xem & Đổi luật bàn'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'finish',
                child: Row(
                  children: [
                    Icon(Icons.flag_rounded, color: AppTheme.dangerRed),
                    SizedBox(width: 10),
                    Text('Kết thúc bàn chơi', style: TextStyle(color: AppTheme.dangerRed)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: isWideScreen
            ? _buildWideTwoPaneLayout(context, game, totalScores, lastScores, rankedPlayers, winCounts, samCounts, lastRound, tableTotal)
            : _buildMobileLayout(context, game, totalScores, lastScores, rankedPlayers, winCounts, samCounts, lastRound, tableTotal),
      ),
      bottomNavigationBar: isWideScreen
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                ),
              ),
              child: SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () => _openQuickRoundSheet(context, game),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 24),
                  label: const Text(
                    '+ NHẬP KẾT QUẢ VÁN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // Mobile Single-column layout
  Widget _buildMobileLayout(
    BuildContext context,
    Game game,
    Map<String, int> totalScores,
    Map<String, int> lastScores,
    List<dynamic> rankedPlayers,
    Map<String, int> winCounts,
    Map<String, int> samCounts,
    Round? lastRound,
    int tableTotal,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      children: [
        // Column Headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Text(
                'NGƯỜI CHƠI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                'VÁN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(width: 24),
              Text(
                'TỔNG ĐIỂM',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Scoreboard cards for each player
        ...game.players.map((player) {
          final total = totalScores[player.id] ?? 0;
          final last = lastScores[player.id] ?? 0;
          final rank = rankedPlayers.indexOf(player) + 1;
          final wins = winCounts[player.id] ?? 0;
          final sams = samCounts[player.id] ?? 0;
          final isWinner = lastRound?.winnerId == player.id;

          return ScoreboardCard(
            player: player,
            totalScore: total,
            lastRoundScore: last,
            rank: rank,
            winsCount: wins,
            samCount: sams,
            isWinnerOfLastRound: isWinner,
          );
        }),

        const SizedBox(height: 6),

        // Balance Check Indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    tableTotal == 0 ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                    size: 16,
                    color: tableTotal == 0 ? AppTheme.primaryGreen : AppTheme.accentGold,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tableTotal == 0 ? 'Bàn cân bằng (Zero-sum)' : 'Tổng điểm lệch',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
              Text(
                'Tổng: $tableTotal',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: tableTotal == 0 ? AppTheme.primaryGreen : AppTheme.accentGold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // LỊCH SỬ CÁC VÁN TRONG BÀN
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'LỊCH SỬ CÁC VÁN',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: AppTheme.accentGold,
              ),
            ),
            Text(
              'Chạm vào ván để sửa/xóa',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        RoundHistoryView(
          game: game,
          onUpdateRound: (round) => context.read<GameProvider>().updateRound(round),
          onDeleteRound: (roundId) => context.read<GameProvider>().deleteRound(roundId),
        ),
      ],
    );
  }

  // Wide Two-pane layout for Desktop / Tablet (Section 13 requirement)
  Widget _buildWideTwoPaneLayout(
    BuildContext context,
    Game game,
    Map<String, int> totalScores,
    Map<String, int> lastScores,
    List<dynamic> rankedPlayers,
    Map<String, int> winCounts,
    Map<String, int> samCounts,
    Round? lastRound,
    int tableTotal,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Bảng Điểm & Bảng xếp hạng
        Expanded(
          flex: 5,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'BẢNG ĐIỂM HIỆN TẠI',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: AppTheme.accentGold,
                ),
              ),
              const SizedBox(height: 12),
              ...game.players.map((player) {
                final total = totalScores[player.id] ?? 0;
                final last = lastScores[player.id] ?? 0;
                final rank = rankedPlayers.indexOf(player) + 1;
                final wins = winCounts[player.id] ?? 0;
                final sams = samCounts[player.id] ?? 0;
                final isWinner = lastRound?.winnerId == player.id;

                return ScoreboardCard(
                  player: player,
                  totalScore: total,
                  lastRoundScore: last,
                  rank: rank,
                  winsCount: wins,
                  samCount: sams,
                  isWinnerOfLastRound: isWinner,
                );
              }),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _openQuickRoundSheet(context, game),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text(
                    '+ NHẬP KẾT QUẢ VÁN TIẾP THEO',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Vertical divider
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),

        // Right Column: Lịch sử ván chi tiết
        Expanded(
          flex: 5,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'LỊCH SỬ CÁC VÁN (Chạm để sửa)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: AppTheme.accentGold,
                    ),
                  ),
                  Text(
                    'Tổng: ${game.roundCount} ván',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RoundHistoryView(
                game: game,
                onUpdateRound: (round) => context.read<GameProvider>().updateRound(round),
                onDeleteRound: (roundId) => context.read<GameProvider>().deleteRound(roundId),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
