# Moa

월 수입을 비율로 나누어 예산을 관리하는 가계부 앱입니다.
수입을 입력하면 설정한 비율대로 카테고리별 예산이 계산되고, 저축·투자는 자동으로 분리됩니다.

> 상태: 개발 중. 진행 상황은 [TODO.md](./TODO.md) 참고.

## 기술 스택

| 영역 | 사용 기술 |
|---|---|
| 앱 | Flutter (iOS / Android) |
| 서버 | Spring Boot 4.1, Java 21, Gradle (Kotlin DSL) |
| 인증 | Spring Security, JWT (jjwt 0.12), BCrypt |
| DB | MySQL 8.4, Spring Data JPA (Hibernate) |
| 배포 | Railway (예정) |

## 폴더 구조

```
moa/
├── flutter/   # 모바일 앱 (package: com.binsu.moa)
├── server/    # Spring Boot 서버 (package: com.binchae.moa)
└── TODO.md    # 진행 체크리스트
```

서버 패키지 구성 (`server/src/main/java/com/binchae/moa/`):

```
config/      SecurityConfig, JwtProvider, JwtAuthFilter
controller/  AuthController, UserController, CategoryController, BudgetRatioController
service/     AuthService, UserService, BudgetCategoryService, BudgetRatioService
repository/  User / BudgetCategory / BudgetRatio / Transaction
entity/      User, BudgetCategory, BudgetRatio, Transaction
dto/         요청·응답 객체
exception/   ApiException, GlobalExceptionHandler
```

## 서버 실행 방법

### 1. 요구 사항
- Java 21
- MySQL 8.4 (macOS: `brew install mysql@8.4`)

### 2. DB 준비
```bash
brew services start mysql@8.4
mysql -u root -e "CREATE DATABASE IF NOT EXISTS moa DEFAULT CHARACTER SET utf8mb4;"
```
소켓 에러가 나면 `mysqld_safe --user=$(whoami) &` 로 직접 실행합니다.

### 3. 비밀 설정 파일 만들기
`jwt.secret`은 git에 올리지 않습니다. 아래 파일을 직접 만들어야 서버가 시작됩니다.

`server/src/main/resources/application-local.properties`
```properties
# 32바이트 이상의 랜덤 문자열
jwt.secret=여기에_긴_랜덤_문자열
```
`application.properties`의 `spring.profiles.active=local` 설정으로 이 파일이 자동으로 합쳐집니다.
DB 비밀번호를 설정했다면 `spring.datasource.password=...` 도 여기에 넣습니다.

### 4. 실행
```bash
cd server
./gradlew bootRun
```
확인: 아래 [API](#api-현재-구현)의 회원가입 curl 예시로 응답이 오는지 확인합니다.

## 앱 실행 방법

```bash
cd flutter
```

에뮬레이터(시뮬레이터)를 띄운 뒤 `flutter run` 을 실행합니다.

```bash
# Windows
flutter emulators --launch Pixel_8
flutter run

# Mac
open -a simulator
flutter run
```

## API (현재 구현)

| 메서드 | 경로 | 설명 | 인증 |
|---|---|---|---|
| POST | `/api/auth/signup` | 회원가입 | 불필요 |
| POST | `/api/auth/login` | 로그인, JWT 발급 | 불필요 |
| DELETE | `/api/users/me` | 회원 탈퇴 (본문 `{"password": "..."}`) | 필요 |
| GET | `/api/categories` | 카테고리 목록 (삭제 제외, 순서대로) | 필요 |
| POST | `/api/categories` | 카테고리 추가 | 필요 |
| PUT | `/api/categories/{id}` | 카테고리 수정 (이름, 홈 표시, 일일 포함) | 필요 |
| DELETE | `/api/categories/{id}` | 카테고리 소프트 삭제 | 필요 |
| GET | `/api/budget-ratios?month=YYYY-MM` | 해당 월에 적용되는 예산 비율 조회 | 필요 |
| PUT | `/api/budget-ratios` | 예산 비율 저장 (적용 시작 월 지정, 합계 100) | 필요 |

인증이 필요한 요청은 헤더에 `Authorization: Bearer <토큰>` 을 붙입니다.
에러 응답은 `{"message": "..."}` 형태로 통일합니다 (400 / 401 / 404 / 409).

예시:
```bash
curl -X POST http://localhost:8080/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"123456"}'
```

## DB 설계

```
users               (id, email, password, created_at)
budget_categories   (id, user_id, name, order_index, include_in_daily,
                     show_on_home, is_deleted, created_at)
budget_ratios       (id, user_id, budget_category_id, ratio, apply_from,
                     saving_ratio, invest_ratio, created_at)
transactions        (id, user_id, title, amount, type, category,
                     budget_category_id, date, memo, created_at, updated_at)
```

```
users 1 ──< budget_categories 1 ──< budget_ratios
users 1 ──< transactions >── 0..1 budget_categories
```

## 설계 결정

- **예산 금액은 저장하지 않고 조회할 때 계산합니다.** `수입 × 비율`로 계산하므로 수입이 바뀌어도 데이터가 어긋나지 않습니다.
- **비율에 적용 시작 월(`apply_from`)을 둡니다.** 비율을 바꿔도 지난 달 예산은 그대로 유지됩니다.
- **카테고리는 소프트 삭제(`is_deleted`)합니다.** 지운 카테고리의 과거 거래 내역이 깨지지 않습니다.
- **카테고리는 이름이 아니라 ID로 참조합니다.** 이름을 바꿔도 거래와의 연결이 유지됩니다.
- **저축·투자는 예산 카테고리가 아니라 별도 비율입니다.** 수입 입력 시 저축·투자 거래가 자동으로 생성됩니다.
- **세션 대신 JWT(STATELESS)를 씁니다.** 서버가 로그인 상태를 저장하지 않아 모바일 앱과 확장에 적합합니다.
- **로그인 실패 메시지를 하나로 통일합니다.** 이메일 존재 여부를 알아내는 공격을 줄입니다.
- **`order`는 SQL 예약어라 `order_index`로 지었습니다.**

## 로드맵

- [x] 인증 (회원가입, 로그인, JWT)
- [ ] 카테고리 / 예산 비율 / 거래 / 홈 API
- [ ] Flutter 앱을 Firebase에서 이 서버로 전환
- [ ] Railway 배포
- [ ] 핵심 Service 테스트

자세한 항목은 [TODO.md](./TODO.md) 에 있습니다.
