import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../services/game_provider.dart';
import 'rules_config_screen.dart';
import 'rules_guide_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gameProvider = context.watch<GameProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('CÀI ĐẶT'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Section: Game Rules
          _buildSectionHeader('LUẬT VÀ TÍNH ĐIỂM'),
          _buildSettingsTile(
            context: context,
            icon: Icons.gavel_rounded,
            iconColor: AppTheme.accentGold,
            title: 'Quy tắc tính điểm Sâm',
            subtitle: gameProvider.savedRules.isCustom
                ? 'Đang dùng: Luật tùy chỉnh'
                : 'Đang dùng: Luật mặc định tiêu chuẩn',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RulesConfigScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context: context,
            icon: Icons.menu_book_rounded,
            iconColor: AppTheme.infoBlue,
            title: 'Hướng dẫn cách chơi & luật Sâm',
            subtitle: 'Chi tiết về Báo Sâm, Đền Sâm, Cóng, Thối Heo',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RulesGuideScreen()),
              );
            },
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('GIAO DIỆN & TRẢI NGHIỆM'),
          _buildSettingsTile(
            context: context,
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            iconColor: isDark ? AppTheme.accentGold : AppTheme.primaryEmerald,
            title: 'Giao diện Tối (Dark mode)',
            subtitle: isDark ? 'Đang bật nền tối Poker Slate' : 'Đang bật nền sáng',
            trailing: Switch(
              value: isDark,
              activeColor: AppTheme.primaryGreen,
              onChanged: (_) => gameProvider.toggleTheme(),
            ),
            onTap: () => gameProvider.toggleTheme(),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('DỮ LIỆU'),
          _buildSettingsTile(
            context: context,
            icon: Icons.delete_sweep_rounded,
            iconColor: AppTheme.dangerRed,
            title: 'Xóa toàn bộ lịch sử bàn chơi',
            subtitle: 'Xóa vĩnh viễn các bàn cũ đã lưu trong máy',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xác nhận xóa lịch sử?'),
                  content: const Text(
                    'Toàn bộ lịch sử các bàn chơi trước đây sẽ bị xóa hoàn toàn khỏi thiết bị. Thao tác này không thể hoàn tác.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Xóa tất cả'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await gameProvider.clearAllHistory();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ Đã xóa toàn bộ lịch sử bàn chơi'),
                      backgroundColor: AppTheme.dangerRed,
                    ),
                  );
                }
              }
            },
          ),

          const SizedBox(height: 36),
          // App Info Card
          Container(
            padding: const EdgeInsets.all(20),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '♠ SÂM ĐIỂM',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      AppConstants.appVersion,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ứng dụng sổ điểm Sâm lốc Offline\nKhông cần mạng Internet • Dữ liệu lưu an toàn trên máy',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppTheme.accentGold,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
