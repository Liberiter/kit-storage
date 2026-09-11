---
track: sql-programming
course: fundamentals
stage: kit
status: approved
---

# Kit — sql-programming / fundamentals

world "책숲"(온라인 서점)과 학습 환경 구축·검증 도구입니다. 코스의 모든
예제·문제는 이 world 위에서 돕니다. 환경은 이 코스의 기준(PostgreSQL 메이저
18, Docker 컨테이너, psql 주력)을 따릅니다. 0장이 안내하는 **두 경로를 모두
지원합니다** — 기본 경로(Docker, 0장 0.1절)와 대안 경로(네이티브 설치, 0장
0.7절). 스크립트는 psql 호출을 `kit_psql.sh` 한 자리에 모아 갈랐고, 같은
`./check_env.sh`가 두 경로 모두를 판정합니다. world는 두 경로에서
같습니다 — 데이터도, **정렬 규칙도**. 다만 화면이 world가 아니라 **여러분 서버
자신의 사실**(설치 방법·역할 이름 같은 것)을 비추는 자리는 대안 경로에서 다르게
보입니다 (아래 「대안 경로의 알려진 차이」).

## World — 온라인 서점 "책숲"

작은 온라인 서점입니다. 고객이 책을 주문하고, 주문에는 여러 권이 담기며,
읽은 책에 리뷰를 남깁니다. 단일 도메인 위에서 난이도가 점진적으로
올라가도록 구성했습니다.

```
customers ──< orders ──< order_items >── books ──< reviews >── customers
 (고객 150)   (주문 620)   (항목 1,243)   (도서 320)  (리뷰 520)
```

| 테이블 | 행 수 | 역할 · 특징 |
|---|---|---|
| customers | 150 | 고객. birth_date는 선택 입력(생성 확률 NULL 30%, 실측 27%), 주문 없는 고객 29명 |
| books | 320 | **2~4장의 주 테이블. 전 열 NOT NULL** (NULL 도입 전 예제용). 8열, 가격 500원 단위(동점 존재), 카테고리 8종 |
| orders | 620 | 주문. shipped_date는 발송 전 NULL. 상태-발송일 정합 CHECK. 주문일 이전 출간 도서만 담김 |
| order_items | 1,243 | 주문-도서 N:M 교차. 주문 시점 단가 보존(단가×수량 계산 쌍) |
| reviews | 520 | 리뷰. comment NULL(별점만 — 생성 확률 35%, 실측 36%), order_id는 **NULL 허용 FK**(구매 인증 300건 / 일반 220건). 구매 인증 리뷰는 배송완료 주문의 발송일 이후에만, 모든 리뷰는 출간·가입 이후에만 존재 (시간 정합) |

시드는 `generate_seed.py`(고정 시드 20260824)가 생성한 `seed.sql`을
커밋한 것입니다 — 재현 가능하며, 직접 수정하지 않습니다.

## 사용법

```bash
./setup.sh       # 컨테이너 기동 + world 적재 + 검증 (처음/재시작)
                 #   성공하면 구축에 쓴 경로를 .kit-mode 에 적습니다 (아래 「구축 경로 기억」)
./check_env.sh   # 환경 검증 = entry check(입장 점검) 판정
./reset.sh       # world를 초기 상태로 복원
./verify.sh <케이스 디렉토리>            # 예제·문제 자동 검증 (기본 ./cases)
./verify.sh --update <케이스 디렉토리>   # 기대 출력 재생성
```

### 두 경로 — 기본(Docker) / 대안(네이티브 설치)

0장의 두 경로(0.1절 기본 경로, 0.7절 대안 경로)를 **같은 스크립트**가
받습니다. 그래서 어느 경로를 쓰셔도 **명령은 그대로**입니다 — 어느 경로로 도는지는
스크립트가 알아서 가릅니다(아래 「구축 경로 기억」). 경로에 따라 무엇이 갈리는지는
아래 표에 있습니다.

| | 기본 경로 (`KIT_MODE=docker`) | 대안 경로 (`KIT_MODE=native`) |
|---|---|---|
| 전제 | Docker 호환 런타임 | 여러분이 설치한 PostgreSQL 18 + psql |
| psql 호출 | `docker exec -i <컨테이너> psql -U postgres …` | 호스트의 `psql …` |
| 접속 정보 | 컨테이너 이름(`KIT_CONTAINER`) | psql이 원래 읽는 `PGHOST`·`PGPORT`·`PGUSER`·`PGPASSWORD` |
| `./setup.sh` | 컨테이너 생성·기동(`LANG=C.UTF-8`) → DB 생성 → 적재 → 검증 | 컨테이너 없음. psql·서버 접속·버전 18·`bookstore` DB를 점검(없으면 **정렬 규칙을 고정해** 생성)한 뒤 적재 → 검증 |
| 경로 지정 | 기본값이므로 지정하지 않아도 됩니다 | **`KIT_MODE=native ./setup.sh` 한 번**. 그 실행이 경로를 `.kit-mode`에 기억하므로 이후 명령에는 붙이지 않아도 됩니다 (아래 「구축 경로 기억」) |
| 정렬 규칙(collation) | 컨테이너 initdb를 `LANG=C.UTF-8`로 못 박아 얻습니다 | `CREATE DATABASE … TEMPLATE template0 LOCALE_PROVIDER builtin BUILTIN_LOCALE 'C.UTF-8'`으로 못 박습니다 |
| `./reset.sh` `./check_env.sh` | 동일 | 동일 |
| `./verify.sh` | 케이스 460건 전량 통과 | **여러분 서버 자신의 사실을 비추는 케이스 몇 건이 다릅니다** — 실측 두 가지: 관리자 역할이 `postgres`인 서버에서 458 PASS / 2 FAIL, 역할이 계정 이름인 서버(Postgres.app 기본)에서 456 PASS / 4 FAIL (아래 「대안 경로의 알려진 차이」) |

대안 경로의 Windows는 **WSL2 배포판(Ubuntu) 안에 Linux와 같은 방법(PGDG
저장소)으로 PostgreSQL 18을 설치**하는 것입니다 — Windows 호스트에 설치한
서버(EDB 인스톨러)는 지원하지 않습니다. kit 스크립트·psql·서버가 모두 같은
WSL2 셸 안에 있으므로 접속 설정도 Linux와 같습니다 (0장 0.7절).

대안 경로 실행 예:

```bash
KIT_MODE=native ./setup.sh       # 서버 점검 + world 적재 (구축 경로를 기억합니다)

# 이후에는 KIT_MODE 없이 그대로 — setup.sh가 적어 둔 .kit-mode 를 따릅니다
./check_env.sh                   # 같은 entry check 판정
./reset.sh                       # 챕터 본문이 맨 명령으로 부르는 자리
./verify.sh ./cases
```

`KIT_MODE=native ./check_env.sh` 처럼 매번 붙여도 됩니다 — 환경 변수는
언제나 상태 파일을 이깁니다.

**kit의 점검은 여러분의 `~/.psqlrc`를 보지 못합니다.** kit 스크립트는 psql을
언제나 `-X`(`--no-psqlrc`)로 부르므로, 그 파일에 `\timing on`·`\x auto`·`SET …`
같은 줄을 두어도 `./check_env.sh`·`./verify.sh`의 판정에는 섞이지 않습니다.
바꿔 말해 그 줄들이 만드는 세션 설정은 **여러분의 대화형 psql 세션만의 것**이고
kit이 판정하지 않습니다.

Linux·WSL2(PGDG 패키지)에서는 관리자 `postgres`에 비밀번호가 없고 같은
컴퓨터 접속이 peer 인증이라, 비밀번호를 정한 뒤
(`sudo -u postgres psql -c "ALTER USER postgres PASSWORD '…';"`)
`PGUSER`·`PGPASSWORD`와 함께 **`PGHOST=localhost`를 지정**합니다. 서버
기동은 `sudo systemctl start postgresql`입니다 — 자세한 순서는 0장 0.7절.

- psql 접속
  - 기본 경로: `docker exec -it ll-sql-fundamentals psql -U postgres -d bookstore`
  - 대안 경로: `psql -d bookstore` (접속 정보는 `PGHOST`·`PGPORT`·`PGUSER`·`PGPASSWORD`로)
- 환경 변수: `KIT_MODE`(docker|native — 지정하지 않으면 `.kit-mode`,
  그것도 없으면 docker), `KIT_PORT`(기본 54321),
  `KIT_CONTAINER`(기본 ll-sql-fundamentals), `KIT_DB`(기본 bookstore),
  `KIT_PSQL`(대안 경로의 psql 실행 파일, 기본 `psql`),
  `KIT_ADMIN_DB`(대안 경로에서 `bookstore` 생성 시 붙는 관리용 DB, 기본 `postgres`)
- 공식 문서: https://www.postgresql.org/docs/18/ (psql 사용법: app-psql)

#### 구축 경로 기억 — `.kit-mode`

`KIT_MODE`를 지정하지 않았을 때 어느 경로로 도는지는 다음 차례로
정해집니다 (정의는 `kit_psql.sh` 「구축 경로 기억」).

1. **환경 변수 `KIT_MODE`** — 지정하면 언제나 이깁니다
   (`KIT_MODE=native ./verify.sh …`).
2. **상태 파일 `kit/.kit-mode`** — `./setup.sh`가 **구축에 성공했을 때** 자기가
   쓴 경로(`docker` 또는 `native`) 한 줄을 적어 둔 파일입니다. 경로를 바꿔
   다시 구축하면(`KIT_MODE=native ./setup.sh`) 그때 갱신됩니다.
3. **상태 파일이 없으면 `docker`** — 아직 `./setup.sh`를 돌리지 않았거나 파일을
   지운 경우입니다. 이 코스의 기본 경로이므로 기본 경로를 쓰시는 분에게는
   달라지는 것이 없습니다. 대안 경로로 준비했는데 이 상태라면
   `KIT_MODE=native ./setup.sh`를 한 번 실행하면 됩니다 — 그때까지는
   `./reset.sh`·`./check_env.sh`가 기본 경로로 돌다가 **원인과 다음 행동을
   내고 종료 코드 1로 실패합니다** (조용히 넘어가지 않습니다). 원인 줄은 셋
   중 하나입니다 — 컴퓨터에 `docker` 명령 자체가 없으면 `docker 명령 없음`,
   `docker`는 있는데 런타임 프로그램(Docker Desktop·OrbStack·Docker 서비스)이
   꺼져 있으면 `런타임 미실행 …`, 런타임은 떠 있는데 컨테이너가 없으면
   `컨테이너(ll-sql-fundamentals) 미실행`. 어느 쪽이든 다음 행동은
   같습니다: `KIT_MODE=native ./setup.sh`를 한 번 실행합니다.

파일 내용이 `docker`/`native`가 아니면 스크립트가 종료 코드 2로 막고 파일을
지우라고 안내합니다. 이 파일은 **여러분 컴퓨터의 상태 파일이므로**
저장소의 `.gitignore`가 추적에서 뺍니다.

#### 대안 경로의 알려진 차이 — 여러분 서버 자신의 사실

world는 두 경로에서 같습니다. 대안 경로에서 달라지는 것은 **world가 아니라
여러분 서버 자신의 사실**입니다 — 그 서버를 어떤 방법으로 설치했는지, 그 안에
어떤 데이터베이스가 있는지, 객체를 만든 **역할(role) 이름**이 무엇인지. 이런
값은 책에 실린 것과 같아질 수 없고, **다르게 나오는 것이 잘못이 아닙니다.**

지금까지 확인된 자리는 다음 셋입니다 (전부라고 단정하지 않습니다 — 새로
알게 되면 여기에 보탭니다).

- **서버를 만든 방법의 표시** — 0장 0.5절 `SHOW server_version;`의 값에는 버전
  번호 뒤에 배포판 표시가 붙습니다. 기본 경로의 컨테이너는
  `18.6 (Debian 18.6-1.pgdg13+2)`, 직접 설치한 서버는 그 설치 방법의 표시(예:
  Homebrew는 `18.6 (Homebrew)`)입니다. 메이저가 18이면 코스에 필요한 조건은
  같으므로 `./check_env.sh`는 앞의 `18.`만 봅니다.
- **서버에 있는 데이터베이스 목록** — 1장 1.2절 «왜 그럴까요»의 `\l`은 서버
  전체를 비춥니다. 어떤 데이터베이스가 있는지와 그것들의 로케일 제공자·Collate·
  Ctype이 담기므로, 대안 경로에서는 그 값들이 여러분 서버의 로케일을 따르고
  여러분이 전에 만들어 둔 다른 데이터베이스도 함께 찍힙니다. `bookstore`의
  정렬 규칙을 고정한 뒤에도 그렇습니다.
- **객체의 소유자 이름** — `\dt`·`\dt+`(1장)와 `\l`에는 `Owner` 열이 있고,
  거기에는 **kit가 접속한 역할 이름**이 그대로 나옵니다. 책은 기본 경로의
  `postgres`로 적혀 있지만, 0장 0.7절이 macOS에 권하는 Postgres.app이나
  Homebrew 설치는 `postgres` 역할을 만들지 않고 **여러분 계정 이름**을 관리자로
  둡니다. 그러면 `Owner` 열의 값과 **열 너비**가 함께 달라집니다.

책에 실린 화면(기본 경로, 역할 `postgres`)의 `\dt` 앞 네 줄입니다.

```
             List of tables
 Schema |    Name     | Type  |  Owner   
--------+-------------+-------+----------
 public | books       | table | postgres
```

같은 명령을 계정 이름이 `rublin`인 서버에서 실행하면 이렇게 나옵니다 — 값도
다르고 `Owner` 열의 폭이 10칸에서 8칸으로 좁아집니다.

```
            List of tables
 Schema |    Name     | Type  | Owner  
--------+-------------+-------+--------
 public | books       | table | rublin
```

읽는 법은 그대로입니다 — 0장 0.5절이 확인하는 것은 「서버가 답하고 있고 메이저가
18이다」이고, 1장 1.2절이 가르치는 것은 「`\l`은 서버에 있는 데이터베이스의 목록을
보여 주고 그중 `bookstore`가 우리가 쓸 것」이며, `\dt`가 가르치는 것은 「이
데이터베이스에 어떤 표가 있는가」입니다. 그 자리의 배포판 표시·목록의 줄
수·`Collate` 열·`Owner` 열이 서버마다 다른 것은 정상입니다.

대안 경로에서 `./verify.sh ./cases`를 돌리면 이 자리들이 FAIL로 나오는데,
**예상된 것으로 읽습니다.** 몇 건이 되는지는 여러분 서버의 구성에 달려
있습니다 — 실측 두 가지입니다.

| 대안 경로 서버의 구성 | 러너 결과 | FAIL 케이스 |
|---|---|---|
| 관리자 역할 이름이 `postgres` (Linux·WSL2 패키지의 기본이며, 0장 0.7절이 접속 정보의 예로 드는 구성) | 458 PASS / 2 FAIL | `ch00-01-show-server-version`·`ch01-04-list-databases` |
| 관리자 역할 이름이 **계정 이름** (Postgres.app·Homebrew의 기본, `PGUSER`를 비워 두는 구성) | 456 PASS / 4 FAIL | 위 둘 + `ch01-01-dt`·`ch01-10-dt-plus` (`Owner` 열) |

둘 다 로케일 `en_US.UTF-8`인 PostgreSQL 18 서버에서 잰 것입니다. 서버 로케일이
다르면 `\l`의 `Collate`·`Ctype` 열이 또 달라집니다.

### entry check 실패 안내

`./check_env.sh`는 실패하면 원인 한 줄과 **다음에 할 일** 한 줄을 함께
냅니다. 분기는 다음과 같습니다. 앞쪽 분기는 `./reset.sh`·`./verify.sh`도 같은
검사를 하므로, 세 번째 열에 **어느 스크립트가 그 줄을 내는지** 적었습니다.

| 분기 | 다음에 할 일 | 이 줄을 내는 스크립트 |
|---|---|---|
| `docker` 명령 없음 (기본 경로) | 0장 0.1절대로 런타임 설치. 대안 경로로 준비하셨다면 `KIT_MODE=native ./setup.sh`를 한 번. 아직 준비하지 않았고 런타임을 쓸 수 없으면 0장 0.7절 | 셋 다 ※ |
| 런타임 미실행 (기본 경로) — `docker` 명령은 있지만 런타임 프로그램이 응답하지 않음 | 런타임 프로그램을 켭니다 — Windows는 Docker Desktop을 실행하고 Settings > Resources > WSL Integration에서 Ubuntu가 켜져 있는지 확인 / macOS는 OrbStack 실행 / Linux는 `sudo systemctl start docker` (0장 0.1절). 그 뒤 `./setup.sh`. 대안 경로로 준비하셨다면 `KIT_MODE=native ./setup.sh`를 한 번 | 셋 다 ※ |
| `psql` 명령 없음 (대안 경로) | 0장 0.7절대로 PostgreSQL 18 설치. PATH에 없으면 `KIT_PSQL=/설치경로/psql` | 셋 다 |
| 컨테이너 미실행 (기본 경로) | `./setup.sh`. 대안 경로로 준비하셨다면 `KIT_MODE=native ./setup.sh`를 한 번 — 상태 파일이 없어 기본 경로로 돌고 있을 뿐일 수 있습니다 | 셋 다 ※ |
| psql 접속 불가 | 기본 경로: `docker logs <컨테이너>` 확인 후 `./setup.sh` 재실행 / 대안 경로: 서버 기동과 접속 정보·DB 이름 확인 후 `./setup.sh` | `./check_env.sh`·`./verify.sh` (`./reset.sh`는 아래) |
| 서버 버전이 18.x가 아님 | 기본 경로: `docker rm -f <컨테이너>` 후 `./setup.sh`(postgres:18로 재생성) / 대안 경로: 18 설치 후 `PGPORT` 등으로 접속을 그쪽으로 | `./check_env.sh`만 |
| world 정렬 규칙 불일치 | 기본 경로: `docker rm -f <컨테이너>` 후 `./setup.sh`(`LANG=C.UTF-8`로 재생성) / 대안 경로: `dropdb bookstore` 후 `./setup.sh`(정렬 규칙을 고정해 재생성). 어느 쪽이든 world는 `seed.sql`에서 다시 적재되므로 잃는 것이 없습니다 | `./check_env.sh`만 |
| world 속성 검증 실패 | `./reset.sh` 후 재시도. 그래도 실패하면 기본 경로는 `docker rm -f <컨테이너>` 후 `./setup.sh`, 대안 경로는 **`dropdb bookstore` 후 `./setup.sh`**(`createdb`로 직접 만들면 로케일이 서버 기본값이 되어 `setup.sh`가 정렬 규칙 검사에서 막습니다 — 만드는 일은 `setup.sh`에 맡깁니다) | `./check_env.sh`만 |

첫 줄의 머리말은 스크립트마다 다릅니다 — `entry check 실패: `·`reset 실패: `·
`검증 러너 실패: `. **※를 단 세 행**에서는 `./reset.sh`·`./verify.sh`의 원인 줄
끝에 ` (기본 경로로 실행 중)`이 더 붙습니다(지금 기본 경로로 돌고 있다는
알림입니다). 예를 들어
`reset 실패: 컨테이너(ll-sql-fundamentals) 미실행 (기본 경로로 실행 중)`처럼
나오면 그 행의 「다음에 할 일」을 따르시면 됩니다.

`./reset.sh`는 **접속까지 확인하지는 않습니다.** 그래서 서버에 붙지 못하는
상황에서는 위 표의 「psql 접속 불가」 대신, 되돌리기를 시도하다 멈추며
`reset 실패: world 초기화 실패 (...)`(괄호 안은 멈춘 단계입니다)와 psql이 낸
메시지를 그대로 냅니다. 표의 뒤 세 행(서버 버전·world 정렬 규칙·world 속성
검증)은 `./check_env.sh`만 보는 검사이므로 다른 두 스크립트에는 나오지
않습니다.

`./verify.sh`는 위 분기에 걸리면 케이스마다 실패를 쏟는 대신 **한 번에 멈추고
종료 코드 2**로 끝냅니다.

world 속성 검증 실패에는 `world_check.sql`의 예외 메시지가 그대로 따라
나옵니다. `W`로 시작하는 번호는 `world_check.sql`의 검사 번호입니다 — 그
파일에서 같은 번호의 주석(`-- W1. …`)을 찾으면 무엇을 보는 검사인지 알 수
있습니다. 스크립트도 그 안내를 함께 출력합니다.

## 상태 되돌리기 — `./reset.sh`

모든 챕터는 **초기 상태에서 시작**합니다. 1~10장은 조회만 하므로 상태를
바꾸지 않고, 11장(DML)·12장(트랜잭션)과 마지막 평가 장은 world를
변경하므로 실습 전후에 `./reset.sh`를 실행합니다 (챕터 본문에 안내).

`./reset.sh`는 `schema.sql` + `seed.sql`을 다시 적재하므로 **두 경로에서
같게 동작합니다.** 대안 경로를 쓰시는 분이 챕터 본문의 맨 `./reset.sh` 안내를
그대로 따를 수 있는 조건은 하나입니다 — **`KIT_MODE=native ./setup.sh`로
구축했을 것**. 그 실행이 구축 경로를 `.kit-mode`에 적어 두고, 이후
`KIT_MODE` 없이 부른 `./reset.sh`가 그것을 따릅니다 (위 「구축 경로 기억」).
조건이 깨지는 경우(상태 파일을 지웠거나, 대안 경로로 구축한 적 없이
`./reset.sh`만 부르는 경우)에는 기본 경로로 돌지만 **조용히 실패하지는
않습니다** — `./reset.sh`가 원인(`docker 명령 없음`, `런타임 미실행 …`,
`컨테이너(…) 미실행` 셋 중 하나)과 다음 행동 (`KIT_MODE=native ./setup.sh`를
한 번 실행)을 내고 종료 코드 1로 끝납니다. 그래서 되돌리기가 되지 않은 채로
다음 실습에 들어가는 일은 없습니다.

기본 경로에서도 같은 세 분기가 있습니다. 컴퓨터를 껐다 켠 뒤처럼 런타임
프로그램(Docker Desktop·OrbStack·Docker 서비스)이 꺼진 채로 `./reset.sh`를
부르면 원인은 `런타임 미실행 …`이고, 다음 행동은 런타임 프로그램을 켠 뒤
`./setup.sh`입니다 — `./setup.sh`가 컨테이너를 다시 띄우고 world도 초기
상태로 되돌리므로 `./reset.sh`를 따로 부를 필요가 없습니다 (위 「entry check
실패 안내」 표의 같은 행).

다만 챕터 본문의 psql **접속** 명령은 기본 경로의
`docker exec -it …` 형태로만 적혀 있습니다. 대안 경로를 쓰시는 분은 그 자리를
`psql -d bookstore`로 바꿔 읽습니다 (위 「두 경로」의 접속 표). 본문의
**출력** 가운데 대안 경로에서 달리 보이는 것은 화면이 world가 아니라 **여러분
서버 자신의 사실**을 비추는 자리입니다 — 지금까지 확인된 셋은 0장 0.5절의
`SHOW server_version;`, 1장 1.2절의 `\l`, 1장 `\dt`·`\dt+`의 `Owner` 열입니다
(위 「대안 경로의 알려진 차이」).
