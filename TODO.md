# Moa TODO

> 항목을 끝낼 때마다 `[ ]` → `[x]` 로 바꾸기. 한 번에 한 섹션만 진행.

---

## 0. 완료 (Flutter 앱, Firebase 버전)

- [x] 회원가입 / 로그인 / 로그아웃 / 탈퇴(재인증)
- [x] 거래 추가 / 수정 / 삭제 / 조회, 자동 저축
- [x] 예산 비율 설정, 카테고리 커스텀(추가/수정/소프트삭제), 홈 표시 최대 5개
- [x] 홈 캘린더, 일일 추천 예산, 거래 목록, 앱 아이콘

---

## 1. 서버 구축 (Spring Boot + MySQL)

### 1-1. 환경 / 기반

- [x] 모노레포 구조 (`flutter/`, `server/`)
- [x] MySQL 8.4 설치 및 실행
- [x] Entity 4개 (User, BudgetCategory, BudgetRatio, Transaction)
- [x] Repository 4개 (JPQL)
- [x] `ddl-auto`를 `update`로 변경 (데이터 유지)
- [x] 비밀키 분리 (`application-local.properties` + `.gitignore`)
- [x] 서버 코드 git push (비밀키가 안 올라가는지 확인 후)

### 1-2. Auth + JWT + Spring Security

- [x] SecurityConfig (BCrypt, STATELESS, CSRF 해제)
- [x] JwtProvider (토큰 발급 / 검증)
- [x] 회원가입 API
- [x] 이메일 중복 확인 API (`GET /api/auth/check-email`)
- [x] 로그인 API
- [x] 예외 처리 (ApiException, GlobalExceptionHandler: 401/409/400)
- [x] JwtAuthFilter (요청마다 토큰 검증)
- [x] `/me` 로 토큰 동작 확인
- [x] 회원 탈퇴 API (비밀번호 확인 후 연관 데이터 삭제)
- [x] `/me` 임시 코드 정리

### 1-3. 예산 카테고리 API

- [x] CategoryRequest / CategoryResponse DTO
- [x] BudgetCategoryService
- [x] `GET /api/categories` 목록 (삭제 제외, order 순)
- [x] `POST /api/categories` 추가
- [x] `PUT /api/categories/{id}` 수정 (이름, 홈 표시, 일일 포함)
- [x] `DELETE /api/categories/{id}` 소프트 삭제
- [x] 홈 표시 최대 5개 검증
- [x] 최소 1개 유지 검증
- [x] 본인 소유 카테고리만 접근 가능한지 검증

### 1-4. 예산 비율 API

- [x] BudgetRatioService
- [x] `GET /api/budget-ratios?month=2026-10` (해당 월 적용 비율)
- [x] `PUT /api/budget-ratios` (적용 시작 월과 함께 저장)
- [x] 합계 100% 검증 (카테고리 + 저축 + 투자)
- [x] 삭제 예정 카테고리 제외 로직

### 1-5. 거래 API

- [x] TransactionRequest / TransactionResponse DTO
- [x] TransactionService
- [x] `GET /api/transactions?year=&month=` 월별 조회
- [x] `POST /api/transactions` 추가
- [x] `PUT /api/transactions/{id}` 수정 (수입은 금액 수정 불가)
- [x] `DELETE /api/transactions/{id}` 삭제
- [x] 수입 입력 시 저축/투자 자동 거래 생성
- [x] 저축 입력 시 출처 예산 카테고리 차감 처리
- [x] 본인 소유 거래만 접근 가능한지 검증

### 1-6. 홈 / 통계 API

- [x] 홈 요약 API (수입/지출/저축 합계, 카테고리별 사용액/잔액)
- [x] 일일 추천 예산 계산 (includeInDaily 카테고리 잔액 / 남은 일수)
- [x] 통계 API 최소 버전 (월별 합계, 카테고리별 지출)

---

## 2. Flutter: Firebase → HTTP 호출 교체

- [x] 삭제 예정 카테고리: 312번 줄에서 합계 계산에서 뺀 카테고리를 저장 목록에는 그대로 넣습니다. 그래서 저장된 합계가 100을 넘을 수 있습니다. 수정하기.
- [x] `dio` 패키지 추가, API 공통 클라이언트 (baseUrl, 토큰 헤더)
- [x] 토큰 저장 (`flutter_secure_storage`)
- [x] AuthService 교체 (가입 / 로그인 / 로그아웃 / 탈퇴)
  - 마이페이지 이메일: 지금은 `FirebaseAuth.instance.currentUser?.email`로 표시. 전환 후에는 로그인할 때 이메일을 저장해 두거나 서버에 `GET /api/users/me`를 다시 만들어야 함
- [x] 로그인 상태 유지 (토큰 존재 여부로 판단)
- [x] BudgetCategoryService 교체
- [x] BudgetService 교체 (비율)
  - 카테고리 삭제 흐름(`deleteCategoryId`가 있을 때)에서는 적용 시작 월을 이번 달로 고정. 다음 달 이후로 저장하면 이번 달 비율에 그 카테고리가 남아 서버가 삭제를 400으로 막음
- [x] TransactionService 교체
  - 자동 투자: HANDOFF에는 저축·투자가 자동 생성된다고 되어 있지만, Flutter는 저축만 만듭니다. 서버는 HANDOFF 기준으로 둘 다 만듭니다.
  - 자동 저축 비율: Flutter는 savingRatio 필드가 아니라 이름이 저축인 카테고리에서 비율을 찾습니다. 서버는 saving_ratio, invest_ratio를 씁니다.
  - 예산 출처: 336번 줄에서 화면에서 고른 출처 대신 항상 저축 카테고리를 저장합니다. 그 이름의 카테고리가 없으면 예외도 납니다.
  - Flutter 쪽은 HTTP 전환 때 투자도 처리해야 합니다. 놓치면 에러 없이 투자 거래가 합계와 목록 표시에서 조용히 빠집니다.
- [x] 홈화면 데이터 로딩 교체
- [x] 회원가입 흐름 교체 (비율 설정 포함)
- [x] 토큰 만료 시 로그인 화면으로 이동
- [x] 에러 메시지 표시 (서버 `{"message"}` 활용)
- [x] Firebase 의존성 / 설정 파일 제거

---

## 3. 배포 (Railway) — 배포 경험 완료 (2026-11-18)

- [x] 비밀값 환경변수화 (jwt.secret, DB 정보)
- [x] `ddl-auto=none` 또는 `validate` 로 전환
- [x] Railway에 MySQL + 서버 배포 (일단 빨리 띄우기)
- [x] HTTPS 적용 확인 (`http://` → 301로 `https://` 이동, 인증서 자동)
- 기록: 프로젝트 `genuine-encouragement`, 서비스 `server`(Root Directory `/server`, Dockerfile 빌드) + `MySQL`, 도메인 `server-production-6e8aa0bf.up.railway.app`, 메모리 약 584MB (`-Xmx256m` 적용 후)
- 지금은 `railway down`으로 내려 둠 (체험 계정, 결제 수단 없음). 설정·환경변수·도메인·DB 볼륨은 남아 있음
  - 시연할 때 다시 띄우기: `main`에 push하거나 대시보드 `server` → Deploy. MySQL도 다시 배포해야 함
- 실사용은 로컬 저장으로 결정 → 4번. 서버는 4번의 "서버 모드"에서 사용

---

## 4. 로컬 저장 전환 (drift, 로그인 없음)

> 결정 (2026-11-18): B안. 저장소를 인터페이스로 분리하고 **로컬 구현(기본)** + **서버 구현(기존 HTTP 코드)** 두 가지를 둠. 빌드 옵션으로 고름.
> 계산 규칙은 서버 Java 코드를 Dart로 옮김 (서버 코드가 설계도). 로컬 데이터는 폰과 함께 사라지므로 백업 필수.

- [x] drift 패키지 추가, 로컬 DB와 테이블 정의 (카테고리, 비율, 거래. 회원 테이블 없음)
- [ ] Repository 인터페이스 정의 (카테고리, 비율, 거래, 홈)
- [ ] 서버 구현: 기존 `*Service`(HTTP)를 인터페이스 구현으로 정리
- [ ] 로컬 구현: 카테고리 (소프트 삭제, 홈 표시 최대 5개, 최소 1개 유지, 비율 남아 있으면 삭제 막기)
- [ ] 로컬 구현: 비율 (적용 시작 월 묶음, 합계 100, 지난 달 변경 불가)
- [ ] 로컬 구현: 거래 (수입 시 저축·투자 자동 생성, 수입 삭제 시 같이 삭제, 날짜 이동, 유형 변경·수입 금액 변경·자동 거래 수정 불가)
- [ ] 로컬 구현: 홈 집계 (카테고리 합집합, 예산 = 수입 × 비율, 사용액은 자동 거래 제외, 일일 추천 예산)
- [ ] 모드 선택: 기본 로컬, `--dart-define=MODE=remote`면 서버 모드 (서버 모드의 baseUrl·로그인·401 처리는 지금 코드 그대로)
- [ ] 로컬 모드 첫 실행: 로그인·가입 대신 기본 카테고리 + 비율 설정 화면. 마이페이지의 로그아웃·탈퇴 숨김
- [ ] 백업: 데이터 파일 내보내기 / 가져오기 (JSON)
- [ ] 내 폰에 설치해서 실사용 (릴리스 빌드)
- [ ] (서버 모드) Flutter baseUrl을 배포 주소로 변경, 실기기 테스트 — 시연이 필요할 때

---

## 5. 마무리

- [ ] README 정리 (구조, 실행 방법, ERD, 설계 결정 이유)
- [ ] 핵심 Service 테스트 (회원가입 중복, 비율 합계 검증, 일일 예산 계산, 월별 비율 적용)
- [ ] 출시 전 보안 / 서버 / DB 점검
- [ ] `findUser` 중복 정리: 같은 메서드가 Service 6개(UserService는 2곳)에 복사되어 있음. 탈퇴 토큰 404→401 변경 때 7곳을 고쳐야 했음
  - 예: `UserRepository`에 `default User getByIdOrThrow(Long id)` 추가, 또는 공통 컴포넌트로 분리

---

## 6. 앱 버그 / 개선

> 4번 이후로는 로컬 구현 기준으로 진행. 아래 항목의 "서버" 부분은 서버 모드도 맞출 때만.

- [ ] 로그인하려다 회원가입 하고 돌아오면 로그인 입력칸 리셋
- [ ] 지출의 예산 출처에 저축·투자 추가 (모아 둔 돈에서 꺼내 쓰기) — Flutter 전환 끝난 뒤 진행
  - 결정: A안(출처에 추가), 지출만 허용. 저축·투자 유형의 출처는 지금처럼 카테고리만
  - 서버: 거래에 `source_type`(카테고리/저축/투자) 칸 추가, `budget_category_id`는 nullable로. 출처 검증(지출만 저축·투자 허용)
  - 홈: 출처가 저축·투자인 지출은 카테고리 사용액에서 제외. 홈 "저축" 합계에서 뺄지 결정 필요 (지난달에 모은 돈을 꺼내면 이번 달 저축이 음수가 될 수 있음)
  - 통계: 카테고리별 지출에는 그대로 포함(거래의 category 기준). 1년 추이 "모은 돈"(수입 − 지출)에서는 어떻게 볼지 결정 필요
  - Flutter: 지출의 예산 카테고리 드롭다운에 저축·투자 항목 추가, 목록·상세에 출처 표시
- [ ] 통계 화면
  - 탭 2개: 카테고리별 지출(기본 탭), 1년 추이
  - 카테고리별 지출: 원형 그래프, 가운데에 총지출, 아래 목록에 카테고리별 비율(%)과 금액 (큰 순). 월 이동은 홈과 같은 `<  2026년 11월  >`
  - 1년 추이: x축 1~12월, 막대 = 수입 − 지출 (양수 파란색 위, 음수 빨간색 아래). 연도 이동 `<  2026년  >`
  - 1년 추이 상단에 "올해 모은 돈" 크게 (+ 파란색, − 빨간색), 아래에 "총수입 − 총지출" 설명 줄
  - 이름은 "모은 돈" (홈의 "저축" = 저축 유형 합계와 구분)
  - 막대 누르면 `_focusedDay`를 그 달로 바꾸고 거래 목록 탭으로 이동 (홈 달력 날짜 누르기와 같은 방식). 미래 달은 이동 안 함
  - 하단 탭에 통계 추가 시 `_currentIndex` 번호가 바뀌는 것 주의
  - API: `GET /api/stats/categories?year=&month=`, `GET /api/stats/yearly?year=`
- [ ] 지출/수입 카테고리 추가·수정·삭제 기능 (지금은 `constants/categories.dart`에 고정. 서버 테이블·API·소프트 삭제 필요, 통계는 계속 거래의 `category` 문자열로 집계)
- [ ] UI 개선 (현금생활 느낌, 직관적이고 예쁘게)

---

## 7. v2로 미룸

- 남은 기간 잔액 분배 추천
- 연간 저축률
- 거래 상세보기 화면 고도화
- 플레이스토어 / 앱스토어 등록
- 예산 없을 때 안내 문구
- 로그인 시도 제한, 비밀번호 정책 강화
- 비율 테이블 정규화: 지금은 `budget_ratios` 한 테이블에 저축·투자 비율(묶음 단위 값)을 카테고리 행마다 반복 저장 (비정규화)
  - 이유: 저축·투자는 카테고리가 아니라 `budget_category_id`(NOT NULL FK)를 가질 수 없어서 열로 둠
  - 지금 불일치가 안 생기는 이유: 저장할 때 묶음 전체를 지우고 다시 넣음 (`deleteByUserAndApplyFrom` + `saveAll`)
  - 숨은 제약: 카테고리가 0개면 저축·투자 비율을 저장할 곳이 없음 (그래서 요청 DTO에 `@NotEmpty`)
  - 개선안: `budget_ratio_sets(user_id, apply_from, saving_ratio, invest_ratio)` + `budget_ratio_items(set_id, budget_category_id, ratio)`로 분리
  - 수정 범위: 엔티티 2개, Repository JPQL, BudgetRatioService, HomeService·StatsService의 비율 조회, 기존 데이터 이전

---

## 학습 방식 메모

- 코드와 명령어에는 설명을 붙인다.
- 완성 코드를 받고 → 비슷한 기능은 직접 만들고 → 끝나면 흐름을 한국어로 설명해본다.

## 하루 시작 전 체크

- `brew services list` 에서 `mysql@8.4` 가 `started` 인지
- 소켓 에러: `mysqld_safe --user=$(whoami) &`
- 서버 실행: `cd server && ./gradlew bootRun`
