import 'package:flutter/material.dart';
import 'package:moa/constants/colors.dart';
import 'package:moa/screens/transaction/transaction_type_screen.dart';
import 'package:moa/services/transaction_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:moa/services/budget_service.dart';
import 'package:moa/constants/categories.dart';

class HomeScreen extends StatefulWidget {
  final DateTime focusedDay;
  final Function(DateTime) onFocusedDayChanged;
  final Function(DateTime)? onDateSelected;
  const HomeScreen({
    super.key,
    required this.focusedDay,
    required this.onFocusedDayChanged,
    required this.onDateSelected,
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

  Map<String, int> expenseByCategory = initialExpenseByCategory;
  Map<String, int> usedByBudgetCategory = initialBudgetCategory;
  Map<String, int> budgetByCategory = initialBudgetCategory;

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
      child: Column(
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
        SizedBox(
          width: 90,
          child: Text(
            '${(budget - used).toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
            style: TextStyle(fontSize: 12),
          ),
        ),
        SizedBox(width: 8),
        SizedBox(
          width: 155,
          child: LinearProgressIndicator(
            value: budget == 0 ? 0 : used / budget,
            minHeight: 15,
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
                      MaterialPageRoute(builder: (context) => TransactionTypeScreen()),
                    ).then(
                      (_) => _loadData(year: _focusedDay.year, month: _focusedDay.month),
                    );
                  },
                  icon: Icon(Icons.add, size: 16),
                  label: Text('추가'),
                ),
              ],
            ),
            SizedBox(height: 30),

            // 수입, 지출, 저축 금액 카드
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildSummaryCard('수입', totalIncome, Colors.blue)),
                Expanded(child: _buildSummaryCard('지출', totalExpense, Colors.red)),
                Expanded(child: _buildSummaryCard('저축', totalSaving, Colors.green)),
              ],
            ),
            SizedBox(height: 30),

            // 캘린더
            Expanded(
              child: TableCalendar(
                calendarFormat: CalendarFormat.month,
                headerVisible: false,
                locale: 'ko_KR',
                rowHeight: 60,
                daysOfWeekHeight: 25,
                firstDay: DateTime.utc(2026, 1, 1),
                lastDay: DateTime(DateTime.now().year + 2, 12, 31),

                calendarStyle: CalendarStyle(
                  // 기본 날짜 스타일
                  defaultTextStyle: TextStyle(fontSize: 13),
                  weekendTextStyle: TextStyle(fontSize: 13, color: Colors.red[300]),
                  outsideTextStyle: TextStyle(fontSize: 13, color: Colors.grey[300]),

                  // 오늘 날짜
                  todayDecoration: BoxDecoration(color: Colors.transparent),
                  todayTextStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),

                  // 셀 여백
                  cellMargin: EdgeInsets.all(4),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  // 요일 행 스타일
                  weekdayStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  weekendStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[300],
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                  ),
                ),

                focusedDay: _focusedDay,
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                  widget.onFocusedDayChanged(focusedDay);
                  _loadData(year: focusedDay.year, month: focusedDay.month);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  widget.onDateSelected?.call(selectedDay);
                },
                calendarBuilders: CalendarBuilders(
                  dowBuilder: (context, day) {
                    final text = ['일', '월', '화', '수', '목', '금', '토'][day.weekday % 7];
                    Color color = Colors.grey[600]!;
                    if (day.weekday == DateTime.sunday) color = Colors.red[300]!;
                    if (day.weekday == DateTime.saturday) color = Colors.blue[300]!;
                    return Center(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    final key = DateTime(day.year, day.month, day.day);
                    final amount = dailyExpense[key];
                    return Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 6, width: 40),
                          Text(
                            '${day.day}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          if (amount != null)
                            Text(
                              '-${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                              style: TextStyle(fontSize: 9, color: Colors.red),
                            ),
                        ],
                      ),
                    );
                  },

                  defaultBuilder: (context, day, focusedDay) {
                    final key = DateTime(day.year, day.month, day.day);
                    final amount = dailyExpense[key];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
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
            Divider(color: Colors.grey[200]),
            SizedBox(height: 10),

            // 예산 프로그레스바
            Column(
              children: [
                _buildProgressBar('생활비'),
                SizedBox(height: 10),
                _buildProgressBar('교통비'),
                SizedBox(height: 10),
                _buildProgressBar('자유비'),
              ],
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
