// [역할] 모드(app_mode.dart)에 맞는 Repository 구현을 골라서 앱 전체에 하나씩 나눠 주는 곳
// - 화면은 AppRepositories.categories처럼 가져다 쓰기만 하고, 로컬인지 서버인지 모른다.
// - Spring에서 @Bean/@Service를 컨테이너가 골라 주입해 주는 역할을 손으로 하는 것 (간단한 서비스 로케이터)
// - static final: 처음 접근할 때 한 번 만들어지고 앱이 끝날 때까지 같은 객체 (DB 연결도 하나만 열림)

import 'package:moa/app_mode.dart';
import 'package:moa/data/local/app_database.dart';
import 'package:moa/data/local/backup_service.dart';
import 'package:moa/data/local/local_category_repository.dart';
import 'package:moa/data/local/local_entry_category_repository.dart';
import 'package:moa/data/local/local_home_repository.dart';
import 'package:moa/data/local/local_ratio_repository.dart';
import 'package:moa/data/local/local_setup.dart';
import 'package:moa/data/local/local_stats_repository.dart';
import 'package:moa/data/local/local_transaction_repository.dart';
import 'package:moa/data/repositories.dart';
import 'package:moa/services/budget_category_service.dart';
import 'package:moa/services/budget_service.dart';
import 'package:moa/services/fixed_entry_category_service.dart';
import 'package:moa/services/home_service.dart';
import 'package:moa/services/stats_service.dart';
import 'package:moa/services/transaction_service.dart';

class AppRepositories {
  AppRepositories._(); // static으로만 사용

  // 로컬 DB는 로컬 모드에서만 연다 (서버 모드에서는 폰에 DB 파일을 만들지 않음)
  static final AppDatabase? _db = isLocalMode ? AppDatabase() : null;
  static AppDatabase get _localDb => _db!;

  static final LocalTransactionRepository? _localTransactions = isLocalMode
      ? LocalTransactionRepository(_localDb)
      : null;

  static final CategoryRepository categories = isLocalMode
      ? LocalCategoryRepository(_localDb)
      : BudgetCategoryService();

  static final RatioRepository ratios = isLocalMode
      ? LocalRatioRepository(_localDb)
      : BudgetService();

  static final TransactionRepository transactions = isLocalMode
      ? _localTransactions!
      : TransactionService();

  static final HomeRepository home = isLocalMode
      ? LocalHomeRepository(_localDb, _localTransactions!)
      : HomeService();

  static final StatsRepository stats = isLocalMode
      ? LocalStatsRepository(_localDb)
      : StatsService();

  // 수입·지출 카테고리: 로컬은 DB에서 관리, 서버는 고정 목록
  static final EntryCategoryRepository entryCategories = isLocalMode
      ? LocalEntryCategoryRepository(_localDb)
      : FixedEntryCategoryService();

  // ---- 로컬 모드 전용 (서버 모드에서 부르면 에러: 화면이 isLocalMode로 먼저 확인해야 함) ----

  static LocalSetup get setup => LocalSetup(_localDb); // 첫 실행 설정
  static BackupService get backup => BackupService(_localDb); // 백업 내보내기·가져오기
}
