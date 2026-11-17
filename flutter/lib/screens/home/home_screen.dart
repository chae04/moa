import 'package:flutter/material.dart';
import 'package:moa/utils/api_error.dart';
import 'package:moa/constants/colors.dart';
import 'package:moa/models/home_model.dart';
import 'package:moa/screens/transaction/transaction_type_screen.dart';
import 'package:moa/services/home_service.dart';
import 'package:table_calendar/table_calendar.dart';

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
  int totalInvest = 0; // 총 투자

  final HomeService _homeService = HomeService(); // 홈 데이터는 서버가 한 번에 계산해서 줌
  late DateTime _focusedDay; // 현재 선택된 날짜
  List<CategorySummary> budgetCategories = []; // 홈에 표시할 카테고리 (예산·사용액·잔액 포함)
  int? dailyBudget; // 일일 예산 추천 (지난달이거나 비율이 없으면 null)

  Map<DateTime, int> dailyExpense = {}; // 날짜별 지출 합계 (달력 표시용)

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

    try {
      // 합계·카테고리별 예산·날짜별 지출·일일 예산을 서버가 계산해서 한 번에 줌
      final home = await _homeService.getHome(y, m);

      // 응답을 기다리는 동안 화면을 벗어났거나 다른 달로 넘겼으면 버림
      // (달을 빠르게 넘기면 이전 달 응답이 늦게 와서 현재 달 화면을 덮어쓰는 문제 방지)
      if (!mounted || _focusedDay.year != y || _focusedDay.month != m) return;

      setState(() {
        totalIncome = home.totalIncome;
        totalExpense = home.totalExpense;
        totalSaving = home.totalSaving;
        totalInvest = home.totalInvest;
        // 삭제됐거나 홈 표시를 끈 카테고리는 바를 그리지 않음 (서버 목록에는 들어 있음)
        budgetCategories = home.categories.where((c) => c.showOnHome && !c.deleted).toList();
        dailyBudget = home.dailyBudget;
        // 달력은 날짜로 금액을 찾으므로 목록 → Map<날짜, 금액>으로 변환
        dailyExpense = {for (var d in home.dailyExpenses) d.date: d.amount};
      });
    } catch (e) {
      // 서버 꺼짐, 토큰 문제 등: 이전 화면 값은 그대로 두고 알림만
      if (!mounted) return;
      final message = apiErrorMessage(e, '홈 정보를 불러오지 못했어요.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // 수입/지출/저축/투자를 한 줄에 하나씩 표시 (왼쪽 이름, 오른쪽 금액)
  // 가로 4칸이면 금액이 커질 때 두 줄로 깨져서 세로 배치로 바꿈
  // color: 이름 글자색 (수입 파랑, 지출 빨강, 저축·투자 초록). 금액은 검정
  Widget _buildSummaryRow(String label, int amount, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 12)),
          SizedBox(width: 10), // 이름과 금액 사이 간격
          Expanded(
            child: Text(
              '${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
              textAlign: TextAlign.right, // 금액 끝을 맞춰서 자릿수 비교가 쉬움
              maxLines: 1, // 두 줄로 넘어가지 않게
              overflow: TextOverflow.ellipsis, // 그래도 넘치면 ...으로
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(CategorySummary category) {
    final budget = category.budget; // 수입 × 비율 (서버 계산)
    final balance = category.remaining; // 예산 - 사용액 (서버 계산, 음수면 초과)

    return Row(
      children: [
        SizedBox(width: 50, child: Text(category.name, style: TextStyle(fontSize: 12))),
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

            // 수입, 지출, 저축, 투자 금액 (2행 2열: 원래 카드와 같은 두 줄 높이라 달력 크기 유지)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryRow('수입', totalIncome, Colors.blue),
                    ),
                    SizedBox(width: 24), // 두 열 사이 간격
                    Expanded(
                      child: _buildSummaryRow('지출', totalExpense, Colors.red),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildSummaryRow('저축', totalSaving, Colors.green)),
                    SizedBox(width: 24),
                    Expanded(child: _buildSummaryRow('투자', totalInvest, Colors.green)),
                  ],
                ),
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
                    _buildProgressBar(category),
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
                  // null(지난달·비율 없음)이면 0원 대신 '-' (0원은 "오늘 쓸 돈 없음"으로 오해할 수 있음)
                  dailyBudget == null
                      ? '-'
                      : '${dailyBudget.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
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
