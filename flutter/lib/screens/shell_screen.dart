import 'package:flutter/material.dart';
import 'package:moa/constants/colors.dart';
import 'package:moa/screens/home/home_screen.dart';
import 'package:moa/screens/transaction/transaction_list_screen.dart';
import 'package:moa/screens/mypage/mypage_screen.dart';
import 'package:moa/screens/stats/stats_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  // 탭 번호: 0 거래 목록, 1 홈(기본), 2 통계, 3 마이페이지
  int _currentIndex = 1; // default : home (index 1)
  DateTime _focusedDay = DateTime.now(); // 현재 보고있는 year, month 저장
  DateTime _selectedDate = DateTime.now();
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _buildScreens();
  }

  void _buildScreens() {
    _screens = [
      TransactionListScreen(
        key: ValueKey(_focusedDay),
        year: _focusedDay.year,
        month: _focusedDay.month,
        selectedDate: _selectedDate,
        onChanged: (year, month) {
          setState(() {
            _focusedDay = DateTime(year, month);
            _buildScreens();
          });
        },
      ),
      HomeScreen(
        key: ValueKey(_focusedDay),
        focusedDay: _focusedDay,
        onFocusedDayChanged: (day) {
          setState(() {
            _focusedDay = day;
            _buildScreens(); // year,month 바뀌면 screens 재생성
          });
        },
        onDateSelected: (date) {
          setState(() {
            _selectedDate = date;
            _currentIndex = 0; // 거래목록 탭으로 이동
            _buildScreens();
          });
        },
      ),
      StatsScreen(
        key: ValueKey(_focusedDay),
        focusedDay: _focusedDay,
        // 1년 추이 막대를 누르면 그 달로 바꾸고 거래 목록 탭으로 (홈 달력 날짜 누르기와 같은 방식)
        onMonthSelected: (month) {
          final now = DateTime.now();
          final isThisMonth = month.year == now.year && month.month == now.month;
          setState(() {
            _focusedDay = month;
            _selectedDate = isThisMonth ? now : month; // 이번 달이면 오늘, 아니면 그 달 1일
            _currentIndex = 0; // 거래목록 탭으로 이동
            _buildScreens();
          });
        },
      ),
      MypageScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 탭이 4개 이상이면 기본이 shifting(배경색 바뀜·라벨 숨김)이라 고정
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) {
            // 현재 위치랑 같은 탭 누르면 '오늘' 날짜로 이동
            setState(() {
              _focusedDay = DateTime.now();
              _selectedDate = DateTime.now();
              _buildScreens();
            });
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        selectedItemColor: primaryColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '거래 목록'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart_outline), label: '통계'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }
}
