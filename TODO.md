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
- [x] 로그인 API
- [x] 예외 처리 (ApiException, GlobalExceptionHandler: 401/409/400)
- [x] JwtAuthFilter (요청마다 토큰 검증)
- [x] `/me` 로 토큰 동작 확인
- [ ] 회원 탈퇴 API (비밀번호 확인 후 연관 데이터 삭제)
- [ ] `/me` 임시 코드 정리

### 1-3. 예산 카테고리 API
- [ ] CategoryRequest / CategoryResponse DTO
- [ ] BudgetCategoryService
- [ ] `GET /api/categories` 목록 (삭제 제외, order 순)
- [ ] `POST /api/categories` 추가
- [ ] `PUT /api/categories/{id}` 수정 (이름, 홈 표시, 일일 포함)
- [ ] `DELETE /api/categories/{id}` 소프트 삭제
- [ ] 홈 표시 최대 5개 검증
- [ ] 최소 1개 유지 검증
- [ ] 본인 소유 카테고리만 접근 가능한지 검증

### 1-4. 예산 비율 API
- [ ] BudgetRatioService
- [ ] `GET /api/budget-ratios?month=2026-10` (해당 월 적용 비율)
- [ ] `PUT /api/budget-ratios` (적용 시작 월과 함께 저장)
- [ ] 합계 100% 검증 (카테고리 + 저축 + 투자)
- [ ] 삭제 예정 카테고리 제외 로직

### 1-5. 거래 API
- [ ] TransactionRequest / TransactionResponse DTO
- [ ] TransactionService
- [ ] `GET /api/transactions?year=&month=` 월별 조회
- [ ] `POST /api/transactions` 추가
- [ ] `PUT /api/transactions/{id}` 수정 (수입은 금액 수정 불가)
- [ ] `DELETE /api/transactions/{id}` 삭제
- [ ] 수입 입력 시 저축/투자 자동 거래 생성
- [ ] 저축 입력 시 출처 예산 카테고리 차감 처리
- [ ] 본인 소유 거래만 접근 가능한지 검증

### 1-6. 홈 / 통계 API
- [ ] 홈 요약 API (수입/지출/저축 합계, 카테고리별 사용액/잔액)
- [ ] 일일 추천 예산 계산 (includeInDaily 카테고리 잔액 / 남은 일수)
- [ ] 통계 API 최소 버전 (월별 합계, 카테고리별 지출)

---

## 2. Flutter: Firebase → HTTP 호출 교체

- [ ] `dio` 패키지 추가, API 공통 클라이언트 (baseUrl, 토큰 헤더)
- [ ] 토큰 저장 (`flutter_secure_storage`)
- [ ] AuthService 교체 (가입 / 로그인 / 로그아웃 / 탈퇴)
- [ ] 로그인 상태 유지 (토큰 존재 여부로 판단)
- [ ] BudgetCategoryService 교체
- [ ] BudgetService 교체 (비율)
- [ ] TransactionService 교체
- [ ] 홈화면 데이터 로딩 교체
- [ ] 회원가입 흐름 교체 (비율 설정 포함)
- [ ] 토큰 만료 시 로그인 화면으로 이동
- [ ] 에러 메시지 표시 (서버 `{"message"}` 활용)
- [ ] Firebase 의존성 / 설정 파일 제거

---

## 3. 배포 (Railway)

- [ ] 비밀값 환경변수화 (jwt.secret, DB 정보)
- [ ] `ddl-auto=none` 또는 `validate` 로 전환
- [ ] Railway에 MySQL + 서버 배포 (일단 빨리 띄우기)
- [ ] Flutter baseUrl을 배포 주소로 변경, 실기기 테스트
- [ ] HTTPS 적용 확인

---

## 4. 마무리

- [ ] README 정리 (구조, 실행 방법, ERD, 설계 결정 이유)
- [ ] 핵심 Service 테스트 (회원가입 중복, 비율 합계 검증, 일일 예산 계산, 월별 비율 적용)
- [ ] 출시 전 보안 / 서버 / DB 점검

---

## 5. 앱 버그 / 개선

- [ ] 로그인하려다 회원가입 하고 돌아오면 로그인 입력칸 리셋
- [ ] 통계 화면
- [ ] UI 개선 (현금생활 느낌, 직관적이고 예쁘게)

---

## 6. v2로 미룸

- 남은 기간 잔액 분배 추천
- 연간 저축률
- 거래 상세보기 화면 고도화
- 플레이스토어 / 앱스토어 등록
- 예산 없을 때 안내 문구
- 로그인 시도 제한, 비밀번호 정책 강화

---

## 학습 방식 메모

- 코드와 명령어에는 설명을 붙인다.
- 완성 코드를 받고 → 비슷한 기능은 직접 만들고 → 끝나면 흐름을 한국어로 설명해본다.

## 하루 시작 전 체크

- `brew services list` 에서 `mysql@8.4` 가 `started` 인지
- 소켓 에러: `mysqld_safe --user=$(whoami) &`
- 서버 실행: `cd server && ./gradlew bootRun`
