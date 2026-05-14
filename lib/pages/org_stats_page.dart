import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

// ── 샘플 데이터 ───────────────────────────────────────────────

class _WorkerStat {
  final String name;
  final int count;
  const _WorkerStat(this.name, this.count);
}

const _workerStats = [
  _WorkerStat('박복지사', 31),
  _WorkerStat('김상담사', 24),
  _WorkerStat('한선생', 22),
  _WorkerStat('이사원', 18),
  _WorkerStat('최담당', 12),
];

class _TypeStat {
  final String label;
  final double value;
  final Color color;
  const _TypeStat(this.label, this.value, this.color);
}

const _typeStats = [
  _TypeStat('개인 상담', 45, AppColors.primary),
  _TypeStat('프로그램', 20, AppColors.amber),
  _TypeStat('가족 상담', 15, AppColors.primaryDark),
  _TypeStat('사례 관리', 12, AppColors.purple),
  _TypeStat('위기 개입', 8, AppColors.red),
];

// ── 페이지 ────────────────────────────────────────────────────

class OrgStatsPage extends StatelessWidget {
  const OrgStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        titleSpacing: 16,
        title: Text('기관 통계', style: AppTypography.title),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_outlined,
                size: 16, color: AppColors.textSecondary),
            label: const Text(
              '내보내기',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 요약 수치 카드 ─────────────────────────────
            _SummaryGrid(),
            const SizedBox(height: 20),

            // ── 사회복지사별 케이스 수 ─────────────────────
            _SectionCard(
              title: '사회복지사별 케이스 수',
              icon: Icons.people_outline,
              child: _WorkerBarSection(),
            ),
            const SizedBox(height: 16),

            // ── 상담 유형별 도넛 차트 ─────────────────────
            _SectionCard(
              title: '상담 유형 분포',
              icon: Icons.pie_chart_outline,
              child: _TypeDonutSection(),
            ),
            const SizedBox(height: 16),

            // ── 위험도 분포 ───────────────────────────────
            _SectionCard(
              title: '위험도 분포',
              icon: Icons.warning_amber_outlined,
              child: const _RiskDistSection(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── 요약 그리드 ───────────────────────────────────────────────

class _SummaryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.7,
      children: const [
        _SummaryCard(
          label: '전체 내담자',
          value: '85',
          unit: '명',
          icon: Icons.people_outline,
          color: AppColors.primary,
        ),
        _SummaryCard(
          label: '이번 달 상담',
          value: '147',
          unit: '건',
          icon: Icons.chat_bubble_outline,
          color: AppColors.primaryDark,
        ),
        _SummaryCard(
          label: '고위험 케이스',
          value: '12',
          unit: '건',
          icon: Icons.warning_amber_outlined,
          color: AppColors.red,
        ),
        _SummaryCard(
          label: '사회복지사',
          value: '8',
          unit: '명',
          icon: Icons.badge_outlined,
          color: AppColors.purple,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const Spacer(),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 2),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}

// ── 섹션 카드 래퍼 ────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(title, style: AppTypography.sectionHeader),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ── 사회복지사별 가로 바 차트 ─────────────────────────────────

class _WorkerBarSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const max = 35; // 최대값보다 약간 크게
    return Column(
      children: _workerStats.map((w) => _HorizBar(
        name: w.name,
        count: w.count,
        max: max,
      )).toList(),
    );
  }
}

class _HorizBar extends StatelessWidget {
  final String name;
  final int count;
  final int max;

  const _HorizBar({
    required this.name,
    required this.count,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              name,
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                // 배경
                Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // 바
                FractionallySizedBox(
                  widthFactor: count / max,
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              '$count건',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 상담 유형 도넛 차트 ───────────────────────────────────────

class _TypeDonutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 도넛 차트
        SizedBox(
          width: 150,
          height: 150,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 46,
              sectionsSpace: 2,
              startDegreeOffset: -90,
              sections: _typeStats
                  .map((t) => PieChartSectionData(
                        value: t.value,
                        color: t.color,
                        title: '',
                        radius: 40,
                      ))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 범례
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _typeStats
                .map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: t.color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(t.label, style: AppTypography.caption),
                          ),
                          Text(
                            '${t.value.toInt()}%',
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ── 위험도 분포 ───────────────────────────────────────────────

class _RiskDistSection extends StatelessWidget {
  const _RiskDistSection();

  @override
  Widget build(BuildContext context) {
    const total = 85;
    const data = [
      (label: '고위험', count: 12, color: AppColors.red),
      (label: '중위험', count: 28, color: AppColors.amber),
      (label: '저위험', count: 45, color: AppColors.primaryDark),
    ];

    return Column(
      children: [
        // 누적 세그먼트 바
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(
            children: data.map((d) {
              return Flexible(
                flex: d.count,
                child: Container(
                  height: 20,
                  color: d.color,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        // 범례 + 수치
        Row(
          children: data.map((d) {
            final pct = (d.count / total * 100).toStringAsFixed(1);
            return Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: d.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(d.label, style: AppTypography.caption),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${d.count}명',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: d.color,
                    ),
                  ),
                  Text(
                    '$pct%',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
