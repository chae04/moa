import 'package:flutter/material.dart';
import 'package:moa/constants/colors.dart';
import 'package:moa/screens/home/home_screen.dart';
import 'package:moa/screens/transaction/transaction_list_screen.dart';
import 'package:moa/screens/mypage/mypage_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 1; // default : home (index 1)
  DateTime _focusedDay = DateTime.now(); // 현재 보고있는 year, month 저장
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
          print('월 바뀜: ${day.year}-${day.month}');
          setState(() {
            _focusedDay = day;
            _buildScreens(); // year,month 바뀌면 screens 재생성
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
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: primaryColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '거래 목록'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }
}
