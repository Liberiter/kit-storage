---
track: sql-programming
course: advanced
stage: kit
status: approved
---

# Kit — sql-programming / advanced

world "책숲 대규모 운영 데이터"(온라인 서점 책숲이 몇 해 더 자란 모습)와 학습 환경 구축·검증 도구입니다.
코스의 모든 예제·문제는 이 world 위에서 돕니다. 환경은 이 코스의 기준(PostgreSQL 메이저 18, Docker
컨테이너, psql 주력)을 따르며, 0장이 안내하는 **두 경로를 모두 지원합니다** — 기본 경로(Docker, 0장
0.1절)와 대안 경로(직접 설치, 0장 0.7절). 스크립트가 경로를 가려 psql을 부르고(공용 함수는
`kit_psql.sh`에 있습니다), 같은 `./check_env.sh`·`./entry_check.sh`가 두 경로 모두를 판정합니다.

이 코스는 실행 계획과 내부 구조를 읽는 코스라, world는 **데이터만이 아니라 서버가 데이터를 다루는
방식까지** 두 경로에서 같게 맞춥니다 — 정렬 규칙, 세션 시간대(UTC)·오류 메시지 언어(영어)·날짜
표기·`to_char`가 읽는 로케일·실수 표시 자릿수, 그리고 **실행 계획을 가르는 설정**(정렬·해시에 쓰는
메모리 한도, 플래너의 비용 어림에 들어가는 값, 병렬 작업자 수 등)입니다. `./setup.sh`가 데이터베이스
설정으로 못 박고 `./check_env.sh`가 확인합니다. 여러분 서버가 시작할 때 정해져 kit이 못 박지 못하는
값(공유 버퍼 크기)은 다르면 알림으로 알려 드립니다(아래 「실패 안내」).

앞 코스들(fundamentals·intermediate)의 kit과 **나란히 두고 써도 됩니다.** 컨테이너·포트·데이터베이스
이름이 다릅니다 (아래 「앞 코스 kit과 함께 쓰기」).

## World — 책숲이 커진 모습

앞 코스의 책숲 운영 데이터(고객·도서·주문·리뷰, 분류 트리, 직원, 재고 원장, 페이지 조회 로그, 그리고
스키마 `legacy`·`antipatterns`)는 **정의도 데이터도 그대로** 있고, 그 곁에 서비스가 커지며 쌓인 큰
테이블들이 더해졌습니다 — 회원 30만 명, 판매 150만 건, 배송 기록, 책마다의 소개·발췌, 독서 토론
게시판. 실행 계획이 갈리고, 공유 버퍼에 다 들어가지 않고, 디스크로 넘치는 정렬이 생기는 규모입니다.

```
stores (12) ──< sales (1,500,000) >── accounts (300,000) ── customers (150, 앞 코스의 고객)
                  │      │
                  │      └── books (320) ──── book_contents (320, 소개·발췌·목차)
                  │
     shipments_sorted (540,037) / shipments_random (540,037) — 같은 배송 기록, 적재 차례만 다름

discussion_posts (30,000, 댓글이 댓글을 다는 깊은 계층)   duty_roster (7, 지점별 당직표)
스키마 theory — 설계 이론 실습용 표 셋
```

| 테이블 | 행 수 | 역할 · 특징 |
|---|---|---|
| stores | 12 | 지점. 1번이 온라인몰, 2~12번이 오프라인 매장 |
| accounts | 300,000 | 회원. 번호가 가입 차례입니다. 이메일은 가입 때 적은 그대로라 대소문자가 섞여 있습니다. `district`(구·시·동)가 정해지면 `city`가 정해집니다 — 두 열이 서로 독립이 아닙니다. 앞 코스의 고객 150명은 `customer_id`로 이어지고 이름·이메일·도시가 같습니다 |
| sales | 1,500,000 | 판매 기록(판매 한 줄 = 책 한 종). 한국 시각으로 2024-01-01~2026-08-31, 시각 차례로 쌓였습니다 — world의 세션 시간대는 UTC라 psql에서는 `2023-12-31 15:00:26+00`(가장 이른 판매)부터 `2026-08-31 14:59:20+00`(가장 늦은 판매)까지로 보입니다. 판매가 몇몇 책에 크게 몰리고, `status`는 거의 전부 `completed`이며 `disputed`는 1,906건뿐입니다. 온라인몰이 약 72%이고, 온라인이면 `channel`이 `web`·`app`, 매장이면 `store`입니다. **기본 키 말고 인덱스가 없습니다** — 외래키 열(`account_id`·`book_id`·`store_id`)에도요 |
| shipments_sorted · shipments_random | 540,037 · 540,037 | 온라인 판매의 배송 기록. 두 테이블의 **행은 같고 디스크에 쌓인 차례만 다릅니다** — 앞의 것은 발송 시각 차례로, 뒤의 것은 뒤섞인 차례로 쌓았습니다. 발송 시각(`shipped_at`)에 같은 정의의 인덱스가 있습니다 |
| book_contents | 320 | 책마다 소개(`summary`)·발췌(`excerpt`)·목차(`toc`, jsonb). 발췌의 크기가 수백 바이트에서 수십 KB까지 갈리고, 잘 압축되는 것과 거의 압축되지 않는 것이 섞여 있습니다 |
| discussion_posts | 30,000 | 독서 토론 게시판. 글타래 2,000개, 댓글이 댓글에 달려 가장 깊은 글은 46단계입니다. `parent_id`에는 인덱스가 없습니다 |
| duty_roster | 7 | 지점별 당직표. 1번 지점은 당직이 두 명입니다 |
| theory.order_book_lines · theory.talk_signups · theory.club_mentors | 1,243 · 58 · 26 | 설계 이론 실습용 표 — 아래 「설계 이론 재료」 |
| 앞 코스의 테이블 | — | customers 150 · books 320 · orders 620 · order_items 1,243 · reviews 520 · page_views 199,220 등 그대로 |

데이터는 kit 파일로 **만들어 냅니다** — 행마다 해시로 난수를 만들어, 누가 언제 구축해도 같은 데이터가
같은 차례로 들어갑니다. 행이 디스크의 몇 번째 페이지 몇 번째 자리에 놓이는지까지 같습니다. 앞 코스의
world를 만드는 파일(`schema.sql`·`seed_ref.sql`·`seed.sql`·`generate_seed.py`·`seed_ops.sql`·
`legacy.sql`·`antipatterns.sql`)은 앞 코스 kit에서 이어받았고, 만들어 내는 데이터도 앞 코스와
같습니다. 이 코스에서는 `./setup.sh`가 그 파일들과 `scale_schema.sql`·`seed_scale.sql`·`theory.sql`로
world를 만듭니다.

## 사용법

```bash
./setup.sh          # 컨테이너 기동 + world 원본 만들기(처음 한 번, 1분 안팎) + world 준비 + 환경 확인
                    #   성공하면 구축에 쓴 경로를 .kit-mode 에 적습니다 (아래 「구축 경로 기억」)
./check_env.sh      # 환경 확인 (접속·버전·world 속성) — 입장 점검의 1단계
./entry_check.sh    # 입장 점검 = 환경 확인 + 4문 채점 (아래 「입장 점검」)
./reset.sh          # world를 초기 상태로 되돌립니다 (1~3초)
./psql.sh           # world 에 psql 로 붙습니다 (두 경로 같은 명령)
./sessions.sh scenarios/deadlock.sql   # 두 세션이 엇갈리는 실습을 재현합니다 (아래 「두 세션 재현」)
./measure.sh 질의.sql                   # 질의 하나의 실행 계획과 시간을 잽니다 (아래 「측정」)
./workload.sh                          # 서비스의 질의 묶음을 돌립니다 (아래 「워크로드」)
./verify.sh <케이스 디렉토리>            # 예제·문제 자동 검증 (기본 ./cases)
```

- psql 접속
  - 어느 경로든: kit 폴더에서 `./psql.sh`
  - 기본 경로: `docker exec -it ll-sql-advanced psql -U postgres -d bookstore_scale`
  - 대안 경로: `psql -d bookstore_scale` (접속 정보는 `PGHOST`·`PGPORT`·`PGUSER`·`PGPASSWORD`로)
- 환경 변수: `KIT_MODE`(docker|native — 지정하지 않으면 `.kit-mode`, 그것도 없으면 docker),
  `KIT_PORT`(기본 54323), `KIT_CONTAINER`(기본 ll-sql-advanced), `KIT_DB`(기본 bookstore_scale),
  `KIT_PSQL`(대안 경로의 psql 실행 파일, 기본 `psql`), `KIT_ADMIN_DB`(world를 지우고 다시 만들 때 붙는
  관리용 데이터베이스, 기본 `postgres`)
- 공식 문서: https://www.postgresql.org/docs/18/ (psql 사용법: app-psql)
- 디스크: 컨테이너(또는 여러분의 서버)가 **2GB 안팎**을 씁니다 — world 원본과 world가 각각 약 430MB이고,
  나머지는 서버가 쓰는 기록 파일(WAL)입니다.

### 앞 코스 kit과 함께 쓰기

| | fundamentals kit | intermediate kit | 이 kit |
|---|---|---|---|
| 컨테이너 이름 | `ll-sql-fundamentals` | `ll-sql-intermediate` | `ll-sql-advanced` |
| 호스트 포트 | 54321 | 54322 | 54323 |
| 데이터베이스 | `bookstore` | `bookstore_ops` | `bookstore_scale` (원본 `bookstore_scale_template`) |
| 구축 경로 기억 파일 | 그 kit 디렉토리의 `.kit-mode` | 그 kit 디렉토리의 `.kit-mode` | 이 kit 디렉토리의 `.kit-mode` |

kit들의 스크립트는 서로의 컨테이너·데이터베이스를 건드리지 않습니다. 대안 경로에서 한 서버에 여러 코스의
데이터베이스를 함께 두어도 이름이 다르므로 공존합니다. 컨테이너를 동시에 띄워도 됩니다(포트가 다릅니다).

### 두 경로 — 기본(Docker) / 대안(직접 설치)

0장의 두 경로(0.1절 기본 경로, 0.7절 대안 경로)를 **같은 스크립트**가 받습니다. 어느 경로를 쓰셔도
**명령은 그대로**이고, 어느 경로로 도는지는 스크립트가 알아서 가립니다(아래 「구축 경로 기억」).

| | 기본 경로 (`KIT_MODE=docker`) | 대안 경로 (`KIT_MODE=native`) |
|---|---|---|
| 전제 | Docker 호환 런타임 | 여러분이 설치한 PostgreSQL 18 + psql. **슈퍼유저로 접속**하고, 서버 설정에 **`shared_preload_libraries = 'pg_stat_statements'`** 가 있어야 합니다(아래) |
| psql 호출 | `docker exec -i <컨테이너> psql -U postgres …` | 호스트의 `psql …` |
| 접속 정보 | 컨테이너 이름(`KIT_CONTAINER`) | psql이 원래 읽는 `PGHOST`·`PGPORT`·`PGUSER`·`PGPASSWORD` |
| `./setup.sh` | 컨테이너 생성·기동(공유 버퍼 128MB, `pg_stat_statements` 올림) → world 원본 만들기 → world 준비 → 환경 확인 | 컨테이너 없음. psql·서버 접속·버전 18·슈퍼유저·`pg_stat_statements`를 점검 → world 원본 만들기 → world 준비 → 환경 확인 |
| 경로 지정 | 기본값이므로 지정하지 않아도 됩니다 | **`KIT_MODE=native ./setup.sh` 한 번**. 그 실행이 경로를 `.kit-mode`에 기억합니다 |
| 정렬 규칙·문자 분류 | 두 경로 같음 — `./setup.sh`가 world 원본을 `CREATE DATABASE … TEMPLATE template0 LOCALE_PROVIDER builtin BUILTIN_LOCALE 'C.UTF-8' LC_COLLATE 'C' LC_CTYPE 'C'`로 만듭니다. 한글 `ORDER BY`의 차례도, 앞부분이 정해진 `LIKE`(`'abc%'`)가 보통의 인덱스를 쓸 수 있는지도 두 경로가 같습니다 | 같음 |
| 세션 설정 | 두 경로 같음 — `./setup.sh`·`./reset.sh`가 world 데이터베이스에 `ALTER DATABASE … SET`으로 겁니다(아래 표). 여러분의 대화형 psql 세션에도 적용됩니다 | 같음 |
| `./reset.sh` 등 나머지 스크립트 | 동일 | 동일 |

world 데이터베이스에 거는 설정은 다음과 같습니다. 여러분이 직접 설치한 서버는 컴퓨터의 시간대와 로케일을
기본값으로 잡고, 설치 방법에 따라 설정 파일의 값이 다를 수 있어 데이터베이스 설정으로 못 박습니다. 한
세션에서 `SET`으로 바꿔 실험하는 것은 그대로 하실 수 있습니다.

| 설정 | 값 | 못 박지 않으면 |
|---|---|---|
| `timezone` · `lc_messages` · `DateStyle` | `UTC` · `C` · `ISO, MDY` | `timestamptz`가 `+09`로 표시되고, 오류 메시지가 한국어로 나오고, `'01/02/2026'` 같은 날짜 입력이 다르게 읽힐 수 있습니다 |
| `lc_monetary` · `lc_numeric` · `lc_time` · `extra_float_digits` | `C` · `C` · `C` · `1` | `to_char`의 통화 기호·자릿수 구분·요일 이름과 실수 값의 자릿수가 달라질 수 있습니다 |
| `jit` | `off` | JIT 컴파일은 서버를 만든 방법에 따라 있기도 없기도 해서(컨테이너 이미지에는 있고 Homebrew 판에는 없습니다), 큰 질의의 `EXPLAIN ANALYZE` 끝에 JIT 블록이 붙는 서버와 붙지 않는 서버가 갈립니다. 이 코스는 JIT를 다루지 않습니다 |
| `work_mem` · `hash_mem_multiplier` · `maintenance_work_mem` | `4MB` · `2` · `64MB` | 정렬·해시가 메모리를 넘어 디스크로 넘치는 경계가 달라집니다 |
| `effective_cache_size` · `random_page_cost` · `seq_page_cost` · `cpu_tuple_cost` · `cpu_index_tuple_cost` · `cpu_operator_cost` | `4GB` · `4` · `1` · `0.01` · `0.005` · `0.0025` | 플래너의 비용 어림이 달라져 다른 계획을 고를 수 있습니다 |
| `max_parallel_workers_per_gather` · `max_parallel_workers` · `parallel_setup_cost` · `parallel_tuple_cost` · `min_parallel_table_scan_size` · `min_parallel_index_scan_size` | `2` · `8` · `1000` · `0.1` · `8MB` · `512kB` | 병렬 계획을 고르는지, 작업자를 몇 개 쓰는지가 달라집니다 |
| `default_statistics_target` · `track_io_timing` · `default_toast_compression` | `100` · `off` · `pglz` | 통계의 크기, `EXPLAIN (ANALYZE, BUFFERS)`의 I/O 시간 줄, 큰 값의 압축 방식이 달라집니다 |

표의 `jit` 줄부터는 `jit`을 빼고 PostgreSQL이 정해 둔 기본값 그대로입니다 — 여러분 서버의 설정 파일이 그 값을 바꿔 두었어도 이 데이터베이스에서는 기본값으로 돈다는 뜻입니다. 위의 두 줄(시간대·로케일 쪽)은 앞 코스 kit과 같은 값입니다.

**대안 경로에서 `pg_stat_statements`를 올리는 법.** 이 코스는 1장부터 이 관찰 도구로 질의를 잽니다. 서버가
시작할 때 읽는 설정이라, 아직 없으면 `KIT_MODE=native ./setup.sh`가 멈추고 할 일을 알려 드립니다 —
`psql -d postgres -c "ALTER SYSTEM SET shared_preload_libraries = 'pg_stat_statements'"`(이미 다른 값이
있으면 쉼표로 이어 적습니다)를 실행하고 서버를 다시 시작한 뒤(macOS Homebrew는
`brew services restart postgresql@18`, Linux·WSL2는 `sudo systemctl restart postgresql`) 다시 실행합니다.
kit은 여러분 서버의 설정 파일을 고치지 않습니다.

대안 경로의 Windows는 **WSL2 배포판(Ubuntu) 안에 Linux와 같은 방법(PGDG 저장소)으로 PostgreSQL 18을
설치**하는 것입니다 — Windows 호스트에 설치한 서버(EDB 인스톨러)는 지원하지 않습니다. Linux·WSL2(PGDG
패키지)에서는 관리자 `postgres`에 비밀번호가 없고 같은 컴퓨터 접속이 peer 인증이라, 비밀번호를 정한 뒤
(`sudo -u postgres psql -c "ALTER USER postgres PASSWORD '…';"`) `PGUSER`·`PGPASSWORD`와 함께
**`PGHOST=localhost`를 지정**합니다 — 자세한 순서는 0장 0.7절.

대안 경로 실행 예:

```bash
KIT_MODE=native ./setup.sh       # 서버 점검 + world 준비 (구축 경로를 기억합니다)

# 이후에는 KIT_MODE 없이 그대로 — setup.sh가 적어 둔 .kit-mode 를 따릅니다
./entry_check.sh                 # 같은 입장 점검
./reset.sh                       # 챕터 본문이 맨 명령으로 부르는 자리
./verify.sh ./cases
```

**kit의 판정은 여러분의 `~/.psqlrc`를 보지 못합니다.** kit 스크립트는 판정에 쓰는 psql을 언제나
`-X`(`--no-psqlrc`)로 부르므로, 그 파일에 `\timing on`·`\x auto`·`SET …` 같은 줄을 두어도
`./check_env.sh`·`./entry_check.sh`·`./verify.sh`의 판정에는 섞이지 않습니다. 바꿔 말해 그 줄들이 만드는
세션 설정은 **여러분의 대화형 psql 세션만의 것**이고 kit이 판정하지 않습니다 — 대안 경로에서 위 표의
설정을 바꾸는 줄(`SET work_mem …`·`SET timezone …` 같은 것)이 있으면 `./check_env.sh`가 알림만 냅니다(아래
「실패 안내」의 `알림: psqlrc …` 행). **그래서 `./check_env.sh`는 통과하는데 psql 화면만 교재와 다르다면
`~/.psqlrc`를 먼저 보세요** — 그 파일을 잠시 다른 이름으로 옮겨 두고(`mv ~/.psqlrc ~/.psqlrc.off`) 다시
접속해 화면이 교재와 같아지면 원인은 그 파일입니다. 기본 경로는 `docker exec`로 여는 컨테이너 안의 psql이
여러분 컴퓨터의 `~/.psqlrc`를 읽지 않으므로 해당하지 않습니다(호스트에 설치한 psql로 컨테이너에 붙으면 그
psql은 `~/.psqlrc`를 읽습니다). `./psql.sh`를 터미널에서 인자 없이 열면 여러분이 직접 여는 psql과 같아서,
대안 경로에서는 `~/.psqlrc`를 읽습니다.

**psql이 스스로 찍는 문구의 언어는 경로마다 다릅니다 — 기본 경로는 영어이고, 대안 경로는 여러분 컴퓨터의
언어 설정을 따릅니다.** 결과표 끝의 행 수(`(5 rows)`), 접속에 실패했을 때의 `psql: error:`처럼 **psql 자신이
찍는 문구**는 psql이 도는 곳의 로케일 설정을 따릅니다. kit 스크립트가 판정과 재현에 쓰는 psql은 그 문구를
교재와 같은 영어로 고정하므로 판정에는 섞이지 않습니다. 하지만 대안 경로에서 여러분이 직접 여는 psql(그리고
`./psql.sh`를 터미널에서 인자 없이 연 것)은 한국어로 설정된 컴퓨터에서 `(5 rows)` 대신 `(5개 행)`을 낼 수
있습니다. 결과는 같고 문구만 다른 것이니 그대로 읽으셔도 됩니다. 교재와 같은 화면을 보고 싶으시면 psql을
이렇게 여세요.

```bash
LC_ALL=C.UTF-8 psql -d bookstore_scale
```

#### 구축 경로 기억 — `.kit-mode`

`KIT_MODE`를 지정하지 않았을 때 어느 경로로 도는지는 다음 차례로 정해집니다 (정의는 `kit_psql.sh`
「구축 경로 기억」).

1. **환경 변수 `KIT_MODE`** — 지정하면 언제나 이깁니다 (`KIT_MODE=native ./verify.sh …`).
2. **상태 파일 `kit/.kit-mode`** — `./setup.sh`가 **구축에 성공했을 때** 자기가 쓴 경로(`docker` 또는
   `native`) 한 줄을 적어 둔 파일입니다. 경로를 바꿔 다시 구축하면 그때 갱신됩니다.
3. **상태 파일이 없으면 `docker`** — 아직 `./setup.sh`를 돌리지 않았거나 파일을 지운 경우입니다. 대안
   경로로 준비했는데 이 상태라면 `KIT_MODE=native ./setup.sh`를 한 번 실행하면 됩니다 — 그때까지는 스크립트가
   기본 경로로 돌다가 **원인과 다음 행동을 내고 0이 아닌 종료 코드로 멈춥니다.** 원인 줄은 `docker 명령 없음`,
   `런타임 미실행 …`, `컨테이너(ll-sql-advanced) 미실행` 가운데 하나이고, 어느 것이든 다음 행동 줄에 「대안
   경로로 준비하셨다면 `KIT_MODE=native ./setup.sh`를 한 번 실행하세요」가 함께 적혀 나옵니다.

파일 내용이 `docker`/`native`가 아니면 스크립트가 종료 코드 2로 막고 파일을 지우라고 안내합니다. 이 파일은
**여러분 컴퓨터의 상태 파일이므로** 받으신 kit 폴더에는 들어 있지 않습니다.

## world 원본과 되돌리기

이 코스의 world는 수백 MB라, 되돌릴 때마다 새로 만들면 시간이 걸립니다. 그래서 world는 데이터베이스 두
개로 삽니다.

- **`bookstore_scale_template` — 원본.** `./setup.sh`가 kit 파일로 한 번 만들고(1분 안팎 — 컴퓨터에 따라
  몇 분), 뒷정리와 통계 수집까지 끝낸 뒤 접속을 막아 둡니다. 다시 `./setup.sh`를 실행해도 지금 kit 파일로
  만든 원본이 이미 있으면 다시 만들지 않습니다(`world 원본 유지: …`) — 컴퓨터를 껐다 켠 뒤의 `./setup.sh`는
  몇 초입니다. kit 파일이 바뀌었으면(kit을 새로 받았으면) 원본을 다시 만듭니다.
- **`bookstore_scale` — 여러분이 쓰는 world.** `./reset.sh`가 원본을 통째로 복제해 다시 만듭니다(1~3초).
  복제는 데이터만이 아니라 통계와 행이 놓인 자리까지 그대로 옮기므로, 되돌린 직후의 world는 언제나 같은
  상태입니다. 그리고 그 상태는 시간이 지나도 저절로 바뀌지 않습니다 — 서버가 뒤에서 하는 정리 작업(자동
  뒷정리·통계 수집)이 할 일을 원본을 만들 때 끝내 두었기 때문입니다.

## 입장 점검 — `./entry_check.sh`

이 코스는 앞 코스(intermediate)를 마친 분을 전제합니다. 입장 점검은 두 단계입니다 (0장 0.5절).

1. **환경 확인** — `./check_env.sh`와 같습니다: psql 접속, 서버 메이저 버전 18, psql 문구의 언어, world
   속성(정렬 규칙 + 세션 설정 + `pg_stat_statements` + world 원본 + 데이터 검사 W1~W27). 문자 분류와 공유
   버퍼 크기는 같은 자리에서 재지만 통과 판정에 넣지 않고 알림만 냅니다.
2. **네 문항 채점** — `entry/q1.sql` ~ `entry/q4.sql`의 머리 주석에 문항이 있습니다. 그 아래에 SQL을 적고
   `./entry_check.sh`를 실행하면 world 위에서 실행해 기대 결과와 대조합니다. 이 네 파일은 `./setup.sh`가
   만들어 둡니다 — **한 번 만들어진 뒤로는 `./setup.sh`를 다시 실행해도, `./reset.sh`로 world를 되돌려도
   덮이지 않으므로** 적어 두신 답은 그대로 남습니다. 여러분이 적는 파일이라 받으신 kit의 갱신 대상에서도
   빠져 있습니다(`.gitignore`).

| 문항 | 묻는 것 | 미통과 시 돌아가 볼 곳 (intermediate) |
|---|---|---|
| q1 | 복합 보고서 질의 — 조인·집계·분류 트리·윈도우 함수 | 1장·3장·4장·5장 |
| q2 | 스키마·제약 설계 — 요구사항으로 테이블과 제약을 만드는 DDL | 6장·7장 |
| q3 | 결함 있는 질의 교정 — 조인이 행을 부풀리는 질의 | 2장·8장 |
| q4 | 실행 계획의 스캔 유형 읽기 + 격리 수준 고르기 | 11장·12장 |

통과 화면은 다음과 같습니다.

```
== 1단계: 환경 확인
환경 확인 통과: PostgreSQL 18.6 (…), world(책숲 대규모 운영 데이터) 적재·속성 확인 완료
== 2단계: 네 문항 채점 (entry/q1.sql ~ q4.sql)
PASS q1
PASS q2
PASS q3
PASS q4
----
입장 점검 통과: 환경 확인 + 4문 전량 통과. 1장으로 가셔도 됩니다.
```

틀리면 `FAIL qN`과 함께 기대 결과와 여러분 결과의 차이(`-` 기대, `+` 실제), 그리고 돌아가 볼 장이 나오고
종료 코드 1로 끝납니다. 채점은 psql의 표 출력을 글자 그대로 대조하므로 **문항이 정한 열 이름·열 차례·정렬
차례**를 지켜야 합니다. q2는 테이블을 만들므로 채점 전후에 `./reset.sh`가 자동으로 돌고, 여러분의 DDL 뒤에
맞는 행과 어긋난 행을 넣어 보아 받아들이는지·거절하는지(그리고 거절의 종류)를 봅니다. 아직 답을 적지 않은
문항은 「아직 답을 적지 않았습니다」로 FAIL입니다.

`./entry_check.sh --reference`는 kit에 든 참조 해답(`entry/reference/`)으로 채점을 돌려 보는 자가 시험입니다
— 기대 결과가 world와 맞는지 확인하는 용도이고 여러분의 답은 보지 않습니다. 참조 해답을 먼저 보면 점검의
뜻이 없어지니, 네 문항을 스스로 풀어 본 뒤에 여세요.

### 실패 안내

kit의 스크립트는 실패하면 원인 한 줄과 **다음에 할 일** 한 줄을 함께 냅니다. `./verify.sh`·`./sessions.sh`·
`./measure.sh`·`./workload.sh`·`./psql.sh`는 실행 전 점검에서 멈추면 종료 코드가 **2**입니다 — 검증·재현
결과가 아니라 실행이 되지 않은 것이기 때문입니다.

| 분기 | 다음에 할 일 |
|---|---|
| `docker` 명령 없음 (기본 경로) | 0장 0.1절대로 런타임 설치. 대안 경로로 준비했다면 `KIT_MODE=native ./setup.sh` |
| 런타임 미실행 (기본 경로) — `docker` 명령은 있지만 런타임 프로그램이 응답하지 않음 | 런타임 프로그램을 켭니다 — Windows는 Docker Desktop을 실행하고 Settings > Resources > WSL Integration에서 Ubuntu가 켜져 있는지 확인 / macOS는 OrbStack 실행 / Linux는 `sudo systemctl start docker` (0장 0.1절). 그 뒤 `./setup.sh` |
| 컨테이너 미실행 (기본 경로) | `./setup.sh` (컴퓨터를 껐다 켠 뒤 흔한 상태 — `setup.sh`가 기존 컨테이너를 다시 시작합니다) |
| `psql` 명령 없음 (대안 경로) | 0장 0.7절대로 PostgreSQL 18 설치. PATH에 없으면 `KIT_PSQL=/설치경로/psql` |
| psql 접속 불가 | `./setup.sh` — world 데이터베이스가 없으면 다시 만듭니다. 대안 경로는 먼저 서버 기동(macOS Homebrew `brew services start postgresql@18`, Linux·WSL2 `sudo systemctl start postgresql`)과 접속 정보를 확인합니다 |
| 서버 버전이 18.x가 아님 | 기본 경로: `docker rm -f ll-sql-advanced` 후 `./setup.sh`(postgres:18로 재생성) / 대안 경로: 18 설치 후 `PGPORT` 등으로 접속을 그쪽으로 |
| 슈퍼유저가 아님 (대안 경로) | `PGUSER=postgres KIT_MODE=native ./setup.sh`처럼 슈퍼유저로 접속해 다시 실행합니다 |
| `pg_stat_statements`가 서버에 올라와 있지 않음 | 대안 경로: 위 「대안 경로에서 `pg_stat_statements`를 올리는 법」 / 기본 경로: 이 kit이 만든 컨테이너가 아닙니다 — `docker rm -f ll-sql-advanced` 후 `./setup.sh` |
| psql 문구 언어 불일치 | 기본 경로: `docker rm -f ll-sql-advanced` 후 `./setup.sh` / 대안 경로: `KIT_PSQL`이 PostgreSQL 18이 설치한 psql 실행 파일을 가리키게 합니다 |
| world 정렬 규칙 불일치 | world 원본이 다른 로케일로 만들어졌습니다. 기본 경로: `docker rm -f ll-sql-advanced` 후 `./setup.sh` / 대안 경로: `dropdb bookstore_scale_template` 후 `./setup.sh` |
| world 세션 설정 불일치 | `./reset.sh` — world를 다시 만들면서 설정을 다시 겁니다. 그래도 같으면 psql 쪽 환경 변수 `PGTZ`·`PGDATESTYLE`·`PGOPTIONS`나 `ALTER ROLE … SET`으로 둔 역할 설정이 데이터베이스 설정을 덮고 있는지 확인하세요 |
| world 원본이 없음 | `./setup.sh` — 원본을 다시 만듭니다 |
| world 속성 검증 실패 | `./reset.sh` 후 재시도. 그래도 실패하면 `./setup.sh` (원본이 지금 kit 파일과 다르면 원본부터 다시 만듭니다). 그래도 같으면 기본 경로는 `docker rm -f ll-sql-advanced`, 대안 경로는 `dropdb bookstore_scale_template` 뒤 `./setup.sh` |
| 「알림: … 문자 분류(LC_CTYPE)가 …」 (실패는 아님) | 그대로 두셔도 됩니다. world 원본이 이 kit이 아닌 방법으로 만들어졌을 때만 나옵니다. 맞추려면 위 「world 정렬 규칙 불일치」와 같은 방법으로 원본을 다시 만듭니다 |
| 「알림: 서버의 공유 버퍼 크기(shared_buffers)가 …」 (대안 경로, 실패는 아님) | 그대로 두셔도 됩니다 — 실행 계획의 `Buffers` 줄(공유 버퍼에서 찾은 `hit`과 밖에서 읽어 온 `read`의 수)과 일부 계획이 교재와 다르게 나올 수 있습니다. 맞추려면 서버 설정의 `shared_buffers`를 `128MB`로 두고 서버를 다시 시작합니다 |
| 「알림: psqlrc 가 여러분의 psql 세션 설정을 바꿉니다」 (대안 경로, 실패는 아님) | psqlrc는 점검의 판정에 들어가지 않지만, 여러분이 직접 여는 psql 세션은 psqlrc의 `SET …` 줄 때문에 본문과 다르게 보일 수 있습니다. 알림이 그 세션의 실제 값과 psql이 읽는 파일의 해당 줄을 보여 줍니다. 코스를 진행하는 동안 그 줄을 지우거나 `--` 주석으로 바꾸세요(임시로는 `psql -X`). `\timing`·`\x auto`·`\pset` 같은 표시 설정은 두어도 kit 점검에 영향이 없습니다 |
| kit 파일을 읽을 수 없음 | 파일이 지워졌거나 옮겨졌습니다 — kit을 다시 받으세요 (0장 0.3절) |
| 「kit 파일 … 을(를) 실행할 수 없습니다 (없거나 실행 권한이 없습니다)」 | 다른 스크립트가 부르는 kit 스크립트(`reset.sh`·`check_env.sh`)가 없거나 실행 권한이 없습니다. 파일이 지워졌다면 kit을 다시 받으세요 (0장 0.3절). 파일은 있는데 권한만 없으면 `chmod +x <파일>`(예: `chmod +x reset.sh`) 뒤 다시 실행하시면 됩니다 |

world 속성 검증 실패에는 `world_check.sql`의 예외 메시지가 그대로 따라 나옵니다. `W`로 시작하는 번호는
`world_check.sql`의 검사 번호입니다 — 그 파일에서 같은 번호의 주석(`-- W1. …`)을 찾으면 무엇을 보는
검사인지 알 수 있습니다.

kit 스크립트는 **한 번에 하나씩**, 앞의 것이 끝난 뒤에 실행하세요. 같은 world를 쓰는 실행이 겹치면 한쪽이
다른 쪽이 만든 상태를 지워 결과가 그때그때 달라집니다. 그래서 world를 쓰는 동안 「지금 이 world를 쓰는
중」이라는 표시를 남기는 스크립트가 있고, 그 표시를 보고 거절하는 스크립트가 있습니다.

| 스크립트 | 도는 동안 표시를 남기는가 | 다른 실행의 표시가 있으면 |
|---|---|---|
| `./setup.sh` | 남기지 않습니다 | world 원본을 건드리기 전에 `오류: 같은 world(…)를 쓰는 다른 실행(PID …)이 있습니다 …`로 멈춥니다 (종료 코드 2) |
| `./check_env.sh` · `./psql.sh` | 남기지 않습니다 | 거절하지 않고 그대로 돕니다 |
| `./reset.sh` | 남기지 않습니다 | `reset 실패: 같은 world(…)를 쓰는 다른 실행(PID …)이 있습니다 …`로 거절합니다 (종료 코드 2) |
| `./entry_check.sh` | 남깁니다 — 1단계(환경 확인)를 마친 뒤입니다 | 2단계로 넘어가면서 `오류: 같은 world(…)를 쓰는 다른 실행(PID …)이 있습니다 …`로 거절합니다 (종료 코드 2) |
| `./verify.sh` · `./sessions.sh` · `./measure.sh` · `./workload.sh` | 남깁니다 | 같은 `오류: …` 문구로 거절합니다 (종료 코드 2) |

거절당하면 그 실행이 끝난 뒤 다시 실행하시면 됩니다. **거꾸로는 막아 주지 않습니다** — 표시를 남기지 않는
`./reset.sh`·`./setup.sh`가 world를 다시 만드는 사이에 시작한 실행은 거절되지 않고, 접속이 끊기거나 엉뚱한
실패를 낼 수 있습니다.

## 상태 되돌리기 — `./reset.sh`

모든 챕터는 **초기 상태에서 시작**합니다. world를 바꾸는 실습 — 인덱스 만들기, 대량 `UPDATE`·`DELETE`,
통계 다시 모으기(`ANALYZE`), 테이블 설정 바꾸기, `review/` 파일 실행 같은 것 — 의 전후에 `./reset.sh`를
실행합니다. 챕터 본문이 그 자리를 알려 드립니다.

`./reset.sh`는 world 데이터베이스(`bookstore_scale`)를 **통째로** 지우고 원본에서 다시 만듭니다. 그래서
**이 데이터베이스 안에 여러분이 만든 것은 스키마와 상관없이 모두 사라집니다** — 남겨 두고 싶은 것은 다른
데이터베이스에 만드세요. 입장 점검의 답 파일(`entry/qN.sql`)은 데이터베이스가 아니라 kit 폴더의 파일이라
그대로 남습니다.

**다른 터미널에 열어 둔 psql은 끊깁니다.** `./reset.sh`는 world 데이터베이스에 붙어 있는 세션을 끊고
다시 만듭니다. 끊은 세션이 있으면 `알림: world 데이터베이스에 붙어 있던 세션 N개를 끊었습니다 …` 한 줄을
냅니다. 그 psql에서 다음 명령을 치면 연결이 끊겼다는 메시지(`FATAL:  terminating connection due to
administrator command` … `Attempting reset: Succeeded.`)가 한 번 나오고 psql이 스스로 다시 붙습니다 — 그
명령은 실행되지 않았으니 한 번 더 입력하세요. 열려 있던 트랜잭션은 끝나지 않은 채 사라집니다(되돌리기가
하려던 일과 같습니다).

`./reset.sh`는 두 경로에서 같게 동작합니다. 대안 경로를 쓰시는 분이 챕터 본문의 맨 `./reset.sh` 안내를
그대로 따를 수 있는 조건은 **`KIT_MODE=native ./setup.sh`로 구축했을 것**입니다. 조건이 깨지면 기본 경로로
돌지만 **조용히 실패하지는 않습니다** — 원인과 다음 행동을 내고 종료 코드 1로 끝납니다.

## 두 세션 재현 — `./sessions.sh`

잠금 대기·데드락·직렬화 실패·긴 트랜잭션처럼 **psql 세션 둘이 엇갈려야 보이는 거동**을, 누가 언제 돌려도
같은 차례로 재현합니다. 스크립트가 세션 A·B를 열어 시나리오 파일의 문장을 정해진 차례로 보내고, 각 세션의
psql 출력을 `[A]`·`[B]` 접두로 찍은 뒤 기대대로 되었는지 판정합니다. 시작 전과 끝난 뒤에 world를 되돌립니다.

```bash
./sessions.sh scenarios/deadlock.sql                 # 데드락
./sessions.sh --keep scenarios/bloat-update.sql      # 끝난 뒤 world 를 되돌리지 않고 둡니다 (들여다본 뒤 ./reset.sh)
```

kit에 든 시나리오(`scenarios/`):

| 파일 | 재현하는 것 |
|---|---|
| `deadlock.sql` | 두 세션이 서로 상대가 잠근 행을 기다려 한쪽이 데드락 오류로 끝납니다 |
| `fk-lock-wait.sql` | 회원을 지우는 트랜잭션이 끝날 때까지, 그 회원의 판매를 넣으려는 세션이 외래키 검사 때문에 기다립니다 |
| `key-share-no-wait.sql` | 키가 아닌 열을 고치는 `UPDATE`는 외래키 검사와 부딪히지 않고, 키 열을 고치는 `UPDATE`는 부딪힙니다 |
| `unique-insert-wait.sql` | 같은 이메일을 넣는 두 번째 세션이 첫 세션의 결말을 기다렸다가 고유 위반으로 끝납니다 |
| `serialization-failure.sql` | 「당직은 적어도 한 명」 규칙을 두 세션이 함께 어기려 할 때 SERIALIZABLE이 한쪽을 오류로 끝냅니다 |
| `write-skew-repeatable-read.sql` | 같은 차례를 REPEATABLE READ로 돌리면 둘 다 커밋되어 규칙이 깨집니다 |
| `long-transaction-vacuum.sql` | 오래된 스냅숏을 쥔 트랜잭션이 열려 있는 동안 VACUUM이 옛 행 버전을 지우지 못합니다 |
| `bloat-update.sql` | 모든 행을 고친 뒤 테이블이 커지고, VACUUM과 VACUUM FULL이 그 공간을 각각 어떻게 다루는지 봅니다 (세션 하나) |

마지막 줄 「결과:」가 판정입니다. 종료 코드 0은 「시나리오가 기대한 대로 되었다」(기대한 오류 코드가 났고,
기다리게 하려던 문장이 실제로 잠금을 기다렸다)입니다. 오류 메시지의 `DETAIL` 줄에 찍히는 프로세스 번호·
트랜잭션 번호는 실행할 때마다 다릅니다.

**여러분이 시나리오를 써도 됩니다** — 같은 형식이면 `./sessions.sh 내-시나리오.sql`로 돌아갑니다. `-- @`로
시작하는 줄이 지시이고, 지시 아래의 줄들이 다음 지시 전까지 한 단계입니다.

```sql
-- @A                 -- 아래 문장을 세션 A 에 보내고 끝나기를 기다립니다 (B 도 같습니다)
BEGIN;
UPDATE books SET stock = stock - 1 WHERE book_id = 1;
-- @B &               -- 세션 B 에 보내되 기다리지 않습니다 — 그 문장이 잠금을 기다리는 상태가 되었는지 확인하고 넘어갑니다
UPDATE books SET stock = stock - 1 WHERE book_id = 1;
-- @observe           -- 세 번째 연결에서 실행해 보여 줍니다 (pg_locks 등)
SELECT locktype, mode, granted FROM pg_locks WHERE locktype = 'transactionid';
-- @A
COMMIT;
-- @B wait            -- 기다리던 B 의 문장이 끝나기를 기다려 결과를 받습니다
-- @expect A ok       -- 판정: A 는 오류 없이
-- @expect B ok       --       B 도 오류 없이 (오류를 기대하면 그 오류 코드, 예: 40P01)
```

지시 줄 끝의 `--` 설명은 위에서 알아보기 쉽게 붙인 것이고, 실제 파일에서는 지시 줄에 아무것도 덧붙이지
마세요. 단계 안의 `--` 줄은 세션에 보내지 않고 그 단계의 설명으로 화면에 찍힙니다. 오류 코드는 그 단계에서
**마지막으로 난 오류**의 것이므로, 판정하려는 문장을 단계의 끝에 두세요. 형식은 `sessions.sh` 머리 주석에도
있습니다.

## 측정 — `./measure.sh`

질의 하나를 `EXPLAIN (ANALYZE, BUFFERS)`로 여러 번 실행해 **계획의 모양**과 **실행 시간**을 냅니다. 질의를
고치거나 인덱스를 만든 전과 후를 같은 방법으로 잴 때 씁니다.

```bash
./measure.sh 내-질의.sql                       # 5번 실행
./measure.sh --compare 전.sql 후.sql 7         # 두 질의를 7번씩 재어 견줍니다
```

질의 파일에는 **문장 하나만** 둡니다. `INSERT`·`UPDATE`·`DELETE`도 잴 수 있고, 매번 되돌리므로 world의
데이터는 바뀌지 않습니다. 다만 되돌린 변경도 테이블에 옛 행 버전의 흔적을 남깁니다 — 변경 문장을 잰 뒤에는
`./reset.sh`로 되돌린 다음 다른 실습으로 넘어가세요. 인덱스를 만든 뒤를 재려면 `CREATE INDEX`는 psql에서 먼저 실행하고 이 도구로는 질의만
잽니다. 화면은 이런 모양입니다.

```
측정: 내-질의.sql (5회 실행 — 변경 문장은 매번 되돌렸습니다)
계획:
  Limit
    -> Sort
      -> Gather
        -> Parallel Seq Scan on sales
1회째: 실행 22.40 ms, 계획 0.20 ms, 버퍼 hit=3 read=18883
2회째부터 4회: 실행 시간 중앙값 16.09 ms (최소 14.09 / 최대 17.79 ms), 마지막 실행의 버퍼 hit=1128 read=17755
```

첫 실행은 공유 버퍼에 아직 없는 블록을 읽어 오는 몫이 섞여 따로 보여 드립니다. **시간은 실행할 때마다,
컴퓨터마다 다릅니다** — 위의 숫자도 한 컴퓨터에서 2026-10-05에 받은 것입니다(`내-질의.sql`은 「회원 한 명의 최근 판매
20건」 질의입니다). 화면 끝에는 이 성질을 알리는 `알림:` 줄이 한 줄 더 붙습니다. 견주기는 같은 컴퓨터에서 연달아 잰 값끼리
하세요. 정렬·해시가 메모리를 넘어 디스크를 썼으면 계획 줄에 그 표시가 붙습니다.

## 워크로드 — `./workload.sh`

책숲 서비스가 보내는 질의를 줄여 흉내 낸 묶음(`workload/`)을 world 위에서 돌립니다 — 빠른 질의와 느린 질의가
섞여 있습니다. 시작할 때 이 데이터베이스의 `pg_stat_statements` 기록을 비우고(다른 데이터베이스의 기록은
건드리지 않습니다), 끝나면 무엇이 시간을 썼는지 들여다볼 질의를 보여 드립니다. 무엇이 느린지는 스크립트가
알려 드리지 않습니다 — 직접 재어 찾는 것이 실습입니다. world는 바꾸지 않습니다.

```bash
./workload.sh       # 한 번
./workload.sh 3     # 세 번
```

## 검토 대상 — `review/`

동료가 썼다는 설정의 질의·스키마·인덱스 제안·동시성 처리·비정규화 제안 다섯 묶음입니다. 각 파일의 머리
주석에 누가 무엇을 부탁했는지가 있습니다. 파일들은 world 위에서 그대로 실행됩니다 — 테이블·인덱스·트리거를
만드는 파일은 스키마 `peer`나 world의 테이블에 그것을 만들므로, 살펴본 뒤 `./reset.sh`로 되돌리세요.

```bash
./psql.sh < review/01-reports.sql
```

## 설계 이론 재료 — 스키마 `theory`

함수 종속과 정규형을 따져 볼 표 세 개입니다. 일부러 여러 사실을 한 테이블에 함께 적어, 같은 사실이 여러 줄에
되풀이됩니다. 처음에는 줄끼리 어긋나는 데가 없고, 한 줄만 고쳐 어긋나게 만들어 보는 것은 실습입니다(끝나면
`./reset.sh`).

| 테이블 | 담은 것 |
|---|---|
| `theory.order_book_lines` | 주문 줄마다 주문 날짜·고객 이름·책 제목을 함께 적은 표 (기본키 `order_id`·`book_id`) |
| `theory.talk_signups` | 저자 강연 신청 원장 — 강연·장소·주소·회원 정보·좌석 번호를 한 줄에 (기본키 `talk_id`·`account_id`) |
| `theory.club_mentors` | 독서 모임의 회원·장르·멘토 배정 (기본키 `account_id`·`genre`, 멘토마다 맡는 장르가 하나) |

앞 코스에서 본 표들(`customers`, 스키마 `legacy`의 판매 원장)도 그대로 있습니다.

## psql 열기 — `./psql.sh`

구축한 경로를 가려 world 데이터베이스에 붙습니다. 터미널에서 인자 없이 열면 대화형 psql이고, 파일을 흘려
넣거나(`./psql.sh < 파일`) 인자를 주면(`./psql.sh -c 'SELECT …'`) 그것을 실행합니다. 기본 경로에서도 kit
폴더의 파일을 그대로 흘려 넣을 수 있습니다.

## 검증 러너 — `./verify.sh`

`cases/`의 케이스(`.sql` 입력 + `.expected` 기대 출력)를 world 위에서 실행해 대조합니다. 코스를 만드는 쪽이
본문의 예제·출력을 검증하는 도구이지만, 여러분도 돌려 볼 수 있습니다 — 전량 PASS면 여러분의 world가 교재의
world와 같다는 뜻입니다. world를 바꾸는 케이스는 실행 전후에 world를 자동으로 되돌립니다.

```
PASS 01-world-claims-counts
…
----
결과: PASS 10 / FAIL 0
```

마지막 줄의 수는 `cases/`에 들어 있는 케이스의 수입니다 — 장이 늘 때마다 그 장의 케이스가 더해지므로 이 수는
커집니다. 위 화면은 2026-10-05에 받은 것입니다.

### 대안 경로의 알려진 차이

갈리는 것은 예제 데이터가 아니라 **여러분 서버 자신의 사실**입니다 — 그 서버를 어떤 방법으로 설치했는지,
어떤 설정으로 돌고 있는지 같은 것들입니다. 예제 데이터(world)는 두 경로에서 같습니다 — 데이터뿐 아니라 통계와
행이 놓인 자리까지 같은 것을 2026-10-05에 두 경로(컨테이너와 macOS Homebrew PostgreSQL 18.6)에서 견주어
확인했습니다. 지금까지 확인된 갈리는 자리는 다음과 같습니다. 새로 알게 되면 여기에 보태겠습니다.

- **서버 버전 문자열** — `SHOW server_version;`은 버전 번호 뒤에 서버를 만든 방법의 표시가 붙습니다(컨테이너
  `18.6 (Debian 18.6-1.pgdg13+2)`, Homebrew `18.6 (Homebrew)`). 이 값을 그대로 싣는 케이스가 생기면 대안
  경로에서 FAIL로 나옵니다. 환경 확인은 앞자리 `18.`만 봅니다.
- **공유 버퍼 크기** — 여러분 서버의 `shared_buffers`가 128MB가 아니면, 실행 계획의 `Buffers` 줄과 일부
  계획이 교재와 다를 수 있습니다(위 「실패 안내」의 알림 행).
- **공유 버퍼에 무엇이 들어 있는가** — `hit`·`read`의 수는 그때까지 어떤 질의를 돌렸는지에 따라 달라집니다.
  같은 서버에서도 그렇습니다. `./reset.sh` 직후의 world는 공유 버퍼에 한 페이지도 없는 상태로 시작합니다.

**실행할 때마다 다른 값**도 있습니다 — 두 경로 모두에서요. `EXPLAIN ANALYZE`의 시간, 트랜잭션 번호(`xmin`·
`xmax`에 찍히는 수), 프로세스 번호, 데이터베이스와 테이블의 내부 번호(OID)는 실행할 때마다, 구축할 때마다
달라집니다. 교재는 이런 값을 글자 그대로 싣지 않거나, 실을 때는 「여러분 화면에서는 다릅니다」라고 밝힙니다.
