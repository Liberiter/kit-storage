---
track: sql-programming
course: fundamentals
stage: kit
status: approved
---

# Kit — sql-programming / fundamentals

world "책숲"(온라인 서점)과 학습 환경 구축·검증 도구. 코스의 모든
예제·문제는 이 world 위에서 돈다 (D-007). 환경은 environment.md의
확정판(PostgreSQL 메이저 18, Docker 컨테이너, psql 주력)을 따른다.
environment.md가 둔 **두 경로를 모두 지원한다** — 기본 경로(Docker)와
대안 경로(네이티브 설치). 스크립트는 psql 호출을 `kit_psql.sh` 한 자리에
모아 갈랐고, 같은 `./check_env.sh`가 두 경로 모두를 판정한다. world는 두
경로에서 같다 — 데이터도, **정렬 규칙도**. 다만 클러스터 전체를 찍는 케이스
한 건은 대안 경로에서 재현되지 않는다 (아래 「대안 경로의 알려진 차이」).

## World — 온라인 서점 "책숲"

작은 온라인 서점이다. 고객이 책을 주문하고, 주문에는 여러 권이 담기며,
읽은 책에 리뷰를 남긴다. 단일 도메인 위 점진 난이도 구성은 pgexercises
(canon 12)를 참조 모델로 했다.

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
커밋한 것이다 — 재현 가능하며, 직접 수정하지 않는다.

## 사용법

```bash
./setup.sh       # 컨테이너 기동 + world 적재 + 검증 (처음/재시작)
                 #   성공하면 구축에 쓴 경로를 .kit-mode 에 적는다 (아래 「구축 경로 기억」)
./check_env.sh   # 환경 검증 = entry check 판정 (curriculum §4)
./reset.sh       # world를 초기 상태로 복원
./verify.sh <케이스 디렉토리>            # 예제·문제 자동 검증 (기본 ./cases)
./verify.sh --update <케이스 디렉토리>   # 기대 출력 재생성
```

### 두 경로 — 기본(Docker) / 대안(네이티브 설치)

environment.md 「학습자 로컬 환경 요구사항」의 두 경로를 **같은 스크립트**가
받는다. 갈리는 것은 psql을 어떻게 부르는가 하나뿐이고, 그 분기는
`kit_psql.sh`의 `kit_psql` 함수 한 곳에 있다.

| | 기본 경로 (`KIT_MODE=docker`) | 대안 경로 (`KIT_MODE=native`) |
|---|---|---|
| 전제 | Docker 호환 런타임 | 학습자가 설치한 PostgreSQL 18 + psql |
| psql 호출 | `docker exec -i <컨테이너> psql -U postgres …` | 호스트의 `psql …` |
| 접속 정보 | 컨테이너 이름(`KIT_CONTAINER`) | psql이 원래 읽는 `PGHOST`·`PGPORT`·`PGUSER`·`PGPASSWORD` |
| `./setup.sh` | 컨테이너 생성·기동(`LANG=C.UTF-8`) → DB 생성 → 적재 → 검증 | 컨테이너 없음. psql·서버 접속·버전 18·`bookstore` DB를 점검(없으면 **정렬 규칙을 고정해** 생성)한 뒤 적재 → 검증 |
| 경로 지정 | 기본값이므로 지정하지 않아도 된다 | **`KIT_MODE=native ./setup.sh` 한 번**. 그 실행이 경로를 `.kit-mode`에 기억하므로 이후 명령에는 붙이지 않아도 된다 (아래 「구축 경로 기억」) |
| 정렬 규칙(collation) | 컨테이너 initdb를 `LANG=C.UTF-8`로 못 박아 얻는다 | `CREATE DATABASE … TEMPLATE template0 LOCALE_PROVIDER builtin BUILTIN_LOCALE 'C.UTF-8'`으로 못 박는다 |
| `./reset.sh` `./check_env.sh` | 동일 | 동일 |
| `./verify.sh` | 케이스 459건 전량 통과 | **458건 동일, `ch01-04-list-databases` 1건만 다르다** (아래 「대안 경로의 알려진 차이」) |

대안 경로 실행 예:

```bash
KIT_MODE=native ./setup.sh       # 서버 점검 + world 적재 (구축 경로를 기억한다)

# 이후에는 KIT_MODE 없이 그대로 — setup.sh가 적어 둔 .kit-mode 를 따른다
./check_env.sh                   # 같은 entry check 판정
./reset.sh                       # 챕터 본문이 맨 명령으로 부르는 자리
./verify.sh ./cases
```

`KIT_MODE=native ./check_env.sh` 처럼 매번 붙여도 된다 — 환경 변수는 언제나
상태 파일을 이긴다.

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

`KIT_MODE`를 지정하지 않았을 때 어느 경로로 도는지는 다음 차례로 정해진다
(정의는 `kit_psql.sh` 「구축 경로 기억」).

1. **환경 변수 `KIT_MODE`** — 지정하면 언제나 이긴다 (`KIT_MODE=native ./verify.sh …`).
2. **상태 파일 `kit/.kit-mode`** — `./setup.sh`가 **구축에 성공했을 때** 자기가
   쓴 경로(`docker` 또는 `native`) 한 줄을 적어 둔 파일. 경로를 바꿔 다시
   구축하면(`KIT_MODE=native ./setup.sh`) 그때 갱신된다.
3. **상태 파일이 없으면 `docker`** — 아직 `./setup.sh`를 돌리지 않았거나 파일을
   지운 경우다. environment.md의 기본 경로이므로 기본 경로 학습자에게는 달라지는
   것이 없다. 대안 경로로 준비했는데 이 상태라면 `KIT_MODE=native ./setup.sh`를
   한 번 실행하면 된다 — 그때까지는 `./reset.sh`·`./check_env.sh`가 기본 경로로
   돌다가 **컨테이너가 없다고 원인과 다음 행동을 내고 종료 코드 1로 실패한다**
   (조용히 넘어가지 않는다).

파일 내용이 `docker`/`native`가 아니면 스크립트가 종료 코드 2로 막고 파일을
지우라고 안내한다. 이 파일은 **학습자의 로컬 상태이지 산출물이 아니므로**
저장소의 `.gitignore`가 추적에서 뺀다.

#### 대안 경로의 알려진 차이 — `ch01-04-list-databases`

러너 케이스 459건 가운데 **`ch01-04-list-databases` 한 건**만 대안 경로에서
재현되지 않는다. 나머지 458건은 두 경로에서 바이트로 같다 (실측).

이 케이스는 `\l`, 즉 **클러스터 전체의 상태**를 찍는다. 기대 출력이 담고 있는
것은 world가 아니라 서버 인스턴스의 사실이다 — 어떤 데이터베이스들이 있는지
(`postgres`·`template0`·`template1`), 그것들의 로케일 제공자와 Collate·Ctype이
무엇인지. 대안 경로에서는 이 셋이 **학습자 서버의 로케일**을 따르고, 학습자가
전에 만들어 둔 다른 데이터베이스도 함께 찍힌다. world를 아무리 정확히 맞춰도
일치시킬 수 없다 — `bookstore`의 정렬 규칙을 고정한 뒤에도 그렇다.

**대안 경로 학습자는 1장 1.2절 «왜 그럴까요»의 `\l` 출력이 자기 화면과 다르게
보인다.** 읽는 법은 그대로다: 그 자리가 가르치는 것은 "`\l`은 서버에 있는
데이터베이스의 목록을 보여 주고, 그중 `bookstore`가 우리가 쓸 것"이라는
사실이며, 목록의 줄 수와 Collate 열의 값이 서버마다 다른 것은 정상이다.

러너에 경로별 건너뛰기는 넣지 않았다. 그것은 케이스의 모양에 과목 고유의
지시자를 더하는 일이고(D-029가 "갈라서는 안 될 것"으로 못 박은 자리), 종료
코드 `0` = "전량 통과"의 뜻도 흐린다. 대신 사실을 문서에 적는다 —
`cases/README.md`의 「기본 경로에서만 재현되는 케이스」.

### entry check 실패 안내

`./check_env.sh`는 실패하면 원인 한 줄과 **다음에 할 일** 한 줄을 함께 낸다
(curriculum §4 Entry check 2번). 분기는 다음과 같다.

| 분기 | 다음에 할 일 |
|---|---|
| `docker` 명령 없음 (기본 경로) | environment.md의 기본 경로대로 런타임 설치. 런타임을 못 쓰면 대안 경로 설치 후 `KIT_MODE=native ./check_env.sh` |
| `psql` 명령 없음 (대안 경로) | environment.md의 대안 경로대로 PostgreSQL 18 설치. PATH에 없으면 `KIT_PSQL=/설치경로/psql` |
| 컨테이너 미실행 (기본 경로) | `./setup.sh` |
| psql 접속 불가 | 기본 경로: `docker logs <컨테이너>` 확인 후 `./setup.sh` 재실행 / 대안 경로: 서버 기동과 접속 정보·DB 이름 확인 후 `./setup.sh` |
| 서버 버전이 18.x가 아님 | 기본 경로: `docker rm -f <컨테이너>` 후 `./setup.sh`(postgres:18로 재생성) / 대안 경로: 18 설치 후 `PGPORT` 등으로 접속을 그쪽으로 |
| world 정렬 규칙 불일치 | 기본 경로: `docker rm -f <컨테이너>` 후 `./setup.sh`(`LANG=C.UTF-8`로 재생성) / 대안 경로: `dropdb bookstore` 후 `./setup.sh`(정렬 규칙을 고정해 재생성). 어느 쪽이든 world는 `seed.sql`에서 다시 적재되므로 잃는 것이 없다 |
| world 속성 검증 실패 | `./reset.sh` 후 재시도. 그래도 실패하면 기본 경로는 `docker rm -f <컨테이너>` 후 `./setup.sh`, 대안 경로는 **`dropdb bookstore` 후 `./setup.sh`**(`createdb`로 직접 만들면 로케일이 서버 기본값이 되어 `setup.sh`가 정렬 규칙 검사에서 막는다 — 만드는 일은 `setup.sh`에 맡긴다) |

world 속성 검증 실패에는 `world_check.sql`의 예외 메시지가 그대로 따라
나온다. `W`로 시작하는 번호는 아래 「요구 매트릭스」의 "검증" 열에서 찾으면
무엇을 보는 검사인지 알 수 있다 — 스크립트도 그 안내를 함께 출력한다.

### 검증 러너 규약 (chapter 단계·red team용)

케이스 = `<이름>.sql` + `<이름>.expected`(출력 + 마지막 줄 `[exit N]`).
첫 줄 `-- runner: reset`이면 실행 전후로 world를 초기화한다(변경형).
오류 기대 케이스는 오류 메시지와 0 아닌 exit를 기대 출력에 담는다.
`cases/`의 smoke 케이스 5개가 세 유형(조회·변경·오류)의 예시다.
D-012에 따라 exit assessment의 자동 검증도 이 러너로 수행한다.

과목 고유 부분 (D-029 — 최소 규약 위에 kit가 정하는 것):

- **입력 파일 확장자**: `.sql` / **주석 문법**: `--`
- **실행 도구와 옵션**: psql을 `-X -q -v ON_ERROR_STOP=1 --pset pager=off`로
  실행하고 케이스 파일을 **표준 입력으로** 넘긴다(`-f`가 아니다 — 기본 경로에서
  파일 경로는 컨테이너 안에서 풀리는데 kit 디렉토리는 마운트되어 있지 않다).
  psql을 어느 경로로 부르는지는 `kit_psql.sh`가 정한다(위 「두 경로」).
- **전사(transcript) 케이스: 지원하지 않는다.** pty로 대화형 세션을 캡처하는
  유형은 이 kit에 없다. 러너가 psql을 `-X -q -v ON_ERROR_STOP=1`로 실행하기
  때문이다 — `ON_ERROR_STOP=1`이 첫 오류에서 실행을 멈추므로 오류 **다음**
  명령의 거동을 한 케이스에 담을 수 없고, `-q`가 명령 태그(`INSERT 0 1`·
  `UPDATE 1`·`BEGIN` 등)를 억제하며, 비대화형 실행이라 프롬프트
  (`bookstore=#`·`=*#`·`=!#`)가 아예 나타나지 않는다. 이 셋에 해당하는 본문
  출력은 케이스로 만들지 않고 `cases/README.md`의 「러너로 재현할 수 없어
  제외한 출력」에 **사유와 직접 재현 명령**을 적는다 (pipeline 「검증 케이스
  규약」). 지원 추가는 kit 파일 수정이므로 kit red team 재검증 대상이며,
  D-029는 이미 approved인 kit에 소급 요구하지 않는다.
- **동시 실행 보호: 거절.** 같은 world를 향한 `verify.sh`가 이미 돌고 있으면 새
  실행은 기다리지 않고 원인·다음 행동을 내고 **종료 코드 2**로 끝난다. 러너가
  도는 동안의 `./reset.sh`도 같은 이유로 거절한다(러너 자신이 부르는 것만
  통과). world는 **접속 방법이 아니라 서버와 DB**(`<호스트>:<포트>/<DB>` — 기본
  경로는 `localhost:<KIT_PORT>`, 대안 경로는 `PGHOST:PGPORT`)로 식별하므로, 호스트
  psql로 같은 컨테이너에 붙는 대안 경로 러너와 기본 경로 러너는 서로를 본다.
  잠금은 `/tmp/learning-loop-kit-<world>.lock` 디렉토리(`TMPDIR`과 무관 — 셸마다
  다른 값이라 잠금이 갈린다)이고 실행이 끝나면(인터럽트 포함) 지워지며, 소유
  프로세스가 죽은 채 남은 잠금은 다음 실행이 걷어낸다. 잠금이 kit 디렉토리가
  아니라 world 단위인 이유는 실제 사고가 두 체크아웃이 같은 컨테이너를 쓰다
  났기 때문이다. **잠금이 보지 못하는 경우** — 다른 머신·다른 사용자에서 온
  접속, 같은 서버를 `localhost`·`127.0.0.1`·`::1` 밖의 표기로 가리키는 접속,
  러너를 거치지 않은 psql 세션 — 에서는 종전 규약대로 실행하는 쪽이 격리를
  맡는다(실행 전 `ps`·`pg_stat_activity` 확인, 또는 전용 컨테이너). 겹쳐 돌려야
  하면 `KIT_CONTAINER`·`KIT_PORT`로 전용 컨테이너를 세운다 (pipeline 「러너는
  동시 실행을 막는다」 — 이 kit은 그 규약 이전에 approved되었고, 세 라운드 연속
  재발 뒤 사용자 확정으로 소급 적용했다).

## 상태 연속성 계획

모든 챕터는 **초기 상태에서 시작**한다. 1~10장은 조회만 하므로 상태를
바꾸지 않고, 11장(DML)·12장(트랜잭션)과 exit assessment는 world를
변경하므로 실습 전후에 `./reset.sh`를 실행한다 (챕터 본문에 안내).
러너의 변경형 케이스는 자동으로 전후 초기화된다.

`./reset.sh`는 `kit_psql`로 `schema.sql` + `seed.sql`을 다시 적재하므로
**두 경로에서 같게 동작한다.** 대안 경로 학습자가 챕터 본문의 맨 `./reset.sh`
안내를 그대로 따를 수 있는 조건은 하나다 — **`KIT_MODE=native ./setup.sh`로
구축했을 것**. 그 실행이 구축 경로를 `.kit-mode`에 적어 두고, 이후 `KIT_MODE`
없이 부른 `./reset.sh`가 그것을 따른다 (위 「구축 경로 기억」). 조건이 깨지는
경우(상태 파일을 지웠거나, 대안 경로로 구축한 적 없이 `./reset.sh`만 부르는
경우)에는 기본 경로로 돌지만 **조용히 실패하지는 않는다** — `./reset.sh`가
원인(`컨테이너(…) 미실행`)과 다음 행동(`KIT_MODE=native ./setup.sh`를 한 번
실행)을 내고 종료 코드 1로 끝난다. 그래서 되돌리기가 되지 않은 채로 다음
실습에 들어가는 일은 없다.

다만 챕터 본문의 psql **접속** 명령은 기본 경로의
`docker exec -it …` 형태로만 적혀 있다. 대안 경로 학습자는 그 자리를
`psql -d bookstore`로 바꿔 읽는다 (위 「두 경로」의 접속 표). 본문의 **출력**
가운데 대안 경로에서 달리 보이는 것은 1장 1.2절의 `\l` 하나뿐이다
(위 「대안 경로의 알려진 차이」).

## 요구 매트릭스 — curriculum §1·§5 대조

"검증" 열은 `world_check.sql`의 검사 번호 (실패 시 예외 발생 —
`check_env.sh`가 실행). **아래 표의 W1~W13은 경로에 의존하지 않는다** —
`world_check.sql`도 `reset.sh`도 `kit_psql`을 거치므로 기본 경로와 대안
경로에서 같은 검사가 같은 world에 대해 돈다.

이 문장의 범위는 **W1~W13이 보는 것**(스키마·행 수·분포·정합성·제약)이지,
world를 담은 데이터베이스의 모든 성질이 아니다. 정렬 규칙(collation)은 W
검사가 보지 않고, 데이터가 아니라 **DB를 만들 때 정해지는 설정**이라 두
경로가 서로 다른 방법으로 같은 값(`C.UTF-8`)에 도달한다 — 기본 경로는
컨테이너 `LANG`, 대안 경로는 `CREATE DATABASE`의 builtin 제공자.
그 결과가 실제로 같은지는 `./check_env.sh`가 두 경로 모두에서 확인한다
(위 「entry check 실패 안내」의 정렬 규칙 분기).

| 챕터 | curriculum 요구 | world의 충족 | 검증 |
|---|---|---|---|
| 1 | 테이블 4~6개 FK 연결, \d 탐색 가치, 공식 문서 연결 | 5테이블·FK 6개(구매 인증 리뷰 포함), 사용법 절의 문서 링크 | W1 |
| 2 | 주 테이블 8열 내외·수백 행, 중복 값 열, NULL 없는 예제 구성 | books 320행 8열 전열 NOT NULL, category·author 중복 값 | W2·W3·W6 |
| 3 | LIKE 유의미 텍스트, BETWEEN·IN 유의미 숫자·날짜 | 제목 패턴('%여행%' 등), 가격대·출간일 범위 | W7·W3 |
| 4 | 정렬 유의미 열·동점 값, 상위 N | 가격 500원 단위 동점, 페이지·날짜 정렬 | W6 |
| 5 | NULL 자연 열 2+ (의미 다른 NULL) | shipped_date(미발생)·birth_date(미입력)·comment(선택) | W4 |
| 6 | 타입 다양성, 계산 쌍, 날짜 연산, 정수 나눗셈 함정 | int·text·date·boolean, 단가×수량, 발송 소요일, 정수 가격 | W8 (+스키마) |
| 7 | 1:N 2쌍+, 조인 필수 질문, FK 열 NULL | 1:N 3쌍 + N:M, reviews.order_id NULL 허용 FK | W1·W13 |
| 8 | 자식 없는 부모, 3테이블 경로 | 주문 없는 고객 29, 주문 없는 책 18·리뷰 없는 책 76, customers-orders-order_items | W5·W1 |
| 9 | 그룹 편차, 집계 숫자 열, NULL 열 집계 | 고객별 주문 수 편차(0~10+), COUNT(comment) 대비 | W6·W4 |
| 10 | 평균 비교 서브쿼리, UNION 호환 집합 | 평균 초과 가격(진부분집합), 동일 구조 조건 분할 | W9 |
| 11 | 변경 실습 + 리셋, PK·FK 위반 오류 경험 | reset.sh, PK·FK·CHECK 위반 검사 | W11 (+reset.sh) |
| 12 | 이체형 시나리오 (차감+기록) | 재고(stock) 차감 + 주문 생성 (cases/04 예시) | W12 |
| §5 공통 | world 정합성 (설정 모순 없음) | 상태-발송일, 가입·출간 전 주문/리뷰 금지, 구매 인증 리뷰 정합(배송완료·발송일 이후·주문 포함 책) | W10·W13 |

## 파일 목록

| 파일 | 역할 |
|---|---|
| schema.sql / seed.sql | world 정의 (스키마 / 시드 — 생성물) |
| generate_seed.py | seed.sql 결정적 생성기 |
| kit_psql.sh | psql 호출 경로 정의(`KIT_MODE=docker`/`native`와 「구축 경로 기억」)와 world 정렬 규칙 기대값·프로브(`KIT_SORT_EXPECTED`·`kit_sort_probe`) — 나머지 스크립트가 읽어들이는 공용 파일 |
| setup.sh / reset.sh | 환경 구축(구축 경로를 `.kit-mode`에 기록) / 초기 상태 복원 |
| `.kit-mode` | **생성물이자 학습자 로컬 상태** — `setup.sh`가 적는 구축 경로 한 줄. `.gitignore` 대상이므로 저장소에 없다 |
| check_env.sh | 환경 검증 (entry check 판정 기준) |
| verify.sh + cases/ | 검증 러너 + smoke 케이스 |
| world_check.sql | world 속성 기계 검사 (W1~W13) |
