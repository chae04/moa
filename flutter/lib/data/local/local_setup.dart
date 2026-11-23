// [역할] 로컬 모드의 "첫 실행 설정" (서버 모드의 회원가입 + 기본 카테고리 + 첫 비율에 해당)
// - 로그인이 없으므로 가입 대신, 처음 앱을 열면 기본 카테고리와 비율을 저장한다.
// - 서버 AuthService.signUp처럼 하나의 트랜잭션: 중간에 실패하면 아무것도 저장되지 않음 → 다시 시도 가능

import 'package:drift/drift.dart';
import 'package:moa/data/app_exception.dart';
import 'package:moa/data/local/app_database.dart';

// 첫 실행 때 만들 카테고리 하나 (서버 SignUpRequest.CategoryItem과 같은 모양)
typedef InitialCategory = ({String name, bool includeInDaily, int ratio});

class LocalSetup {
  static const int _maxShowOnHome = 5;

  final AppDatabase _db;
  LocalSetup(this._db);

  // 설정을 끝냈는지 = 카테고리가 하나라도 있는지 (카테고리는 최소 1개 유지 규칙이 있어서 한 번 만들면 0이 되지 않음)
  Future<bool> isSetUp() async {
    final first = await (_db.select(_db.budgetCategories)..limit(1)).getSingleOrNull();
    return first != null;
  }

  // 기본 카테고리 + 이번 달부터 적용할 비율 저장
  Future<void> createInitial({
    required List<InitialCategory> categories,
    required int savingRatio,
    required int investRatio,
  }) async {
    if (categories.isEmpty) throw const AppException('카테고리를 1개 이상 입력해주세요.');
    for (final c in categories) {
      final name = c.name.trim();
      if (name.isEmpty) throw const AppException('카테고리 이름을 입력해주세요.');
      if (name.length > 10) throw const AppException('카테고리 이름은 10자 이내로 입력해주세요.');
    }
    for (final r in [savingRatio, investRatio, ...categories.map((c) => c.ratio)]) {
      if (r < 0) throw const AppException('비율은 0 이상이어야 합니다.');
      if (r > 100) throw const AppException('비율은 100 이하여야 합니다.');
    }
    final total =
        categories.fold(0, (sum, c) => sum + c.ratio) + savingRatio + investRatio;
    if (total != 100) throw AppException('비율 합계는 100이어야 합니다. 현재: $total');

    final applyFrom = currentMonth();
    await _db.transaction(() async {
      await _db
          .into(_db.ratioSets)
          .insert(
            RatioSetsCompanion.insert(
              applyFrom: applyFrom,
              savingRatio: savingRatio,
              investRatio: investRatio,
            ),
          );
      for (var i = 0; i < categories.length; i++) {
        final c = categories[i];
        final id = await _db
            .into(_db.budgetCategories)
            .insert(
              BudgetCategoriesCompanion.insert(
                name: c.name.trim(),
                orderIndex: i,
                showOnHome: Value(i < _maxShowOnHome), // 앞에서 5개까지만 홈에 표시
                includeInDaily: Value(c.includeInDaily),
              ),
            );
        await _db
            .into(_db.ratioItems)
            .insert(
              RatioItemsCompanion.insert(
                applyFrom: applyFrom,
                categoryId: id,
                ratio: c.ratio,
              ),
            );
      }
    });
  }
}
