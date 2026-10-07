import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class RulesGuideScreen extends StatelessWidget {
  const RulesGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HƯỚNG DẪN LUẬT SÂM LỐC'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildGuideSection(
            context: context,
            title: '1. Giới thiệu tổng quan',
            content: 'Sâm Lốc là trò chơi bài dân gian phổ biến, dùng bộ bài Tây 52 lá.\n'
                '• Số người chơi: Từ 2 đến 5 người (mỗi người 10 lá; hoặc chơi theo quy ước nhóm).\n'
                '• Thứ tự quân bài: 3 < 4 < ... < K < A < 2 (Heo lớn nhất).\n'
                '• Chất (cơ, rô, tép, bích) không phân biệt lớn nhỏ, chỉ so độ lớn số.',
            icon: Icons.info_outline_rounded,
          ),
          const SizedBox(height: 16),
          _buildGuideSection(
            context: context,
            title: '2. Báo Sâm (Xin Sâm) & Đền Sâm',
            content: '• Báo Sâm: Trước khi ván bắt đầu, người chơi cảm thấy bài mình có thể đánh một mạch hết mà không ai chặn được có thể Báo Sâm.\n'
                '• Báo Sâm thành công: Nếu không ai chặn được và về hết bài, người báo Sâm thắng đậm (ăn 20 điểm/lá từ mỗi người chơi khác).\n'
                '• Đền Sâm: Nếu có một người khác chặn được bài, người báo Sâm thua và phải đền cho cả bàn hoặc đền toàn bộ cho người chặn.',
            icon: Icons.campaign_rounded,
            badgeColor: AppTheme.accentGold,
          ),
          const SizedBox(height: 16),
          _buildGuideSection(
            context: context,
            title: '3. Cóng (Cháy bài)',
            content: '• Khi có người về nhất mà người chơi khác chưa đánh ra được bất kỳ lá bài nào trên tay (vẫn còn nguyên 10 lá).\n'
                '• Người bị Cóng sẽ bị phạt nặng (mặc định 15 lá) + cộng thêm phạt thối heo hoặc thối tứ quý (nếu có trên tay).',
            icon: Icons.local_fire_department_rounded,
            badgeColor: AppTheme.dangerRed,
          ),
          const SizedBox(height: 16),
          _buildGuideSection(
            context: context,
            title: '4. Thối Heo (2) & Tứ quý',
            content: '• Thối 2: Khi ván kết thúc, ai còn giữ quân 2 trên tay sẽ bị phạt thêm (thường 10 lá cho 2 đen, 15 lá cho 2 đỏ).\n'
                '• Thối Tứ Quý: Ai còn tứ quý trên tay bị phạt tương đương 15-20 lá.\n'
                '• Chặn 2: 1 tứ quý chặt được 1 quân 2 (hoặc 2 tứ quý chặt đôi 2 tùy luật địa phương).',
            icon: Icons.warning_amber_rounded,
            badgeColor: AppTheme.accentAmber,
          ),
          const SizedBox(height: 16),
          _buildGuideSection(
            context: context,
            title: '5. Ăn trắng (Tới trắng)',
            content: 'Về nhất ngay sau khi chia bài nếu sở hữu:\n'
                '• Sảnh Rồng (10 lá liên tiếp từ 3 đến A)\n'
                '• Tứ quý 2 (4 quân Heo)\n'
                '• Đồng màu (10 lá cùng đỏ hoặc cùng đen)\n'
                '• 5 đôi hoặc 3 sám cô.\n'
                'Thắng tương đương mức điểm Báo Sâm (20 lá mỗi người).',
            icon: Icons.military_tech_rounded,
            badgeColor: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection({
    required BuildContext context,
    required String title,
    required String content,
    required IconData icon,
    Color badgeColor = AppTheme.infoBlue,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: badgeColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
