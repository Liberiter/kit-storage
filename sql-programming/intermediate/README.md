---
track: sql-programming
course: intermediate
stage: kit
status: approved
---

# Kit — sql-programming / intermediate

world "책숲 운영 데이터"(온라인 서점 책숲의 운영 기록)와 학습 환경 구축·검증 도구입니다.
코스의 모든 예제·문제는 이 world 위에서 돕니다. 환경은 이 코스의 기준(PostgreSQL 메이저
18, Docker 컨테이너, psql 주력)을 따르며, 0장이 안내하는 **두 경로를 모두 지원합니다**
— 기본 경로(Docker, 0장 0.1절)와 대안 경로(직접 설치, 0장 0.7절). 스크립트는 psql 호출을
`kit_psql.sh` 한 자리에 모아 갈랐고, 같은 `./check_env.sh`·`./entry_check.sh`가 두 경로
모두를 판정합니다. world는 두 경로에서 같습니다 — 데이터도, **정렬 규칙도, 문자 분류도, 세션
시간대(UTC)·오류 메시지 언어(영어)·날짜 표기(`ISO, MDY`)·`to_char`가 읽는 로케일(통화·숫자·
날짜 이름)도** (`./setup.sh`가 데이터베이스 설정으로 못 박고 `./check_env.sh`가 확인합니다 — 단
여러분의 psqlrc가 세션 설정을 바꾸는 경우는 점검 결과에 넣지 않고 알림으로 알립니다, 아래
「실패 안내」). 남은 차이는 아래 「대안 경로의 알려진 차이」에 있습니다.

앞 코스(fundamentals)의 kit과 **나란히 두고 써도 됩니다.** 컨테이너·포트·데이터베이스
이름이 다릅니다 (아래 「앞 코스 kit과 함께 쓰기」).

## World — 온라인 서점 "책숲"의 운영 데이터

앞 코스에서 쓴 책숲 서점이 한 해 더 자란 모습입니다. 고객·도서·주문·주문 항목·리뷰 다섯
테이블은 **앞 코스와 정의도 데이터도 같고**, 그 위에 서점을 운영하면서 쌓이는 기록이
더해졌습니다 — 분류 트리, 직원 조직, 도서 메타(ISBN·태그), 공급사 피드와 공급 현황, 재고
입출고 원장, 그리고 도서 페이지 조회 로그 약 20만 건.

```
                 categories (분류 트리, 자기 참조)
                      ▲ name
customers ──< orders ──< order_items >── books ──< reviews >── customers
   (150)      (620)      (1,243)         (320)     (520)
                                           │
          staff (24, 자기 참조) ──< stock_movements (1,535) >── books
                                           books ──< page_views (199,220) >── customers (NULL 허용)
                                           books ── book_meta (320)   books ── book_supply (196)
                                           supplier_feed (85, 외부 피드 원본 — 외래키 없음)
```

| 테이블 | 행 수 | 역할 · 특징 |
|---|---|---|
| categories | 12 | 분류 트리 3단(전체 > 문학·교양·실용·어린이 > 8개 말단). `parent_id`가 자기 참조 — 재귀 질의 대상. `books.category`가 말단 이름을 참조합니다 |
| customers · books · orders · order_items · reviews | 150 · 320 · 620 · 1,243 · 520 | 앞 코스 책숲 그대로. `reviews.order_id`는 NULL 허용 외래키(구매 인증 300 / 일반 220) |
| staff | 24 | 직원. 대표 1명(`manager_id` NULL) → 팀장 → 매니저·사원. self join·`NOT IN` 함정 재료 |
| book_meta | 320 | ISBN-13(UNIQUE)과 태그 배열(`text[]`, 1~6개) |
| book_supply | 196 | 공급사가 알린 공급가·공급 가능 재고의 최신 상태. 피드를 반복 적재해 갱신하는 UPSERT 대상 |
| supplier_feed | 85 | 공급사 피드를 **받은 그대로**. 두 날짜(8/25·9/1)에 걸쳐 같은 책이 반복 등장(23권), 완전 중복 행 1, 없는 책 번호 1, 음수 가격 1 |
| stock_movements | 1,535 | 재고 입출고 원장(입고 +, 출고 −, 담당 직원). 책마다 합계가 `books.stock`과 같고 누적 잔량은 음수가 되지 않습니다 |
| page_views | 199,220 | 2026-06-01~08-31 도서 페이지 조회 로그. `viewed_at timestamptz`, 방문자 시간대 5종(한국 85%), `context jsonb`(device·referrer·dwell_ms·scroll_pct, 광고 유입만 utm), 비로그인 방문은 `customer_id` NULL(60%). 기본 키 말고 인덱스가 없습니다 — 인덱스를 만드는 것이 11장 실습 |
| legacy.sales_ledger | 207 | **별도 스키마 `legacy`** — 6장 정규화 실습용 비정규 원장. 2025년 주문을 스프레드시트처럼 한 줄에 펼친 것(고객 정보 반복, 도서 1~3 가로 배치, 전 열 글자) |
| antipatterns.* | 4테이블 | **별도 스키마 `antipatterns`** — 8장 진단·교정 대상. 쉼표 목록 태그, EAV, 이메일 기본 키, 전화번호 칸 셋, 다형 연결, 부동소수 금액, 표기가 뒤섞인 상태 값 |

핵심 다섯 테이블의 시드 `seed.sql`과 생성기 `generate_seed.py`는 앞 코스 kit의 파일을
**그대로** 가져왔습니다(주석에 적힌 장 번호는 앞 코스의 것입니다). 운영 테이블은
`seed_ops.sql`이 적재할 때 **결정적으로 생성**합니다 — 행마다 해시로 난수를 만들어,
누가 언제 구축해도 같은 데이터가 나옵니다. 분류 트리와 직원은 `seed_ref.sql`에 손으로
적었습니다.

## 사용법

```bash
./setup.sh          # 컨테이너 기동 + world 적재 + 환경 확인 (처음/재시작)
                    #   성공하면 구축에 쓴 경로를 .kit-mode 에 적습니다 (아래 「구축 경로 기억」)
./check_env.sh      # 환경 확인 (접속·버전·world 속성) — 입장 점검의 1단계
./entry_check.sh    # 입장 점검 = 환경 확인 + 4문 채점 (아래 「입장 점검」)
./reset.sh          # world를 초기 상태로 복원 (public·legacy·antipatterns 세 스키마)
./verify.sh <케이스 디렉토리>            # 예제·문제 자동 검증 (기본 ./cases)
./verify.sh --update <케이스 디렉토리>   # 기대 출력 재생성
./concurrency.sh <시나리오> [격리 수준]  # 12장 동시성 이상 현상 자동 재현 (아래 「동시성 실습」)
```

- psql 접속
  - 기본 경로: `docker exec -it ll-sql-intermediate psql -U postgres -d bookstore_ops`
  - 대안 경로: `psql -d bookstore_ops` (접속 정보는 `PGHOST`·`PGPORT`·`PGUSER`·`PGPASSWORD`로)
- 환경 변수: `KIT_MODE`(docker|native — 지정하지 않으면 `.kit-mode`, 그것도 없으면 docker),
  `KIT_PORT`(기본 54322), `KIT_CONTAINER`(기본 ll-sql-intermediate), `KIT_DB`(기본
  bookstore_ops), `KIT_PSQL`(대안 경로의 psql 실행 파일, 기본 `psql`), `KIT_ADMIN_DB`(대안
  경로에서 `bookstore_ops` 생성 시 붙는 관리용 DB, 기본 `postgres`)
- 공식 문서: https://www.postgresql.org/docs/18/ (psql 사용법: app-psql)

### 앞 코스 kit과 함께 쓰기

| | fundamentals kit | 이 kit |
|---|---|---|
| 컨테이너 이름 | `ll-sql-fundamentals` | `ll-sql-intermediate` |
| 호스트 포트 | 54321 | 54322 |
| 데이터베이스 | `bookstore` | `bookstore_ops` |
| 구축 경로 기억 파일 | 그 kit 디렉토리의 `.kit-mode` | 이 kit 디렉토리의 `.kit-mode` |

두 kit의 스크립트는 서로의 컨테이너·데이터베이스를 건드리지 않습니다. 대안 경로에서 한
서버에 두 코스의 데이터베이스를 함께 두어도 이름이 다르므로 공존합니다. 두 컨테이너를
동시에 띄워도 됩니다(포트가 다릅니다).

### 두 경로 — 기본(Docker) / 대안(직접 설치)

0장의 두 경로(0.1절 기본 경로, 0.7절 대안 경로)를 **같은 스크립트**가 받습니다. 갈리는
것은 psql을 어떻게 부르는가 하나뿐이고, 그 분기는 `kit_psql.sh`의 `kit_psql` 함수 한 곳에
있습니다.

| | 기본 경로 (`KIT_MODE=docker`) | 대안 경로 (`KIT_MODE=native`) |
|---|---|---|
| 전제 | Docker 호환 런타임 | 여러분이 설치한 PostgreSQL 18 + psql |
| psql 호출 | `docker exec -i <컨테이너> psql -U postgres …` | 호스트의 `psql …` |
| 접속 정보 | 컨테이너 이름(`KIT_CONTAINER`) | psql이 원래 읽는 `PGHOST`·`PGPORT`·`PGUSER`·`PGPASSWORD` |
| `./setup.sh` | 컨테이너 생성·기동(`LANG=C.UTF-8`) → DB 생성 → 세션 설정 고정 → 동시성 스크립트 복사 → 적재 → 환경 확인 | 컨테이너 없음. psql·서버 접속·버전 18·`bookstore_ops` DB를 점검(없으면 **정렬 규칙을 고정해** 생성) → 세션 설정 고정 → 적재 → 환경 확인 |
| 경로 지정 | 기본값이므로 지정하지 않아도 됩니다 | **`KIT_MODE=native ./setup.sh` 한 번**. 그 실행이 경로를 `.kit-mode`에 기억하므로 이후 명령에는 붙이지 않아도 됩니다 |
| 정렬 규칙(collation) | 컨테이너 initdb를 `LANG=C.UTF-8`로 못 박아 얻습니다 | `CREATE DATABASE … TEMPLATE template0 LOCALE_PROVIDER builtin BUILTIN_LOCALE 'C.UTF-8'`으로 못 박습니다 |
| 세션 시간대·메시지 언어·날짜 표기·로케일 | 두 경로 같음 — `ALTER DATABASE bookstore_ops SET timezone TO 'UTC'`·`SET lc_messages TO 'C'`·`SET DateStyle TO 'ISO, MDY'`·`SET lc_monetary/lc_numeric/lc_time TO 'C'`를 `./setup.sh`가 적용합니다(다시 실행해도 안전). 여러분이 직접 설치한 서버는 컴퓨터의 시간대(예: Asia/Seoul)와 로케일을 기본값으로 잡는데, 그대로 두면 `timestamptz`가 본문의 `+00`이 아니라 `+09`로 표시되고, 오류 메시지가 한국어로 나오고, `'01/02/2026'` 같은 날짜 입력이 다르게 읽히고, `to_char`의 통화 기호(`L`)·요일 이름(`TM`)이 `₩`·한국어로 나올 수 있어 데이터베이스 설정으로 고정합니다. 여러분의 대화형 psql 세션에도 적용됩니다 | 같음 |
| 문자 분류(LC_CTYPE) | 컨테이너 initdb의 `C.UTF-8` | `CREATE DATABASE … LC_COLLATE 'C' LC_CTYPE 'C'`로 만듭니다(점검이 받아들이는 값은 C 계열 — `C`·`POSIX`·`C.UTF-8`). 이 설정은 만들 때만 정할 수 있어, 다른 값으로 이미 만들어진 `bookstore_ops`는 `dropdb` 뒤 `./setup.sh`로 다시 만들라고 안내합니다. 고정하지 않으면 macOS에서 행 전체를 한 값으로 찍는 출력(`SELECT t FROM t`, `ROW(…)::text`)에서 한글이 `"신아린"`처럼 따옴표로 감싸여 교재와 다르게 보입니다 |
| `./reset.sh` `./check_env.sh` `./entry_check.sh` `./verify.sh` | 동일 | 동일 |
| `./concurrency.sh --terminal` | 컨테이너 안 `/kit/concurrency/`의 스크립트를 실행 | `concurrency/`의 스크립트를 직접 실행 |

대안 경로의 Windows는 **WSL2 배포판(Ubuntu) 안에 Linux와 같은 방법(PGDG 저장소)으로
PostgreSQL 18을 설치**하는 것입니다 — Windows 호스트에 설치한 서버(EDB 인스톨러)는
지원하지 않습니다. kit 스크립트·psql·서버가 모두 같은 WSL2 셸 안에 있으므로 접속 설정도
Linux와 같습니다 (0장 0.7절).

대안 경로 실행 예:

```bash
KIT_MODE=native ./setup.sh       # 서버 점검 + world 적재 (구축 경로를 기억합니다)

# 이후에는 KIT_MODE 없이 그대로 — setup.sh가 적어 둔 .kit-mode 를 따릅니다
./entry_check.sh                 # 같은 입장 점검
./reset.sh                       # 챕터 본문이 맨 명령으로 부르는 자리
./verify.sh ./cases
```

Linux·WSL2(PGDG 패키지)에서는 관리자 `postgres`에 비밀번호가 없고 같은 컴퓨터 접속이
peer 인증이라, 비밀번호를 정한 뒤
(`sudo -u postgres psql -c "ALTER USER postgres PASSWORD '…';"`)
`PGUSER`·`PGPASSWORD`와 함께 **`PGHOST=localhost`를 지정**합니다. 서버 기동은
`sudo systemctl start postgresql`입니다 — 자세한 순서는 0장 0.7절.

#### 구축 경로 기억 — `.kit-mode`

`KIT_MODE`를 지정하지 않았을 때 어느 경로로 도는지는 다음 차례로 정해집니다 (정의는
`kit_psql.sh` 「구축 경로 기억」).

1. **환경 변수 `KIT_MODE`** — 지정하면 언제나 이깁니다 (`KIT_MODE=native ./verify.sh …`).
2. **상태 파일 `kit/.kit-mode`** — `./setup.sh`가 **구축에 성공했을 때** 자기가 쓴 경로
   (`docker` 또는 `native`) 한 줄을 적어 둔 파일입니다. 경로를 바꿔 다시 구축하면
   (`KIT_MODE=native ./setup.sh`) 그때 갱신됩니다.
3. **상태 파일이 없으면 `docker`** — 아직 `./setup.sh`를 돌리지 않았거나 파일을 지운
   경우입니다. 대안 경로로 준비했는데 이 상태라면 `KIT_MODE=native ./setup.sh`를 한 번
   실행하면 됩니다 — 그때까지는 모든 스크립트가 기본 경로로 돌다가 **원인과 다음 행동을
   내고 종료 코드 1로 실패합니다** (`./verify.sh`와 `./concurrency.sh`는 종료 코드 2 — 검증·
   재현 결과가 아니라 실행 오류라는 뜻입니다). 원인 줄은 셋 중 하나입니다 — `docker 명령 없음`,
   `런타임 미실행 …`, `컨테이너(ll-sql-intermediate) 미실행`. 세 경우 모두 다음 행동
   줄에 「대안 경로로 준비하셨다면 `KIT_MODE=native ./setup.sh`를 한 번 실행하세요」가
   함께 적혀 나옵니다.

파일 내용이 `docker`/`native`가 아니면 스크립트가 종료 코드 2로 막고 파일을 지우라고
안내합니다. 이 파일은 **여러분 컴퓨터의 상태 파일이므로** 저장소의 `.gitignore`가
추적에서 뺍니다.

## 입장 점검 — `./entry_check.sh`

이 코스는 앞 코스(fundamentals)를 마친 분을 전제합니다. 입장 점검은 두 단계입니다
(0장 0.5절).

1. **환경 확인** — `./check_env.sh`와 같습니다: psql 접속, 서버 메이저 버전 18, world
   속성(정렬 규칙 + 문자 분류 + 세션 시간대·메시지 언어·날짜 표기·로케일 + 데이터 검사 W1~W16).
2. **네 문항 채점** — `entry/q1.sql` ~ `entry/q4.sql`의 머리 주석에 문항이 있습니다. 그
   아래에 SQL을 적고 `./entry_check.sh`를 실행하면 world 위에서 실행해 기대 결과와
   대조합니다.

| 문항 | 묻는 것 | 미통과 시 돌아가 볼 곳 (fundamentals) |
|---|---|---|
| q1 | 단일 테이블 조회 — 조건·정렬 | 2장·3장·4장 |
| q2 | 조인 | 7장·8장 |
| q3 | 집계 — GROUP BY·평균 | 9장 |
| q4 | 변경 + 트랜잭션 — 주문 한 건을 세 테이블에 걸쳐 기록 | 11장·12장 |

통과 화면은 다음과 같습니다.

```
== 1단계: 환경 확인
환경 확인 통과: PostgreSQL 18.6 (…), world(책숲 운영 데이터) 적재·속성 확인 완료
== 2단계: 네 문항 채점 (entry/q1.sql ~ q4.sql)
PASS q1
PASS q2
PASS q3
PASS q4
----
입장 점검 통과: 환경 확인 + 4문 전량 통과. 1장으로 가셔도 됩니다.
```

틀리면 `FAIL qN`과 함께 기대 결과와 여러분 결과의 차이(`-` 기대, `+` 실제), 그리고
돌아가 볼 장이 나오고 종료 코드 1로 끝납니다. 채점은 psql의 표 출력을 글자 그대로
대조하므로 **문항이 정한 열 이름·열 차례·정렬 차례**를 지켜야 합니다 — 값이 같아도 열
이름이 다르면 다르게 읽습니다. q4는 world를 바꾸므로 채점 전후에 `./reset.sh`가
자동으로 돕니다. 아직 답을 적지 않은 문항은 「아직 답을 적지 않았습니다」로 FAIL입니다.

`./entry_check.sh --reference`는 kit에 든 참조 해답(`entry/reference/`)으로 채점을
돌려 보는 자가 시험입니다 — 기대 결과가 world와 맞는지 확인하는 용도이고 여러분의 답은
보지 않습니다. 참조 해답을 먼저 보면 점검의 뜻이 없어지니, 네 문항을 스스로 풀어 본 뒤에
여세요.

### 실패 안내

`./check_env.sh`(그리고 그것을 먼저 부르는 `./entry_check.sh`)는 실패하면 원인 한 줄과
**다음에 할 일** 한 줄을 함께 냅니다. `./reset.sh`·`./verify.sh`·`./concurrency.sh`의
앞 세 분기도 같은 문구입니다. `./verify.sh`와 `./concurrency.sh`(두 모드 모두)는 「psql 접속
불가」까지 같은 문구로 멈추되 종료 코드가 **2**입니다 — 케이스가 실패했거나 재현이 기대와
달랐다는 뜻(1)이 아니라 실행이 되지 않은 것이기 때문입니다.

| 분기 | 다음에 할 일 |
|---|---|
| `docker` 명령 없음 (기본 경로) | 0장 0.1절대로 런타임 설치. 대안 경로로 준비했다면 `KIT_MODE=native ./setup.sh` |
| 런타임 미실행 (기본 경로) — `docker` 명령은 있지만 런타임 프로그램이 응답하지 않음 | 런타임 프로그램을 켭니다 — Windows는 Docker Desktop을 실행하고 Settings > Resources > WSL Integration에서 Ubuntu가 켜져 있는지 확인 / macOS는 OrbStack 실행 / Linux는 `sudo systemctl start docker` (0장 0.1절). 그 뒤 `./setup.sh` |
| 컨테이너 미실행 (기본 경로) | `./setup.sh` (컴퓨터를 껐다 켠 뒤 흔한 상태 — `setup.sh`가 기존 컨테이너를 다시 시작합니다) |
| `psql` 명령 없음 (대안 경로) | 0장 0.7절대로 PostgreSQL 18 설치. PATH에 없으면 `KIT_PSQL=/설치경로/psql` |
| psql 접속 불가 | 기본 경로: `docker logs ll-sql-intermediate` 확인 후 `./setup.sh` 재실행 / 대안 경로: 서버 기동(macOS Homebrew `brew services start postgresql@18`, Linux·WSL2 `sudo systemctl start postgresql`)과 접속 정보·DB 이름 확인 후 `./setup.sh` |
| 서버 버전이 18.x가 아님 | 기본 경로: `docker rm -f ll-sql-intermediate` 후 `./setup.sh`(postgres:18로 재생성) / 대안 경로: 18 설치 후 `PGPORT` 등으로 접속을 그쪽으로 |
| world 정렬 규칙 불일치 | 기본 경로: `docker rm -f ll-sql-intermediate` 후 `./setup.sh` / 대안 경로: `dropdb bookstore_ops` 후 `./setup.sh`(정렬 규칙을 고정해 재생성). 어느 쪽이든 world는 다시 적재되므로 잃는 것이 없습니다 |
| world 문자 분류 불일치 (LC_CTYPE) | 만들 때 정해지는 설정이라 바꿀 수 없습니다. 기본 경로: `docker rm -f ll-sql-intermediate` 후 `./setup.sh` / 대안 경로: **`dropdb bookstore_ops` 후 `./setup.sh`**(정렬 규칙과 문자 분류를 고정해 재생성). world는 다시 적재되므로 잃는 것이 없습니다 |
| world 세션 설정 불일치 (시간대·메시지 언어·날짜 표기·로케일) | 두 경로 같음: `./setup.sh`를 다시 실행합니다 — 설정만 다시 적용하며 컨테이너도 데이터베이스도 지우지 않습니다. 그래도 같으면 psql 쪽 환경 변수 `PGTZ`·`PGDATESTYLE`이나 `ALTER ROLE … SET`으로 둔 역할 설정이 데이터베이스 설정을 덮고 있는지 확인하세요 |
| 「알림: psqlrc 가 여러분의 psql 세션 설정을 바꿉니다」 (대안 경로, 실패는 아님) | kit 스크립트는 psql을 `-X`로 불러 psqlrc를 읽지 않습니다 — psqlrc는 점검의 판정에 들어가지 않지만, 여러분이 직접 여는 psql 세션은 psqlrc의 `SET timezone …`·`SET DateStyle …`·`SET lc_* …` 때문에 본문과 다르게 보일 수 있습니다. 알림은 psqlrc를 읽은 세션의 **실제 값**과 psql이 실제로 읽는 파일(`~/.psqlrc`, 버전별 `~/.psqlrc-18`·`~/.psqlrc-<psql -V 가 찍는 전체 버전>` — Homebrew·PGDG 빌드는 `18.6 (Homebrew)`처럼 접미가 붙습니다, `PSQLRC`가 가리키는 파일, 시스템 psqlrc)의 해당 줄을 보여 줍니다. 코스를 진행하는 동안 그 줄을 지우거나 `--` 주석으로 바꾸세요(임시로는 `psql -X`). `\timing`·`\x auto`·`\pset` 같은 표시 설정은 두어도 kit 점검에 영향이 없습니다 |
| world 속성 검증 실패 | `./reset.sh` 후 재시도. 그래도 실패하면 기본 경로는 `docker rm -f ll-sql-intermediate` 후 `./setup.sh`, 대안 경로는 **`dropdb bookstore_ops` 후 `./setup.sh`**(`createdb`로 직접 만들면 로케일이 서버 기본값이 되어 `setup.sh`가 정렬 규칙 검사에서 막습니다) |

world 속성 검증 실패에는 `world_check.sql`의 예외 메시지가 그대로 따라 나옵니다. `W`로
시작하는 번호는 `world_check.sql`의 검사 번호입니다 — 그 파일에서 같은 번호의 주석
(`-- W1. …`)을 찾으면 무엇을 보는 검사인지 알 수 있습니다.

`./verify.sh`·`./reset.sh`·`./entry_check.sh`·`./concurrency.sh`는 **같은 world를 쓰는 다른
실행이 돌고 있으면 기다리지 않고 종료 코드 2로 거절합니다** (「다른 검증 러너(PID …)가
같은 world를 쓰고 있습니다」). 그 실행이 끝난 뒤 다시 실행하세요.

## 상태 되돌리기 — `./reset.sh`

모든 챕터는 **초기 상태에서 시작**합니다. `./reset.sh`는 스키마 `public`(책숲 운영 world
12테이블)·`legacy`·`antipatterns` 셋을 지우고 다시 만듭니다 — 약 3초. 여러분이 이 세
스키마 안에 만든 인덱스·뷰·함수·트리거·테이블은 함께 사라지고, 다른 스키마에 만든 것은
남습니다.

| 장 | world를 바꾸는 실습 | 되돌리는 때 |
|---|---|---|
| 1~5 | 조회만 | 필요 없음 |
| 6 | `legacy.sales_ledger`를 분해해 새 테이블을 만들어 봅니다 | 실습 전후 |
| 7 | 제약을 더하고 `supplier_feed`를 `book_supply`에 반복 적재(UPSERT)합니다 | 실습 전후 |
| 8 | `antipatterns` 스키마를 교정합니다 | 실습 전후 |
| 9 | 조회 위주 (타입 변환·JSONB·배열) | 필요 없음 |
| 10 | 뷰·함수·트리거를 만듭니다 | 실습 전후 |
| 11 | `page_views`에 인덱스를 만들어 실행 계획을 비교합니다 | 실습 전후 (인덱스를 지워 처음 상태로) |
| 12 | 두 세션이 `books.stock`을 바꿉니다 | 실습 전후 (`./concurrency.sh` 자동 모드는 스스로 되돌립니다) |
| 마지막 평가 장 | DDL·변경 문항 | 문항 전후 |

`./reset.sh`는 두 경로에서 같게 동작합니다. 대안 경로를 쓰시는 분이 챕터 본문의 맨
`./reset.sh` 안내를 그대로 따를 수 있는 조건은 하나입니다 — **`KIT_MODE=native ./setup.sh`로
구축했을 것**. 조건이 깨지면(상태 파일을 지웠거나 대안 경로로 구축한 적이 없으면) 기본
경로로 돌지만 **조용히 실패하지는 않습니다** — 원인과 다음 행동을 내고 종료 코드 1로
끝나므로, 되돌리기가 되지 않은 채로 다음 실습에 들어가는 일은 없습니다.

## 동시성 실습 — `./concurrency.sh` (12장)

psql 세션 둘이 같은 책의 재고를 놓고 엇갈릴 때 생기는 이상 현상을 재현합니다. 시나리오
둘(`lost-update` 갱신 손실, `nonrepeatable-read` 반복 불가능 읽기) × 격리 수준 둘
(`read-committed` 기본값, `repeatable-read`)입니다. 대상은 1번 책(재고 5)입니다.

**자동 재현** — 스크립트가 두 세션을 열어 정해진 차례로 문장을 보내고 전사를 찍은 뒤
판정합니다. 끝나면 1번 책의 재고를 원래 값으로 되돌립니다.

```bash
./concurrency.sh lost-update                     # READ COMMITTED: 갱신 손실이 재현됩니다
./concurrency.sh lost-update repeatable-read     # REPEATABLE READ: 오류로 차단됩니다
./concurrency.sh nonrepeatable-read              # READ COMMITTED: 두 번째 읽기가 달라집니다
./concurrency.sh nonrepeatable-read repeatable-read
```

각 줄의 `[A]`·`[B]`는 그 세션의 psql 출력이고, 마지막 「결과:」 줄이 판정입니다. 종료 코드
0은 「그 격리 수준에서 기대한 대로 되었다」(READ COMMITTED에서는 이상 현상이 **재현**되고,
REPEATABLE READ에서는 **차단**된다)입니다.

**두 터미널에서 직접 따라 하기** — 터미널을 둘 열고 각각 한 세션을 맡습니다. 스크립트가
한 단계씩 실행하며 상대 터미널에서 할 일을 안내하고 Enter를 기다립니다.

```bash
# 터미널 1
./concurrency.sh --terminal A lost-update
# 터미널 2
./concurrency.sh --terminal B lost-update
```

끝나면 `./reset.sh`로 되돌립니다. 격리 수준은 두 터미널에 같은 값을 주세요.

## 검증 러너 — `./verify.sh`

`cases/`의 케이스(`.sql` 입력 + `.expected` 기대 출력)를 world 위에서 실행해 대조합니다.
코스를 만드는 쪽이 본문의 예제·출력을 검증하는 도구이지만, 여러분도 돌려 볼 수 있습니다
— 전량 PASS면 여러분의 world가 교재의 world와 같다는 뜻입니다. 변경형 케이스는 실행 전후에
world를 자동으로 되돌립니다.

```
PASS 01-counts
…
----
결과: PASS 8 / FAIL 0
```

### 대안 경로의 알려진 차이

현재 알려진 차이는 **없습니다** — kit의 케이스 8건은 **직접 설치한 서버**(macOS Homebrew
PostgreSQL 18.6, 컴퓨터 시간대 Asia/Seoul·로케일 en_US.UTF-8로 초기화한 것)에서도 컨테이너와
같은 결과(8 PASS)를 냅니다. 그렇게 되는 조건이 `./setup.sh`가 고정하는 **세션 시간대(UTC)와
메시지 언어**입니다 — 고정하지 않으면 `timestamptz`가 `+09`로 표시되고 오류 메시지가 바뀌어
케이스 두 건(`05`·`07`)이 달라지는 것을 확인했습니다. `./check_env.sh`가 이 설정을 매번
확인하므로, 어긋나면 통과하지 않습니다(위 「실패 안내」). 같은 서버에서 world 테이블 9개의
행을 글자 그대로 비교해도 컨테이너와 같았고, 한글의 대소문자 변환·`ORDER BY`·정규식·
`to_char`(통화 기호 `L`·자릿수 `G`/`D`·요일·월 이름 `TM` 포함)도 같았습니다 — `to_char`가 읽는
`lc_monetary`·`lc_numeric`·`lc_time`도 `./setup.sh`가 `C`로 고정하기 때문입니다(고정하지 않으면
en_US 서버에서 `L`이 `$`, ko_KR 서버에서 `₩`·한국어 요일이 됩니다).

실행 계획(`EXPLAIN`)의 비용·추정 행 수·병렬 작업자 수는 **서버 설정**에 따라 달라질 수
있습니다. 기본 경로의 컨테이너는 PostgreSQL 기본 설정이고, 여러분이 직접 설치한 서버의
설정이 다르면(예: `max_parallel_workers_per_gather`) 11장 본문의 계획과 다른 모양이 나올
수 있습니다. 그 경우 본문이 가르치는 읽는 법(스캔 유형·인덱스 사용 여부)은 그대로입니다.
