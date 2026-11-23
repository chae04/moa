// [역할] 한 달 달력 (날짜마다 그날 지출 합계 표시). 예전 홈 화면의 캘린더를 거래 목록에서 쓰려고 옮긴 것
// - 오늘은 진한 동그라미, 선택한 날은 연한 동그라미
// - 날짜를 누르면 onDaySelected, 달을 넘기면 onPageChanged

import 'package:flutter/material.dart';
import 'package:moa/constants/colors.dart';
import 'package:moa/utils/format.dart';
import 'package:table_calendar/table_calendar.dart';

class MonthCalendar extends StatelessWidget {
  final DateTime focusedDay; // 보여 줄 달
  final DateTime selectedDay; // 선택한 날
  final Map<DateTime, int> dailyExpense; // 날짜(그날 0시) → 지출 합계
  final void Function(DateTime day) onDaySelected;
  final void Function(DateTime focusedDay) onPageChanged;

  const MonthCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.dailyExpense,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
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
          border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
        ),
      ),

      focusedDay: focusedDay,
      onPageChanged: onPageChanged, // 달을 넘기면 화면이 그 달 거래를 다시 읽음
      // 선택한 날 표시 + 누르면 그날 거래 목록
      selectedDayPredicate: (day) => isSameDay(day, selectedDay),
      onDaySelected: (selected, focused) => onDaySelected(selected),
      calendarBuilders: CalendarBuilders(
        dowBuilder: (context, day) {
          final text = ['일', '월', '화', '수', '목', '금', '토'][day.weekday % 7];
          Color color = Colors.grey[600]!;
          if (day.weekday == DateTime.sunday) color = Colors.red[300]!;
          if (day.weekday == DateTime.saturday) color = Colors.blue[300]!;
          return Center(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
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
                  decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
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
                    '-${formatNumber(amount)}',
                    style: TextStyle(fontSize: 9, color: Colors.red),
                  ),
              ],
            ),
          );
        },

        // 선택한 날: 오늘과 같은 모양, 색만 연하게
        selectedBuilder: (context, day, focusedDay) {
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
                    color: primaryColor.withValues(alpha: 0.45),
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
                    '-${formatNumber(amount)}',
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
                    '-${formatNumber(amount)}',
                    style: TextStyle(fontSize: 9, color: Colors.red),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
