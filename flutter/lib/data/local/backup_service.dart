// [역할] 로컬 데이터 백업: 모든 테이블을 JSON 문자열로 내보내고, JSON에서 통째로 되살린다.
// - 로컬 DB는 폰 안에만 있어서 폰을 잃어버리거나 앱을 지우면 사라진다 → 주기적으로 파일로 내보내 두는 용도
// - 파일 저장·공유·선택 같은 화면 작업은 마이페이지가 하고, 이 클래스는 "DB ↔ JSON 문자열"만 담당 (테스트하기 쉽게)
// - id를 그대로 보존해서 되살림 → 거래의 출처(budgetCategoryId)와 자동 거래 연결(sourceTransactionId)이 유지됨

import 'dart:convert';

import 'package:moa/data/app_exception.dart';
import 'package:moa/data/local/app_database.dart';

class BackupService {
  // JSON 구조가 바뀌면 올리고, 가져오기에서 버전별로 처리
  // 1: 카테고리, 비율, 거래 / 2: + 수입·지출 카테고리(entryCategories), 거래.fundSource
  static const int formatVersion = 2;

  final AppDatabase _db;
  BackupService(this._db);

  // 전체 데이터 → JSON 문자열
  // toJson(): drift가 행마다 만들어 준 변환 함수 (DateTime은 밀리초 숫자로 저장됨)
  Future<String> exportJson() async {
    final data = {
      'app': 'moa',
      'version': formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'categories': (await _db.select(_db.budgetCategories).get())
          .map((r) => r.toJson())
          .toList(),
      'ratioSets': (await _db.select(_db.ratioSets).get())
          .map((r) => r.toJson())
          .toList(),
      'ratioItems': (await _db.select(_db.ratioItems).get())
          .map((r) => r.toJson())
          .toList(),
      'transactions': (await _db.select(_db.transactions).get())
          .map((r) => r.toJson())
          .toList(),
      'entryCategories': (await _db.select(_db.entryCategories).get())
          .map((r) => r.toJson())
          .toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data); // 사람이 열어 봐도 읽히게 들여쓰기
  }

  // JSON 문자열 → 지금 데이터를 전부 지우고 백업 내용으로 교체
  // - 하나의 트랜잭션: 파일이 깨져서 중간에 실패하면 원래 데이터가 그대로 남음
  Future<void> importJson(String json) async {
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      throw const AppException('백업 파일을 읽을 수 없어요.');
    }
    if (data['app'] != 'moa' || data['version'] is! int) {
      throw const AppException('Moa 백업 파일이 아니에요.');
    }
    if ((data['version'] as int) > formatVersion) {
      throw const AppException('더 새 버전의 앱에서 만든 백업이에요. 앱을 업데이트해주세요.');
    }

    List<Map<String, dynamic>> list(String key) =>
        ((data[key] as List?) ?? const []).cast<Map<String, dynamic>>();

    try {
      final categories = list('categories').map(CategoryRow.fromJson).toList();
      final sets = list('ratioSets').map(RatioSetRow.fromJson).toList();
      final items = list('ratioItems').map(RatioItemRow.fromJson).toList();
      final transactions = list('transactions').map(TransactionRow.fromJson).toList()
        // 원본 수입을 자동 거래보다 먼저 넣어야 외래키(source_transaction_id)가 통과함
        ..sort(
          (a, b) => (a.sourceTransactionId == null ? 0 : 1).compareTo(
            b.sourceTransactionId == null ? 0 : 1,
          ),
        );
      // v1 백업에는 수입·지출 카테고리가 없음 → 그때는 지금 기기의 목록을 그대로 둠
      final hasEntryCategories = data.containsKey('entryCategories');
      final entryCategories = list(
        'entryCategories',
      ).map(EntryCategoryRow.fromJson).toList();

      await _db.transaction(() async {
        // 지우는 순서: 다른 테이블을 가리키는 쪽부터 (거래 → 비율 항목 → 묶음 → 카테고리)
        await _db.delete(_db.transactions).go();
        await _db.delete(_db.ratioItems).go();
        await _db.delete(_db.ratioSets).go();
        await _db.delete(_db.budgetCategories).go();
        if (hasEntryCategories) await _db.delete(_db.entryCategories).go();

        // 넣는 순서: 가리켜지는 쪽부터
        for (final r in categories) {
          await _db.into(_db.budgetCategories).insert(r);
        }
        for (final r in sets) {
          await _db.into(_db.ratioSets).insert(r);
        }
        for (final r in items) {
          await _db.into(_db.ratioItems).insert(r);
        }
        for (final r in transactions) {
          await _db.into(_db.transactions).insert(r);
        }
        for (final r in entryCategories) {
          await _db.into(_db.entryCategories).insert(r);
        }
      });
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('백업 파일 내용이 올바르지 않아요.');
    }
  }
}
