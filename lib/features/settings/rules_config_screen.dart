import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/game_rules.dart';
import '../../services/game_provider.dart';

class RulesConfigScreen extends StatefulWidget {
  const RulesConfigScreen({super.key});

  @override
  State<RulesConfigScreen> createState() => _RulesConfigScreenState();
}

class _RulesConfigScreenState extends State<RulesConfigScreen> {
  bool _isCustom = false;
  late TextEditingController _basePointsController;
  late TextEditingController _congCardsController;
  late TextEditingController _samWinController;
  late TextEditingController _denSamController;
  late TextEditingController _thoi2BlackController;
  late TextEditingController _thoi2RedController;
  late TextEditingController _thoiTuQuyController;
  late TextEditingController _anTrangController;
  bool _autoZeroSum = true;

  @override
  void initState() {
    super.initState();
    final rules = context.read<GameProvider>().savedRules;
    _isCustom = rules.isCustom;
    _basePointsController = TextEditingController(text: rules.basePointsPerCard.toString());
    _congCardsController = TextEditingController(text: rules.congCards.toString());
    _samWinController = TextEditingController(text: rules.samWinPerPlayer.toString());
    _denSamController = TextEditingController(text: rules.denSamPenalty.toString());
    _thoi2BlackController = TextEditingController(text: rules.thoi2BlackCards.toString());
    _thoi2RedController = TextEditingController(text: rules.thoi2RedCards.toString());
    _thoiTuQuyController = TextEditingController(text: rules.thoiTuQuyCards.toString());
    _anTrangController = TextEditingController(text: rules.anTrangPerPlayer.toString());
    _autoZeroSum = rules.autoZeroSum;
  }

  @override
  void dispose() {
    _basePointsController.dispose();
    _congCardsController.dispose();
    _samWinController.dispose();
    _denSamController.dispose();
    _thoi2BlackController.dispose();
    _thoi2RedController.dispose();
    _thoiTuQuyController.dispose();
    _anTrangController.dispose();
    super.dispose();
  }

  void _resetToDefault() {
    setState(() {
      _isCustom = false;
      const def = GameRules.defaultRules;
      _basePointsController.text = def.basePointsPerCard.toString();
      _congCardsController.text = def.congCards.toString();
      _samWinController.text = def.samWinPerPlayer.toString();
      _denSamController.text = def.denSamPenalty.toString();
      _thoi2BlackController.text = def.thoi2BlackCards.toString();
      _thoi2RedController.text = def.thoi2RedCards.toString();
      _thoiTuQuyController.text = def.thoiTuQuyCards.toString();
      _anTrangController.text = def.anTrangPerPlayer.toString();
      _autoZeroSum = def.autoZeroSum;
    });
  }

  Future<void> _saveRules() async {
    final rules = GameRules(
      id: _isCustom ? 'custom' : 'default',
      name: _isCustom ? 'Luật tùy chỉnh' : 'Luật tiêu chuẩn Sâm Lốc',
      isCustom: _isCustom,
      basePointsPerCard: int.tryParse(_basePointsController.text) ?? 1,
      congCards: int.tryParse(_congCardsController.text) ?? 15,
      samWinPerPlayer: int.tryParse(_samWinController.text) ?? 20,
      denSamPenalty: int.tryParse(_denSamController.text) ?? 20,
      thoi2BlackCards: int.tryParse(_thoi2BlackController.text) ?? 10,
      thoi2RedCards: int.tryParse(_thoi2RedController.text) ?? 15,
      thoiTuQuyCards: int.tryParse(_thoiTuQuyController.text) ?? 15,
      anTrangPerPlayer: int.tryParse(_anTrangController.text) ?? 20,
      autoZeroSum: _autoZeroSum,
    );

    await context.read<GameProvider>().updateSavedRules(rules);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Đã lưu cài đặt luật tính điểm!'),
          backgroundColor: AppTheme.primaryGreen,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LUẬT TÍNH ĐIỂM'),
        actions: [
          TextButton(
            onPressed: _resetToDefault,
            child: const Text('Mặc định', style: TextStyle(color: AppTheme.accentGold)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chọn Luật Mặc định / Tùy chỉnh
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    RadioListTile<bool>(
                      value: false,
                      groupValue: _isCustom,
                      title: const Text('Luật mặc định', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Chuẩn Sâm Lốc: Thắng = số lá, Sâm = 20 lá, Cóng = 15 lá'),
                      activeColor: AppTheme.primaryGreen,
                      onChanged: (val) {
                        _resetToDefault();
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<bool>(
                      value: true,
                      groupValue: _isCustom,
                      title: const Text('Luật tùy chỉnh', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Tự chỉnh điểm phạt theo quy ước nhóm chơi của bạn'),
                      activeColor: AppTheme.accentGold,
                      onChanged: (val) {
                        setState(() {
                          _isCustom = true;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'CHI TIẾT ĐIỂM PHẠT',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: AppTheme.accentGold,
                ),
              ),
              const SizedBox(height: 12),

              _buildNumberField(
                label: 'Điểm thắng cơ bản (mỗi lá bài còn lại)',
                controller: _basePointsController,
                suffix: 'điểm/lá',
                enabled: _isCustom,
                helper: 'Người thua mất số lá còn lại nhân điểm này',
              ),
              const SizedBox(height: 14),

              _buildNumberField(
                label: 'Phạt Cóng (cháy bài, không đánh được lá nào)',
                controller: _congCardsController,
                suffix: 'lá',
                enabled: _isCustom,
                helper: 'Người bị cóng bị tính số lá này (mặc định 15 lá)',
              ),
              const SizedBox(height: 14),

              _buildNumberField(
                label: 'Báo Sâm thành công (mỗi người đền)',
                controller: _samWinController,
                suffix: 'lá/điểm',
                enabled: _isCustom,
                helper: 'Người thắng nhận điểm này từ mỗi người chơi còn lại',
              ),
              const SizedBox(height: 14),

              _buildNumberField(
                label: 'Đền Sâm (khi báo Sâm thất bại bị chặn)',
                controller: _denSamController,
                suffix: 'lá/điểm',
                enabled: _isCustom,
                helper: 'Người báo Sâm thất bại phải đền số điểm này',
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      label: 'Thối Heo đen',
                      controller: _thoi2BlackController,
                      suffix: 'lá',
                      enabled: _isCustom,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      label: 'Thối Heo đỏ',
                      controller: _thoi2RedController,
                      suffix: 'lá',
                      enabled: _isCustom,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      label: 'Thối Tứ quý',
                      controller: _thoiTuQuyController,
                      suffix: 'lá',
                      enabled: _isCustom,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      label: 'Ăn trắng',
                      controller: _anTrangController,
                      suffix: 'lá',
                      enabled: _isCustom,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Zero sum switch
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                ),
                child: SwitchListTile(
                  value: _autoZeroSum,
                  title: const Text(
                    'Tự động cân bằng tổng điểm',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Tổng điểm cả bàn luôn bằng 0 (Điểm người thắng = Tổng điểm người thua bị phạt)',
                    style: TextStyle(fontSize: 12),
                  ),
                  activeColor: AppTheme.primaryGreen,
                  onChanged: (val) {
                    setState(() {
                      _autoZeroSum = val;
                    });
                  },
                ),
              ),

              const SizedBox(height: 32),

              // NÚT LƯU LUẬT
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _saveRules,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text(
                    'LƯU LUẬT TÍNH ĐIỂM',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    required String suffix,
    String? helper,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        helperMaxLines: 2,
        suffixText: suffix,
      ),
    );
  }
}
