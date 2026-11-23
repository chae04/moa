import 'package:flutter/material.dart';
import 'package:moa/utils/api_error.dart';
import 'package:moa/constants/colors.dart';
import 'package:moa/models/home_model.dart';
import 'package:moa/utils/format.dart';
import 'package:moa/screens/transaction/transaction_type_screen.dart';
import 'package:moa/data/app_repositories.dart'; // 모드(로컬/서버)에 맞는 저장소
import 'package:moa/data/repositories.dart';
import 'package:moa/widgets/budget_card.dart';

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

  final HomeRepository _homeService =
      AppRepositories.home; // 홈 데이터는 저장소가 한 번에 계산해서 줌 (로컬/서버)
  late DateTime _focusedDay; // 현재 선택된 날짜
  List<CategorySummary> budgetCategories = []; // 홈에 표시할 카테고리 (예산·사용액·잔액 포함)
  int? dailyBudget; // 하루 추천 금액 = 오늘 아침 기준 잔액 ÷ 남은 일수 (지난달이거나 비율이 없으면 null)
  int? todayBudget; // 오늘 추천 = 오늘 아침 기준 잔액 ÷ 남은 일수 (이번 달·로컬 모드에서만 값이 있음)
  int? todaySpent; // 오늘 쓴 돈 (이번 달·로컬 모드에서만 값이 있음)
  int? todayRemaining; // 오늘 남은 돈 = 하루 추천 금액 - 오늘 쓴 돈 (음수면 초과)

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
        budgetCategories = home.categories
            .where((c) => c.showOnHome && !c.deleted)
            .toList();
        dailyBudget = home.dailyBudget;
        todayBudget = home.todayBudget;
        todaySpent = home.todaySpent;
        todayRemaining = home.todayRemaining;
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
              formatWon(amount),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 24.0, top: 60.0, right: 24.0, bottom: 24.0),
        child: Column(
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
            SizedBox(height: 16),

            // 헤더 아래는 스크롤 (봉투가 많아도 화면 밖으로 잘리지 않게)
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // 수입, 지출, 저축, 투자 금액 (2행 2열)
                  // 연한 배경 카드로 묶음 (캘린더는 거래 목록 탭으로 옮김)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
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
                            Expanded(
                              child: _buildSummaryRow('저축', totalSaving, Colors.green),
                            ),
                            SizedBox(width: 24),
                            Expanded(
                              child: _buildSummaryRow('투자', totalInvest, Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // 일일 예산: 오늘 남은 돈 + 하루 추천 금액
                  _buildDailyBudget(),
                  SizedBox(height: 20),

                  // 예산 봉투: 카테고리마다 카드 하나 (남은 돈, 남은 비율)
                  if (budgetCategories.isNotEmpty) ...[
                    Text(
                      '예산 봉투',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    for (final category in budgetCategories)
                      BudgetCard(
                        key: ValueKey(category.categoryId),
                        name: category.name,
                        remaining: category.remaining,
                        budget: category.budget,
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 일일 예산 카드: 오늘 남은 돈 + 하루 추천 금액
  // - 오늘 남은 돈: 오늘 추천 - 오늘 쓴 돈. 이번 달(로컬 모드)일 때만 보임, 넘게 쓰면 빨간색
  // - 하루 추천 금액: 내일부터 남은 날에 하루씩 쓸 수 있는 금액. 오늘 넘게 쓰면 그만큼 줄어듦
  // - null(지난달이거나 비율 없음)이면 안내 문구 (0원은 "쓸 돈 없음"으로 오해할 수 있음)
  // - 누르면 오늘 거래 목록으로 이동
  Widget _buildDailyBudget() {
    final now = DateTime.now();
    final isThisMonth = _focusedDay.year == now.year && _focusedDay.month == now.month;
    final hasToday = isThisMonth && todayRemaining != null && todayBudget != null;
    final over = (todayRemaining ?? 0) < 0;

    final perDayText = Text(
      dailyBudget == null ? '-' : formatWon(dailyBudget!),
      style: TextStyle(
        fontSize: hasToday ? 16 : 26, // 오늘 남은 돈이 있으면 그쪽을 크게
        fontWeight: FontWeight.bold,
        color: hasToday ? Colors.black87 : primaryColor,
      ),
    );

    return GestureDetector(
      onTap: isThisMonth ? () => widget.onDateSelected?.call(now) : null,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasToday) ...[
              // 오늘 남은 돈 (크게)
              Text('오늘 남은 돈', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              SizedBox(height: 4),
              Text(
                over ? '초과 ${formatWon(-todayRemaining!)}' : formatWon(todayRemaining!),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: over ? Colors.red : primaryColor,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '오늘 추천 ${formatWon(todayBudget!)} − 오늘 쓴 돈 ${formatWon(todaySpent!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: primaryColor.withValues(alpha: 0.12)),
              ),
              // 하루 추천 금액 (내일부터 남은 날, 작게 한 줄)
              Row(
                children: [
                  Text(
                    '내일 추천 금액',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  Spacer(),
                  if (dailyBudget != null) perDayText,
                ],
              ),
              SizedBox(height: 2),
              Text(
                dailyBudget == null ? '오늘이 이달 마지막 날이에요' : '내일부터 하루에 이만큼씩 쓰면 예산에 맞아요',
                style: TextStyle(
                  fontSize: 11,
                  color: over ? Colors.red[300] : Colors.grey[500],
                ),
              ),
            ] else ...[
              // 이번 달이 아니거나(다음 달 이후) 오늘 값이 없는 경우: 하루 추천 금액만 크게
              Text('하루 추천 금액', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              SizedBox(height: 4),
              perDayText,
              if (dailyBudget == null) ...[
                SizedBox(height: 6),
                Text(
                  '지난 달이거나 예산 비율이 없어서 추천하지 않아요.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
