// [역할] 화면에 보여 줄 금액·날짜 문자열 만들기 (여러 화면에 흩어져 있던 정규식 포맷을 한 곳으로)

// 1234567 → "1,234,567"
String formatNumber(int n) {
  final digits = n.abs().toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'), // 뒤에 숫자가 3개씩 남는 자리마다 쉼표
    (m) => '${m[1]},',
  );
  return n < 0 ? '-$digits' : digits;
}

// 1234567 → "1,234,567원"
String formatWon(int n) => '${formatNumber(n)}원';

// 부호를 붙인 금액: +1,000원 / -1,000원 / 0원
String formatSignedWon(int n) => n > 0 ? '+${formatWon(n)}' : formatWon(n);
