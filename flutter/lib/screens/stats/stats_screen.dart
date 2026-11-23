// [역할] 통계 화면 (하단 탭 "통계")
// - 탭 1 "카테고리별 지출"(기본): 그 달 지출을 카테고리별 원형 그래프 + 비율·금액 목록 (큰 순)
// - 탭 2 "1년 추이": 1~12월 막대 = 그 달 모은 돈(수입 - 지출). 양수 파란색 위, 음수 빨간색 아래
//   막대를 누르면 그 달의 거래 목록으로 이동 (미래 달은 이동 안 함)
// - "모은 돈" = 수입 - 지출. 홈의 "저축"(저축 유형 합계)과 다른 값이라 이름을 구분
// - 데이터는 AppRepositories.stats (로컬 구현 / 서버 /api/stats)

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:moa/constants/colors.dart';
import 'package:moa/data/app_repositories.dart';
import 'package:moa/models/stats_model.dart';
import 'package:moa/utils/api_error.dart';
import 'package:moa/utils/format.dart';

class StatsScreen extends StatefulWidget {
  final DateTime focusedDay; // 홈·거래 목록과 같은 달에서 시작
  final void Function(DateTime month) onMonthSelected; // 1년 추이 막대를 눌렀을 때 (그 달 거래 목록으로)

  const StatsScreen({super.key, required this.focusedDay, required this.onMonthSelected});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  // 원형 그래프 조각 색 (큰 순서대로 돌려 씀)
  static const _palette = [
    Color(0xFFE57373),
    Color(0xFF64B5F6),
    Color(0xFF81C784),
    Color(0xFFFFB74D),
    Color(0xFFBA68C8),
    Color(0xFF4DB6AC),
    Color(0xFFF06292),
    Color(0xFF90A4AE),
  ];

  late DateTime _month; // 카테고리별 지출 탭의 달
  late int _year; // 1년 추이 탭의 연도
  CategoryStatsModel? _categoryStats;
  YearlyStatsModel? _yearlyStats;

  @override
  void initState() {
    super.initState();
    _month = DateTime(widget.focusedDay.year, widget.focusedDay.month);
    _year = widget.focusedDay.year;
    _loadCategoryStats();
    _loadYearlyStats();
  }

  Future<void> _loadCategoryStats() async {
    final month = _month;
    try {
      final stats = await AppRepositories.stats.getCategoryStats(month.year, month.month);
      if (!mounted || month != _month) return; // 기다리는 동안 다른 달로 넘겼으면 버림
      setState(() => _categoryStats = stats);
    } catch (e) {
      _showError(e, '통계를 불러오지 못했어요.');
    }
  }

  Future<void> _loadYearlyStats() async {
    final year = _year;
    try {
      final stats = await AppRepositories.stats.getYearlyStats(year);
      if (!mounted || year != _year) return;
      setState(() => _yearlyStats = stats);
    } catch (e) {
      _showError(e, '통계를 불러오지 못했어요.');
    }
  }

  void _showError(Object e, String fallback) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e, fallback))));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 60, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('통계', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TabBar(
                labelColor: primaryColor,
                indicatorColor: primaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: '카테고리별 지출'),
                  Tab(text: '1년 추이'),
                ],
              ),
              SizedBox(height: 8),
              Expanded(
                child: TabBarView(children: [_buildCategoryTab(), _buildYearlyTab()]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- 탭 1: 카테고리별 지출 ----

  Widget _buildCategoryTab() {
    final stats = _categoryStats;
    return Column(
      children: [
        _buildNavigator(
          label: '${_month.year}년 ${_month.month}월',
          onPrev: () {
            setState(() => _month = DateTime(_month.year, _month.month - 1));
            _loadCategoryStats();
          },
          onNext: () {
            setState(() => _month = DateTime(_month.year, _month.month + 1));
            _loadCategoryStats();
          },
        ),
        if (stats == null)
          Expanded(child: Center(child: CircularProgressIndicator()))
        else if (stats.categories.isEmpty)
          Expanded(
            child: Center(
              child: Text('이 달은 지출이 없어요.', style: TextStyle(color: Colors.grey[500])),
            ),
          )
        else
          Expanded(
            child: ListView(
              children: [
                SizedBox(height: 8),
                SizedBox(
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          centerSpaceRadius: 64, // 가운데 구멍 (총지출 표시 자리)
                          sectionsSpace: 2,
                          sections: [
                            for (var i = 0; i < stats.categories.length; i++)
                              PieChartSectionData(
                                value: stats.categories[i].amount.toDouble(),
                                color: _palette[i % _palette.length],
                                radius: 36,
                                showTitle: false, // 이름·비율은 아래 목록에서
                              ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('총지출', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          SizedBox(height: 4),
                          Text(
                            formatWon(stats.totalExpense),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                for (var i = 0; i < stats.categories.length; i++)
                  _buildCategoryRow(i, stats.categories[i], stats.totalExpense),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryRow(int index, CategoryAmount item, int total) {
    final percent = total == 0 ? 0 : (item.amount * 100 / total).round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _palette[index % _palette.length],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10),
          Expanded(child: Text(item.category, style: TextStyle(fontSize: 14))),
          SizedBox(
            width: 48,
            child: Text(
              '$percent%',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          SizedBox(width: 12),
          Text(
            formatWon(item.amount),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ---- 탭 2: 1년 추이 ----

  Widget _buildYearlyTab() {
    final stats = _yearlyStats;
    return Column(
      children: [
        _buildNavigator(
          label: '$_year년',
          onPrev: () {
            setState(() => _year -= 1);
            _loadYearlyStats();
          },
          onNext: () {
            setState(() => _year += 1);
            _loadYearlyStats();
          },
        ),
        if (stats == null)
          Expanded(child: Center(child: CircularProgressIndicator()))
        else
          Expanded(
            child: ListView(
              children: [
                SizedBox(height: 8),
                Text('올해 모은 돈', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                SizedBox(height: 4),
                Text(
                  formatSignedWon(stats.totalSaved),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: stats.totalSaved >= 0 ? Colors.blue : Colors.red,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '총수입 ${formatWon(stats.totalIncome)} − 총지출 ${formatWon(stats.totalExpense)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                SizedBox(height: 24),
                SizedBox(height: 240, child: _buildBarChart(stats)),
                SizedBox(height: 8),
                Text(
                  '막대를 누르면 그 달의 거래 목록으로 이동해요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBarChart(YearlyStatsModel stats) {
    final values = stats.months.map((m) => m.saved.toDouble()).toList();
    final maxAbs = values.fold(0.0, (a, v) => v.abs() > a ? v.abs() : a);
    final bound = maxAbs == 0 ? 1.0 : maxAbs * 1.1; // 위아래 여유 10%

    final now = DateTime.now();
    bool isFuture(int month) =>
        _year > now.year || (_year == now.year && month > now.month);

    return BarChart(
      BarChartData(
        minY: -bound, // 음수 막대가 아래로 내려갈 공간
        maxY: bound,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${value.toInt()}',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
        barTouchData: BarTouchData(
          handleBuiltInTouches: false, // 기본 말풍선 대신 눌렀을 때 이동
          touchCallback: (event, response) {
            if (event is! FlTapUpEvent) return; // 손을 뗐을 때만
            final index = response?.spot?.touchedBarGroupIndex;
            if (index == null) return;
            final month = index + 1;
            if (isFuture(month)) return; // 미래 달은 이동 안 함
            widget.onMonthSelected(DateTime(_year, month));
          },
        ),
        barGroups: [
          for (var i = 0; i < 12; i++)
            BarChartGroupData(
              x: i + 1,
              barRods: [
                BarChartRodData(
                  fromY: 0,
                  toY: values[i],
                  width: 14,
                  color: values[i] >= 0 ? Colors.blue : Colors.red,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // `<  2026년 11월  >` 같은 이동 줄
  Widget _buildNavigator({
    required String label,
    required VoidCallback onPrev,
    required VoidCallback onNext,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed: onPrev, icon: Icon(Icons.chevron_left)),
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        IconButton(onPressed: onNext, icon: Icon(Icons.chevron_right)),
      ],
    );
  }
}
