import 'package:flutter/material.dart';
import 'package:moa/constants/colors.dart';
import 'package:moa/screens/transaction/transaction_form_screen.dart';
import 'package:moa/services/transaction_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:moa/services/budget_service.dart';

class HomeScreen extends StatefulWidget {
  final DateTime focusedDay;
  final Function(DateTime) onFocusedDayChanged;
  const HomeScreen({
    super.key,
    required this.focusedDay,
    required this.onFocusedDayChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalIncome = 0; // 총 수입
  int totalExpense = 0; // 총 지출
  int totalSaving = 0; // 총 저축

  final TransactionService _transactionService = TransactionService();
  final BudgetService _budgetService = BudgetService();
  late DateTime _focusedDay; // 현재 선택된 날짜
  Map<DateTime, int> dailyExpense = {}; // 날짜별 지출 합계

  // 카테고리별 지출
  Map<String, int> expenseByCategory = {
    '식비': 0,
    '교통': 0,
    '쇼핑': 0,
    '구독': 0,
    '취미': 0,
    '고정비': 0,
    '기타': 0,
  };

  // 예산 카테고리별 사용 금액
  Map<String, int> usedByBudgetCategory = {
    '생활비': 0,
    '저축': 0,
    '자유비': 0,
    '교통비': 0,
    '투자': 0,
  };

  // 카테고리별 예산
  Map<String, int> budgetByCategory = {'생활비': 0, '저축': 0, '자유비': 0, '교통비': 0, '투자': 0};

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay;
    _loadData();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedDay != widget.focusedDay) {
      setState(() {
        _focusedDay = widget.focusedDay;
      });
      _loadData(year: widget.focusedDay.year, month: widget.focusedDay.month);
    }
  }

  Future<void> _loadData({int? year, int? month}) async {
    print('_loadData 호출: $year, $month');
    final y = year ?? _focusedDay.year;
    final m = month ?? _focusedDay.month;
    final monthStr = '${y}-${m.toString().padLeft(2, '0')}';
    final transactions = await _transactionService.getMonthlyTransactions(y, m);

    // 날짜별 지출 계산
    Map<DateTime, int> tempDaily = {};
    for (var t in transactions) {
      if (t.type == '지출') {
        final day = DateTime(t.date.year, t.date.month, t.date.day);
        tempDaily[day] = (tempDaily[day] ?? 0) + t.amount;
      }
    }

    setState(() {
      dailyExpense = tempDaily;
      totalIncome = transactions
          .where((t) => t.type == '수입')
          .fold(0, (sum, t) => sum + t.amount);
      totalExpense = transactions
          .where((t) => t.type == '지출')
          .fold(0, (sum, t) => sum + t.amount);
      totalSaving = transactions
          .where((t) => t.type == '저축')
          .fold(0, (sum, t) => sum + t.amount);

      // usedByBudgetCategory 초기화
      usedByBudgetCategory = {'생활비': 0, '저축': 0, '자유비': 0, '교통비': 0, '투자': 0};

      for (var t in transactions) {
        if (t.budgetCategory != null) {
          usedByBudgetCategory[t.budgetCategory!] =
              (usedByBudgetCategory[t.budgetCategory!] ?? 0) + t.amount;
        }
      }
    });

    // 예산 데이터 불러오기
    final budget = await _budgetService.getBudget(monthStr);
    if (budget != null) {
      print('[$_focusedDay] categories: ${budget.categories}');

      setState(() {
        for (var c in budget.categories) {
          print('[$_focusedDay] category: ${c['category']}, amount: ${c['amount']}');

          budgetByCategory[c['category']] = c['amount'];
        }
      });
    }
    print('[$_focusedDay] budgetByCategory: $budgetByCategory');
    print('[$_focusedDay] usedByBudgetCategory: $usedByBudgetCategory');
  }

  // 수입/지출/저축 카드 형태로 표시
  Widget _buildSummaryCard(String label, int amount, Color color) {
    return Container(
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 12)),
          SizedBox(width: 20),
          Text(
            '${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String category) {
    final budget = budgetByCategory[category] ?? 0;
    final used = usedByBudgetCategory[category] ?? 0;
    final percent = budget == 0 ? 0 : ((used / budget) * 100).toInt();

    return Row(
      children: [
        SizedBox(width: 50, child: Text(category, style: TextStyle(fontSize: 12))),
        SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: budget == 0 ? 0 : used / budget,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 8),
        SizedBox(width: 40, child: Text('$percent%', style: TextStyle(fontSize: 12))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 24.0, top: 60.0, right: 24.0, bottom: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                // 상단: 년월, 거래추가 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 이전 달 이동 버튼
                    IconButton(
                      onPressed: () {
                        final prev = DateTime(_focusedDay.year, _focusedDay.month - 1);
                        if (prev.isBefore(DateTime(2026, 1, 1))) return; // 2026년 1월 이전 막기
                        // month - 1이 0이 되면 Dart가 자동으로 전해 12월로 처리해줘
                        setState(() => _focusedDay = prev);
                        widget.onFocusedDayChanged(prev);
                        _loadData(year: prev.year, month: prev.month);
                      },
                      icon: Icon(Icons.chevron_left),
                    ),
                    Text(
                      '${_focusedDay.year}년 ${_focusedDay.month}월',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    // 다음 달 이동 버튼
                    IconButton(
                      onPressed: () {
                        final next = DateTime(_focusedDay.year, _focusedDay.month + 1);
                        final limit = DateTime(DateTime.now().year + 2, 12, 31);
                        if (next.isAfter(limit)) return; // 2년 뒤 이후 막기
                        // month + 1이 13이 되면 Dart가 자동으로 다음해 1월로 처리해줘
                        setState(() => _focusedDay = next);
                        widget.onFocusedDayChanged(next);
                        _loadData(year: next.year, month: next.month);
                      },
                      icon: Icon(Icons.chevron_right),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionFormScreen(),
                          ),
                        ).then(
                          (_) =>
                              _loadData(year: _focusedDay.year, month: _focusedDay.month),
                        );
                      },
                      icon: Icon(Icons.add, size: 16),
                      label: Text('추가'),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // 수입, 지출, 저축 금액 카드
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryCard('수입', totalIncome, Colors.blue),
                    _buildSummaryCard('지출', totalExpense, Colors.red),
                    _buildSummaryCard('저축', totalSaving, Colors.green),
                  ],
                ),
                SizedBox(height: 16),

                // 캘린더
                SizedBox(
                  height: 350,
                  child: TableCalendar(
                    headerVisible: false,
                    locale: 'ko_KR',
                    firstDay: DateTime.utc(2026, 1, 1),
                    lastDay: DateTime(DateTime.now().year + 2, 12, 31),
                    focusedDay: _focusedDay,
                    onPageChanged: (focusedDay) {
                      setState(() => _focusedDay = focusedDay);
                      widget.onFocusedDayChanged(focusedDay);
                      _loadData(year: focusedDay.year, month: focusedDay.month);
                    },
                    calendarBuilders: CalendarBuilders(
                      todayBuilder: (context, day, focusedDay) {
                        final key = DateTime(day.year, day.month, day.day);
                        final amount = dailyExpense[key];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            if (amount != null)
                              Text(
                                '-${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                                style: TextStyle(fontSize: 9, color: Colors.red),
                              ),
                          ],
                        );
                      },

                      defaultBuilder: (context, day, focusedDay) {
                        final key = DateTime(day.year, day.month, day.day);
                        final amount = dailyExpense[key];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${day.day}', style: TextStyle(fontSize: 12)),
                            if (amount != null)
                              Text(
                                '-${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                                style: TextStyle(fontSize: 9, color: Colors.red),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),

            // 예산 프로그레스바
            Column(
              children: [
                _buildProgressBar('생활비'),
                SizedBox(height: 8),
                _buildProgressBar('교통비'),
                SizedBox(height: 8),
                _buildProgressBar('자유비'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
