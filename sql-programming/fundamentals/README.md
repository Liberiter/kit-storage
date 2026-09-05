---
track: sql-programming
course: fundamentals
stage: kit
status: approved
---

# Kit — sql-programming / fundamentals

world "책숲"(온라인 서점)과 학습 환경 구축·검증 도구. 코스의 모든
예제·문제는 이 world 위에서 돈다. 환경은 이 코스의 기준(PostgreSQL 메이저
18, Docker 컨테이너, psql 주력)을 따른다. 0장이 안내하는 **두 경로를 모두
지원한다** — 기본 경로(Docker, 0장 0.1절)와 대안 경로(네이티브 설치, 0장
0.7절). 스크립트는 psql 호출을 `kit_psql.sh` 한 자리에 모아 갈랐고, 같은
`./check_env.sh`가 두 경로 모두를 판정한다. world는 두 경로에서 같다 —
데이터도, **정렬 규칙도**. 다만 클러스터 전체를 찍는 케이스 한 건은 대안
경로에서 재현되지 않는다 (아래 「대안 경로의 알려진 차이」).

## World — 온라인 서점 "책숲"

작은 온라인 서점이다. 고객이 책을 주문하고, 주문에는 여러 권이 담기며,
읽은 책에 리뷰를 남긴다. 단일 도메인 위에서 난이도가 점진적으로 올라가도록
구성했다.

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
./check_env.sh   # 환경 검증 = entry check(입장 점검) 판정
./reset.sh       # world를 초기 상태로 복원
./verify.sh <케이스 디렉토리>            # 예제·문제 자동 검증 (기본 ./cases)
./verify.sh --update <케이스 디렉토리>   # 기대 출력 재생성
```

### 두 경로 — 기본(Docker) / 대안(네이티브 설치)

0장의 두 경로(0.1절 기본 경로, 0.7절 대안 경로)를 **같은 스크립트**가
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
| `./verify.sh` | 케이스 460건 전량 통과 | **459건 동일, `ch01-04-list-databases` 1건만 다르다** (아래 「대안 경로의 알려진 차이」) |

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
   지운 경우다. 이 코스의 기본 경로이므로 기본 경로 학습자에게는 달라지는
   것이 없다. 대안 경로로 준비했는데 이 상태라면 `KIT_MODE=native ./setup.sh`를
   한 번 실행하면 된다 — 그때까지는 `./reset.sh`·`./check_env.sh`가 기본 경로로
   돌다가 **원인과 다음 행동을 내고 종료 코드 1로 실패한다** (조용히 넘어가지
   않는다). 원인 줄은 둘 중 하나다 — 컴퓨터에 `docker` 명령 자체가 없으면
   `docker 명령 없음`, `docker`는 있는데 컨테이너가 없으면
   `컨테이너(ll-sql-fundamentals) 미실행`. 어느 쪽이든 다음 행동은 같다:
   `KIT_MODE=native ./setup.sh`를 한 번 실행한다.

파일 내용이 `docker`/`native`가 아니면 스크립트가 종료 코드 2로 막고 파일을
지우라고 안내한다. 이 파일은 **학습자의 로컬 상태이지 산출물이 아니므로**
저장소의 `.gitignore`가 추적에서 뺀다.

#### 대안 경로의 알려진 차이 — `ch01-04-list-databases`

러너 케이스 460건 가운데 **`ch01-04-list-databases` 한 건**만 대안 경로에서
재현되지 않는다. 나머지 459건은 두 경로에서 바이트로 같다 (실측).

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
대안 경로에서 `./verify.sh ./cases`를 돌리면 이 한 건의 FAIL은 예상된 것으로
읽는다.

### entry check 실패 안내

`./check_env.sh`는 실패하면 원인 한 줄과 **다음에 할 일** 한 줄을 함께 낸다.
분기는 다음과 같다.

| 분기 | 다음에 할 일 |
|---|---|
| `docker` 명령 없음 (기본 경로) | 0장 0.1절대로 런타임 설치. 런타임을 못 쓰면 0장 0.7절의 대안 경로 설치 후 `KIT_MODE=native ./check_env.sh` |
| `psql` 명령 없음 (대안 경로) | 0장 0.7절대로 PostgreSQL 18 설치. PATH에 없으면 `KIT_PSQL=/설치경로/psql` |
| 컨테이너 미실행 (기본 경로) | `./setup.sh` |
| psql 접속 불가 | 기본 경로: `docker logs <컨테이너>` 확인 후 `./setup.sh` 재실행 / 대안 경로: 서버 기동과 접속 정보·DB 이름 확인 후 `./setup.sh` |
| 서버 버전이 18.x가 아님 | 기본 경로: `docker rm -f <컨테이너>` 후 `./setup.sh`(postgres:18로 재생성) / 대안 경로: 18 설치 후 `PGPORT` 등으로 접속을 그쪽으로 |
| world 정렬 규칙 불일치 | 기본 경로: `docker rm -f <컨테이너>` 후 `./setup.sh`(`LANG=C.UTF-8`로 재생성) / 대안 경로: `dropdb bookstore` 후 `./setup.sh`(정렬 규칙을 고정해 재생성). 어느 쪽이든 world는 `seed.sql`에서 다시 적재되므로 잃는 것이 없다 |
| world 속성 검증 실패 | `./reset.sh` 후 재시도. 그래도 실패하면 기본 경로는 `docker rm -f <컨테이너>` 후 `./setup.sh`, 대안 경로는 **`dropdb bookstore` 후 `./setup.sh`**(`createdb`로 직접 만들면 로케일이 서버 기본값이 되어 `setup.sh`가 정렬 규칙 검사에서 막는다 — 만드는 일은 `setup.sh`에 맡긴다) |

world 속성 검증 실패에는 `world_check.sql`의 예외 메시지가 그대로 따라
나온다. `W`로 시작하는 번호는 `world_check.sql`의 검사 번호다 — 그 파일에서
같은 번호의 주석(`-- W1. …`)을 찾으면 무엇을 보는 검사인지 알 수 있다.
스크립트도 그 안내를 함께 출력한다.

## 상태 되돌리기 — `./reset.sh`

모든 챕터는 **초기 상태에서 시작**한다. 1~10장은 조회만 하므로 상태를
바꾸지 않고, 11장(DML)·12장(트랜잭션)과 마지막 평가 장은 world를
변경하므로 실습 전후에 `./reset.sh`를 실행한다 (챕터 본문에 안내).

`./reset.sh`는 `schema.sql` + `seed.sql`을 다시 적재하므로 **두 경로에서
같게 동작한다.** 대안 경로 학습자가 챕터 본문의 맨 `./reset.sh` 안내를
그대로 따를 수 있는 조건은 하나다 — **`KIT_MODE=native ./setup.sh`로
구축했을 것**. 그 실행이 구축 경로를 `.kit-mode`에 적어 두고, 이후 `KIT_MODE`
없이 부른 `./reset.sh`가 그것을 따른다 (위 「구축 경로 기억」). 조건이 깨지는
경우(상태 파일을 지웠거나, 대안 경로로 구축한 적 없이 `./reset.sh`만 부르는
경우)에는 기본 경로로 돌지만 **조용히 실패하지는 않는다** — `./reset.sh`가
원인(`docker 명령 없음` 또는 `컨테이너(…) 미실행`)과 다음 행동
(`KIT_MODE=native ./setup.sh`를 한 번 실행)을 내고 종료 코드 1로 끝난다.
그래서 되돌리기가 되지 않은 채로 다음 실습에 들어가는 일은 없다.

다만 챕터 본문의 psql **접속** 명령은 기본 경로의
`docker exec -it …` 형태로만 적혀 있다. 대안 경로 학습자는 그 자리를
`psql -d bookstore`로 바꿔 읽는다 (위 「두 경로」의 접속 표). 본문의 **출력**
가운데 대안 경로에서 달리 보이는 것은 1장 1.2절의 `\l` 하나뿐이다
(위 「대안 경로의 알려진 차이」).
