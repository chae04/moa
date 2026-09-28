import 'package:flutter/material.dart';
import 'package:moa/constants/colors.dart';
import 'package:moa/screens/transaction/transaction_type_screen.dart';
import 'package:moa/services/transaction_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:moa/services/budget_service.dart';
import 'package:moa/constants/categories.dart';
import 'package:moa/services/budget_category_service.dart';
import 'package:moa/models/budget_category_model.dart';

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
  final BudgetCategoryService _budgetCategoryService = BudgetCategoryService();
  List<BudgetCategoryModel> budgetCategories = [];
  int dailyBudget = 0; // 일일 예산 추천

  Map<DateTime, int> dailyExpense = {}; // 날짜별 지출 합계
  Map<String, int> expenseByCategory = initialExpenseByCategory;
  Map<String, int> usedByBudgetCategory = {};
  Map<String, int> budgetByCategory = {};

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
    final y = year ?? _focusedDay.year;
    final m = month ?? _focusedDay.month;
    final cats = await _budgetCategoryService.getCategories();

    final monthStr = '${y}-${m.toString().padLeft(2, '0')}';

    final transactions = await _transactionService.getMonthlyTransactions(y, m);
    final userBudget = await _budgetService.getUserBudget();

    final income = transactions
        .where((t) => t.type == '수입')
        .fold(0, (sum, t) => sum + t.amount);

    Map<DateTime, int> tempDaily = {};
    for (var t in transactions) {
      if (t.type == '지출') {
        final day = DateTime(t.date.year, t.date.month, t.date.day);
        tempDaily[day] = (tempDaily[day] ?? 0) + t.amount;
      }
    }

    // ID 기준으로 초기화
    Map<String, int> tempUsed = {for (var c in budgetCategories) c.id: 0};
    Map<String, int> tempBudget = {for (var c in budgetCategories) c.id: 0};

    setState(() {
      budgetCategories = cats.where((c) => c.showOnHome).toList();
      dailyExpense = tempDaily;
      totalIncome = income;
      totalExpense = transactions
          .where((t) => t.type == '지출')
          .fold(0, (sum, t) => sum + t.amount);
      totalSaving = transactions
          .where((t) => t.type == '저축')
          .fold(0, (sum, t) => sum + t.amount);

      // usedByBudgetCategory - ID 기준
      for (var t in transactions) {
        if (t.budgetCategoryId != null) {
          tempUsed[t.budgetCategoryId!] = (tempUsed[t.budgetCategoryId!] ?? 0) + t.amount;
        }
      }
      usedByBudgetCategory = tempUsed;
    });

    // 예산 불러오기
    final budget = await _budgetService.getBudget(monthStr);
    final budgetData = budget ?? userBudget;
    print('budget: $budget');
    print('userBudget: $userBudget');
    if (budgetData != null) {
      setState(() {
        for (var c in budgetData.categories) {
          print('category: $c');

          final categoryId = c['categoryId'] as String?;
          if (categoryId != null) {
            tempBudget[categoryId] = (income * (c['ratio'] as int) / 100).round();
          }
        }
        budgetByCategory = tempBudget;
      });
    }

    // dailyBudget 계산
    if (userBudget != null) {
      int totalRemaining = 0;
      for (var c in userBudget.categories) {
        final categoryId = c['categoryId'] as String?;
        if (categoryId != null && c['includeInDaily'] == true) {
          final b = budgetByCategory[categoryId] ?? 0;
          final used = usedByBudgetCategory[categoryId] ?? 0;
          totalRemaining += (b - used);
        }
      }
      final now = DateTime.now();
      final lastDay = DateTime(now.year, now.month + 1, 0);
      final remainingDays = lastDay.day - now.day + 1;
      setState(() {
        dailyBudget = remainingDays > 0 ? (totalRemaining / remainingDays).round() : 0;
      });
    }
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

  Widget _buildProgressBar(String categoryId, String categoryName) {
    final budget = budgetByCategory[categoryId] ?? 0;
    final used = usedByBudgetCategory[categoryId] ?? 0;
    final balance = budget - used;
    print('$categoryName - budget: $budget, used: $used');

    return Row(
      children: [
        SizedBox(width: 50, child: Text(categoryName, style: TextStyle(fontSize: 12))),
        SizedBox(
          width: 90,
          child: Text(
            '${balance.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
            style: TextStyle(fontSize: 12),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: budget == 0 ? 0 : (balance / budget).clamp(0.0, 1.0),
            minHeight: 15,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
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
                rowHeight: 48,
                daysOfWeekHeight: 25,
                firstDay: DateTime.utc(2026, 1, 1),
                lastDay: DateTime(DateTime.now().year + 2, 12, 31),

                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,

                  // 기본 날짜 스타일
                  defaultTextStyle: TextStyle(fontSize: 13),
                  weekendTextStyle: TextStyle(fontSize: 13, color: Colors.red[300]),
                  outsideTextStyle: TextStyle(fontSize: 13, color: Colors.grey[300]),

                  // 셀 여백
                  cellMargin: EdgeInsets.all(0),
                  cellPadding: EdgeInsets.all(0),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
                    return Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 6),
                          Text('${day.day}', style: TextStyle(fontSize: 12)),
                          if (amount != null)
                            Text(
                              '-${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                              style: TextStyle(fontSize: 9, color: Colors.red),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 16),

            if (budgetCategories.isNotEmpty) ...[
              Divider(color: Colors.grey[200]),
              SizedBox(height: 10),
            ],

            // 예산 프로그레스바
            Column(
              children: budgetCategories.map((category) {
                return Column(
                  children: [
                    _buildProgressBar(category.id, category.name),
                    SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ),

            // 일일 예산 추천
            Divider(color: Colors.grey[200]),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('일일 추천 예산', style: TextStyle(fontSize: 13, color: Colors.grey)),
                Text(
                  '${dailyBudget.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
