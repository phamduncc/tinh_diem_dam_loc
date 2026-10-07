import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../services/game_provider.dart';
import '../game/game_screen.dart';
import '../settings/rules_config_screen.dart';

class NewGameScreen extends StatefulWidget {
  const NewGameScreen({super.key});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  int _playerCount = 4;
  late List<TextEditingController> _nameControllers;
  final TextEditingController _tableTitleController = TextEditingController();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _tableTitleController.text = 'Bàn Sâm #${DateTime.now().hour}h${DateTime.now().minute}';
    _initControllers();
  }

  void _initControllers() {
    _nameControllers = List.generate(5, (_) => TextEditingController());
  }

  @override
  void dispose() {
    _tableTitleController.dispose();
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _setPlayerCount(int count) {
    setState(() {
      _playerCount = count;
    });
  }

  Future<void> _startGame() async {
    setState(() {
      _submitted = true;
    });

    // Bắt buộc nhập tên cho tất cả người chơi
    final emptyIndices = <int>[];
    for (int i = 0; i < _playerCount; i++) {
      if (_nameControllers[i].text.trim().isEmpty) {
        emptyIndices.add(i + 1);
      }
    }

    if (emptyIndices.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vui lòng nhập tên cho tất cả $_playerCount người chơi (chưa nhập Người chơi ${emptyIndices.join(', ')})!',
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Kiểm tra trùng tên
    final selectedNames = <String>[];
    for (int i = 0; i < _playerCount; i++) {
      selectedNames.add(_nameControllers[i].text.trim());
    }

    final lowerNames = selectedNames.map((n) => n.toLowerCase()).toList();
    if (lowerNames.toSet().length != selectedNames.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tên người chơi không được trùng nhau! Vui lòng kiểm tra lại.'),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final provider = context.read<GameProvider>();
    final activeGame = provider.activeGame;

    if (activeGame != null && activeGame.isInProgress) {
      final shouldOverwrite = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Bàn chơi đang diễn ra'),
          content: Text(
            'Bàn "${activeGame.title}" đang chơi (Ván ${activeGame.roundCount}). Bạn có muốn lưu bàn cũ vào lịch sử và bắt đầu bàn mới không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Lưu & Tạo bàn mới'),
            ),
          ],
        ),
      );

      if (shouldOverwrite != true) return;
      await provider.finishGame();
    }

    final title = _tableTitleController.text.trim().isEmpty
        ? 'Bàn Sâm ${DateTime.now().day}/${DateTime.now().month}'
        : _tableTitleController.text.trim();

    await provider.createGame(
      playerNames: selectedNames,
      title: title,
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GameScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gameProvider = context.watch<GameProvider>();
    final rules = gameProvider.savedRules;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TẠO BÀN MỚI'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tên bàn
              TextField(
                controller: _tableTitleController,
                decoration: InputDecoration(
                  labelText: 'Tên bàn chơi',
                  prefixIcon: const Icon(Icons.table_restaurant_rounded, color: AppTheme.accentGold),
                  hintText: 'Ví dụ: Bàn vui vẻ, Bàn tối thứ 6...',
                ),
              ),
              const SizedBox(height: 24),

              // Số người chơi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Số người chơi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$_playerCount người',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [2, 3, 4, 5].map((count) {
                  final isSelected = _playerCount == count;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _setPlayerCount(count),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryGreen
                                : (isDark ? AppTheme.darkCard : AppTheme.lightCard),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryGreen
                                  : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                              width: 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primaryGreen.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Tiêu đề phần người chơi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tên người chơi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Bắt buộc nhập $_playerCount người',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentGold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Danh sách nhập tên người chơi
              ...List.generate(_playerCount, (index) {
                final color = AppConstants.playerColors[index % AppConstants.playerColors.length];
                final isMissing = _submitted && _nameControllers[index].text.trim().isEmpty;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: _nameControllers[index],
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) {
                      if (_submitted) {
                        setState(() {});
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Người chơi ${index + 1} *',
                      hintText: 'Nhập tên người chơi ${index + 1}...',
                      errorText: isMissing ? 'Vui lòng nhập tên người chơi ${index + 1}' : null,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: color,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      suffixIcon: _nameControllers[index].text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _nameControllers[index].clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Luật tính điểm preview & customize
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.gavel_rounded, color: AppTheme.accentGold),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                rules.isCustom ? 'Luật tùy chỉnh' : 'Luật mặc định',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Sâm: ${rules.samWinPerPlayer}đ | Cóng: ${rules.congCards}đ',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            rules.autoZeroSum ? 'Tự cân bằng bàn = 0đ' : 'Tính điểm tự do',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RulesConfigScreen()),
                        );
                      },
                      child: const Text('Đổi luật'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // NÚT BẮT ĐẦU
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                  onPressed: _startGame,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'BẮT ĐẦU CHƠI',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
