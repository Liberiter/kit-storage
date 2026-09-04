# 검증 케이스 목록

러너는 `../verify.sh`. 케이스 규약은 `../README.md`의 "검증 러너 규약" 절을 따른다.

## 이 문서의 직접 재현 명령은 기본 경로 표기다

「러너로 재현할 수 없어 제외한 출력」의 **직접 재현 명령**은 전부 기본 경로
(Docker, `KIT_MODE=docker`)의 표기로 적혀 있다. 대안 경로(`KIT_MODE=native`,
네이티브 설치)에서 재현하는 사람은 다음과 같이 바꿔 읽는다 — 옵션과 입력은
그대로다.

| 이 문서의 표기 | 대안 경로에서 |
|---|---|
| `docker exec -it ll-sql-fundamentals psql -U postgres -d bookstore …` | `psql -d bookstore …` |
| `docker exec -i ll-sql-fundamentals psql -U postgres -d bookstore … < 파일` | `psql -d bookstore … < 파일` |

접속 정보는 psql이 원래 읽는 `PGHOST`·`PGPORT`·`PGUSER`·`PGPASSWORD`로 준다
(`../README.md`의 「두 경로」). `./reset.sh`는 두 경로에서 그대로 쓴다.

## 기본 경로에서만 재현되는 케이스

**`ch01-04-list-databases`** 한 건은 기본 경로(Docker)에서만 러너를 통과한다.
나머지 458건은 두 경로에서 바이트로 같다 (실측: 대안 경로 458 PASS / 1 FAIL).

이 케이스의 입력은 `\l`이고, 기대 출력은 world가 아니라 **클러스터 전체의
상태**를 담는다 — 서버에 어떤 데이터베이스가 있는지(`postgres`·`template0`·
`template1`)와 그것들의 로케일 제공자·Collate·Ctype이다. 대안 경로에서는 그
값들이 학습자 서버의 로케일을 따르고, 학습자가 전에 만들어 둔 다른
데이터베이스도 함께 찍힌다. `bookstore`의 정렬 규칙을 기본 경로와 같게
고정한 뒤에도 일치시킬 수 없는, **구조적인** 차이다.

케이스를 지우지 않고 남겨 둔다 — 기본 경로가 코스의 기본값이고, 1장 본문이
싣는 `\l` 출력의 회귀 검증은 그 경로에서 유효하다. 러너에 경로별 건너뛰기를
넣지도 않았다: 케이스의 모양에 과목 고유의 지시자를 더하는 일이고(D-029가
"갈라서는 안 될 것"으로 못 박은 자리), 종료 코드 `0` = "전량 통과"의 뜻도
흐려진다. 대안 경로에서 러너를 돌리는 사람은 이 한 건의 FAIL을 예상된 것으로
읽는다 (`../README.md`의 「대안 경로의 알려진 차이」).

## 접두사 규칙

- `NN-*` — kit 자체의 smoke 케이스(조회·변경·오류 세 유형의 예시). kit 단계 산출물.
- `chNN-*` — NN장 본문이 실은 실행 결과·데이터 주장의 회귀 케이스. chapter 단계가
  추가한다. 챕터 본문의 출력 블록과 **바이트 단위로 같아야** 한다.

## psql 출력의 열 너비는 결과 집합마다 다르다

위의 "바이트 단위로 같아야 한다"는 **한 케이스와 그 케이스 자신의 기대 출력** 사이의
관계다. **케이스와 케이스 사이에는 적용되지 않는다** — 러너도 케이스 사이의 등가는
검사하지 않는다 (pipeline "러너가 검사하는 것과 검사하지 않는 것").

psql은 결과에 든 **가장 긴 값**에 맞춰 각 열의 너비를 잡는다. 그래서 같은 열을 뽑아도
결과 집합이 다르면 표의 가로 너비가 달라진다. 예를 들어 `ch04-19`(상위 5권)와
`ch04-20`(상위 10권)의 앞 다섯 줄은 **같은 책이 같은 차례로** 나오지만, `ch04-20`에
더 긴 제목이 하나 들어 있어 `title` 열이 한 칸 넓다 — 바이트로는 다르다.

따라서 **서로 다른 질의의 출력에 "바이트 일치"나 "한 글자도 다르지 않다"를 주장하지
않는다.** 무엇이 같은지를 정확히 적는다: 행 내용인지, 차례인지, 값인지. 바이트 등가는
"의도적으로 출력이 같은 케이스 쌍" 절에 적힌 쌍에만 성립하며, 그 쌍은
`check_chapter.py`가 `cmp`로 확인한다.

(근거: 4장 red team 라운드 1의 반려 D3·D4 — 값과 차례가 같은 두 출력에 "한 글자도
다르지 않다"를 주장했고 열 너비 차이로 거짓이었다.)

## ch01 — 1장 «관계형 데이터베이스와 첫 만남»

| 케이스 | 챕터에서의 위치 |
|---|---|
| ch01-01-dt | 1.2 따라 하기 2단계 `\dt` |
| ch01-02-d-books | 1.2 따라 하기 3단계 `\d books` · 7.2 따라 하기 3단계(같은 출력을 다시 싣는다 — `Referenced by:`를 읽는 자리) |
| ch01-03-d-orders | 1.2 따라 하기 4단계 `\d orders` |
| ch01-04-list-databases | 1.2 왜 그럴까요 `\l` — **기본 경로에서만 재현된다** (위 「기본 경로에서만 재현되는 케이스」) |
| ch01-05-d-customers | 1.2 practice 1 `\d customers` · 6.1 개념(같은 출력을 다시 싣는다 — 네 가지 타입을 보이는 자리) · 7.1 따라 하기 1단계(같은 출력을 다시 싣는다 — `Indexes:`의 `PRIMARY KEY`를 읽는 자리) |
| ch01-06-select-1-plus-1 | 1.3 따라 하기 1단계 `SELECT 1 + 1;` |
| ch01-07-d-reviews | exercise 2 해설 `\d reviews` · 7.2 따라 하기 4단계(같은 출력을 다시 싣는다 — 외래키 셋과 `order_id`의 널 허용을 읽는 자리) |
| ch01-08-d-order-items | exercise 3 해설 `\d order_items` · 7.1 따라 하기 3단계(같은 출력을 다시 싣는다 — 복합 기본키를 읽는 자리). 7.2 따라 하기 1단계는 이 출력의 `Foreign-key constraints:` 세 줄만 발췌한다 |
| ch01-09-books-title-price | 1.3 practice 뒤 [미리보기] `SELECT title, price FROM books LIMIT 3;` · 4.2 따라 하기 1단계가 **입력이 바이트 동일한** 질의를 다시 싣는다(그 자리는 `ch04-14-limit-3-no-order`가 따로 갖고 있다 — 아래 「4장이 케이스를 새로 만들지 않은 출력」의 마지막 문단 참조) |
| ch01-10-dt-plus | exercise 5 해설 `\dt+` |
| ch01-11-syntax-error | 1.3 따라 하기 3단계 `SELCT 1 + 1;` (오류 기대, exit 3) |
| ch01-12-same-name-customers | **주장 케이스**(본문 주장의 근거) — exercise 3의 근거. 이름 '최연우'인 고객이 3명(4·12·111)이고 도시·이메일이 다르며 셋 다 주문이 있다는 사실 |
| ch01-13-world-claims-counts | **주장 케이스** — 본문이 인용하는 수치 주장 5건. 주문 없는 고객 29, 고객 4의 주문 6건·항목 11행·1권 주문 3건, 동명이인 그룹 31 |
| ch01-14-sheet-rows | **주장 케이스**(본문 표의 근거) — 1.1 문제 상황의 '사장님 주문 시트' 표 5줄을 world에서 그대로 재구성한다 |

### 러너로 재현할 수 없어 케이스로 만들지 않은 출력

러너는 `psql -X -q`(비대화형)로 실행하므로, 대화형 세션에서만 나오는 출력은
바이트 대조가 불가능하다. 아래는 의도적으로 제외한 것이며, 검증이 필요하면
`docker exec -it ll-sql-fundamentals psql -U postgres -d bookstore`로 직접 재현한다.

| 챕터의 블록 | 제외 이유 |
|---|---|
| 접속 배너(`psql (18.6 ...)` / `Type "help" for help.`)와 `bookstore=#` 프롬프트 | 대화형 세션에서만 출력된다 |
| 세미콜론 누락 시 `bookstore=#` → `bookstore-#` 프롬프트 전이 (1.3 따라 하기 2단계, exercise 4-3) | 프롬프트는 비대화형에서 출력되지 않는다 |
| `\d nosuchtable` → `Did not find any relation named "nosuchtable".` (exercise 4-1) | 정보성 메시지라 `-q`에서 억제된다(출력 없이 exit 3) |
| `\l;` → `invalid command \l;` + `Try \? for help.` (1.2 흔한 실수, exercise 4-2) | 첫 줄은 나오지만 `Try \? for help.`는 대화형에서만 덧붙는다 |
| 존재하지 않는 DB로 접속 실패 메시지 (1.2 왜 그럴까요) | psql 기동 자체가 실패하는 경우라 러너의 세션 모델 밖이다 |
| `\?` · `\h` 출력 (1.3 따라 하기 4단계) | 챕터가 출력을 싣지 않는다(직접 실행하게 한다) |

### 1장에서 주장 케이스에서 뺀 수치

- **출력 블록 안에서 학습자가 직접 셀 수 있는 수치는 넣지 않았다** (D-033).
  1.2 따라 하기 2단계·«왜 그럴까요»·exercise 1이 되풀이하는 「다섯 개의 테이블」은
  `ch01-01-dt`의 기대 출력에 다섯 줄과 `(5 rows)`로 찍혀 있고, exercise 2 해설의
  「`Foreign-key constraints` 세 줄」은 `ch01-07-d-reviews`의 기대 출력에서 그대로
  센다. 둘 다 `ch01-13-world-claims-counts`에 다시 담지 않았다.

### 1장의 의도된 반례 (D-025)

- **없다.** 1장은 서식 규칙을 선언하지 않는다 — `style.md`의 1장 절(R1·R2)은
  2장이 서식 규약을 세우면서 정리한 것이고, 1장 본문에는 규칙 선언 소절이 없다.
- 1.3 «흔한 실수»의 소문자 `select 1 + 1;`은 R1을 어긴 **실행 코드가 아니라**
  산문 속 인라인 코드다. "대문자는 읽기 편하라고 쓰는 관례일 뿐"이라는 문장이
  인용한 형태이고, 같은 문단이 "이 코스에서는 관례를 따라 키워드를 대문자로
  씁니다"로 회수한다.
- `ch01-11-syntax-error`(`SELCT 1 + 1;`)는 서식 규칙이 아니라 **오탈자가 어떤
  오류를 내는지**가 대상이므로 D-025의 반례가 아니다.

## ch02 — 2장 «원하는 열 고르기 — SELECT»

| 케이스 | 챕터에서의 위치 |
|---|---|
| ch02-01-select-title-author | 2.1 따라 하기 2단계 `SELECT title, author FROM books LIMIT 5;` |
| ch02-02-select-author-title | 2.1 따라 하기 3단계 `SELECT author, title FROM books LIMIT 5;` |
| ch02-03-select-star | 2.1 따라 하기 4단계 `SELECT * FROM books LIMIT 5;` |
| ch02-04-select-without-from | 2.1 왜 그럴까요 `SELECT title;` (오류 기대, exit 3) |
| ch02-05-select-quoted-title | 2.1 흔한 실수 `SELECT 'title' FROM books LIMIT 3;` |
| ch02-06-select-title-pages-date | 2.1 practice 1 풀이 |
| ch02-07-select-typo-column | 2.1 practice 2 풀이 `SELECT titel, ...` (오류 기대, exit 3) |
| ch02-08-alias-korean | 2.2 따라 하기 1단계 (한글 별칭) |
| ch02-09-alias-quoted | 2.2 따라 하기 2단계 (큰따옴표 별칭) |
| ch02-10-alias-without-as | 2.2 따라 하기 3단계 (AS 생략) — ch02-08과 출력이 같아야 한다. style.md R7의 **의도된 반례**(읽을 줄만 알면 되는 형태)다 |
| ch02-11-alias-single-quote-error | 2.2 왜 그럴까요 `AS '제목'` (오류 기대, exit 3) |
| ch02-12-missing-comma | 2.2 흔한 실수 `SELECT title author FROM books LIMIT 5;` — style.md R7의 근거가 되는 **의도된 반례**(쉼표 누락이 조용히 별칭으로 해석된다) |
| ch02-13-alias-page-count | 2.2 practice 1 풀이 |
| ch02-14-alias-not-a-column | 2.2 practice 2 풀이 `SELECT 제목 ...` (오류 기대, exit 3) |
| ch02-15-category-duplicates | 2.3 문제 상황 `SELECT category FROM books LIMIT 10;` |
| ch02-16-distinct-category | 2.3 따라 하기 1단계 `SELECT DISTINCT category FROM books;` |
| ch02-17-distinct-stock | 2.3 따라 하기 2단계 `SELECT DISTINCT stock FROM books;` |
| ch02-18-distinct-category-stock | 2.3 따라 하기 3단계 (두 열 조합) |
| ch02-19-distinct-parens | 2.3 흔한 실수 `DISTINCT(category)` — ch02-18과 출력이 같아야 한다 |
| ch02-20-distinct-category-alias | 2.3 practice 1 풀이 |
| ch02-21-ex1-new-arrivals | exercise 1 해설 |
| ch02-22-ex2-alias-list | exercise 2 해설 — 한 줄이면 89칸이라 style.md R4대로 두 줄 |
| ch02-23-pb1-print-list | problem 1 해설 (인쇄용 도서 목록) |
| ch02-24-pb2-distinct-stock-alias | problem 2 해설 (재고 수량 값의 종류) |
| ch02-25-pb3-distinct-author-title | problem 3 해설 (a) `SELECT DISTINCT author, title ... LIMIT 5;` |
| ch02-26-world-claims-counts | **주장 케이스** — 본문이 인용하는 수치 주장 12건 — books 8열·320행, category 8종, stock 10종, author 197종, title 320종, book_id 320종, (category, stock) 조합 80, (author, title) 조합 320, 재고 0인 요리책 7종·재고 60인 어린이책 4종, NULL이 든 행 0 |
| ch02-27-books-columns | **주장 케이스**(본문 표의 근거) — 2.1 «개념»의 `books` 열 표(이름·순서·타입) 8줄을 스키마에서 그대로 재구성한다 |

### 2장에서 의도적으로 출력이 같은 케이스 쌍

입력이 다른데 출력이 같아야 하는 것 자체가 본문의 주장인 쌍이다. `.expected`가
바이트 동일한 것은 중복이 아니라 회귀 검증의 대상이다.

| 쌍 | 본문의 주장 |
|---|---|
| ch02-08 = ch02-10 | 2.2 따라 하기 3단계 — `AS`를 생략해도 결과가 같다 |
| ch02-18 = ch02-19 | 2.3 흔한 실수 — `DISTINCT(열)`의 괄호는 아무 일도 하지 않는다 |

### 2장에서 출력 블록 없이 행 수만 언급한 질의

본문이 결과를 싣지 않고 `(N rows)`만 인용하는 질의들이다(결과가 길어 지면에 싣지
않았다). 인용한 수치는 전부 `ch02-26-world-claims-counts`가 고정한다.

| 질의 | 본문 위치 | 인용 수치 |
|---|---|---|
| `SELECT DISTINCT title FROM books;` | 2.3 practice 2 | 320행 |
| `SELECT DISTINCT book_id FROM books;` | 2.3 흔한 실수 | 320행 |
| `SELECT DISTINCT author FROM books;` | exercise 3, problem 3 (b)(c) | 197행 |
| `SELECT DISTINCT category, stock FROM books;` | 2.3 왜 그럴까요, exercise 4 | 80행 |
| `SELECT DISTINCT author, title FROM books;` | problem 3 지문·(a) 해설 | 320행 (`ch02-26`의 "(author, title) 조합의 가짓수") |

### 2장이 케이스를 새로 만들지 않은 출력

- 2.1 따라 하기 1단계의 `\d books`는 챕터가 출력을 다시 싣지 않고 1장 1.2절
  따라 하기 3단계를 참조하므로 케이스를 새로 만들지 않았다 — `ch01-02-d-books`가
  같은 출력을 이미 고정한다.
- 2.1 «개념»의 서식 규칙 예제 네 개는 **출력을 싣지 않으므로** 케이스를 만들지
  않았다 (검증 케이스 규약 — "출력을 싣지 않는 학습자용 입력 블록"의 (c)).
  어느 것도 기존 케이스와 입력이 같지 않다.
  - ① 일곱 열을 한 줄로 적은 86칸 질의 — R3·R4의 근거가 되는 **의도된 반례**다
    (아래 「2장의 의도된 반례」 참조).
  - ② 같은 질의를 절마다 나눈 것 — R4의 예제.
  - `SELECT title, author FROM books;` — R3의 예제. `ch02-01`과 달리 `LIMIT`이
    없어 입력이 같지 않다.
  - 여덟 열을 열마다 나눈 질의 — R5의 예제.

### 2장에서 주장 케이스에서 뺀 수치

- **출력 블록 안에서 학습자가 직접 셀 수 있는 수치는 넣지 않았다** (D-033).
  2.3 «문제 상황»의 「열 개만 봤는데도 `에세이`가 세 번, `역사`·`소설`·
  `자기계발`이 두 번씩」은 `ch02-15-category-duplicates`의 기대 출력 열 줄을
  세면 그대로 나온다. 2.3 따라 하기 1단계의 「320행이 8행으로 줄었다」의 8도
  `ch02-16`의 기대 출력에 찍혀 있다(320은 `ch02-26`이 따로 고정한다).
- 2.3 «개념»의 도식이 든 `(역사, 5)`·`(역사, 12)`·`(에세이, 5)` 세 조합은
  **주장 케이스로 고정하지 않았다.** 이 그림이 주장하는 것은 그 조합이 world에
  실재한다는 사실이 아니라 「두 열의 조합이 다르면 다른 행이다」라는 규칙이고,
  분야 이름과 재고 값은 그 규칙을 보이려고 고른 예시다 (world의 특정 행을 옮겨
  적은 표가 아니다). 조합의 **가짓수 80**은 `ch02-26`이 고정한다.

### 2장의 의도된 반례 (D-025)

2장은 서식 규약을 세우는 장이라 규칙의 근거가 되는 반례를 세 번 싣는다. 세 건
모두 D-025의 네 조건을 만족한다.

- **`ch02-10-alias-without-as`** (2.2 따라 하기 3단계, `AS` 생략) — ① R7의 선언
  지점(2.2 «흔한 실수» 끝)보다 **앞**에 있다. ② R7이 바로 이 코드를 근거로
  도입된다("따라 하기 3단계에서 보았듯 `AS` 없이 쓴 질의도 똑같이 동작하므로
  남이 쓴 코드에서 만나면 읽을 수 있어야 하지만, 직접 쓸 때는 적습니다"). ③ 회수
  서술이 같은 소절 안에 있다. ④ 위 케이스 목록의 그 줄에 "style.md R7의 의도된
  반례"라고 적어 두었다.
- **`ch02-12-missing-comma`** (2.2 «흔한 실수», 쉼표 누락) — ① R7 선언 직전에
  있다. ② "`AS`를 생략하면 쉼표를 빠뜨린 것이 오류가 아니라 별칭으로 해석되어
  조용히 지나가기 때문입니다 — 방금 본 그대로입니다"가 이 코드를 그대로 근거로
  든다. ③ [주의] 콜아웃이 같은 소절에서 회수한다. ④ 케이스 목록에 기록되어 있다.
- **케이스가 없는 반례 — 2.1 «개념»의 ①(일곱 열을 한 줄로 적은 86칸 질의).**
  ① R3·R4의 선언보다 앞이다. ② 본문이 "①은 86칸이라 들어가지 않습니다 — 이
  규칙이 다루는 경우가 아니니 규칙 둘로 넘어갑니다"라고 적어 R4를 이 코드에서
  끌어낸다. ③ "①과 ②는 같은 질의입니다"와 규칙 둘의 선언이 같은 소절 안에서
  회수한다. ④ **출력을 싣지 않아 케이스가 없으므로** 위 「2장이 케이스를 새로
  만들지 않은 출력」에 사유와 함께 적었다.

## ch03 — 3장 «원하는 행 고르기 — WHERE»

| 케이스 | 챕터에서의 위치 |
|---|---|
| ch03-01-books-title-category | 3.1 문제 상황 `SELECT title, category FROM books LIMIT 10;` |
| ch03-02-where-category-travel | 3.1 따라 하기 2단계 (여행 분야만) |
| ch03-03-where-title-only | 3.1 따라 하기 3단계 (조건 열을 선택 목록에서 뺀다) |
| ch03-04-where-price-41000 | 3.1 따라 하기 4단계 `price >= 41000` (LIMIT 없이 11행) |
| ch03-05-where-no-match | 3.1 왜 그럴까요 `category = '만화'` (0행) |
| ch03-06-where-unquoted-error | 3.1 흔한 실수 `= 여행` (오류 기대, exit 3) |
| ch03-07-where-trailing-space | 3.1 흔한 실수 `= '여행 '` (0행) |
| ch03-08-practice-cooking | 3.1 practice 1 풀이 |
| ch03-09-practice-page-count | 3.1 practice 2 풀이 `page_count > 700` |
| ch03-10-price-le-9000 | 3.2 따라 하기 1단계 `price <= 9000` (13행) |
| ch03-11-not-equal-travel | 3.2 따라 하기 2단계 `<>` |
| ch03-12-not-equal-bang | 3.2 따라 하기 2단계 뒤 `!=` — ch03-11과 출력이 같아야 한다 |
| ch03-13-between-price | 3.2 따라 하기 3단계 `BETWEEN 25000 AND 30000` |
| ch03-14-in-categories | 3.2 따라 하기 4단계 `IN ('여행', '요리')` |
| ch03-15-like-jeju | 3.2 따라 하기 5단계 `LIKE '%제주%'` (4행) |
| ch03-16-like-prefix | 3.2 따라 하기 6단계 `LIKE '한 권으로 읽는%'` |
| ch03-17-distinct-price-range | 3.2 왜 그럴까요 — BETWEEN이 양 끝을 포함한다는 증거 |
| ch03-18-between-reversed | 3.2 왜 그럴까요 `BETWEEN 30000 AND 25000` (0행) |
| ch03-19-equals-pattern | 3.2 흔한 실수 `title = '%제주%'` (0행) |
| ch03-20-like-no-wildcard | 3.2 흔한 실수 `title LIKE '제주'` (0행) |
| ch03-21-practice-under-10000 | 3.2 practice 1 풀이 `price < 10000` |
| ch03-22-practice-like-sajeon | 3.2 practice 2 풀이 `LIKE '%사전%'` |
| ch03-23-and-travel-cheap | 3.3 따라 하기 1단계 `AND` (LIMIT 없이 6행) |
| ch03-24-or-two-categories | 3.3 따라 하기 2단계 `OR` — ch03-14와 출력이 같아야 한다 |
| ch03-25-not-between | 3.3 따라 하기 3단계 `NOT (price BETWEEN ...)` |
| ch03-26-three-conditions | 3.3 따라 하기 4단계 — 조건 셋, style.md R10의 줄 나누기 |
| ch03-27-or-and-no-parens | 3.3 왜 그럴까요 — 괄호 없는 OR/AND (40행). style.md R12의 **의도된 반례** |
| ch03-28-or-and-parens | 3.3 왜 그럴까요 — 괄호를 친 같은 조건 (8행) |
| ch03-29-or-literal-error | 3.3 흔한 실수 `OR '요리'` (오류 기대, exit 3) |
| ch03-30-and-contradiction | 3.3 흔한 실수 `category = '여행' AND category = '요리'` (0행) |
| ch03-31-practice-essay-cheap | 3.3 practice 1 풀이 |
| ch03-32-practice-cook-kids-cheap | 3.3 practice 2 풀이 (괄호 친 OR + AND, 7행) |
| ch03-33-ex1-price-8000 | exercise 1 해설 `price <= 8000` (6행) |
| ch03-34-ex2-like-note-end | exercise 2 해설 `LIKE '%노트'` |
| ch03-35-ex3-published-2025 | exercise 3 해설 (날짜 비교) |
| ch03-36-ex3-unquoted-date-error | exercise 3 해설 — 날짜에서 작은따옴표를 뺀 질의 (오류 기대, exit 3). `2025-01-01`이 뺄셈 식으로 계산되어 `date >= integer` 오류가 난다 |
| ch03-37-ex4-in-and-price | exercise 4 해설 (`IN` + `AND`) |
| ch03-38-ex5-review-distinct-author | 복습 exercise 해설 (2장 DISTINCT·별칭 + 이 장의 WHERE) |
| ch03-39-pb1-travel-fair | problem 1 해설 (여행 도서전 매대 목록) |
| ch03-40-pb2-gift-corner | problem 2 해설 (조건 셋 + 별칭 셋) |
| ch03-41-pb3-fixed-query | problem 3 해설 — 동료의 0행 질의를 고친 것 |
| ch03-42-world-claims-counts | **주장 케이스** — 본문이 인용하는 수치 주장 53건 (분야별·가격대별·패턴별 행 수, 괄호 유무에 따른 40 대 8·48 대 62·20 대 51 등) |
| ch03-43-world-claims-text | **주장 케이스** — exercise 3 지문의 「책숲의 책은 1998년부터 2026년까지 걸쳐 있습니다」를 뒷받침하는 날짜 주장 2건 (가장 이른 출간일 1998-01-19, 가장 늦은 출간일 2026-06-18). 값이 정수가 아니라 날짜라 ch03-42와 나눴다 (pipeline "주장 케이스" — 값의 타입이 섞이면 케이스를 나눈다). **4장의 같은 주장도 이 케이스가 뒷받침한다** — 4.1 practice 2의 「맨 위가 2026년 6월 18일」과 exercise 2 해설의 「가장 오래된 책은 1998년 1월 19일」이 같은 값이고 질의도 같으므로 4장에 중복 케이스를 만들지 않았다 (검증 케이스 규약 — 입력이 같으면 같은 케이스다) |

### 3장에서 의도적으로 출력이 같은 케이스 쌍

| 쌍 | 본문의 주장 |
|---|---|
| ch03-11 = ch03-12 | 3.2 따라 하기 2단계 — `!=`는 `<>`의 별칭이라 결과가 한 글자도 다르지 않다 |
| ch03-14 = ch03-24 | 3.3 따라 하기 2단계 — `IN (a, b)`와 `= a OR = b`의 결과가 한 줄도 다르지 않다 |

### 3장에서 출력 블록 없이 행 수만 언급한 질의

본문이 결과를 싣지 않고 `(N rows)`만 인용하거나, 실린 케이스에서 `LIMIT`만 뗀
질의들이다. 인용한 수치는 전부 `ch03-42-world-claims-counts`가 고정한다.

| 질의 | 본문 위치 | 인용 수치 |
|---|---|---|
| `SELECT title, category FROM books;` (WHERE 없음) | 3.1 문제 상황, 3.1 왜 그럴까요 | 320행 |
| ch03-02에서 `LIMIT`을 뗀 질의 (여행 분야) | 3.1 따라 하기 2단계 | 36행 |
| ch03-08에서 `LIMIT`을 뗀 질의 (요리 분야) | 3.1 practice 1 | 44행 |
| ch03-09에서 `LIMIT`을 뗀 질의 (700쪽 초과) | 3.1 practice 2 | 30행 |
| ch03-11에서 `LIMIT`을 뗀 질의 (`<> '여행'`) | 3.2 따라 하기 2단계 | 284행 |
| ch03-13에서 `LIMIT`을 뗀 질의 (25000~30000원) | 3.2 따라 하기 3단계 | 59행 |
| ch03-14/ch03-24에서 `LIMIT`을 뗀 질의 (여행·요리) | 3.2 따라 하기 4단계, 3.3 따라 하기 2단계 | 80행 |
| ch03-16에서 `LIMIT`을 뗀 질의 (`'한 권으로 읽는%'`) | 3.2 따라 하기 6단계 | 32행 |
| ch03-21에서 `LIMIT`을 뗀 질의 (1만 원 미만) | 3.2 practice 1 | 21행 |
| ch03-22에서 `LIMIT`을 뗀 질의 (`'%사전%'`) | 3.2 practice 2 | 41행 |
| `... WHERE title LIKE '%사전';` (사전으로 끝남) | 3.2 practice 2 해설 | 41행 |
| ch03-25에서 `LIMIT`을 뗀 질의 (1만~4만 원 밖) | 3.3 따라 하기 3단계 | 38행 |
| ch03-27에서 `LIMIT`을 뗀 질의 (괄호 없는 OR/AND) | 3.3 왜 그럴까요 | 40행 |
| `... WHERE category = '요리' AND price <= 10000;` | 3.3 왜 그럴까요 (40행의 내역) | 4종 |
| ch03-34에서 `LIMIT`을 뗀 질의 (`'%노트'`) | exercise 2 | 43행 |
| ch03-35에서 `LIMIT`을 뗀 질의 (2025-01-01 이후) | exercise 3 | 15행 |
| ch03-37에서 `LIMIT`을 뗀 질의 (여행·요리 & 2만 원 이상) | exercise 4 | 48행 |
| `... WHERE (category = '여행' OR category = '요리') AND price >= 20000 LIMIT 5;` | exercise 4 해설의 대안 풀이 | 행 수 인용 없음 (48행짜리 ch03-37과 같은 조건) |
| ch03-39에서 `LIMIT`을 뗀 질의 (여행 & 2만 원 이하) | problem 1 | 14행 |
| ch03-40에서 `LIMIT`을 뗀 질의 (선물 코너) | problem 2 | 20행 |
| ch03-41에서 `LIMIT`을 뗀 질의 (고친 질의) | problem 3 (c) | 27행 |
| `... WHERE category = '여행' OR category = '요리' AND price <= 15000;` | problem 3 채점 포인트 | 52행 |
| `... WHERE category = '요리' OR category = '어린이' AND price < 10000;` | 3.3 practice 2 해설 | 47행 |
| `... WHERE category IN ('요리', '어린이') AND price < 10000;` | 3.3 practice 2 해설 | 7행 (같은 결과) |
| `... WHERE price <= '8000';` (따옴표 붙인 숫자) | exercise 1 채점 포인트 | 6행 (같은 결과) |
| `... WHERE price < 8000;` | exercise 1 해설·채점 포인트 | 0행 |
| `... WHERE title = '%노트';` | exercise 2 채점 포인트 | 0행 |
| `... WHERE published_date > '2025-01-01';` | exercise 3 채점 포인트 | 15행 (같은 결과 — 2025-01-01에 출간된 도서 0종) |
| `... WHERE category = '여행' OR category = '요리' AND price >= 20000;` | exercise 4 해설·채점 포인트 | 62행 |
| `... WHERE category = '요리' AND price >= 20000;` | exercise 4 해설 (62행의 내역) | 26종 |
| `... WHERE category = '여행' AND price >= 30000;` | 복습 exercise 지문 (b)·해설 | 9종 |
| `... WHERE category IN ('어린이', '요리') AND price BETWEEN 10000 AND 20000 AND stock > 0;` | problem 2 해설 | 20행 (같은 결과) |
| `... WHERE category = '어린이' OR category = '요리' AND price BETWEEN 10000 AND 20000 AND stock >= 1;` | problem 2 채점 포인트 | 51행 |
| `... WHERE category = '여행' AND category = '요리' AND price <= 15000;` | problem 3 지문·(a) 해설 | 0행 |

### 3장이 케이스를 새로 만들지 않은 출력

- 3.1 따라 하기 1단계의 `\d books`는 챕터가 출력을 다시 싣지 않고 1장 1.2절
  따라 하기 3단계를 참조하므로 케이스를 새로 만들지 않았다 — `ch01-02-d-books`가
  같은 출력을 이미 고정한다 (2장과 같은 처리다).
- 3.1 «개념»의 서식 규칙 예제(R8을 선언하며 싣는 세 줄짜리 질의)는 **출력을
  싣지 않으므로** 케이스를 만들지 않았다 (2장과 같은 처리다 — 검증 케이스 규약의
  (c)). 어느 케이스 입력과도 바이트 동일하지 않다.

### 3장에서 우연히 바이트가 같은 케이스

- **`ch03-05`·`ch03-07`·`ch03-18`·`ch03-19`·`ch03-20`·`ch03-30`의 기대 출력이
  서로 바이트 동일한 것은 우연이다.** 여섯 케이스는 모두 `SELECT title FROM books
  WHERE ...` 꼴이고 결과가 0행이라 머리글 두 줄과 `(0 rows)`만 남는 **구조적**
  동일이다. 본문 어디도 두 출력이 같다는 것을 주장의 근거로 쓰지 않으므로
  「의도적으로 출력이 같은 케이스 쌍」 표에는 넣지 않는다 — 그 표는 바이트
  동일성 자체가 본문 주장의 근거인 쌍의 자리이고 도구가 `cmp`로 검사한다.

### 3장에서 주장 케이스에서 뺀 수치

- **출력 블록 안에서 학습자가 직접 셀 수 있는 수치는 넣지 않았다** (D-033).
  3.1 «문제 상황»의 「열 줄 중 여행 분야는 네 번째 한 줄뿐이고 나머지 아홉 줄」은
  `ch03-01`의 기대 출력 열 줄에서 그대로 세고, 3.2 따라 하기 6단계의 「다섯 줄
  모두 그 말로 시작합니다」와 practice 2 해설의 「실린 다섯 줄은 모두 `사전`으로
  끝납니다」도 각각 `ch03-16`·`ch03-22`의 기대 출력에서 센다. 그 질의들에서
  `LIMIT`을 뗀 **전체 행 수**(32·41)는 출력에 찍히지 않으므로 위 D-021 표에
  넣고 `ch03-42`가 고정한다.

### 3장의 의도된 반례 (D-025)

- `ch03-27-or-and-no-parens` — 3.3 «왜 그럴까요»가 style.md **R12**(괄호로
  우선순위를 드러낸다)를 세우기 **전에** 싣는 코드다. 규칙을 어긴 질의가 40행을
  내고 괄호를 친 `ch03-28`이 8행을 내는 대비가 곧 R12의 근거이며, 같은 소절
  안에서 "이 절이 곧 세울 규칙을 일부러 어긴 것"이라고 밝히고 규칙을 선언해
  회수한다.

## ch04 — 4장 «순서 매기고 개수 줄이기 — ORDER BY·LIMIT»

| 케이스 | 챕터에서의 위치 |
|---|---|
| ch04-01-cheap-books-unsorted | 4.1 문제 상황 `WHERE price <= 8500` (정렬 없음, 9행) |
| ch04-02-order-by-price | 4.1 따라 하기 1단계 `ORDER BY price` (오름차순) |
| ch04-03-order-by-price-desc | 4.1 따라 하기 2단계 `ORDER BY price DESC` |
| ch04-04-travel-cheap-sorted | 4.1 따라 하기 3단계 — WHERE로 고른 뒤 ORDER BY로 세운다 |
| ch04-05-expensive-tie | 4.1 따라 하기 4단계 — 정렬 키가 하나뿐일 때 동점 행의 순서 (11행) |
| ch04-06-expensive-two-keys | 4.1 따라 하기 5단계 — 2차 정렬 키로 동점을 가른다 |
| ch04-07-alias-in-where-error | 4.1 왜 그럴까요 — 별칭은 `WHERE`에서 못 쓴다 (오류 기대, exit 3) |
| ch04-08-alias-in-order-by | 4.1 왜 그럴까요 — 같은 별칭이 `ORDER BY`에서는 동작한다 |
| ch04-09-order-by-before-where-error | 4.1 왜 그럴까요 — `ORDER BY`를 `WHERE` 앞에 두면 문법 오류 (exit 3) |
| ch04-10-second-key-default-asc | 4.1 흔한 실수 — `ORDER BY price DESC, page_count`의 둘째 키는 오름차순 |
| ch04-11-source-order-unchanged | 4.1 흔한 실수 — 정렬해도 원래 테이블의 행 차례는 그대로 (ch04-01과 같은 행 차례) |
| ch04-12-practice-thick-books | 4.1 practice 1 풀이 (쪽수 내림차순 + 정가 내림차순) |
| ch04-13-practice-newest-2026 | 4.1 practice 2 풀이 (2026년 출간, 최신순) |
| ch04-14-limit-3-no-order | 4.2 따라 하기 1단계 — `LIMIT`만 쓰면 아무 3행. 입력이 `ch01-09-books-title-price`와 **바이트 동일**하다(1.3 [미리보기]) — 사정은 아래 「4장이 케이스를 새로 만들지 않은 출력」의 마지막 문단에 적었다 |
| ch04-15-top5-price-desc | 4.2 따라 하기 2단계 — `ORDER BY` + `LIMIT` = 상위 5종 |
| ch04-16-top5-offset5 | 4.2 따라 하기 3단계 — `LIMIT 5 OFFSET 5`로 6~10위 |
| ch04-17-limit-more-than-rows | 4.2 따라 하기 4단계 — 남은 행이 `LIMIT`보다 적으면 있는 만큼만 (2행) |
| ch04-18-top10-price-desc | 4.2 왜 그럴까요 — `LIMIT 10`의 앞 5줄이 ch04-15와 차례가 다르다 |
| ch04-19-top5-unique-key | 4.2 왜 그럴까요 — `book_id`를 마지막 정렬 키로 둔 상위 5종 |
| ch04-20-top10-unique-key | 4.2 왜 그럴까요 — 같은 정렬의 `LIMIT 10`. 앞 5줄의 **행 내용과 차례**가 ch04-19와 같아야 한다 (열 너비는 다르다 — 아래 대비 표 참조) |
| ch04-21-limit3-offset3 | 4.2 흔한 실수 — `OFFSET 3`은 4~6위 (ch04-20의 4·5·6번째 줄과 **같은 세 권이 같은 차례로** 나와야 한다) |
| ch04-22-limit-before-order-error | 4.2 흔한 실수 — `LIMIT`을 `ORDER BY` 앞에 두면 문법 오류 (exit 3) |
| ch04-23-practice-cheapest-3 | 4.2 practice 1 풀이 (가장 싼 3종) |
| ch04-24-practice-newest-page2 | 4.2 practice 2 풀이 (한 쪽 3종짜리 목록의 2쪽) |
| ch04-25-ex1-thin-books | exercise 1 해설 (쪽수가 적은 5종) |
| ch04-26-ex2-oldest-books | exercise 2 해설 (가장 오래된 3종) |
| ch04-27-ex3-travel-expensive | exercise 3 해설 (여행 분야 비싼 순 5종 + 별칭 2개) |
| ch04-28-ex4-midprice-newest | exercise 4 해설 (`BETWEEN` + 최신순 5종) |
| ch04-29-ex5-review-distinct-prices | 복습 exercise 해설 (2장 DISTINCT·별칭 + 3장 WHERE + 이 장 ORDER BY·LIMIT) |
| ch04-30-pb1-cooking-new | problem 1 해설 (요리 분야 재고 있는 신간 3종) |
| ch04-31-pb2-new-arrivals-page3 | problem 2 해설 (신간 목록 3쪽 — `LIMIT 5 OFFSET 10`) |
| ch04-32-pb3-low-stock-5 | problem 3 (a) — 동료가 쓴 질의 (`LIMIT 5`) |
| ch04-33-pb3-low-stock-8 | problem 3 (a) — 같은 질의의 `LIMIT 8`. 앞 5줄의 4·5번째 자리에 ch04-32와 **다른 책**이 들어가야 한다 |
| ch04-34-pb3-low-stock-fixed | problem 3 (b)(c) 해설 — 정렬 키를 셋으로 늘려 고친 질의 |
| ch04-35-world-claims-counts | **주장 케이스** — 본문이 인용하는 수치 주장 33건 (가격대별·쪽수별·분야별 행 수, 최고가·최저가, 가장 많은/적은 쪽수, `book_id`의 유일성, 42000원 동점 세 권의 book_id, 그리고 `OFFSET`을 `LIMIT` 앞에 적은 형태가 문법 오류가 아니라는 것). 출간일의 양 끝은 값이 날짜라 이 표에서 뺐다 — `ch03-43-world-claims-text`가 같은 질의로 고정한다 |

### 4장에서 출력 블록 없이 행 수·수치만 언급한 질의

본문이 결과를 싣지 않고 개수만 인용하는 질의들이다(결과가 길거나, 본문의 다른
질의를 설명하기 위한 곁가지다). 인용한 수치는 전부 `ch04-35-world-claims-counts`가
고정한다.

| 질의 | 본문 위치 | 인용 수치 |
|---|---|---|
| `SELECT title, price FROM books ORDER BY price DESC;` (LIMIT 없음) | 4.2 문제 상황 | 320행 |
| `... WHERE price >= 41500;` | 4.2 문제 상황 | 6종 |
| `... WHERE price = 42000;` | 4.2 문제 상황 | 3종 |
| `SELECT DISTINCT book_id FROM books;` | 4.2 왜 그럴까요 [미리보기] | 320가지 (= 행 수) |
| `... WHERE price = 8000;` | 4.2 practice 1 해설 | 6종 |
| `... WHERE category = '여행';` | exercise 3 해설 | 36종 |
| `... WHERE price BETWEEN 10000 AND 20000;` | exercise 4 해설 | 106종 |
| `SELECT DISTINCT price FROM books WHERE category = '여행';` | 복습 exercise 해설 | 26행 |
| `... WHERE category = '요리';` | problem 1 해설 | 44종 |
| `... WHERE category = '요리' AND stock >= 1;` | problem 1 해설 | 37종 |
| `... WHERE published_date >= '2025-01-01';` | problem 2 해설 | 15종 |
| `... WHERE published_date >= '2026-01-01' AND price BETWEEN 10000 AND 20000;` | exercise 4 해설 ("여덟 종 중 이 가격대는 한 종뿐") | 1종 |
| `... WHERE category = '어린이' AND stock = 0;` | problem 3 힌트·(a) 해설 | 3종 |
| `... WHERE category = '어린이' AND stock = 1;` | problem 3 힌트·(a) 해설 | 4종 |

### 4장에서 주장 케이스에서 뺀 수치

- **출력 블록 안에서 학습자가 직접 셀 수 있는 수치는 위 표에 넣지 않았다**
  (D-033). 4.1 practice 1의 "760쪽 다섯 종", 4.1 따라 하기 4·5단계의 "42000원
  셋·41500원 셋·41000원 다섯", exercise 1의 "가장 얇은 책 120쪽", 4.1 practice 2의
  "맨 위가 2026년 6월 18일", exercise 2 해설의 "1998년 1월 19일"이 그렇다. 다만
  네 수치는 `ch04-35-world-claims-counts`가, 두 날짜는 `ch03-43-world-claims-text`가
  회귀 방어용으로 함께 고정한다.

### 4장에서 의도적으로 정렬 순서가 흔들리는 케이스 (부분 등가)

4장은 "`ORDER BY`가 동점을 남기면 `LIMIT` 값에 따라 결과가 달라진다"는 공식 문서의
경고를 **실행으로 보이는** 장이다. 아래 케이스들은 그 대비를 만들기 위해 일부러
유일한 정렬 키를 두지 않았다. 기대 출력이 이 world·이 PostgreSQL 버전에서 관측된
순서를 고정한 것이므로, **차이가 사라지면(= 두 결과의 앞부분이 같아지면) 본문의
주장이 무너진다.** 러너가 그 회귀를 잡는 지점이다.

| 케이스 쌍 | 본문의 주장 |
|---|---|
| ch04-15 ↔ ch04-18 | 4.2 왜 그럴까요 — `LIMIT 5`와 `LIMIT 10`의 앞 5줄에는 **같은 다섯 권**이 들어가지만 **차례가 다르다**(42000원 세 권 중 앞 두 권의 차례와, 41500원 두 권의 차례가 각각 뒤바뀐다). 41500원은 동점이 세 권인데 다섯 자리에 두 권만 들어가므로, 어느 두 권이 뽑힐지가 보장되지 않는다는 것이 본문의 요지다 |
| ch04-19 ↔ ch04-20 | 4.2 왜 그럴까요 — 마지막 정렬 키로 `book_id`를 얹으면 앞 5줄의 **행 내용과 차례**가 같다 (위 쌍의 교정본). psql은 결과에 든 가장 긴 값에 맞춰 열 너비를 잡으므로 두 `.expected`의 앞 5줄이 **바이트로 같지는 않다** — 러너도 케이스 사이의 바이트 비교는 하지 않는다 |
| ch04-32 ↔ ch04-33 | problem 3 (a) — 동료 질의의 `LIMIT 5`와 `LIMIT 8`은 앞 5줄에 서로 다른 책이 들어간다 |

`ch04-05`(정렬 키 하나)와 `ch04-06`(2차 키 추가), `ch04-10`(둘째 키가 오름차순)도
같은 계열의 대비이며, 셋 다 4.1절 본문이 출력을 나란히 싣고 설명한다.

### 4장이 케이스를 새로 만들지 않은 출력

- 4.1 따라 하기의 psql 접속 명령(`docker exec -it ...`)은 1장 1.2절 따라 하기
  1단계를 참조할 뿐 출력을 싣지 않는다. 3장 problem 2 힌트가 언급한 `\d books`도
  같으며, 출력을 싣는 자리는 `ch01-02-d-books`가 이미 고정한다 (2·3장과 같은
  처리다).
- 4장이 인용하는 **출간일의 양 끝**(가장 이른 1998-01-19, 가장 늦은 2026-06-18)은
  3장이 같은 질의로 이미 고정하므로 4장 케이스를 새로 만들지 않았다 —
  `ch03-43-world-claims-text`가 그 자리다 (검증 케이스 규약 — 입력이 같으면 같은
  케이스다).
- **`ch04-14-limit-3-no-order`는 `ch01-09-books-title-price`와 입력이 바이트
  동일하다** (머리 주석을 빼면 둘 다 `SELECT title, price FROM books LIMIT 3;`).
  지금 규약이라면 `ch01-09` 줄에 4.2 따라 하기 1단계를 덧붙이고 끝냈을 자리이나,
  「입력이 같으면 같은 케이스다」는 4장 승인(2026-08-26) **뒤에** 선 규칙이고,
  지금 `ch04-14`를 지우면 4.2 따라 하기 1단계의 출력 블록이 `ch04-*` 어느
  케이스와도 짝이 없어져 `check_chapter.py` H8의 역방향 대조가 4장에 영구히
  WARN을 낸다(H8은 `chNN-` 접두사가 **그 장의 번호와 같은** 케이스만 본다).
  잃는 것이 얻는 것보다 크므로 케이스를 그대로 두고, 두 줄에 상호 참조를 적는
  것으로 대신한다. 두 기대 출력이 바이트 동일한 데 대한 판정은 아래
  「4장에서 우연히 바이트가 같은 케이스」에 적었다.

### 4장에서 우연히 바이트가 같은 케이스

- **`ch01-09-books-title-price` = `ch04-14-limit-3-no-order`.** 두 기대 출력이
  바이트 동일한 것은 우연이 아니라 **입력 중복**의 결과다 (머리 주석을 빼면 둘 다
  `SELECT title, price FROM books LIMIT 3;` — 사정은 위 「4장이 케이스를 새로
  만들지 않은 출력」의 마지막 항목에 적었다). 다만 그 동일성은 **본문의 주장이
  아니다** — 어느 장도 "1장과 같다"고 말하지 않는다. 따라서 「의도적으로 출력이
  같은 케이스 쌍」 표에는 넣지 않고 이 절에 판정만 남긴다.

### 4장의 의도된 반례 (D-025)

- **없다.** 4장이 도입하는 서식 규칙 R13~R16은 모두 «개념»에서 선언되고, 그 뒤의
  코드는 전부 규칙을 지킨다. R15가 거부하는 `ORDER BY 2`와 R14가 생략하라고 한
  `ASC`는 **규칙을 선언하는 문장이 인용한 형태**일 뿐 실행되는 펜스 코드가 아니다
  (`ch04-10-second-key-default-asc`도 질의 자체에는 `ASC`를 적지 않는다 — 머리
  주석이 "둘째 키는 DESC가 아니라 ASC다"라고 설명할 뿐이다).
- 2·3장이 `LIMIT`을 미리 쓴 것은 R16이 서기 전의 일이라 `style.md` §0의 소급 적용
  금지에 해당하지 D-025의 반례가 아니다. 4장 본문도 그 사실을 밝힌다.
- `ch04-07`·`ch04-09`·`ch04-22`(세 가지 오류)와 `ch04-11`(정렬해도 원본 차례는
  그대로)은 **내용**이 대상인 반례이지 서식 규칙을 어긴 코드가 아니다.

## ch05 — 5장 «값이 없다는 것 — NULL»

| 케이스 | 챕터에서의 위치 |
|---|---|
| ch05-01-orders-first-10 | 5.1 문제 상황 — `orders` 앞 10건 (4·9번의 발송일이 빈칸) |
| ch05-02-shipped-eq-null | 5.1 문제 상황 — `WHERE shipped_date = NULL` (오류 없이 0행) |
| ch05-03-shipped-is-null | 5.1 따라 하기 1단계 — `IS NULL`로 고쳐 행이 나온다 |
| ch05-04-shipped-is-not-null | 5.1 따라 하기 2단계 — `IS NOT NULL` |
| ch05-05-birth-date-is-null | 5.1 따라 하기 3단계 — `customers.birth_date`의 NULL |
| ch05-06-comment-is-null | 5.1 따라 하기 4단계 — `reviews.comment`의 NULL |
| ch05-07-is-null-and-status | 5.1 따라 하기 5단계 — 3장의 `AND`·`<>`와 엮는다 |
| ch05-08-null-comparisons | 5.1 왜 그럴까요 — `NULL = NULL`·`1 = NULL`·`NULL IS NULL`의 결과 |
| ch05-09-shipped-ne-null | 5.1 왜 그럴까요 — `<> NULL`도 0행 |
| ch05-10-order-by-null-asc | 5.1 왜 그럴까요 — 오름차순에서 NULL은 맨 뒤 (고객 4의 주문 6건) |
| ch05-11-order-by-null-desc | 5.1 왜 그럴까요 — 같은 6건, `DESC`에서는 NULL이 맨 앞 |
| ch05-12-comment-empty-string | 5.1 흔한 실수 — `comment = ''`는 0행 |
| ch05-13-shipped-empty-string-error | 5.1 흔한 실수 — 날짜 열에 `= ''` (오류 기대, exit 3) |
| ch05-14-cancelled-is-null | 5.1 흔한 실수 — 취소된 주문의 발송일도 NULL |
| ch05-15-practice-birth-null | 5.1 practice 1 풀이 |
| ch05-16-practice-comment-null-rating5 | 5.1 practice 2 풀이 |
| ch05-17-reviews-raw | 5.2 문제 상황 — 리뷰 6건, 5·6번의 코멘트가 빈칸 |
| ch05-18-coalesce-comment | 5.2 따라 하기 1단계 — `COALESCE` 적용 (머리글이 `coalesce`) |
| ch05-19-coalesce-alias | 5.2 따라 하기 2단계 — 별칭으로 머리글을 고친다 (style.md R19) |
| ch05-20-coalesce-rules | 5.2 따라 하기 3단계 — 짧은 식으로 규칙 확인 |
| ch05-21-coalesce-rating5-latest | 5.2 따라 하기 4단계 — 3·4장의 절과 함께 |
| ch05-22-table-unchanged | 5.2 왜 그럴까요 — 테이블의 `comment`는 여전히 NULL |
| ch05-23-coalesce-order-swapped | 5.2 왜 그럴까요 — 인자 순서를 뒤집으면 전부 첫 인자 |
| ch05-24-coalesce-type-error | 5.2 흔한 실수 — 날짜 열을 글자로 채우면 오류 (exit 3) |
| ch05-25-coalesce-empty-string | 5.2 흔한 실수 — 빈 문자열로 채우면 화면이 그대로다 |
| ch05-26-practice-coalesce-rating1 | 5.2 practice 1 풀이 |
| ch05-27-practice-coalesce-order-id | 5.2 practice 2 풀이 — 숫자 열의 NULL을 0으로 |
| ch05-28-ex1-comment-null-latest | exercise 1 해설 |
| ch05-29-ex2-birth-date-oldest | exercise 2 해설 |
| ch05-30-ex3-coalesce-low-rating-2026 | exercise 3 해설 |
| ch05-31-ex5-review-null-first | 복습 exercise (a) — `DESC`에서 NULL이 앞을 차지한 결과 |
| ch05-32-ex5-review-fixed | 복습 exercise (b)(c) — `IS NOT NULL`로 거른 질의 |
| ch05-33-pb1-pending-shipments | problem 1 해설 (발송 현황판) |
| ch05-34-pb2-review-print | problem 2 해설 (빈칸 없는 리뷰 표) |
| ch05-35-pb3-comment-eq-null | problem 3 (a) — 동료가 쓴 `WHERE comment = NULL` (0행) |
| ch05-36-pb3-fixed | problem 3 (b)(c) 해설 — `IS NULL`로 고친 질의 |
| ch05-37-world-claims-counts | **주장 케이스** — 본문이 인용하는 수치 주장 35건 (NULL·NOT NULL 개수, 상태별 주문 수, 고객 4의 주문 내역, `= NULL`·`<> NULL`·`= ''`이 찾는 행 수 0, `books` 8열 전부 NOT NULL 등) |
| ch05-38-world-claims-text | **주장 케이스** — 본문이 인용하는 날짜 주장 3건 (복습 exercise의 가장 늦은 발송일 2026-08-22, problem 1의 발송 대기 중 가장 이른 주문일 2024-03-07, exercise 2의 가장 이른 생일 1962-03-10). 값이 정수가 아니라 날짜라 ch05-37과 나눴다 (pipeline "주장 케이스" — 값의 타입이 섞이면 케이스를 나눈다) |

### 5장에서 출력 블록 없이 행 수만 언급한 질의

본문이 결과를 싣지 않고 `(N rows)`만 인용하거나, 실린 케이스에서 `LIMIT`만 뗀
질의들이다. 인용한 수치는 전부 `ch05-37-world-claims-counts`가 고정하고,
날짜 주장은 `ch05-38-world-claims-text`가 고정한다.

| 질의 | 본문 위치 | 인용 수치 |
|---|---|---|
| ch05-03에서 `LIMIT`을 뗀 질의 (발송일 없는 주문) | 5.1 따라 하기 1단계 | 144행 |
| ch05-04에서 `LIMIT`을 뗀 질의 (발송된 주문) | 5.1 따라 하기 2단계 | 476행 |
| ch05-05에서 `LIMIT`을 뗀 질의 (생일 미기재 고객) | 5.1 따라 하기 3단계 | 41행 |
| ch05-06에서 `LIMIT`을 뗀 질의 (코멘트 없는 리뷰) | 5.1 따라 하기 4단계 | 189행 |
| ch05-07에서 `LIMIT`을 뗀 질의 (발송 대기, 취소 제외) | 5.1 따라 하기 5단계 | 83행 |
| ch05-14에서 `LIMIT`을 뗀 질의 (취소된 주문) | 5.1 흔한 실수 | 61행 |
| ch05-15에서 `LIMIT`을 뗀 질의 | 5.1 practice 1 | 41행 |
| ch05-16에서 `LIMIT`을 뗀 질의 | 5.1 practice 2 | 64행 |
| `SELECT COALESCE(comment, '별점만 남겼습니다') AS "리뷰 내용" FROM reviews;` | 5.2 흔한 실수 | 520행 |
| ch05-26에서 `LIMIT`을 뗀 질의 | 5.2 practice 1 | 23행 |
| ch05-30에서 `LIMIT`을 뗀 질의 | exercise 3 | 122행 |
| `SELECT review_id FROM reviews WHERE comment IS NULL;` | exercise 4 지문·해설 | 189행 |
| `SELECT review_id FROM reviews WHERE comment IS NOT NULL;` | exercise 4 지문·해설 | 331행 |
| `SELECT review_id FROM reviews WHERE comment = '';` | exercise 4 지문·해설 | 0행 |
| ch05-33에서 `LIMIT`을 뗀 질의 (발송 대기 전체) | problem 1 해설 | 83행 |
| ch05-34에서 `LIMIT`을 뗀 질의 (별점 4점 이상) | problem 2 해설 | 331행 |
| ch05-36에서 `ORDER BY`·`LIMIT`을 뗀 질의 | problem 3 (c) 해설 | 189행 |

5.1 "왜 그럴까요"의 대비 표(144·476·620·0·0)와 5.1 개념·요약이 인용하는
`orders` 620행, `customers` 150명, `reviews` 520건, `books` 320행·8열,
3장에서 얻은 여행 36종·비여행 284종도 모두 `ch05-37`이 함께 고정한다.

### 5장에서 주장 케이스에서 뺀 수치

- **출력 블록 안에서 학습자가 직접 셀 수 있는 수치는 위 표에 넣지 않았다**
  (D-033). exercise 1 해설의 「가장 최근 것이 2026년 8월 23일」은
  `ch05-28-ex1-comment-null-latest`의 기대 출력 첫 줄에 그대로 찍혀 있고,
  5.1 «문제 상황»의 「4·9번의 발송일이 빈칸」은 `ch05-01`의 열 줄에서 센다.
  5.2 따라 하기 1·2단계의 「여섯 줄 중 5·6번 줄이 비어 있다」도 같다
  (`ch05-17`·`ch05-18`·`ch05-19`·`ch05-25`).
- **이미 바이트로 고정된 값들의 산술은 새 주장이 아니다** (D-032). exercise 4의
  「189 + 331 = 520」은 세 값이 각각 `ch05-37`의 기대 출력에 바이트로 박혀 있으므로
  합 자체를 별도 행으로 고정하지 않았다 — world가 바뀌면 세 행이 먼저 깨진다.

### 5장에서 의도적으로 출력이 같은 케이스 쌍 (D-022)

입력이 다른데 기대 출력이 **바이트 동일한** 쌍이다. 그 동일성 자체가 본문 주장의
기계적 증거이므로 중복이 아니라 회귀 검증의 대상이며, 케이스를 합치지 않는다
(D-022). `check_chapter.py`가 이 표를 읽어 `cmp`한다.

| 쌍 | 본문의 주장 |
|---|---|
| ch05-12 = ch05-35 | 널을 값처럼 견주는 **두 가지 잘못된 조건이 똑같이 0행을 낸다.** `ch05-12`는 `WHERE comment = ''`(5.1 «흔한 실수»), `ch05-35`는 `WHERE comment = NULL`(problem 3 (a)의 동료 질의)이고 선택 목록·테이블이 같아 결과가 바이트 단위로 같다. 뒷받침하는 본문 주장 — exercise 4 채점 포인트 "`= ''`가 오류가 아니라 0행이라는 것을 확인했는가", problem 3 채점 포인트 "`comment = ''`로 고쳤다면 **여전히 0행**입니다" |

`ch05-02-shipped-eq-null`·`ch05-09-shipped-ne-null`도 0행이지만 선택 목록이 서로
달라(`order_date` 포함 여부) 열 구성이 다르므로 이 표에 넣지 않는다 — 바이트
동일이 아니다.

### 5장에서 의도적으로 거의 같은 출력을 내는 케이스 (부분 등가)

**바이트 등가 주장이 아니다** — 첫 줄(머리글)만 다르고 그 아래가 바이트 동일한
쌍이다. 위의 D-022 표와 성격이 다르므로 `=`가 아니라 `↔`로 적는다.

| 케이스 쌍 | 확인된 관계 | 본문의 주장 |
|---|---|---|
| ch05-17 ↔ ch05-25 | 두 `.expected`의 **1행(머리글)만 다르고 2행 이하는 바이트 동일**하다 (`diff`로 확인: `1c1`) | 5.2 흔한 실수 — "머리글만 `리뷰 내용`으로 바뀌었을 뿐, 5·6번 줄은 여전히 비어 있습니다" |
| ch05-18 ↔ ch05-19 | 같은 관계다 (`diff`가 `1c1`). 머리글이 `coalesce` ↔ `리뷰 내용`으로만 갈린다 | 5.2 따라 하기 2단계 — "여섯 줄의 내용은 1단계와 같고 머리글만 `리뷰 내용`으로 바뀌었습니다" |

네 케이스 모두 세 번째 열의 표시 폭이 24칸으로 같다 — 머리글(`comment`·
`coalesce`·`리뷰 내용`)이 아니라 결과에 든 가장 긴 값
`두고두고 읽을 책이에요`(22칸)가 폭을 정하고, 세 머리글 중 어느 것도 그보다
길지 않기 때문이다.

러너는 케이스 사이의 관계를 검사하지 않고(pipeline "러너가 검사하는 것과 검사하지
않는 것") `check_chapter.py`도 `↔` 표기는 읽지 않으므로, 이 관계는 사람이 `diff`로
확인한 것이다. 본문도 "바이트가 같다"가 아니라 한 블록 안에서 눈으로 확인되는
주장만 한다.

### 5장의 의도된 반례 (D-025)

- `ch05-02-shipped-eq-null` — 5.1 «문제 상황»이다. style.md **R17**(널 여부는
  `IS NULL`로 적는다)을 **선언하기 전에** `= NULL`을 써서 0행이 나오는 것을 보이고,
  바로 다음 «개념»이 그 결과를 근거로 R17을 세워 회수한다. 이 장의 존재 이유가 되는
  반례다.
- `ch05-09-shipped-ne-null`(5.1 «왜 그럴까요»)과 `ch05-35-pb3-comment-eq-null`
  (problem 3의 동료 질의)은 R17 **선언 이후**에 나오지만, R17이 명시한 예외
  ("`= NULL`·`<> NULL`로 쓴 형태 자체가 설명 대상인 자리")에 해당한다. 5.1 «개념»의
  [참고] 콜아웃이 "이 장에는 `= NULL`을 쓴 질의가 앞으로도 몇 번 더 나온다"고 미리
  밝혀 둔다. `ch05-08-null-comparisons`의 `NULL = NULL`·`1 = NULL`은 열의 널 여부를
  판정하는 조건이 아니라 비교의 결과값 자체를 보이는 식이므로 R17의 대상이 아니다.
- `ch05-18-coalesce-comment` — 5.2 «따라 하기» 1단계다. style.md **R19**(`COALESCE`로
  만든 열에는 별칭을 붙인다)를 **선언하기 전에** 일부러 별칭 없이 실행해, 머리글에
  `coalesce`가 찍히는 것을 보인다. 바로 다음 2단계(`ch05-19-coalesce-alias`)가 별칭을
  붙인 결과와 PostgreSQL 문서의 기본 열 이름 규칙을 근거로 R19를 세워 회수한다.
  본문은 1단계 머리말에서 "여기서는 일부러 별칭을 붙이지 않습니다"라고 미리 밝힌다.
  5.2 «개념»은 이 규칙을 선언하지 않고 "따라 하기에서 이유와 함께 정하겠다"고만 적어
  두므로, 반례가 규칙 선언보다 앞이라는 조건이 지켜진다.

### 5장이 케이스를 새로 만들지 않은 출력

- 5.1 따라 하기의 psql 접속 명령(`docker exec -it ...`)은 1장 1.2절 따라 하기
  1단계를 참조할 뿐 출력을 싣지 않는다 (2~4장과 같은 처리다).
- 5.1·5.2 «개념»의 서식 규칙 예제(R17을 선언하며 싣는 질의와 R18을 선언하며
  싣는 `COALESCE` 질의)는 **출력을 싣지 않으므로** 케이스를 만들지 않았다
  (검증 케이스 규약의 (c) — 2·3장과 같은 처리다). 어느 케이스 입력과도 바이트
  동일하지 않다. 6장 README가 "5장 R17 예제와 같은 처리다"라고 가리키는 자리가
  여기다.
- 5.1 문제 상황이 언급하는 `\d orders`와 들어가며가 언급하는 `\d books`는
  출력을 다시 싣지 않고 1장을 참조한다 — `ch01-03-d-orders`와
  `ch01-02-d-books`가 같은 출력을 이미 고정한다. 특히 "`books`의 여덟 열에
  빠짐없이 `not null`이 붙어 있다"와 "`orders`에서는 `shipped_date`에만
  붙어 있지 않다"는 두 진술의 근거가 그 두 케이스다.

## ch06 — 6장 «데이터 타입과 함수»

| 케이스 | 챕터에서의 위치 |
|---|---|
| ch06-01-order-items-raw | 6.1 문제 상황 — `order_items` 앞 5줄 (금액 열이 없다) |
| ch06-02-amount-multiply | 6.1 따라 하기 1단계 — `quantity * unit_price` |
| ch06-03-shipping-days | 6.1 따라 하기 2단계 — `shipped_date - order_date` (5장 `IS NOT NULL`과 함께) |
| ch06-04-title-author-concat | 6.1 따라 하기 3단계 — `title \|\| ' / ' \|\| author` |
| ch06-05-opt-in-boolean | 6.1 따라 하기 4단계 — 불리언 열이 그 자체로 검색 조건이 된다 |
| ch06-06-title-times-two-error | 6.1 왜 그럴까요 — `title * 2` (오류 기대, exit 3) |
| ch06-07-string-constant-times-two | 6.1 왜 그럴까요 — `'8000' * 2`, 문자열 상수는 문맥에 맞춰진다 |
| ch06-08-date-plus-integer | 6.1 왜 그럴까요 — `order_date + 3`은 날짜다 |
| ch06-09-integer-division | 6.1 흔한 실수 — `price / 1000`이 소수점을 버린다 |
| ch06-10-no-alias-column | 6.1 흔한 실수 — 별칭 없는 계산 열의 머리글이 `?column?`. style.md R22의 **의도된 반례**(D-025) |
| ch06-11-practice-top-amount | 6.1 practice 1 풀이 (금액 큰 순 5줄) |
| ch06-12-practice-slowest-shipping | 6.1 practice 2 풀이 (발송이 오래 걸린 5건) |
| ch06-13-null-first-desc | 6.1 practice 2 해설 — `WHERE`를 빼면 소요일이 없는 144건이 `DESC` 정렬에서 맨 앞을 차지한다 (5장 5.1절의 규칙이 계산 열에도 적용된다) |
| ch06-14-divide-integers | 6.2 문제 상황 — `9500 / 1000`이 9다 |
| ch06-15-cast-numeric-scalar | 6.2 따라 하기 1단계 — `CAST(9500 AS numeric) / 1000` |
| ch06-16-cast-price-thousand | 6.2 따라 하기 2단계 — `books`에 형변환 적용 |
| ch06-17-colon-cast-price-thousand | 6.2 따라 하기 3단계 — `price::numeric` 표기. ch06-16과 출력이 바이트 동일해야 한다 (아래 D-022 절). style.md **R21의 명시된 예외**(두 표기가 같은 일을 한다는 것을 실행으로 보이는 자리)에 해당한다 |
| ch06-18-date-like-error | 6.2 따라 하기 4단계 — 날짜 열에 `LIKE` (오류 기대, exit 3) |
| ch06-19-cast-date-text-like | 6.2 따라 하기 5단계 — 날짜를 글자로 바꾼 뒤 `LIKE '2025%'` (7행) |
| ch06-20-cast-timing | 6.2 왜 그럴까요 — 형변환의 시점이 결과를 가른다 (세 열 대비) |
| ch06-21-cast-title-error | 6.2 흔한 실수 — `CAST(title AS integer)` (오류 기대, exit 3) |
| ch06-22-practice-page-hundred | 6.2 practice 1 풀이 (쪽수를 백 쪽 단위로) |
| ch06-23-practice-2024-books | 6.2 practice 2 풀이 (2024년 출간 9종) |
| ch06-24-round-price-thousand | 6.3 따라 하기 1단계 — `round(..., 1)` |
| ch06-25-length-title | 6.3 따라 하기 2단계 — `length(title)` |
| ch06-26-upper-email | 6.3 따라 하기 3단계 — `upper(email)` |
| ch06-27-to-char-year-month | 6.3 따라 하기 4단계 — `to_char(published_date, 'YYYY년 MM월')` |
| ch06-28-round-digits | 6.3 왜 그럴까요 — `round`의 둘째 인자 유무·값에 따른 차이 |
| ch06-29-email-unchanged | 6.3 왜 그럴까요 — 함수는 테이블의 값을 바꾸지 않는다 |
| ch06-30-round-integer-division | 6.3 흔한 실수 — `round(price / 1000, 1)`이 오류 없이 틀린다 |
| ch06-31-length-price-error | 6.3 흔한 실수 — `length(price)` (오류 기대, exit 3) |
| ch06-32-practice-longest-title | 6.3 practice 1 풀이 (제목이 가장 긴 5종) |
| ch06-33-practice-newest-year-month | 6.3 practice 2 풀이 (최신 5종의 출간 연월) |
| ch06-34-ex1-quantity-three | exercise 1 해설 (수량 3인 항목, 2장 별칭 5개 + R5 서식) |
| ch06-35-ex2-four-days | exercise 2 해설 (나흘 걸린 주문, 계산식을 `WHERE`에) |
| ch06-36-ex3-doc-to-char | exercise 3 해설 — 문서 탐색(S1.4). 9.8절 표에서 `Dy` 패턴을 찾아 적용 |
| ch06-37-ex4-predict-division | exercise 4 해설 — 예상을 먼저 적고 대조하는 문제(S1.3)의 네 식 |
| ch06-38-ex5-review-price-band | 복습 exercise 해설 (2장 DISTINCT·별칭 + 4장 ORDER BY·LIMIT + 6.1 정수 나눗셈) |
| ch06-39-pb1-shelf-label | problem 1 해설 (여행 매대 라벨 — 이어붙이기 + `length`) |
| ch06-40-pb2-settlement-sheet | problem 2 해설 (금액 10만 원 이상 정산 시트) |
| ch06-41-pb3-colleague-query | problem 3 (a) — 동료가 쓴 질의 (오류 기대, exit 3) |
| ch06-42-pb3-half-fixed | problem 3 (b) — 오류만 고쳐 `만원` 열이 조용히 틀린 상태 |
| ch06-43-pb3-fixed | problem 3 (c) 해설 — 두 곳을 모두 고친 질의 |
| ch06-44-world-claims-counts | **주장 케이스** — 본문이 인용하는 world 수치 주장 26건 (테이블 행 수, 금액·소요일의 최대·최소, 광고 수신 동의 93·비동의 57, `price / 1000`·`price / 10000` 값의 가짓수, 정가 최대·최소, 2025년 7종·2024년 9종, 제목 글자 수 최대·최소, 여행 36종, 여행 분야에서 라벨이 23글자인 책 5종 등). 그중 「quantity 값의 가짓수 3」은 **본문에 대응하는 자리가 없는 회귀 방어용 초과 고정**이다 — 본문 어디도 "수량이 세 가지"라고 말하지 않으며, 케이스 머리 주석이 그 사실을 밝힌다 |
| ch06-45-expression-claims | **주장 케이스** — 본문이 출력 블록 없이 참이라고 말한 식 10건 (`CAST('42' AS integer)`, `9500 / 1000.0`과 `CAST(9500 AS numeric) / 1000`의 동치, `408 / 100`, 형변환이 늦을 때의 `round(124500 / 1000, 1)`, 복습 exercise 채점 포인트의 `CAST(42000 AS numeric) / 10000`·`CAST(41500 AS numeric) / 10000`, 5장 `COALESCE` 호출) |

### 6장에서 의도적으로 출력이 같은 케이스 쌍 (D-022)

입력이 다른데 기대 출력이 **바이트 동일한** 쌍이다. 그 동일성 자체가 본문 주장의
기계적 증거이므로 케이스를 합치지 않는다. `check_chapter.py`가 이 표를 읽어 `cmp`한다.

| 쌍 | 본문의 주장 |
|---|---|
| ch06-16 = ch06-17 | 6.2 따라 하기 3단계 — "2단계와 결과가 한 줄도 다르지 않습니다". `CAST(price AS numeric)`와 `price::numeric`이 완전히 같은 일을 한다는 것이 이 절의 요지이고, 선택 목록·별칭·정렬·`LIMIT`이 모두 같아 두 기대 출력이 바이트 단위로 같다 |

### 6장에서 출력 블록 없이 수치·결과만 언급한 질의

본문이 결과를 싣지 않고 개수나 값만 인용하는 자리들이다(결과가 길거나, 본문의
다른 질의를 설명하기 위한 곁가지다). 인용한 수치는 전부 `ch06-44-world-claims-counts`와
`ch06-45-expression-claims`가 고정한다.

| 질의 · 식 | 본문 위치 | 인용 값 | 고정하는 케이스 |
|---|---|---|---|
| `SELECT count(*) FROM order_items;` | 들어가며, 6.1 문제 상황 | 1,243줄 | ch06-44 |
| `... FROM customers;` / `... WHERE marketing_opt_in;` | 6.1 따라 하기 4단계 | 150명 중 동의 93·비동의 57 | ch06-44 |
| `SELECT count(*) FROM orders WHERE shipped_date IS NULL;` (미발송 주문 — ch06-13이 `DESC` 맨 앞에 보이는 그 행들) | 6.1 practice 2, exercise 2 해설 | 144건 | ch06-44 |
| `... WHERE published_date BETWEEN '2025-01-01' AND '2025-12-31';` | 6.2 따라 하기 5단계의 [참고] | 7종 (ch06-19와 같은 수) | ch06-44 |
| `SELECT CAST('42' AS integer);` | 6.2 흔한 실수 | 42 (오류가 아니다) | ch06-45 |
| `SELECT 9500 / 1000.0;` | 6.2 왜 그럴까요 | `CAST(9500 AS numeric) / 1000`과 같은 값 | ch06-45 |
| `SELECT page_count / 100 FROM books;` | 6.2 practice 1 해설 | 408이 4가 된다 | ch06-45 |
| ch06-34에서 `LIMIT`을 뗀 질의 (수량 3) | exercise 1 해설 | 169건 | ch06-44 |
| ch06-35에서 `LIMIT`을 뗀 질의 (나흘 걸린 주문) | exercise 2 해설 | 79건 | ch06-44 |
| ch06-38에서 `LIMIT`을 뗀 질의 (만 원 단위 값의 종류) | 복습 exercise 해설 | 다섯 줄 (4·3·2·1·0), 정가 8,000~42,000원 | ch06-44 |
| `SELECT CAST(42000 AS numeric) / 10000, CAST(41500 AS numeric) / 10000;` | 복습 exercise 채점 포인트 | 4.2000000000000000과 4.1500000000000000으로 갈린다 | ch06-45 |
| ch06-39에서 `LIMIT`을 뗀 질의 (여행 분야) | problem 1 해설 | 36종 | ch06-44 |
| `SELECT count(*) FROM books WHERE category = '여행' AND length(title || ' / ' || author) = 23;` | problem 1 채점 포인트 | 5종 (동점이 딱 다섯 줄이라 `LIMIT 5`가 뽑는 다섯 권은 언제나 같다) | ch06-44 |
| ch06-40에서 `LIMIT`을 뗀 질의 (금액 10만 원 이상) | problem 2 해설 | 26건 | ch06-44 |
| `SELECT round(124500 / 1000, 1);` | problem 2 해설 | 124.0 (형변환이 늦으면 500원이 사라진다) | ch06-45 |

### 6장에서 주장 케이스에서 뺀 수치

- **출력 블록 안에서 학습자가 직접 셀 수 있는 수치는 위 표에 넣지 않았다**
  (D-033). 6.1 따라 하기 1·2단계의 "18,500원짜리 2권이 37,000원", 6.1 practice 1의
  "최댓값 126,000원", practice 2의 "가장 오래 걸린 4일", 6.3 따라 하기 2단계의
  "10글자·17글자", practice 1의 "19글자", problem 1의 "23글자", exercise 4의
  "가와 나가 둘 다 41"이 그렇다. 다만 `ch06-44`가 최댓값·최솟값 형태로 함께
  고정한다.

### 6장의 의도된 반례 (D-025)

- `ch06-10-no-alias-column` — 6.1 «흔한 실수»가 style.md **R22**(계산이나 함수로
  만든 열에는 별칭을 붙인다)를 **선언하기 전에** 싣는 코드다. 별칭을 일부러 빼서
  머리글에 `?column?`이 찍히는 것을 보이고, 바로 그 결과와 PG-DOC 7.3.2의 기본 열
  이름 규칙을 근거로 같은 소절 안에서 R22를 선언해 회수한다. 본문은 이 질의를
  실행하기 전에 "앞의 질의에서 `price` 열과 별칭을 빼고 세 줄만 뽑아 봅시다"라고
  밝히고, 규칙 선언 직후에 "방금 실행한 질의는 별칭을 **일부러 빼서** 이 규칙을
  어긴 것"이라고 적는다.
- 그 밖의 오류 기대 케이스(`ch06-06`·`ch06-18`·`ch06-21`·`ch06-31`·`ch06-41`)는
  서식 규칙을 어긴 것이 아니라 **타입이 맞지 않는 질의가 어떤 오류를 내는지**를
  보이는 것이므로 D-025의 대상이 아니다. 값이 조용히 틀리는 케이스
  (`ch06-30`·`ch06-42`, `round`를 정수 나눗셈 뒤에 씌운 것)도 마찬가지다 — 서식
  규칙이 아니라 **내용**이 대상이다.
- `ch06-17-colon-cast-price-thousand`는 R21을 어긴 것이 아니라 **R21이 본문에 명시한
  예외**(`::`로 쓴 형태 자체가 설명 대상인 자리)에 해당하므로 D-025의 반례가 아니다.
  R11이 `OR`에 대해, R17이 `= NULL`에 대해 둔 단서와 같은 구조다.

### 6장이 케이스를 새로 만들지 않은 출력

- 6.1 «개념»이 다시 싣는 `\d customers` 출력은 1장 1.2절 practice 1과 **입력이
  같으므로** 새 케이스를 만들지 않았다 (검증 케이스 규약 — "입력이 같으면 같은
  케이스다"). `ch01-05-d-customers`가 그 출력을 이미 고정하며, "`customers`의
  `Type` 열에 `integer`·`text`·`date`·`boolean` 네 가지가 보인다"는 6.1절의 진술이
  그 케이스에 걸려 있다.
- 6.1 «문제 상황»이 언급하는 `\d order_items`는 출력을 다시 싣지 않고 1장
  exercise 3을 참조한다 — `ch01-08-d-order-items`가 이미 고정한다.
- 6.1 따라 하기의 psql 접속 명령(`docker exec -it ...`)은 1장 1.2절 따라 하기
  1단계를 참조할 뿐 출력을 싣지 않는다 (2~5장과 같은 처리다).
- 6.1 «개념»과 6.2·6.3 «개념»의 서식 규칙 예제(R20·R21·R22·R23을 선언하며 싣는
  질의)는 출력을 싣지 않으므로 케이스를 만들지 않았다 (5장 R17 예제와 같은 처리다).

## ch07 — 7장 «테이블 연결하기 — 조인»

| 케이스 | 챕터에서의 위치 |
|---|---|
| ch07-01-same-name-three | 7.1 문제 상황 — 이름 '최연우'로는 한 사람을 집을 수 없다 (동명이인 3명) |
| ch07-02-customer-12 | 7.1 따라 하기 2단계 — 기본키 값으로 고르면 1행 |
| ch07-03-customer-by-email | 7.1 왜 그럴까요 — `email`도 유일하다(UNIQUE 제약). 그래도 기본키는 `customer_id` 하나뿐 |
| ch07-04-pk-not-null | 7.1 왜 그럴까요 — 기본키 열에는 널인 행이 없다 (0행, 5장 `IS NULL`) |
| ch07-05-order-items-one-row | 7.1 흔한 실수 — 복합 기본키는 두 열이 함께 있어야 한 행을 집는다 |
| ch07-06-practice-customer-4 | 7.1 practice 1 풀이 (고객 4번) |
| ch07-07-practice-order-item-227-43 | 7.1 practice 2 풀이 (주문 227번의 도서 43번) |
| ch07-08-order-1-items | 7.2 문제 상황 — `order_items`에는 도서번호만 있고 제목이 없다 |
| ch07-09-books-in-order-1 | 7.2 따라 하기 2단계 — 번호를 손으로 옮겨 `books`를 다시 조회한다 (3장 `IN`) |
| ch07-10-reviews-null-order | 7.2 왜 그럴까요 — 외래키 열에도 널이 올 수 있다 (구매 인증 없는 리뷰, 5장 `IS NULL`) |
| ch07-11-practice-review-301 | 7.2 practice 1 풀이 (1) — 리뷰 301번이 가진 번호들 |
| ch07-12-practice-book-14 | 7.2 practice 1 풀이 (2) — `book_id` 14로 `books` 조회 |
| ch07-13-practice-order-1 | 7.2 practice 2 풀이 (1) — 주문 1번이 가진 고객 번호 |
| ch07-14-practice-customer-34 | 7.2 practice 2 풀이 (2) — `customer_id` 34로 `customers` 조회 |
| ch07-15-join-order-1 | 7.3 따라 하기 1단계 — 첫 `INNER JOIN`. 7.3 개념의 서식 규칙 예제와 입력이 같다(그 자리는 출력을 싣지 않는다) |
| ch07-16-join-all-items | 7.3 따라 하기 2단계 — 조건 없이 전체를 조인한 앞 5줄 |
| ch07-17-join-travel-amount | 7.3 따라 하기 3단계 — 3장 조건·6장 계산과 함께 (여행 분야, 금액 큰 순) |
| ch07-18-join-busan-orders | 7.3 따라 하기 4단계 — 두 번째 1:N 쌍 (`customers` ──< `orders`) |
| ch07-19-join-no-on-error | 7.3 왜 그럴까요 — `ON`을 빼면 문법 오류다 (오류 기대, exit 3) |
| ch07-20-reviews-298-303-raw | 7.3 왜 그럴까요 — 조인하기 전의 리뷰 여섯 줄 (301~303은 `order_id`가 널) |
| ch07-21-reviews-298-303-join | 7.3 왜 그럴까요 — 같은 범위를 `orders`와 조인하면 세 줄이 사라진다 |
| ch07-22-ambiguous-column-error | 7.3 흔한 실수 — 열 이름을 한정하지 않으면 `is ambiguous` (오류 기대, exit 3). style.md **R26이 명시한 예외**에 해당한다 |
| ch07-23-join-book-29-repeats | 7.3 흔한 실수 — 여러 주문에 담긴 책 한 권이 결과에서 네 줄이 된다 |
| ch07-24-practice-join-order-227 | 7.3 practice 1 풀이 (주문 227번을 제목과 함께) |
| ch07-25-practice-join-cooking-amount | 7.3 practice 2 풀이 (요리 분야, 금액 큰 순) |
| ch07-26-ex1-rating-five | exercise 1 해설 (별점 5점 리뷰가 달린 책) |
| ch07-27-ex2-cooking-two-or-more | exercise 2 해설 (요리 분야 2권 이상, 3장 `AND`) |
| ch07-28-ex3-seoul-2026 | exercise 3 해설 (서울 고객의 2026년 주문, 3장 `BETWEEN`) |
| ch07-29-ex4-top-amount | exercise 4 해설 (금액 큰 순 다섯 줄, 6장 계산 + 4장 정렬) |
| ch07-30-ex5-review-travel-coalesce | 복습 exercise 해설 (3장 `LIKE`·비교 + 5장 `COALESCE`) |
| ch07-31-pb1-low-rating | problem 1 해설 (별점 1~2점 리뷰를 최근 것부터) |
| ch07-32-pb2-stock-shortage | problem 2 해설 (재고보다 많이 주문된 항목 — `WHERE`에서 두 테이블의 열을 견준다) |
| ch07-33-pb3-join-orders-empty | problem 3 (a) — 동료가 쓴 질의. `orders`와 내부 조인해 놓고 널을 찾아 0행이 된다 |
| ch07-34-pb3-unverified-reviews | problem 3 (b) 해설 — `books`와만 조인해야 220건이 남는다 |
| ch07-35-world-claims-counts | **주장 케이스** — 본문이 인용하는 world 수치 주장 31건 (테이블 행 수, 동명이인 그룹 31, 외래키 제약 6, 구매 인증 300·일반 220, 조인 결과 행 수, 여행 148·요리 187, 부산 고객 16·주문 66, exercise·problem의 전체 건수, 채점 포인트가 드는 반례 두 건과 동점 근거 네 건) |
| ch07-36-world-claims-text | **주장 케이스** — 본문이 인용하는 키 구성 주장 12건 (다섯 테이블의 기본키 열, 각 테이블의 외래키 열, `reviews`의 외래키 중 널을 허용하는 열, 참조 방향). 값이 개수(정수)가 아니라 열 이름(글자)이라 ch07-35와 나눴다 (pipeline "주장 케이스" — 값의 타입이 섞이면 케이스를 나눈다. 이름 마지막 마디 `-text`가 그 타입을 선언한다) |

### 7장에서 출력 블록 없이 수치·결과만 언급한 질의

본문이 결과를 싣지 않고 개수만 인용하는 자리들이다(결과가 길어 지면에 싣지
않았다). 인용한 수치는 전부 `ch07-35-world-claims-counts`가 고정한다 (D-021).

| 질의 | 본문 위치 | 인용 값 | 고정하는 케이스 |
|---|---|---|---|
| 이름이 겹치는 고객 무리 수 | 7.1 문제 상황, 7.1 흔한 실수 | 31개 | ch07-35 |
| `SELECT count(*) FROM order_items;` | 들어가며, 7.3 문제 상황 | 1,243줄 | ch07-35 |
| 책숲의 외래키 제약 수 | 7.2 개념 | 여섯 개 | ch07-35 |
| `... FROM reviews WHERE order_id IS NULL;` / `IS NOT NULL` | 7.2 왜 그럴까요, 7.3 왜 그럴까요, problem 3 해설 | 220건 / 300건 | ch07-35 |
| ch07-16에서 `LIMIT`을 뗀 질의 | 7.3 따라 하기 2단계, exercise 4 해설 | 1,243행 | ch07-35 |
| ch07-17에서 `LIMIT`을 뗀 질의 (여행 분야) | 7.3 따라 하기 3단계 | 148행 | ch07-35 |
| 부산 고객 수 / ch07-18에서 `LIMIT`을 뗀 질의 | 7.3 따라 하기 4단계 | 16명 / 66건 | ch07-35 |
| `reviews`를 `orders`와 조인한 전체 행 수 | 7.3 왜 그럴까요 | 300건 | ch07-35 |
| ch07-25에서 `LIMIT`을 뗀 질의 (요리 분야) | 7.3 practice 2 | 187행 | ch07-35 |
| ch07-26에서 `LIMIT`을 뗀 질의 (별점 5점) | exercise 1 해설 | 160건 | ch07-35 |
| ch07-27에서 `LIMIT`을 뗀 질의 (요리 2권 이상) | exercise 2 해설 | 81건 | ch07-35 |
| ch07-28에서 `LIMIT`을 뗀 질의 (서울·2026년) | exercise 3 해설 | 44건 | ch07-35 |
| ch07-30에서 `LIMIT`을 뗀 질의 (제목에 여행, 4점 이상) | 복습 exercise 해설 | 42건 | ch07-35 |
| ch07-31에서 `LIMIT`을 뗀 질의 (별점 1~2점) | problem 1 해설 | 77건 | ch07-35 |
| ch07-32에서 `LIMIT`을 뗀 질의 (재고 부족 항목) | problem 2 해설 | 172건 | ch07-35 |
| ch07-34에서 `LIMIT`을 뗀 질의 (구매 인증 없는 리뷰) | problem 3 해설 | 220건 | ch07-35 |
| `SELECT count(*) FROM books WHERE title = '여행';` | 복습 exercise 채점 포인트 | 0행 (`LIKE` 대신 `=`로 적었을 때) | ch07-35 |
| `SELECT count(*) FROM reviews WHERE order_id = NULL;` | problem 3 채점 포인트 | 0행 (`IS NULL` 대신 `= NULL`로 적었을 때) | ch07-35 |
| 서울·2026년 주문 중 주문일이 겹치는 날의 수 | exercise 3 채점 포인트 | 이틀 | ch07-35 |
| problem 1의 상위 다섯 줄 중 리뷰 30·51·100번이 같은 날짜인지 | problem 1 채점 포인트 | 셋이 상위 다섯 줄에 들고, 셋의 `review_date` 가짓수가 1 | ch07-35 |
| 재고 부족 항목이 둘 이상인 주문의 수 | problem 2 채점 포인트 | 9건 | ch07-35 |

### 7장에서 주장 케이스에서 뺀 수치

- **출력 블록 안에서 학습자가 직접 셀 수 있는 수치는 위 표에 넣지 않았다**
  (D-033). 7.1 문제 상황의 "동명이인 3명", 7.3 흔한 실수의 "네 줄", 7.2 왜
  그럴까요의 "1,243줄에 흩어진다"가 그렇다 — 해당 출력 블록 안에서 그대로 셀 수
  있거나 위 D-021 표가 이미 고정한 값이다. 다만 `ch07-35`가 같은 수치를 함께
  고정한다.

본문이 키 구성에 대해 하는 주장(다섯 테이블의 기본키가 무엇인지, `order_items`의
기본키가 두 열인지, `reviews`의 외래키 셋 중 널을 허용하는 것이 `order_id`뿐인지,
`books`를 가리키는 테이블이 둘인지)은 `\d` 출력 블록에서 읽을 수 있는 것과
7.2 개념의 관계 표에 옮겨 적은 것이 섞여 있으므로 `ch07-36-world-claims-text`가
따로 고정한다.

### 7장에서 의도적으로 거의 같은 출력을 내는 케이스 (부분 등가)

바이트 동일은 아닌데 **부분적 일치 자체가 본문의 주장**인 쌍이다. 러너도
`check_chapter.py`도 케이스 사이의 등가를 판정하지 않으므로(pipeline "러너가
검사하는 것과 검사하지 않는 것"), 무엇이 같은지를 아래에 못 박는다.

| 쌍 | 무엇이 같은가 · 본문의 주장 |
|---|---|
| ch07-09 ↔ ch07-15 | **`title` 열의 값 세 개가 같은 차례로** 나온다(「우리가 몰랐던 꼬마 화가 안내서」→「처음 만나는 섬 여행 안내서」→「우리가 몰랐던 항해 사전」). 7.3 따라 하기 1단계가 "7.2절 따라 하기 2단계에서 얻은 세 권이 같은 차례로 나왔다"고 말하는 근거다. 나머지 열은 다르다 — ch07-09는 `book_id`·`author`·`price`, ch07-15는 `order_id`·`quantity`를 낸다. 두 질의의 정렬 키가 각각 `books.book_id`와 `order_items.book_id`인데 조인 조건이 그 둘을 같게 하므로 차례가 일치한다 |
| ch07-20 ↔ ch07-21 | **앞 세 줄의 `review_id`와 `order_id` 값이 같다**(298→227, 299→155, 300→422). 뒤 세 줄(301·302·303)은 ch07-20에만 있고 ch07-21에는 없다 — 7.3 «왜 그럴까요»의 "여섯 줄이 세 줄이 되었다"가 이 차이다. 열 구성도 다르다(ch07-21에 `order_date`·`status`가 붙고 `rating`이 빠진다) |
| ch06-34 ↔ ch07-29 | **주문번호와 `금액` 열의 값 다섯 개가 같은 차례로** 나온다(511/126000 → 488/124500 → 215/123000 → 227/123000 → 485/123000). exercise 4 해설이 "6장 exercise 1에서 번호로만 보았던 바로 그 다섯 줄"이라고 말하는 근거다. 6장 질의는 `WHERE quantity = 3`으로 걸렀고 7장 질의는 거르지 않았는데도 같은 다섯 줄인 것은 금액 상위권이 전부 수량 3인 항목이기 때문이다. 열 구성은 다르다 — 6장은 도서번호·수량·단가를, 7장은 제목·분야를 낸다 |

### 7장에서 앞 장의 케이스를 다시 쓴 자리 (새 케이스를 만들지 않음)

- `\d` 메타명령 넷은 **입력이 1장의 케이스와 같으므로** 새 케이스를 만들지
  않았다 (검증 케이스 규약 — "입력이 같으면 같은 케이스다"). 위쪽 ch01 표의
  해당 줄에 7장에서의 위치를 함께 적어 두었다.
  - `\d customers` → `ch01-05-d-customers` (7.1 따라 하기 1단계)
  - `\d order_items` → `ch01-08-d-order-items` (7.1 따라 하기 3단계. 7.2 따라
    하기 1단계는 이 출력의 `Foreign-key constraints:` 세 줄만 발췌해 다시 싣는다)
  - `\d books` → `ch01-02-d-books` (7.2 따라 하기 3단계)
  - `\d reviews` → `ch01-07-d-reviews` (7.2 따라 하기 4단계)
- 7.3 «개념»의 서식 규칙 예제(R24·R25·R26을 선언하며 싣는 질의)는 출력을 싣지
  않으므로 케이스를 만들지 않았다. 그중 마지막 예제는 `ch07-15-join-order-1`과
  입력이 같다.
- 7.3 «개념»의 문장 모양 도식과 7.1·7.2·7.3 «개념»의 관계 도식은 psql 출력이
  아니라 그림이므로 케이스가 아니다.
- 7.1·7.2·7.3 따라 하기의 psql 접속 명령(`docker exec -it ...`)은 1장 1.2절
  따라 하기 1단계를 참조할 뿐 출력을 싣지 않는다 (2~6장과 같은 처리다).

### 7장의 의도된 반례 (D-025)

- **없다.** 7장이 도입하는 서식 규칙 R24·R25·R26은 모두 «개념»에서 선언되고,
  그 뒤의 코드는 전부 규칙을 지킨다.
- `ch07-22-ambiguous-column-error`는 R26을 어긴 코드이지만 D-025의 반례가
  아니라 **R26이 본문에 명시한 예외**(한정하지 않은 형태 자체가 설명 대상인
  자리)에 해당한다. R11이 `OR`에, R17이 `= NULL`에, R21이 `::`에 둔 단서와 같은
  구조이며, 6장의 `ch06-17`과 같은 처리다. 본문도 실행 전에 "규칙 셋을 일부러
  어긴 것"이라고 밝힌다.
- 그 밖의 오류 기대 케이스(`ch07-19`)와 값이 조용히 비는 케이스
  (`ch07-04`·`ch07-33`)는 서식 규칙이 아니라 **내용**이 대상이므로 D-025의
  대상이 아니다.

## ch08 — 8장 «조인 넓히기 — OUTER 조인과 다중 조인»

| 케이스 | 챕터에서의 위치 |
|---|---|
| ch08-01-customers-6-9 | 8.1 문제 상황 — 고객 명단 6~9번 네 명 (7번 조유나가 있다) |
| ch08-02-inner-join-6-9 | 8.1 문제 상황 — 내부 조인하면 조유나가 사라진다 (7장 조인) |
| ch08-03-left-join-6-9 | 8.1 따라 하기 1단계 — `INNER`를 `LEFT`로 바꾸면 조유나가 널과 함께 남는다. 8.1 개념의 서식 규칙 예제(R27)와 입력이 같다(그 자리는 출력을 싣지 않는다) |
| ch08-04-left-join-coalesce | 8.1 따라 하기 2단계 — 널 자리를 5장 `COALESCE`로 채운다 |
| ch08-05-customers-without-orders | 8.1 따라 하기 3단계 — `WHERE 오른쪽.기본키 IS NULL`로 짝 없는 행만 고른다 |
| ch08-06-busan-without-orders | 8.1 따라 하기 4단계 — 왼쪽 테이블의 조건(`city`)과 함께 쓴다 |
| ch08-07-orders-left-join-customers | 8.1 왜 그럴까요 — 왼쪽·오른쪽을 바꾸면 남는 쪽이 달라진다 (주문에는 고객이 반드시 있어 내부 조인과 같은 620행) |
| ch08-08-right-columns-all-null | 8.1 왜 그럴까요 — 짝이 없으면 오른쪽 테이블의 **모든** 열이 널이 된다 (`not null`인 `status`까지) |
| ch08-09-where-right-condition | 8.1 흔한 실수 — 오른쪽 테이블의 열을 `WHERE`에 걸면 왼쪽 외부 조인이 내부 조인처럼 된다 |
| ch08-10-condition-in-on | 8.1 흔한 실수 — 같은 조건을 `ON`으로 옮기면 왼쪽 행이 남는다 |
| ch08-11-nullable-column-trap | 8.1 흔한 실수 — 널을 허용하는 열(`shipped_date`)로 `IS NULL`을 걸면 짝이 있는 행까지 섞인다 |
| ch08-12-practice-books-without-reviews | 8.1 practice 1 풀이 — 리뷰가 하나도 없는 책 |
| ch08-13-practice-seoul-without-orders | 8.1 practice 2 풀이 — 서울 고객 중 주문이 없는 사람 |
| ch08-14-order-5-titles-only | 8.2 문제 상황 — 두 테이블만 이으면 제목은 나와도 누가 샀는지 모른다 |
| ch08-15-three-tables-order-1 | 8.2 따라 하기 1단계 — 세 테이블 다중 조인. 8.2 개념의 서식 규칙 예제(R28)와 입력이 같다(그 자리는 출력을 싣지 않는다) |
| ch08-16-four-tables-busan | 8.2 따라 하기 2단계 — 네 테이블 다중 조인 (부산 손님이 산 책) |
| ch08-17-three-tables-reviews | 8.2 따라 하기 3단계 — `reviews`를 가운데 두고 양쪽으로 뻗는 경로 |
| ch08-18-all-left-6-8 | 8.2 따라 하기 4단계 — 조인 셋을 모두 `LEFT JOIN`으로 이으면 주문 없는 고객이 남는다 |
| ch08-19-left-then-inner-6-8 | 8.2 왜 그럴까요 — `LEFT JOIN` 뒤에 `INNER JOIN`을 이으면 널로 남긴 행이 다시 버려진다 |
| ch08-20-join-order-error | 8.2 왜 그럴까요 — 아직 이어 붙이지 않은 테이블을 `ON`에서 부르면 `missing FROM-clause entry` (오류 기대, exit 3) |
| ch08-21-wrong-join-condition | 8.2 흔한 실수 — 타입만 같고 뜻이 다른 열끼리 이으면 오류 없이 뜻 없는 결과가 나온다 |
| ch08-22-practice-three-tables-227 | 8.2 practice 1 풀이 — 주문 227번을 세 테이블로 |
| ch08-23-practice-four-tables-daegu | 8.2 practice 2 풀이 — 대구 손님이 산 책 (네 테이블) |
| ch08-24-ex1-never-sold-books | exercise 1 해설 — 한 번도 주문에 담기지 않은 책 |
| ch08-25-ex2-low-rating-reviewers | exercise 2 해설 — 별점 1~2점 리뷰의 손님과 책 (세 테이블) |
| ch08-26-ex3-science-buyers | exercise 3 해설 — 과학 분야 책을 산 손님 (네 테이블) |
| ch08-27-ex4-science-without-reviews | exercise 4 해설 — 리뷰가 없는 과학 분야 책 (왼쪽 조건 + `IS NULL`) |
| ch08-28-ex5-rating-offset | 복습 exercise 해설 (4·7장) — 내부 조인 + `ORDER BY` 두 키 + `LIMIT ... OFFSET` |
| ch08-29-pb1-oldest-without-orders | problem 1 해설 — 주문이 하나도 없는 손님을 가입일 이른 순으로 |
| ch08-30-pb2-children-buyers | problem 2 해설 — 어린이 분야 책을 산 손님 (네 테이블) |
| ch08-31-pb3-colleague-query | problem 3 (a) — 동료가 쓴 질의. 취소 조건을 `WHERE`에 걸어 취소가 없는 손님이 통째로 사라진다 |
| ch08-32-pb3-cancelled-with-on | problem 3 (b) 해설 — 같은 조건을 `ON`으로 옮기면 취소가 없는 손님도 남는다 |
| ch08-33-world-claims-counts | **주장 케이스** — 본문이 인용하는 world 수치 주장 40건 (테이블 행 수, 주문 없는 고객 29, 내부 조인 620 대 왼쪽 외부 조인 649, 짝 없는 행을 고르는 여러 방식의 행 수, 세·네 테이블 조인의 행 수, exercise·problem의 전체 건수, 채점 포인트가 드는 근거, 스키마 주장 세 건). 본문에 출력 블록이 없다 |

### 8장에서 출력 블록 없이 수치·결과만 언급한 질의

본문이 결과를 싣지 않고 개수만 인용하는 자리들이다(결과가 길어 지면에 싣지
않았다). 인용한 수치는 전부 `ch08-33-world-claims-counts`가 고정한다 (D-021).

| 질의 | 본문 위치 | 인용 값 | 고정하는 케이스 |
|---|---|---|---|
| ch08-05에서 `LIMIT`을 뗀 질의 (주문 없는 고객) | 8.1 따라 하기 3단계, problem 1 해설 | 29명 | ch08-33 |
| `SELECT count(*) FROM customers;` | 8.1 따라 하기 3단계, 8.2 흔한 실수 | 150명 | ch08-33 |
| ch08-07에서 `LIMIT`을 뗀 질의 (`orders`를 왼쪽에) | 8.1 왜 그럴까요, 8.2 흔한 실수 | 620행 | ch08-33 |
| ch08-08에서 `LIMIT`을 뗀 질의 (`status IS NULL`) | 8.1 왜 그럴까요 | 29행 | ch08-33 |
| ch08-11에서 `LIMIT`을 뗀 질의 (`shipped_date IS NULL`) | 8.1 흔한 실수 | 173행 | ch08-33 |
| ch08-12에서 `LIMIT`을 뗀 질의 (리뷰 없는 책) | 8.1 practice 1 | 76권 | ch08-33 |
| ch08-16에서 `LIMIT`을 뗀 질의 (부산 손님이 산 책) | 8.2 따라 하기 2단계 | 134행 | ch08-33 |
| ch08-17에서 `LIMIT`을 뗀 질의 (별점 5점) | 8.2 따라 하기 3단계, 복습 exercise 해설 | 160건 | ch08-33 |
| `order_items`의 행 수 / 네 테이블 내부 조인의 행 수 | 8.2 흔한 실수 | 1,243줄 / 1,243행 | ch08-33 |
| ch08-23에서 `LIMIT`을 뗀 질의 (대구 손님이 산 책) | 8.2 practice 2 | 125행 | ch08-33 |
| ch08-24에서 `LIMIT`을 뗀 질의 (한 번도 안 팔린 책) | exercise 1 해설 | 18권 | ch08-33 |
| ch08-25에서 `LIMIT`을 뗀 질의 (별점 1~2점) | exercise 2 해설 | 77건 | ch08-33 |
| ch08-26에서 `LIMIT`을 뗀 질의 (과학 분야를 산 손님) | exercise 3 해설 | 119행 | ch08-33 |
| ch08-27에서 `LIMIT`을 뗀 질의 (리뷰 없는 과학 책) | exercise 4 해설 | 6권 | ch08-33 |
| ch08-30에서 `LIMIT`을 뗀 질의 (어린이 분야를 산 손님) | problem 2 해설 | 138행 | ch08-33 |
| `SELECT count(*) FROM orders WHERE status = '취소';` | problem 3 해설 | 61건 | ch08-33 |
| 주문 5번을 낸 고객이 부산의 오채원인지 | 8.2 문제 상황 | 그렇다(해당 행 1) | ch08-33 |
| `orders.status`에 널이 없다 / `reviews.comment`에는 널이 있다 | 8.1 왜 그럴까요, exercise 4 채점 포인트 | 0행 / 189행 | ch08-33 |
| `customers`와 `books`를 직접 잇는 외래키의 유무 | 8.2 개념 | 0개 | ch08-33 |
| 주문 없는 고객 중 가입일이 겹치는 날의 수 | problem 1 채점 포인트 | 0 | ch08-33 |
| 한 주문에 같은 분야 책이 둘 이상 담긴 주문의 수 | exercise 3·problem 2 채점 포인트 | 과학 5건 / 어린이 9건 | ch08-33 |
| `SELECT count(*) FROM reviews WHERE order_id IS NULL;` | 8장 떠올려 보기 | 220건 | ch07-35 |

### 8장에서 주장 케이스에서 뺀 수치

- **출력 블록 안에서 학습자가 직접 셀 수 있는 수치는 위 표에 넣지 않았다**
  (D-033). 8.1 문제 상황의 "여섯 줄", 8.1 따라 하기 4단계의 "세 명", 8.2 따라 하기
  4단계의 "여덟 줄", 8.2 흔한 실수의 "김시우가 네 줄"이 그렇다.

### 8장에서 의도적으로 거의 같은 출력을 내는 케이스 (부분 등가)

바이트 동일은 아닌데 **부분적 일치 자체가 본문의 주장**인 쌍이다. 러너도
`check_chapter.py`도 케이스 사이의 등가를 판정하지 않으므로(pipeline "러너가
검사하는 것과 검사하지 않는 것"), 무엇이 같은지를 아래에 못 박는다.

| 쌍 | 무엇이 같은가 · 본문의 주장 |
|---|---|
| ch08-02 ↔ ch08-03 | ch08-02의 **여섯 데이터 줄과 머리글 두 줄이 모두** ch08-03에 같은 차례로 그대로 들어 있다. 다른 것은 두 곳뿐이다 — ch08-03에 조유나 줄(`7 | 조유나 | | `)이 셋째 데이터 줄로 끼어들고, 꼬리표가 `(6 rows)` 대신 `(7 rows)`다. 8.1 따라 하기 1단계가 "나머지 여섯 줄은 문제 상황의 내부 조인 결과와 값도 차례도 같습니다"라고 말하는 근거다 |
| ch08-01 ↔ ch08-03 | ch08-01의 **네 고객번호와 이름**(6 신현우, 7 조유나, 8 김시우, 9 오다은)이 ch08-03에도 모두 나온다(6번과 8번은 주문 수만큼 되풀이된다). 8.1 문제 상황의 "명단에는 분명히 있던 사람"과 따라 하기 1단계의 "조유나가 돌아왔습니다"가 이 대조다. 열 구성은 다르다 — ch08-01은 `city`·`signup_date`를, ch08-03은 `order_id`·`order_date`를 낸다 |
| ch08-05 ↔ ch08-08 | **`customer_id`와 `name` 열의 값 다섯 쌍이 같은 차례로** 나온다(7 조유나 → 13 조도윤 → 18 한현우 → 24 한채원 → 28 장현우). 8.1 «왜 그럴까요»가 "3단계와 같은 다섯 사람이 같은 차례로 나왔습니다"라고 말하는 근거다. 셋째 열은 다르다 — ch08-05는 `city`와 `order_id`를, ch08-08은 `status`를 낸다 |
| ch08-18 ↔ ch08-19 | ch08-19의 **일곱 데이터 줄과 머리글 두 줄이 모두** ch08-18에 같은 차례로 그대로 들어 있다. 다른 것은 두 곳뿐이다 — ch08-18에 조유나 줄이 넷째 데이터 줄로 끼어들고, 꼬리표가 `(7 rows)` 대신 `(8 rows)`다. 8.2 «왜 그럴까요»가 "나머지 일곱 줄은 4단계와 값도 차례도 같습니다"라고 말하는 근거다 |

### 8장에서 케이스를 새로 만들지 않은 출력

- 8.1 «개념»의 서식 규칙 예제(R27을 선언하며 싣는 질의)는 `ch08-03`과, 8.2
  «개념»의 예제(R28)는 `ch08-15`와 **입력이 같으므로** 새 케이스를 만들지
  않았다 (검증 케이스 규약 — "입력이 같으면 같은 케이스다"). 두 자리 모두
  출력을 싣지 않는다.
- 8.1 «개념»의 조인 도식과 8.2 «개념»의 경로 도식은 psql 출력이 아니라 그림
  이므로 케이스가 아니다.
- 8.1 따라 하기의 psql 접속 명령(`docker exec -it ...`)은 1장 1.2절 따라 하기
  1단계를 참조할 뿐 출력을 싣지 않는다 (2~7장과 같은 처리다).
- 8.2 문제 상황이 언급하는 7장 7.3절 따라 하기 4단계(부산 손님의 주문)와
  8.2 practice 1이 언급하는 7장 7.3절 practice 1(주문 227번)은 출력을 다시
  싣지 않고 참조만 한다 — `ch07-18`·`ch07-24`가 이미 고정한다.

### 8장의 의도된 반례 (D-025)

- **없다.** 8장이 도입하는 서식 규칙 R27·R28은 모두 «개념»에서 선언되고, 그
  뒤의 코드는 전부 규칙을 지킨다.
- `ch08-09`(오른쪽 조건을 `WHERE`에 건 질의), `ch08-11`(널 허용 열로 건
  `IS NULL`), `ch08-20`(조인 차례 오류), `ch08-21`(뜻이 맞지 않는 조인 조건),
  `ch08-31`(동료가 쓴 질의)은 모두 **내용**이 대상인 반례이지 서식 규칙을 어긴
  코드가 아니다. 서식은 그대로 지킨다 — D-025의 대상이 아니다 (7장의
  `ch07-19`·`ch07-33`과 같은 처리다).

## ch09 — 9장 «요약하기 — 집계»

| 케이스 | 챕터에서의 위치 |
|---|---|
| ch09-01-science-prices | 9.1 문제 상황 — 과학 분야 책값 다섯 줄(눈으로는 평균을 낼 수 없다) |
| ch09-02-count-books | 9.1 따라 하기 1단계 `count(*)`. 9.1 개념의 서식 규칙 예제(R29)와 입력이 같다(그 자리는 출력을 싣지 않는다) |
| ch09-03-science-count-min-max | 9.1 따라 하기 2단계 — 개수·최솟값·최댓값을 한 줄로 |
| ch09-04-science-avg-raw | 9.1 따라 하기 3단계 — `avg`의 소수점 아래가 길다 |
| ch09-05-science-avg-round | 9.1 따라 하기 3단계 — 6장의 `round`로 다듬는다 |
| ch09-06-order-5-amount | 9.1 따라 하기 4단계 — `sum(unit_price * quantity)` (6장 계산 복습) |
| ch09-07-reviews-count-star-vs-column | 9.1 따라 하기 5단계 — `count(*)` 520 대 `count(comment)` 331 |
| ch09-08-orders-null-aggregates | 9.1 왜 그럴까요 — 널인 행은 `count(열)`·`min`·`max`에서 빠진다 |
| ch09-09-shipping-days | 9.1 왜 그럴까요 — 평균의 분모는 값이 있는 행 수다 (849 ÷ 476 = 1.78) |
| ch09-10-manual-average | 9.1 흔한 실수 — 합계 ÷ 개수는 정수 나눗셈에 걸린다 (6장) |
| ch09-11-science-cheapest-and-priciest | 9.1 흔한 실수 — 한 줄로 요약된 최저가와 최고가는 서로 다른 책의 값이다 |
| ch09-12-practice-reviews-summary | 9.1 practice 1 풀이 — 리뷰 건수와 평균 별점 |
| ch09-13-practice-novel-stats | 9.1 practice 2 풀이 — 소설 분야의 네 가지 집계 |
| ch09-14-group-by-missing-error | 9.2 문제 상황 — 그룹 없이 열과 집계를 함께 고르면 오류 (오류 기대, exit 3) |
| ch09-15-books-by-category | 9.2 따라 하기 1단계 — 분야별 권수. 9.2 개념의 서식 규칙 예제(R30)와 입력이 같다(그 자리는 출력을 싣지 않는다) |
| ch09-16-category-stats | 9.2 따라 하기 2단계 — 그룹마다 집계를 여럿 |
| ch09-17-expensive-by-category | 9.2 따라 하기 3단계 — `WHERE`로 먼저 거른 뒤 묶는다 |
| ch09-18-orders-per-customer | 9.2 따라 하기 4단계 — 조인한 결과를 그룹으로 묶는다 |
| ch09-19-city-status-groups | 9.2 따라 하기 5단계 — 그룹 키가 둘일 때 |
| ch09-20-null-group | 9.2 왜 그럴까요 — 그룹 키가 널인 행들은 한 그룹으로 모인다 (29줄) |
| ch09-21-group-by-two-keys-fine | 9.2 왜 그럴까요 — 그룹 키를 늘리면 그룹이 잘아진다 |
| ch09-22-left-join-count-star | 9.2 흔한 실수 — `LEFT JOIN` 뒤의 `count(*)`는 짝 없는 행을 1로 센다 |
| ch09-23-left-join-count-column | 9.2 흔한 실수 — `count(오른쪽 테이블의 열)`로 고치면 0이 된다 |
| ch09-24-group-without-order-by | 9.2 흔한 실수 — `ORDER BY`가 없으면 그룹의 차례는 보장되지 않는다 |
| ch09-25-practice-customers-by-city | 9.2 practice 1 풀이 — 도시별 고객 수 상위 셋 |
| ch09-26-practice-orders-by-status | 9.2 practice 2 풀이 — 주문 상태별 건수 |
| ch09-27-aggregate-in-where-error | 9.3 문제 상황 — 집계 함수를 `WHERE`에 쓰면 오류 (오류 기대, exit 3) |
| ch09-28-big-buyers | 9.3 따라 하기 1단계 — `HAVING count(*) >= 20`. 9.3 개념의 서식 규칙 예제(R31)와 입력이 같다(그 자리는 출력을 싣지 않는다) |
| ch09-29-where-and-having | 9.3 따라 하기 2단계 — `WHERE`(행)와 `HAVING`(그룹)을 함께 |
| ch09-30-avg-price-having | 9.3 따라 하기 3단계 — `HAVING avg(price) >= 24000` |
| ch09-31-top-rated-books | 9.3 따라 하기 4단계 — 조인·그룹·집계·`HAVING`·정렬·`LIMIT` 종합 |
| ch09-32-novel-count-where | 9.3 왜 그럴까요 — 그룹 키 조건을 `WHERE`에 (권장) |
| ch09-33-novel-count-having | 9.3 왜 그럴까요 — 같은 조건을 `HAVING`에. ch09-32와 기대 출력이 바이트 동일하다 |
| ch09-34-having-alias-error | 9.3 흔한 실수 — `HAVING`에는 별칭을 쓸 수 없다 (오류 기대, exit 3) |
| ch09-35-having-row-condition-error | 9.3 흔한 실수 — 그룹 키도 집계도 아닌 열은 `HAVING`에 적을 수 없다 (오류 기대, exit 3) |
| ch09-36-practice-books-many-reviews | 9.3 practice 1 풀이 — 리뷰 5건 이상인 책 |
| ch09-37-practice-big-cities | 9.3 practice 2 풀이 — 고객 15명 이상인 도시 |
| ch09-38-ex1-stock-by-category | exercise 1 해설 — 분야별 재고 합계 (`sum`) |
| ch09-39-ex2-top-reviewers | exercise 2 해설 — 리뷰를 많이 쓴 손님 다섯 (조인 + 그룹) |
| ch09-40-ex3-books-review-counts | exercise 3 해설 — `LEFT JOIN` + `count(열)`로 리뷰 0건인 책까지 |
| ch09-41-ex4-completed-by-city | exercise 4 해설 — `WHERE`(상태) + `HAVING`(건수) |
| ch09-42-ex5-review-comment-counts | 복습 exercise (5·7장) (a) 해설 — `count(*)`와 `count(comment)`를 나란히 |
| ch09-43-ex5-comment-not-empty | 복습 exercise (5·7장) (b) 해설 — 동료가 더한 `WHERE comment <> ''`. 널인 행이 통째로 빠져 `HAVING`이 세는 대상이 바뀐다 |
| ch09-44-ex6-orders-by-month | 복습 exercise (6장) 해설 — `to_char`로 만든 값을 그룹 키로 |
| ch09-45-pb1-sales-by-category | problem 1 해설 — 분야별 매출 상위 셋 |
| ch09-46-pb2-lowest-rated-books | problem 2 해설 — 리뷰 4건 이상인 책 중 평균 별점이 낮은 다섯 |
| ch09-47-pb3-colleague-query | problem 3 (a) — 동료가 쓴 질의. `LEFT JOIN` 뒤의 `count(*)`가 0을 1로 만든다 |
| ch09-48-pb3-fixed-query | problem 3 (b) 해설 — `count(reviews.review_id)`로 고친 질의 |
| ch09-49-world-claims-counts | **주장 케이스** — 본문이 인용하는 world 수치 주장 32건 (테이블 행 수, 과학 분야 29권, 널인 값의 개수, 분야·도시의 가짓수, `HAVING` 기준을 넘는 그룹의 수, 채점 포인트가 드는 근거, 스키마 주장, 본문이 자기 출력에서 센 자릿수). 본문에 출력 블록이 없다 |

### 9장에서 출력 블록 없이 수치·결과만 언급한 질의

본문이 결과를 싣지 않고 개수만 인용하는 자리들이다(결과가 길거나, 앞 장에서
이미 확인한 값을 다시 부르는 자리다). 인용한 수치는 전부
`ch09-49-world-claims-counts`가 고정한다 (D-021).

| 질의 | 본문 위치 | 인용 값 | 고정하는 케이스 |
|---|---|---|---|
| `SELECT count(*) FROM books WHERE category = '과학';` | 9.1 문제 상황 | 29권 | ch09-49 |
| `books.category`의 가짓수 | 9.1 문제 상황, 9.2 문제 상황·따라 하기 2단계, problem 1 해설 | 여덟 가지 | ch09-49 |
| 8장 8.1절에서 센 주문 없는 고객 (ch08-05에서 `LIMIT`을 뗀 질의) | 들어가며, 9.1 문제 상황, 9.2 왜 그럴까요 | 29명 | ch09-49 |
| `SELECT count(*) FROM books;` | 9.1 따라 하기 1단계, 9.2 예측해 보기·개념 | 320권 | ch09-49 |
| `SELECT count(*) FROM order_items WHERE order_id = 5;` | 9.1 따라 하기 4단계 | 두 줄 | ch09-49 |
| `customers`와 `orders`를 내부 조인한 행 수 | 9.3 개념의 절 차례 그림 | 620행 | ch09-49 |
| `SELECT count(*) FROM reviews WHERE comment IS NULL;` | 9.1 따라 하기 5단계 | 189건 | ch09-49 |
| `SELECT count(*) FROM orders WHERE shipped_date IS NULL;` | 9.1 왜 그럴까요 | 144건 | ch09-49 |
| `SELECT count(*) FROM reviews WHERE rating IS NULL;` | 9.1 practice 1 해설 | 0행(널이 없다) | ch09-49 |
| 이름이 겹치는 고객 이름의 가짓수 | 9.2 따라 하기 4단계 | 31가지(겹치는 이름이 있다) | ch09-49 |
| 제목이 겹치는 책 제목의 가짓수 / `category`·`title` 조합의 가짓수 | 9.2 왜 그럴까요 | 0가지 / 320가지 | ch09-49 |
| `customers.city`의 가짓수 | 9.2 practice 1, 9.3 practice 2, exercise 4 해설 | 열 곳 | ch09-49 |
| 9.2 «개념» 도식에 적은 (분야, 가격) 세 조합 | 9.2 개념 | 실제 books의 행이다(해당 4행) | ch09-49 |
| ch09-37에서 `HAVING` 기준을 넘는 도시를 센 질의 | 9.3 practice 2 | 다섯 곳 | ch09-49 |
| 리뷰가 한 건뿐이고 그 별점이 5점인 책 수 | 9.3 따라 하기 4단계 | 22권(그런 책이 있다) | ch09-49 |
| ch09-36에서 `HAVING` 기준만 남기고 `LIMIT`을 뗀 질의 | 9.3 practice 1 | 14권 | ch09-49 |
| ch09-31·ch09-46에서 `LIMIT`을 뗀 질의 (리뷰 4건 이상인 책) | problem 2 채점 포인트 | 31권 | ch09-49 |
| ch09-40에서 리뷰 수가 0인 것만 센 질의 | exercise 3 해설 | 76권 | ch09-49 |

### 9장에서 주장 케이스에서 뺀 수치

- **출력 블록 안에서 학습자가 직접 셀 수 있는 수치는 위 표에 넣지 않았다**
  (D-033). 「일곱 분입니다」(9.3 따라 하기 1단계), 「아홉 분입니다」(2단계),
  「네 분야입니다」(3단계), 「다섯 곳입니다」(9.3 practice 2), 「세 곳」
  (exercise 4)이 그렇다. 그래도 이 값들은 `HAVING`의 기준을 넘는 그룹의 수라
  눈으로 세는 것 말고 근거를 남길 자리가 없으므로, ch09-49에도 함께 고정해 두었다.
- 반대로 **본문이 자기 출력에서 센 값이지만 그 결과가 출력에 찍히지 않는** 한
  건은 ch09-49이 고정한다 — 9.1 따라 하기 3단계의 「소수점 아래가 열두 자리」
  (출력 `25913.793103448276`에서 센 자릿수)이다. 출력 블록은 있지만 **센 결과
  자체는 어디에도 찍히지 않아** 러너도 본문 대조도 잡지 못하는 자리다 (9장
  red team 라운드 1의 반려 D1).
  `length(split_part(CAST(avg(price) AS text), '.', 2))`로 고정했다.
- **이미 바이트로 고정된 값들의 산술은 새 주장이 아니다** (D-032). 9.1 「왜
  그럴까요」의 「849 ÷ 476 = 1.7836...」은 ch09-49에 넣지 않았다. 849·476은
  `ch09-09-shipping-days`가 이미 바이트 단위로 고정하고 있어 회귀 구멍이 없고,
  몫은 그 두 값의 산술이지 새로운 world 사실 주장이 아니다. 값 열이
  정수(`bigint`)인 이 표에 소수를 넣으려면 억지 인코딩이 끼어들어
  본문(「1.7836...」)과 표를 바로 대조할 수 없게 된다 (pipeline "주장 케이스" —
  값의 타입이 섞이면 케이스를 나눈다).
- 같은 이유로 problem 1 해설의 「소설과 에세이는 1,500원 차이」도 넣지 않았다 —
  6019000과 6017500이 `ch09-45-pb1-sales-by-category`의 기대 출력 4·5행에
  바이트로 박혀 있고, 차이는 그 두 값의 뺄셈이다 (D-032).

### 9장에서 의도적으로 출력이 같은 케이스 쌍 (D-022)

| 쌍 | 뒷받침하는 본문 주장 |
|---|---|
| ch09-32 = ch09-33 | 9.3 «왜 그럴까요» — 그룹 키에 대한 조건은 `WHERE`에 적으나 `HAVING`에 적으나 **결과가 같다**. 본문이 "두 기대 출력은 글자 하나 다르지 않습니다"라고 적는 자리이며, 입력이 다르므로 별개 케이스로 유지한다 (D-022) |

### 9장에서 의도적으로 거의 같은 출력을 내는 케이스 (부분 등가)

바이트 동일은 아닌데 **부분적 일치 자체가 본문의 주장**인 쌍이다. 러너도
`check_chapter.py`도 케이스 사이의 등가를 판정하지 않으므로(pipeline "러너가
검사하는 것과 검사하지 않는 것"), 무엇이 같은지를 아래에 못 박는다.

| 쌍 | 무엇이 같은가 · 본문의 주장 |
|---|---|
| ch09-22 ↔ ch09-23 | 머리글 두 줄과 네 데이터 줄의 **차례·고객번호·이름이 모두 같고**, 다른 것은 넷째 줄(7번 조유나)의 주문수 한 자리뿐이다 — ch09-22는 `1`, ch09-23은 `0`. 9.2 «흔한 실수»가 "나머지 세 손님의 값은 2·3·1로 앞의 결과와 같습니다"라고 말하는 근거다 |
| ch09-47 ↔ ch09-48 | 머리글 두 줄과 여덟 데이터 줄의 **차례·고객번호·이름이 모두 같고**, 다른 것은 3·6·7번 손님의 리뷰수 세 자리뿐이다 — ch09-47은 셋 다 `1`, ch09-48은 셋 다 `0`. problem 3 해설이 "세 손님이 0으로 바뀌었습니다. 나머지 다섯 손님의 값은 그대로"라고 말하는 근거다 |
| ch09-18 ↔ ch09-28 | ch09-18의 **일곱 줄 전부**(머리글 두 줄 + 데이터 다섯 줄)가 ch09-28의 앞 일곱 줄과 바이트 동일하다. 다른 것은 ch09-28이 그 뒤에 두 줄(34번 조수아 21, 119번 조서연 21)과 `(7 rows)` 꼬리표를 더 갖는다는 점뿐이다. 9.3 따라 하기 1단계가 "9.2절 4단계에서는 `LIMIT 5`로 다섯 줄만 보았는데 … 34번 조수아, 119번 조서연 손님이 21건으로 새로 보이는군요"라고 말하는 근거다 |
| ch09-15 ↔ ch09-24 | **여덟 개의 (분야, 권수) 쌍이 양쪽에 모두 있고 값도 같지만 줄의 차례가 다르다.** ch09-15는 권수 내림차순·분야 순, ch09-24는 서버가 그룹을 만든 차례다. 9.2 «흔한 실수»가 "값은 1단계와 같은데 차례가 뒤죽박죽입니다"라고 말하는 근거다. 열 너비도 같아 **바이트로는 줄의 차례만 다르다** |
| ch09-03·ch09-05 ↔ ch09-16 | ch09-16의 «과학» 줄이 내는 권수 `29`와 평균가격 `25913.8`이 ch09-03의 권수와 ch09-05의 평균가격과 **같은 값**이다. 9.2 따라 하기 2단계가 "9.1절 2·3단계에서 받은 값과 같지요"라고 말하는 근거다. 열 구성과 표의 너비는 다르다 |
| ch08-12 ↔ ch09-40 | **다섯 도서번호와 제목이 같은 차례로** 나온다(1·3·9·11·18번). exercise 3 해설이 "8장 8.1절 practice 1에서 뽑았던 그 책들이지요"라고 말하는 근거다. 셋째 열은 다르다 — ch08-12는 `category`를, ch09-40은 리뷰 수(모두 0)를 낸다 |
| ch09-42 ↔ ch09-43 | **제목이 겹치는 데이터 줄이 둘뿐이다** — 「어느 날의 혁명 이야기」(6·6)와 「밤에 읽는 한 그릇 연습」(5·5). ch09-42는 다섯 줄, ch09-43은 네 줄이고 제목 열의 너비도 달라 바이트로는 머리글부터 다르다. 복습 exercise 5 (b) 해설이 "(a)의 다섯 권 중 둘만 남았습니다. (a)의 화면에는 없던 책 둘이 그 자리에 들어왔지요"라고 말하는 근거다 |

### 9장에서 케이스를 새로 만들지 않은 출력

- 9.1 «개념»의 서식 규칙 예제(R29)는 `ch09-02`와, 9.2 «개념»의 예제(R30)는
  `ch09-15`와, 9.3 «개념»의 예제(R31)는 `ch09-28`과 **입력이 같으므로** 새
  케이스를 만들지 않았다 (검증 케이스 규약 — "입력이 같으면 같은 케이스다").
  세 자리 모두 출력을 싣지 않는다.
- 9.1 «개념»의 집계 도식, 9.2 «개념»의 그룹 도식, 9.3 «개념»의 절 차례
  그림은 psql 출력이 아니라 그림이므로 케이스가 아니다.
- 9.1 따라 하기의 psql 접속 명령(`docker exec -it ...`)은 1장 1.2절 따라 하기
  1단계를 참조할 뿐 출력을 싣지 않는다 (2~8장과 같은 처리다).
- 9.2 문제 상황이 인용하는 `WHERE category = '과학'`은 산문 속 인라인 코드로
  9.1 따라 하기 2단계(`ch09-03`)를 되짚는 자리이며, 질의 전체를 싣지도 출력을
  싣지도 않는다.
- 8장 8.1절 practice 1(리뷰 없는 책)과 8장 8.2절 문제 상황(주문 5번의 항목
  두 줄)은 참조만 하고 출력을 다시 싣지 않는다 — `ch08-12`·`ch08-14`가 이미
  고정한다.

### 9장의 의도된 반례 (D-025)

- **없다.** 9장이 도입하는 서식 규칙 R29~R32는 모두 «개념»에서 선언되고, 그
  뒤의 코드는 전부 규칙을 지킨다.
- `ch09-14`·`ch09-27`·`ch09-34`·`ch09-35`(네 가지 오류), `ch09-10`(정수
  나눗셈), `ch09-22`·`ch09-47`(`count(*)` 함정), `ch09-24`(`ORDER BY` 없는
  그룹), `ch09-43`(널을 `<> ''`로 걸러 내려는 시도)은 모두 **내용**이 대상인
  반례이지 서식 규칙을 어긴 코드가 아니다.
  서식은 그대로 지킨다 — D-025의 대상이 아니다 (7·8장과 같은 처리다).

## ch10 — 10장 «질의 속의 질의 — 서브쿼리와 집합 연산»

| 케이스 | 챕터에서의 위치 |
|---|---|
| ch10-01-avg-price | 10.1 문제 상황 — 평균 가격을 먼저 구한다(9장 방식의 첫 단계) |
| ch10-02-above-average-hardcoded | 10.1 문제 상황 — 그 값을 손으로 옮겨 적어 다시 묻는다 |
| ch10-03-above-average-subquery | 10.1 따라 하기 1단계 — 같은 자리에 질의를 넣는다. 10.1 개념의 서식 규칙 예제(R33)와 입력이 같다(그 자리는 출력을 싣지 않는다). ch10-02와 기대 출력이 바이트 동일하다 |
| ch10-04-cheapest-books | 10.1 따라 하기 2단계 — `min` 서브쿼리로 가장 싼 책(9장이 미뤄 둔 것) |
| ch10-05-price-vs-average | 10.1 따라 하기 3단계 — 서브쿼리를 선택 목록에 놓는다 |
| ch10-06-books-with-many-reviews | 10.1 따라 하기 4단계 — 여러 행을 내놓는 서브쿼리를 `IN`에. 10.1 개념의 서식 규칙 예제(R34)와 입력이 같다(그 자리는 출력을 싣지 않는다) |
| ch10-07-books-without-reviews | 10.1 따라 하기 5단계 — `NOT IN`으로 리뷰 없는 책(8장의 답을 다른 길로) |
| ch10-08-scalar-subquery-multi-row-error | 10.1 왜 그럴까요 — 여러 행짜리 서브쿼리를 `=`에 쓰면 오류 (오류 기대, exit 3) |
| ch10-09-empty-subquery-avg | 10.1 왜 그럴까요 — 행이 없는 그룹의 평균은 널 |
| ch10-10-empty-subquery-compare | 10.1 왜 그럴까요 — 널을 돌려주는 서브쿼리는 오류가 아니라 0행 |
| ch10-11-subquery-too-many-columns-error | 10.1 흔한 실수 — `IN`의 서브쿼리는 열이 하나여야 한다 (오류 기대, exit 3) |
| ch10-12-not-in-with-null | 10.1 흔한 실수 — `NOT IN`의 목록에 널이 섞이면 0행 |
| ch10-13-not-in-null-fixed | 10.1 흔한 실수 — 서브쿼리 안에서 널을 걸러 고친다 |
| ch10-14-practice-thick-books | 10.1 practice 1 풀이 — 평균 쪽수를 넘는 책 |
| ch10-15-practice-frequent-reviewers | 10.1 practice 2 풀이 — 리뷰 10건 이상인 손님의 이름 |
| ch10-16-loyal-customers | 10.2 문제 상황 — 단골 명단(주문 20건 이상) |
| ch10-17-active-reviewers | 10.2 문제 상황 — 리뷰어 명단(리뷰 10건 이상) |
| ch10-18-union-lists | 10.2 따라 하기 1단계 — `UNION`. 10.2 개념의 서식 규칙 예제(R35·R36·R38)와 입력이 같다(그 자리는 출력을 싣지 않는다) |
| ch10-19-union-all-lists | 10.2 따라 하기 2단계 — `UNION ALL`은 겹치는 행도 남긴다 |
| ch10-20-intersect-lists | 10.2 따라 하기 3단계 — `INTERSECT` |
| ch10-21-except-lists | 10.2 따라 하기 4단계 — `EXCEPT` |
| ch10-22-except-reversed | 10.2 따라 하기 4단계 — 앞뒤를 바꾼 `EXCEPT`(방향이 있다) |
| ch10-23-union-all-labeled | 10.2 따라 하기 5단계 — 구분 라벨을 붙인 `UNION ALL`. 10.2 개념의 서식 규칙 예제(R37)와 입력이 같다(그 자리는 출력을 싣지 않는다) |
| ch10-24-union-column-count-error | 10.2 왜 그럴까요 — 열 개수가 다르면 오류 (오류 기대, exit 3) |
| ch10-25-union-type-error | 10.2 왜 그럴까요 — 짝이 되는 열의 타입이 다르면 오류 (오류 기대, exit 3) |
| ch10-26-order-by-in-first-query-error | 10.2 흔한 실수 — 묶이는 질의에 `ORDER BY`를 붙이면 문법 오류 (오류 기대, exit 3). style.md R36의 **의도된 반례** |
| ch10-27-second-alias-ignored | 10.2 흔한 실수 — 결과의 열 이름은 첫 질의의 것이다. style.md R37의 **의도된 반례** |
| ch10-28-practice-union-small | 10.2 practice 1 풀이 — 고객번호 10번까지의 `UNION` |
| ch10-29-practice-except-small | 10.2 practice 2 풀이 — 같은 범위의 `EXCEPT` |
| ch10-30-ex1-oldest-book | exercise 1 해설 — `min(published_date)` 서브쿼리 |
| ch10-31-ex2-cancelled-customers | exercise 2 해설 — 취소 주문이 있는 손님(`IN` 서브쿼리) |
| ch10-32-ex3-pricier-than-all-science | exercise 3(문서 탐색) 해설 — `> ALL` (공식 문서 9.24.5) |
| ch10-33-ex4-never-ordered-books | exercise 4 해설 — 한 번도 주문되지 않은 책(`EXCEPT`) |
| ch10-34-ex5-expensive-travel-titles | 복습 exercise 5(3장) 해설 — `LIKE` + 서브쿼리 |
| ch10-35-ex6-no-orders-left-join | 복습 exercise 6(8장) 해설 (가) — `LEFT JOIN` + `IS NULL` |
| ch10-36-ex6-no-orders-except | 복습 exercise 6(8장) 해설 (나) — 같은 답을 `EXCEPT`로. ch10-35와 기대 출력이 바이트 동일하다 |
| ch10-37-pb1-loyal-and-reviewer-names | problem 1 해설 — `INTERSECT`를 `IN`의 오른쪽에. 묶이는 질의를 절마다 나눈 배치는 style.md R38 |
| ch10-38-pb2-reviewers-without-orders | problem 2 해설 — `EXCEPT`를 `IN`의 오른쪽에. 묶이는 질의를 절마다 나눈 배치는 style.md R38 |
| ch10-39-pb3-restock-candidates | problem 3 해설 — 스칼라 서브쿼리 + `IN` 서브쿼리 |
| ch10-40-world-claims-counts | **주장 케이스** — 본문이 인용하는 world 수치 주장 22건(테이블 행 수, 분야·최고가, 조건을 만족하는 행 수, 널인 값의 개수, 집합 연산 결과의 크기). 본문에 출력 블록이 없다 |

### 10장에서 출력 블록 없이 수치·결과만 언급한 질의

본문이 결과를 싣지 않거나 `LIMIT`으로 잘라 싣고 개수만 인용하는 자리들이다.
인용한 수치는 전부 `ch10-40-world-claims-counts`가 고정한다 (D-021).

| 질의 | 본문 위치 | 인용 값 | 고정하는 케이스 |
|---|---|---|---|
| `SELECT count(*) FROM books;` | 10.1 개념의 도식("320행을 걸러 냅니다"), 왜 그럴까요 | 320행 | ch10-40 |
| ch10-03에서 `LIMIT`을 뗀 질의 (평균 가격 초과) | 10.1 따라 하기 1단계 | 조건에 맞는 책이 다섯 권보다 많다(156권) | ch10-40 |
| `SELECT count(*) FROM books WHERE category = '과학';` | 10.1 왜 그럴까요("과학 분야 책값은 스물아홉 줄") | 29줄 | ch10-40 |
| `SELECT count(*) FROM books WHERE category = '만화';` | 10.1 왜 그럴까요("책숲에는 '만화' 분야가 없습니다") | 0권 | ch10-40 |
| ch10-07의 `NOT IN`이 안전한 근거 — `reviews.book_id`에 널이 없다 | 10.1 흔한 실수 | 0행 | ch10-40 |
| `SELECT count(*) FROM reviews WHERE order_id IS NULL;` | 10.1 흔한 실수("`order_id`가 널인 것이 섞여 있다") | 220행 | ch10-40 |
| ch10-13에서 `LIMIT`을 뗀 질의 (인증 리뷰가 없는 주문) | 10.1 흔한 실수("0행이 391건이 되었지요") | 391건 | ch10-40 |
| `SELECT count(*) FROM orders;` | 10.1 흔한 실수("주문 620건 중에") | 620건 | ch10-40 |
| ch10-14에서 `LIMIT`을 뗀 질의 (평균 쪽수 초과) | 10.1 practice 1 | 다섯 권보다 훨씬 많다(160권) | ch10-40 |
| ch10-31에서 `LIMIT`을 뗀 질의 (취소 이력 손님) | exercise 2 해설 | 서른다섯 분 | ch10-40 |
| `SELECT max(price) FROM books WHERE category = '과학';` | exercise 3 해설("가장 비싼 책이 41,000원") | 41000 | ch10-40 |
| ch10-33에서 `LIMIT`을 뗀 질의 (주문된 적 없는 책) | exercise 4 해설 | 열여덟 권 | ch10-40 |
| ch10-34에서 `LIMIT`을 뗀 질의 (제목에 '여행' + 평균 초과) | 복습 exercise 5 해설 | 열일곱 권 | ch10-40 |
| ch10-36에서 `LIMIT`을 뗀 질의 (주문 없는 손님) | 복습 exercise 6 해설 | 스물아홉 분 | ch10-40 |
| ch10-38에서 `LIMIT`을 뗀 질의 (리뷰는 있고 주문은 없는 손님) | problem 2 해설 | 스물네 분 | ch10-40 |
| ch10-39에서 `LIMIT`을 뗀 질의 (재고 평균 미만 + 리뷰 있음) | problem 3 해설 | 백쉰여덟 권 | ch10-40 |

### 10장에서 주장 케이스에서 뺀 수치

- **출력 블록 안에서 학습자가 직접 셀 수 있는 수치는 위 표에 넣지 않았다**
  (D-033). 「여섯 권입니다」(10.1 따라 하기 2단계), 「열네 권입니다」(4단계),
  「일곱 분입니다」(10.1 practice 2·10.2 문제 상황), 「여덟 분입니다」(10.2
  따라 하기 1단계), 「열네 줄입니다」(2·5단계), 「여섯 분입니다」(3단계),
  「아홉 분입니다」(10.2 practice 1), 「여섯 권입니다」(exercise 3 해설),
  「여섯 분입니다」(problem 1 해설)가 그렇다. 다만 10.2의 두 명단 크기(각 7명)는
  `UNION`·`INTERSECT`·`EXCEPT`의 결과 크기를 설명하는 근거로 본문 여러 곳에서
  되풀이되므로 ch10-40에도 함께 고정해 두었다.
- **이미 바이트로 고정된 값들의 산술은 새 주장이 아니다** (D-032). 본문이 자기
  출력의 두 수를 견주는 자리 — 10.2 따라 하기 1단계의 「일곱 더하기 일곱은
  열넷인데 여덟 줄」과 2단계의 「17·34·51·68·85·119번이 각각 두 줄씩」 — 는
  ch10-40에 넣지 않았다. 피연산자가 모두 `ch10-16`·`ch10-17`·`ch10-18`·
  `ch10-19`의 기대 출력에 바이트로 박혀 있어 world가 바뀌면 그 케이스들이 먼저
  깨지므로, 산술 결과를 따로 고정할 회귀 구멍이 없다.

### 10장에서 의도적으로 출력이 같은 케이스 쌍 (D-022)

| 쌍 | 뒷받침하는 본문 주장 |
|---|---|
| ch10-02 = ch10-03 | 10.1 따라 하기 1단계 — 평균을 손으로 옮겨 적은 질의와 서브쿼리로 적은 질의의 **결과가 같다**. 본문이 "두 출력은 글자 하나 다르지 않습니다"라고 적는 자리이며, 입력이 다르므로 별개 케이스로 유지한다 (D-022) |
| ch10-35 = ch10-36 | 복습 exercise 6 — 같은 물음에 8장의 `LEFT JOIN` + `IS NULL`과 이 장의 `EXCEPT`가 **같은 답**을 낸다. 본문이 "두 출력은 글자 하나 다르지 않습니다"라고 적는 자리다 |

### 10장에서 의도적으로 거의 같은 출력을 내는 케이스 (부분 등가)

바이트 동일은 아닌데 **부분적 일치 자체가 본문의 주장**인 쌍이다. 러너도
`check_chapter.py`도 케이스 사이의 등가를 판정하지 않으므로(pipeline "러너가
검사하는 것과 검사하지 않는 것"), 무엇이 같은지를 아래에 못 박는다.

| 쌍 | 무엇이 같은가 · 본문의 주장 |
|---|---|
| ch10-18 ↔ ch10-27 | **여덟 개의 고객번호가 같은 차례로** 나온다(17·34·47·51·68·85·102·119). 다른 것은 머리글 한 줄뿐이다 — ch10-18은 `고객번호`, ch10-27은 `단골`이고, 그 차이 때문에 표의 너비도 다르다(psql이 열 너비를 머리글에 맞추므로 데이터 줄의 앞 여백이 네 칸씩 줄어 열 줄 전부가 바이트로는 다르다). 10.2 «흔한 실수»가 "이 결과에 실린 고객번호 여덟 개는 따라 하기 1단계와 같습니다. 달라진 것은 머리글뿐이고, psql이 열 너비를 머리글에 맞추므로 표가 그만큼 좁아진 것도 함께 보세요"라고 말하는 근거다 |
| ch10-16 ↔ ch10-20 | ch10-20의 **여섯 줄이 모두 ch10-16 안에 있다**(17·34·51·68·85·119). ch10-16에만 있는 것은 102번 한 줄이고, 그 한 줄이 곧 ch10-21의 답이다. 10.2 따라 하기 3·4단계가 "1단계에서 한 번만 실렸다고 말한 바로 그 여섯 분", "단골 일곱 분 중 여섯 분이 리뷰어 명단에도 있었으니 남는 것은 한 분"이라고 말하는 근거다 |
| ch10-07 ↔ ch08-12 | **다섯 도서번호와 제목이 같은 차례로** 나온다(1·3·9·11·18번). 10.1 따라 하기 5단계가 "8장 8.1절 practice 1에서 뽑았던 바로 그 다섯 권"이라고 말하는 근거다. 머리글과 열 구성은 다르다 — ch08-12는 별칭 없이 `book_id`·`title`·`category` 세 열을 내고, ch10-07은 `도서번호`·`제목` 두 열만 낸다 |
| ch10-35·ch10-36 ↔ ch08-05 | **다섯 고객번호가 같은 차례로** 나온다(7·13·18·24·28번). 복습 exercise 6 해설이 "8장 8.1절 따라 하기 3단계에서 세었던 그 스물아홉 분… 여기 보이는 다섯 분도 그때와 같은 분들"이라고 말하는 근거다. 열 구성은 다르다 — ch08-05는 이름·도시·주문번호를 함께 내고 10장 쪽은 고객번호 한 열만 낸다 |
| ch10-06 ↔ ch09-36 | ch09-36의 다섯 도서번호(54·123·2·80·89번)가 **ch10-06의 열네 줄 안에 모두 있다.** 10.1 따라 하기 4단계가 "9장 practice에서 뽑은 다섯 권이 이 열네 권 안에 모두 들어 있다"고 말하는 근거다. 차례와 열 구성은 다르다 — ch09-36은 리뷰 수 내림차순이고 ch10-06은 도서번호 순이다 |

### 10장에서 케이스를 새로 만들지 않은 출력

- 10.1 «개념»의 서식 규칙 예제(R33)는 `ch10-03`과, (R34)는 `ch10-06`과,
  10.2 «개념»의 예제(R35·R36·R38)는 `ch10-18`과, (R37)은 `ch10-23`과 **입력이
  같으므로** 새 케이스를 만들지 않았다 (검증 케이스 규약 — "입력이 같으면 같은
  케이스다"). 네 자리 모두 출력을 싣지 않는다.
- 10.1 «개념»의 서브쿼리 계산 순서 도식과 10.2 «개념»의 집합 도식은 psql 출력이
  아니라 그림이므로 케이스가 아니다. 두 그림에는 world의 행이 옮겨 적혀 있지
  않다(10.2의 도식은 ㉠·㉡·㉢이라는 이름만 쓴다).
- 10.1 따라 하기의 psql 접속 명령(`docker exec -it ...`)은 1장 1.2절 따라 하기
  1단계를 참조할 뿐 출력을 싣지 않는다 (2~9장과 같은 처리다).
- exercise 3 해설이 산문 속 인라인 코드로 인용하는
  `WHERE price > (SELECT max(price) FROM books WHERE category = '과학')`은 질의
  전체가 아니라 절 하나이고 출력을 싣지 않는다. 그것이 `ch10-32`와 같은 답을
  낸다는 주장은 과학 분야 최고가(41,000원)로 뒷받침되며 `ch10-40`이 그 값을
  고정한다.
- 8장 8.1절 practice 1(리뷰 없는 책)·8장 8.2절(주문 없는 손님 29명)과 9장
  practice·problem 3은 참조만 하고 출력을 다시 싣지 않는다 — `ch08-12`·
  `ch09-36`·`ch09-48`이 이미 고정한다.

### 10장의 의도된 반례 (D-025)

- **없다.** 10장이 도입하는 서식 규칙 R33~R38은 모두 «개념»에서 선언되고, 그
  뒤의 코드는 규칙을 지킨다.
- `ch10-26`(묶이는 질의의 `ORDER BY`)과 `ch10-27`(뒤 질의의 별칭)은 R36·R37이
  각각 단서로 허용한 자리다 — "그렇게 적으면 어떻게 되는지를 실행으로 보이는
  예제와 그 해설"이며, R11·R17·R21·R26이 둔 것과 같은 종류의 단서다. 규칙 선언
  **뒤**에 오므로 D-025의 반례가 아니라 규칙 자신의 예외 조항에 해당한다.
- `ch10-02`(평균을 손으로 옮겨 적은 질의), `ch10-08`·`ch10-11`·`ch10-12`·
  `ch10-24`·`ch10-25`(다섯 가지 오류·함정)는 모두 **내용**이 대상인 반례이지
  서식 규칙을 어긴 코드가 아니다. 서식은 그대로 지킨다 (7~9장과 같은 처리다).

## ch11 — 11장 «데이터 넣고 고치고 지우기 — DML»

11장은 world를 **변경하는 첫 장**이다. 변경형 케이스는 첫 줄에 `-- runner: reset`을
두어 러너가 실행 전후로 world를 초기화한다 (러너 최소 규약). 조회만 하는 케이스
(`ch11-01`·`ch11-15`·`ch11-21`·`ch11-28`·`ch11-34`·`ch11-45`·`ch11-48`·`ch11-50`)
에는 그 줄이 없다 — 상태를 바꾸지 않으므로 초기화가 필요 없다.

| 케이스 | 챕터에서의 위치 |
|---|---|
| ch11-01-book-not-yet-there | 11.1 문제 상황 — 새로 들여온 책이 아직 없다(0행) |
| ch11-02-format-insert-customer | 11.1 개념 — 서식 규칙 R39·R40의 예제. 본문은 출력을 싣지 않는다 |
| ch11-03-format-insert-book | 11.1 개념 — 서식 규칙 R41(긴 열 목록의 괄호 배치)의 예제. 본문은 출력을 싣지 않는다 |
| ch11-04-format-insert-two-books | 11.1 개념 — 서식 규칙 R42(여러 행)의 예제. 본문은 출력을 싣지 않는다 |
| ch11-05-insert-new-book | 11.1 따라 하기 1단계 — 새 책 한 권을 넣고 확인한다 |
| ch11-06-insert-two-books | 11.1 따라 하기 2단계 — 여러 행을 한 문장으로 |
| ch11-07-insert-new-customer | 11.1 따라 하기 3단계 — 널을 허용하는 열은 적지 않아도 된다 |
| ch11-08-insert-duplicate-pk-error | 11.1 따라 하기 4단계 — 기본키 중복 (오류 기대, exit 3) |
| ch11-09-insert-fk-error | 11.1 따라 하기 5단계 — 외래키 위반 (오류 기대, exit 3) |
| ch11-10-insert-missing-column-error | 11.1 왜 그럴까요 — NOT NULL 열 누락 (오류 기대, exit 3) |
| ch11-11-insert-check-error | 11.1 왜 그럴까요 — 검사 제약 위반 (오류 기대, exit 3) |
| ch11-12-insert-swapped-values | 11.1 흔한 실수 — 값의 차례가 어긋나도 타입이 맞으면 조용히 들어간다 |
| ch11-13-practice-insert-review | 11.1 practice 1 풀이 — 리뷰 한 건 넣기 |
| ch11-14-practice-insert-two-books | 11.1 practice 2 풀이 — 책 두 권을 한 문장으로 |
| ch11-15-book-before-update | 11.2 문제 상황 — 고칠 대상을 먼저 조회한다 |
| ch11-16-format-update-book | 11.2 개념 — 서식 규칙 R43의 예제. 본문은 출력을 싣지 않는다 |
| ch11-17-update-stock | 11.2 따라 하기 1단계 — 열 하나를 고치고 확인한다 |
| ch11-18-update-two-columns | 11.2 따라 하기 2단계 — 열 두 개를 한 문장으로 |
| ch11-19-update-with-expression | 11.2 따라 하기 3단계 — `stock - 1`처럼 지금 값을 재료로 쓴다 |
| ch11-20-update-no-match | 11.2 따라 하기 4단계 — 조건에 맞는 행이 없어도 오류가 아니다 |
| ch11-21-essay-before-update | 11.2 따라 하기 5단계 — 바꾸기 전에 같은 조건으로 세어 둔다 |
| ch11-22-update-essay-price | 11.2 따라 하기 5단계 — 실행하고 다시 세어 확인한다 |
| ch11-23-update-without-where | 11.2 왜 그럴까요 — `WHERE` 없는 `UPDATE`가 320행을 모두 고친다 |
| ch11-24-update-check-error | 11.2 왜 그럴까요 — 검사 제약은 `UPDATE`도 막는다 (오류 기대, exit 3) |
| ch11-25-update-set-and-error | 11.2 흔한 실수 — `SET`의 대입을 `AND`로 이으면 오류 (오류 기대, exit 3) |
| ch11-26-practice-update-price | 11.2 practice 1 풀이 — 한 권의 가격 고치기 |
| ch11-27-practice-update-stock-up | 11.2 practice 2 풀이 — 재고가 0인 소설 채우기 |
| ch11-28-order-4-and-items | 11.3 문제 상황 — 지울 주문과 딸린 항목 확인 |
| ch11-29-format-delete-review | 11.3 개념 — 서식 규칙 R44의 예제. 본문은 출력을 싣지 않는다 |
| ch11-30-delete-order-fk-error | 11.3 따라 하기 1단계 — 자식이 딸린 부모는 지워지지 않는다 (오류 기대, exit 3) |
| ch11-31-delete-order-with-items | 11.3 따라 하기 2단계 — 딸린 항목부터 지우고 주문을 지운다 |
| ch11-32-delete-no-match | 11.3 따라 하기 3단계 — 조건에 맞는 행이 없어도 오류가 아니다 |
| ch11-33-delete-without-where | 11.3 왜 그럴까요 — `WHERE` 없는 `DELETE`가 리뷰 520건을 모두 지운다 |
| ch11-34-delete-star-error | 11.3 흔한 실수 — `DELETE * FROM`은 문법 오류 (오류 기대, exit 3) |
| ch11-35-update-comment-to-null | 11.3 흔한 실수 — 값 하나를 비우는 것은 `UPDATE`의 일이다(고치기 전·후를 한 케이스에 담는다) |
| ch11-36-practice-delete-review | 11.3 practice 1 풀이 — 리뷰 한 건 지우기 |
| ch11-37-practice-delete-low-ratings | 11.3 practice 2 풀이 — 별점 1점 리뷰 모두 지우기 |
| ch11-38-ex1-insert-customer | exercise 1 해설 — 새 손님 넣기(생일까지) |
| ch11-39-ex2-refill-travel-stock | exercise 2 해설 — 재고가 적은 여행 책 채우기 |
| ch11-40-ex3-delete-quiet-low-ratings | exercise 3 해설 — 별점 낮고 한 줄평 없는 리뷰 지우기 |
| ch11-41-ex4-rating-check-error | exercise 4 지문 — 별점 6점이 막히는 오류 (오류 기대, exit 3) |
| ch11-42-ex4-rating-fixed | exercise 4 해설 — 별점을 5로 고쳐 다시 넣기 |
| ch11-43-ex5-new-category-book | 복습 exercise 5(2장) 해설 — 새 분야 책을 넣고 `DISTINCT`로 분야 목록 |
| ch11-44-ex6-restock-popular-books | 복습 exercise 6(9장) 해설 — `HAVING` 서브쿼리로 고른 책의 재고 채우기 |
| ch11-45-pb1-count-cancelled-2024 | problem 1 해설 — 지울 주문·항목을 먼저 센다 |
| ch11-46-pb1-delete-cancelled-2024 | problem 1 해설 — 항목부터 지우고 주문을 지운다 |
| ch11-47-pb2-insert-three-books | problem 2 해설 — 신간 세 권을 넣고 분야별 권수 |
| ch11-48-pb3-count-never-ordered | problem 3 해설 — 대상 권수를 먼저 센다 |
| ch11-49-pb3-zero-stock-never-ordered | problem 3 해설 — 그 책들의 재고를 0으로 |
| ch11-50-world-claims-counts | **주장 케이스** — 본문이 인용하는 world 수치 주장 25건(테이블 행 수, 최대 번호, 분야별 권수, 조건을 만족하는 행 수). 본문에 출력 블록이 없다 |

`ch11-02`·`ch11-03`·`ch11-04`·`ch11-16`·`ch11-29` 다섯 케이스는 **기대 출력이
비어 있다**(`[exit 0]`만 있다). 본문이 서식 규칙을 보이려고 실은 변경 문장이라
출력을 싣지 않기 때문이며, 이 케이스가 고정하는 것은 "그 문장이 오류 없이
실행된다"는 사실이다. 다섯의 `.expected`가 서로 바이트 동일한 것은 이 구성의
결과이지 본문의 주장이 아니다 — 그래서 「의도적으로 출력이 같은 케이스 쌍」 절에
넣지 않았다. 같은 이유로 `ch09-02-count-books` = `ch11-32-delete-no-match`
(둘 다 `권수 | 320`), `ch10-10-empty-subquery-compare` = `ch11-01-book-not-yet-there`
(둘 다 `도서번호 | 제목 | 가격` 세 열의 0행)도 우연히 같아진 것이지 본문이 등가를
주장하는 자리가 아니다.

`ch11-46`(과 그 앞의 `ch11-45`)은 **8칸 들여쓴 줄**을 갖는다 —
`WHERE order_id IN (` 아래 4칸 들여쓴 서브쿼리(R34) 안에서 `AND` 앞에서 줄을 바꿔
다시 4칸을 더 들여썼기 때문이다(R10). 1~10장에 없던 폭이라 `check_chapter.py`
H10이 후보로 올리지만, 두 규칙을 겹쳐 적용한 결과이지 새 배치가 아니다
(style.md R44의 둘째 예제가 같은 모양이다).

### 러너로 재현할 수 없어 케이스로 만들지 않은 출력

| 챕터의 블록 | 제외 이유 |
|---|---|
| 11.1 «개념»의 명령 태그 블록 `INSERT 0 1` | 러너는 `psql -X -q`로 실행하는데 `-q`가 명령 태그를 억제한다(`kit/verify.sh`의 `run_case`). 직접 재현: kit 디렉토리에서 `./reset.sh && docker exec -i ll-sql-fundamentals psql -U postgres -d bookstore -X -v ON_ERROR_STOP=1 < cases/ch11-03-format-insert-book.sql`(`-q` 없이) — `INSERT 0 1` 한 줄이 나온다. 실행 후 `./reset.sh`. **`-f`가 아니라 표준 입력(`<`)으로 넘긴다** — `-f`의 경로는 컨테이너 안에서 풀리는데 kit 디렉토리는 컨테이너에 마운트되어 있지 않다 (러너의 `run_case`도 같은 이유로 `<`를 쓴다) |

본문이 산문 속 인라인 코드로 언급하는 나머지 명령 태그(`INSERT 0 2`·`INSERT 0 3`·
`UPDATE 1`·`UPDATE 4`·`UPDATE 14`·`UPDATE 16`·`UPDATE 18`·`UPDATE 44`·`UPDATE 320`·
`UPDATE 0`·`DELETE 1`·`DELETE 2`·`DELETE 7`·`DELETE 11`·`DELETE 23`·`DELETE 29`·
`DELETE 520`·`DELETE 0`)도 같은 이유로 러너가 대조하지 않는다. 다만 그 숫자는
**변경된 행 수**이므로 아래 두 절이 값으로 뒷받침한다 — 출력 블록 안에서 셀 수
있거나, `ch11-50`이 고정한다.

### 11장에서 출력 블록 없이 수치만 언급한 질의

본문이 결과를 싣지 않고 개수만 인용하는 자리들이다. 인용한 수치는 전부
`ch11-50-world-claims-counts`가 고정한다 (D-021).

| 질의 | 본문 위치 | 인용 값 | 고정하는 케이스 |
|---|---|---|---|
| `SELECT count(*) FROM books;` | 11.1 왜 배우나요("320행은 1장에서 본 그대로") | 320 | ch11-50 |
| `SELECT max(book_id) FROM books;` | 11.1 예측해 보기·따라 하기 1단계("마지막 도서번호가 320") | 320 | ch11-50 |
| `SELECT count(*) FROM information_schema.columns WHERE table_name = 'books';` | 11.1 예측해 보기("열이 여덟 개") | 8 | ch11-50 |
| `SELECT stock FROM books WHERE book_id = 5;` | 11.2 따라 하기 3단계("35권에서 34권") | 35 | ch11-50 |
| `SELECT count(*) FROM books WHERE category = '소설' AND stock = 0;` | 11.2 practice 2("네 권", `UPDATE 4`) | 4 | ch11-50 |
| `SELECT count(*) FROM reviews;` | 11.3 왜 그럴까요("520건이 모두 사라졌습니다", `DELETE 520`)·practice 1·2·exercise 3 | 520 | ch11-50 |
| `SELECT count(*) FROM reviews WHERE rating = 1;` | 11.3 practice 2(`DELETE 23`) | 23 | ch11-50 |
| `SELECT count(*) FROM books WHERE category = '여행' AND stock < 5;` | exercise 2(`UPDATE 16`, "열여섯 권") | 16 | ch11-50 |
| `SELECT count(*) FROM reviews WHERE rating <= 2 AND comment IS NULL;` | exercise 3(`DELETE 29`) | 29 | ch11-50 |
| `SELECT count(DISTINCT category) FROM books;` | 복습 exercise 5("여덟 종이던 분야") | 8 | ch11-50 |
| `SELECT count(*) FROM orders WHERE status = '취소';` | problem 1("61건에서 54건") | 61 | ch11-50 |
| `SELECT count(*) FROM books WHERE category = '어린이';` | problem 2("어린이가 39권에서 40권") | 39 | ch11-50 |
| `SELECT count(*) FROM books WHERE category = '과학';` | problem 2("과학이 29권에서 30권") | 29 | ch11-50 |
| `SELECT count(*) FROM books WHERE category = '소설';` | problem 2("소설이 45권에서 46권") | 45 | ch11-50 |
| `SELECT count(*) FROM books WHERE book_id = 1;` | 11.1 따라 하기 4단계(1번 도서번호가 이미 쓰이고 있다는 전제) | 1 | ch11-50 |
| `SELECT count(*) FROM customers WHERE customer_id = 9999;` | 11.1 따라 하기 5단계(9999번 손님이 없다는 전제) | 0 | ch11-50 |
| `SELECT count(comment) FROM reviews WHERE review_id = 1;` | 11.3 흔한 실수(1번 리뷰에 원래 한 줄평이 있었다는 전제) | 1 | ch11-50 |

### 11장에서 주장 케이스에서 뺀 수치

- **출력 블록 안에서 그대로 셀 수 있는 수치는 넣지 않았다** (D-033). 명령 태그의
  숫자 대부분이 여기 든다 — 11.1 따라 하기 2단계의 `INSERT 0 2`(확인 질의가 두 줄),
  11.2 따라 하기 1·2단계의 `UPDATE 1`(확인 질의가 한 줄), 4단계의 `UPDATE 0`(걸린
  책 0), 5단계의 `UPDATE 44`(권수 44가 `ch11-21`·`ch11-22`에 찍힌다), 왜 그럴까요의
  `UPDATE 320`(권수 320), 11.3 따라 하기 2단계의 `DELETE 2`·`DELETE 1`(문제 상황
  `ch11-28`이 항목 두 줄과 주문 한 줄을 보인다), 3단계의 `DELETE 0`(권수 320 그대로),
  practice 1의 `DELETE 1`, 복습 exercise 6의 `UPDATE 14`(권수 14), problem 1의
  `DELETE 11`·`DELETE 7`(`ch11-45`가 11과 7을 보인다), problem 2의 `INSERT 0 3`(값
  묶음 세 개가 본문 코드에 있다), problem 3의 `UPDATE 18`(`ch11-48`이 18을 보인다),
  복습 exercise 5의 "아홉 종"(`ch11-43`이 9행을 낸다)이 그렇다.
- **이미 바이트로 고정된 값들의 산술은 새 주장이 아니다** (D-032). 11.2 따라 하기
  5단계의 "최저가와 최고가만 정확히 1,000원씩 올라갔습니다"는 `ch11-21`(8000·39000)과
  `ch11-22`(9000·40000)가 네 값을 모두 바이트로 고정하므로 따로 넣지 않았다. 같은
  이유로 11.3 practice 1의 "520건에서 519건"(519는 `ch11-36`에), practice 2의 "497건"
  (`ch11-37`에), exercise 3의 "491건"(`ch11-40`에), problem 1의 "54건"(`ch11-46`에),
  problem 2의 40·30·46권(`ch11-47`에), 복습 exercise 5 채점 포인트의 "321줄"
  (320 + 1)도 넣지 않았다.

### 11장에서 케이스를 새로 만들지 않은 출력

- 11.1 «따라 하기» 앞머리의 쉘 블록(`cd ... && ./reset.sh` + `docker exec -it ...`)과
  11.2·11.3 «왜 그럴까요»의 `./reset.sh` 블록은 psql 출력이 아니라 쉘 명령이고
  출력을 싣지 않는다. `bash`로 펜스했으므로 케이스 대조의 대상이 아니다.
- 11.1 «개념»의 `INSERT INTO 테이블 (열1, 열2, 열3)` / 11.2 «개념»의
  `UPDATE 테이블 SET ... WHERE 조건` / 11.3 «개념»의 `DELETE FROM 테이블 WHERE 조건`
  세 블록은 실제 테이블이 아니라 **문장의 모양**을 보이는 뼈대이므로 실행할 수 없다.
  언어를 밝히지 않은 펜스로 실었고 출력도 싣지 않는다.
- exercise 4의 지문은 `ch11-41`의 입력만 싣고 출력은 해설 토글 안에 싣는다 —
  같은 케이스가 두 자리를 뒷받침한다.

### 11장에서 우연히 바이트가 같은 케이스

쌍의 한쪽이 앞 장의 케이스이므로 뒤 장인 11장의 절에 적는다 (검증 케이스 규약).
둘 다 동일성 자체를 본문이 근거로 쓰지 않으므로 「의도적으로 출력이 같은 케이스 쌍」
표에는 넣지 않는다.

- **`ch09-02-count-books` = `ch11-32-delete-no-match`.** 두 케이스가 마지막에
  실행하는 문장이 `SELECT count(*) AS 권수 FROM books;`로 같고, `ch11-32`의
  `DELETE`가 한 행도 지우지 않아 world 상태도 같으므로 출력이 바이트로 같아진다.
  11.3 따라 하기 3단계가 말하는 "책은 320권 그대로입니다"는 **320이라는 값**에
  대한 주장이고 그 값은 `ch11-50-world-claims-counts`가 고정한다 — 9장 케이스와
  바이트가 같다는 사실은 어느 장도 주장하지 않는다.
- **`ch10-10-empty-subquery-compare` = `ch11-01-book-not-yet-there`.** 선택 목록과
  별칭이 `book_id AS 도서번호, title AS 제목, price AS 가격`으로 같고 두 질의가
  모두 0행을 내므로, 머리글 두 줄과 `(0 rows)`만 남아 열 너비까지 같아지는
  **구조적** 동일이다. 0행이 되는 사정은 서로 다르다 — `ch10-10`은 널과 견주는
  조건이 「알 수 없음」이 되어서고(10.1 «왜 그럴까요»), `ch11-01`은 아직 없는 책을
  찾아서다(11.1 «문제 상황»).

### 11장의 의도된 반례 (D-025)

- **없다.** 11장이 도입하는 서식 규칙 R39~R44는 모두 «개념»에서 선언되고, 그 뒤의
  코드는 규칙을 지킨다.
- 11.1 «흔한 실수»의 `ch11-12`(값의 차례가 어긋난 `INSERT`), 11.2 «흔한 실수»의
  `ch11-25`(`SET`을 `AND`로 이은 문장), 11.3 «흔한 실수»의 `ch11-34`(`DELETE * FROM`),
  그리고 오류를 기대하는 나머지 케이스는 모두 **내용**이 대상인 반례이지 서식 규칙을
  어긴 코드가 아니다. 서식은 그대로 지킨다 (7~10장과 같은 처리다).
- R40("열 목록을 반드시 적습니다")을 어긴 코드, 즉 열 목록을 생략한 `INSERT`는
  본문에 **싣지 않았다**. 그 형태의 위험은 `ch11-12`(차례가 어긋나면 조용히 들어간다)가
  이미 실행으로 보이므로, 규칙의 근거를 얻으려고 반례를 더 실을 필요가 없었다.

## ch12 — 12장 «전부 되거나 전부 안 되거나 — 트랜잭션»

12장도 11장처럼 world를 변경한다. 변경형 케이스는 첫 줄에 `-- runner: reset`을 두어
러너가 실행 전후로 world를 초기화한다 (러너 최소 규약). 조회만 하는 케이스
(`ch12-01`·`ch12-08`·`ch12-22`·`ch12-26`·`ch12-27`)에는 그 줄이 없다.

| 케이스 | 챕터에서의 위치 |
|---|---|
| ch12-01-order-intake-before | 12.1 문제 상황 — 주문을 받기 전의 장부 상태. **12.1 따라 하기 3단계**가 같은 질의를 그대로 다시 실으므로 이 케이스가 두 자리를 뒷받침한다 (입력이 같으면 같은 케이스다) |
| ch12-02-format-transaction-block | 12.1 개념 — 서식 규칙 R45·R46의 예제. 본문은 출력을 싣지 않는다 |
| ch12-03-order-intake-commit | 12.1 따라 하기 1단계 — 세 문장을 묶어 확정한다 |
| ch12-04-order-intake-fk-error | 12.1 따라 하기 2단계 — 트랜잭션 안에서도 외래키 제약이 막는다 (오류 기대, exit 3) |
| ch12-05-single-update-autocommit | 12.1 왜 그럴까요 — 묶지 않은 문장 하나만 실행한 장부 |
| ch12-06-practice-order-intake | 12.1 practice 1 풀이 — 다른 손님·다른 책의 주문 접수 |
| ch12-07-practice-cancel-order | 12.1 practice 2 풀이 — 두 `DELETE`를 한 덩어리로 |
| ch12-08-books-price-before | 12.2 문제 상황 — 올리기 전 책 전체의 가격대 |
| ch12-09-format-rollback | 12.2 개념 — 서식 규칙 R47의 예제. 본문은 출력을 싣지 않는다 |
| ch12-10-rollback-missing-where | 12.2 따라 하기 1단계 — 확정 전 되돌리기(변경 후·롤백 후 두 표를 한 케이스에) |
| ch12-11-commit-essay-price | 12.2 따라 하기 2단계 — 확인하고 확정하기(확인 표와 확정 뒤 표를 한 케이스에) |
| ch12-12-rollback-after-commit | 12.2 따라 하기 3단계 — 확정 뒤의 `ROLLBACK`은 되돌리지 못한다(`WARNING` 포함) |
| ch12-13-practice-rollback-delete | 12.2 practice 1 풀이 — 너무 많이 지운 것을 되돌린다 |
| ch12-14-practice-commit-delete | 12.2 practice 2 풀이 — 확인하고 확정한다 |
| ch12-15-ex1-order-intake | exercise 1 해설 — 주문 접수를 확인 뒤 확정 |
| ch12-16-ex2-rollback-selfhelp-stock | exercise 2 해설 — 잘못 이해한 지시를 되돌린다 |
| ch12-17-ex3-delete-order-error | exercise 3 지문 — 지우는 차례가 거꾸로라 막힌다 (오류 기대, exit 3). 입력은 지문에, 출력은 해설 토글에 실린다 |
| ch12-18-ex3-delete-order-fixed | exercise 3 해설 — 차례를 바로잡아 다시 실행 |
| ch12-19-ex4-restock-low-stock | exercise 4 해설 — 먼저 세고, 확인하고, 확정 |
| ch12-20-ex5-zero-stock-unreviewed | 복습 exercise 5(10장) 해설 — `NOT IN` 서브쿼리로 고른 책의 재고를 0으로 |
| ch12-21-ex6-new-book-first-sale | 복습 exercise 6(11장) 해설 — 신간 등록과 첫 판매를 한 덩어리로 |
| ch12-22-pb1-order-45-before | problem 1 해설 — 되돌릴 대상을 먼저 확인한다 |
| ch12-23-pb1-cancel-order-45 | problem 1 해설 — 재고 복구·항목 삭제·주문 삭제를 한 덩어리로 |
| ch12-24-pb2-delete-customer-rollback | problem 2 해설 — 탈퇴 손님의 기록을 네 테이블에서 지운 뒤, 센 값이 기준을 넘어 되돌린다 |
| ch12-25-pb3-swap-order-item | problem 3 해설 — 항목 교체와 두 책의 재고 조정 |
| ch12-26-world-claims-counts | **주장 케이스** — 본문이 인용하는 world 수치 주장 20건(책의 가격·재고, 특정 주문의 항목 수·수량, 가장 큰 주문번호, 존재/부재). 본문에 출력 블록이 없다 |
| ch12-27-world-claims-text | **주장 케이스** — 본문이 이름으로 부르는 책 제목 4건과 손님 이름 1건. 실측값이 글자라 수치 주장과 케이스를 나눴다 (검증 케이스 규약 — 값의 타입이 섞이면 케이스를 나눈다). 본문에 출력 블록이 없다 |

`ch12-02`·`ch12-09`의 `.expected`는 **비어 있다**(`[exit 0]`만 있다). 서식 규칙을
보이려고 실은 변경 문장이라 본문이 출력을 싣지 않기 때문이며, 이 케이스가 고정하는
것은 "그 문장이 오류 없이 실행된다"는 사실이다. 11장의 같은 유형 다섯
(`ch11-02`·`ch11-03`·`ch11-04`·`ch11-16`·`ch11-29`)과 바이트 동일한 것은 이 구성의
결과이지 본문의 주장이 아니다 — 그래서 「의도적으로 출력이 같은 케이스 쌍」 절에
넣지 않았다.

### 러너로 재현할 수 없어 케이스로 만들지 않은 출력

| 챕터의 블록 | 제외 이유 |
|---|---|
| 12.2 «왜 그럴까요»의 psql 세션 전사 블록 (`bookstore=# BEGIN;`으로 시작해 `bookstore=#`으로 끝나는 블록) | 이 블록이 보이는 것은 **오류로 중단된 트랜잭션**의 거동(프롬프트 `=*#`·`=!#`, `current transaction is aborted` 메시지, `COMMIT`에 `ROLLBACK`으로 답하는 것)인데, 러너는 psql을 `-X -q -v ON_ERROR_STOP=1`로 실행하므로 **첫 오류에서 실행이 멈춘다**(`kit/verify.sh`의 `run_case`). 오류 **다음** 명령이 어떻게 되는지를 한 케이스에 담을 수 없고, `-q`가 명령 태그(`BEGIN`·`UPDATE 1`·`ROLLBACK`)도 억제한다. 이 kit는 전사 케이스를 지원하지 않는다 (kit README의 러너 규약 — D-029는 approved kit에 소급 요구하지 않는다). 직접 재현: kit 디렉토리에서 `./reset.sh` 뒤 `docker exec -it ll-sql-fundamentals psql -U postgres -d bookstore -X --pset pager=off`로 접속해 블록의 여섯 줄(`BEGIN;` / `UPDATE ...` / `DELETE ...` / `SELECT ...` / `COMMIT;` / `SELECT ...`)을 차례로 입력한다. 트랜잭션이 전부 취소되므로 실행 뒤 world는 그대로다 |

- 이 전사의 두 줄짜리 외래키 오류 메시지(`update or delete on table "orders" ...` /
  `DETAIL:  Key (order_id)=(4) is still referenced from table "order_items".`)는
  **`ch11-30-delete-order-fk-error`의 기대 출력이 이미 바이트로 고정한다** — 같은
  `DELETE FROM orders WHERE order_id = 4;`가 낸 메시지다. 전사에서 러너 대조를
  빠져나가는 것은 프롬프트 줄과 명령 태그, 그리고 중단 상태의 오류 메시지뿐이다.
- 본문이 산문 속 인라인 코드로 언급하는 명령 태그(`BEGIN`·`COMMIT`·`ROLLBACK`·
  `UPDATE 1`·`UPDATE 2`·`UPDATE 44`·`UPDATE 76`·`UPDATE 88`·`INSERT 0 1`·
  `DELETE 1`·`DELETE 2`·`DELETE 3`·`DELETE 23`)도 `-q`에 억제되어 러너가 대조하지
  않는다. 「떠올려 보기」 1번의 `UPDATE 320`은 12장이 실행한 것이 아니라 11장
  11.2 «왜 그럴까요»를 되짚는 인용이다 (그 값은 `ch11-23`이 고정한다). 그 숫자는 **변경된 행 수**이므로 아래 두 절이 값으로 뒷받침한다 — 출력
  블록 안에서 셀 수 있거나, `ch12-26`이 고정한다. (11장의 같은 처리와 같다.)

### 12장에서 출력 블록 없이 수치만 언급한 질의

본문이 결과를 싣지 않고 값만 인용하는 자리들이다. 인용한 값은 전부
`ch12-26-world-claims-counts`(정수)와 `ch12-27-world-claims-text`(글자)가 고정한다
(D-021).

| 질의 | 본문 위치 | 인용 값 | 고정하는 케이스 |
|---|---|---|---|
| `SELECT title, price FROM books WHERE book_id = 1;` | 12.1 문제 상황·따라 하기 1단계(「빛나는 혁명 이야기」, 29,500원) | 빛나는 혁명 이야기 / 29500 | ch12-27 / ch12-26 |
| `SELECT count(*) FROM books WHERE book_id = 1;` | 12.1 따라 하기 1단계(`UPDATE 1`이 한 행인 근거) | 1 | ch12-26 |
| `SELECT count(*) FROM books WHERE book_id = 99999;` | 12.1 따라 하기 2단계("그런 도서번호는 `books`에 없습니다") | 0 | ch12-26 |
| `SELECT title, price, stock FROM books WHERE book_id = 100;` | 12.1 practice 1(「오늘의 채소」, 28,500원, 재고 35권) | 오늘의 채소 / 28500 / 35 | ch12-27 / ch12-26 |
| `SELECT count(*) FROM order_items WHERE order_id = 4;` | 12.1 practice 2("항목이 두 줄 딸려 있어서") | 2 | ch12-26 |
| `SELECT count(*) FROM orders WHERE order_id = 4 AND status = '취소';` | 12.2 왜 그럴까요("취소된 4번 주문을 정리하면서") | 1 | ch12-26 |
| `SELECT title, price, stock FROM books WHERE book_id = 3;` | exercise 1("조용한 서재 노트", 22,500원, 재고 20권)·problem 3(재고 20권) | 조용한 서재 노트 / 22500 / 20 | ch12-27 / ch12-26 |
| `SELECT max(order_id) FROM orders;` | exercise 1 채점 포인트(새 주문에 매겨질 번호 621 = 620 + 1) | 620 | ch12-26 |
| `SELECT count(*) FROM order_items WHERE order_id = 28;` | exercise 3("항목이 세 줄 딸려 있습니다", `DELETE 3`) | 3 | ch12-26 |
| `SELECT count(*) FROM orders WHERE order_id = 28 AND status = '취소';` | exercise 3("28번 주문(취소된 주문이고 …)") | 1 | ch12-26 |
| `SELECT count(*) FROM books WHERE title = '빛나는 계절';` | 복습 exercise 6(신간이므로 아직 없다는 전제) | 0 | ch12-26 |
| `SELECT count(*) FROM orders WHERE order_id = 45 AND status = '취소';` | problem 1("취소 주문 하나를 마무리합니다") | 1 | ch12-26 |
| `SELECT stock FROM books WHERE book_id = 249;` | 12.2 왜 그럴까요 전사(마지막 조회의 35권) | 35 | ch12-26 |
| `SELECT count(*) FROM books WHERE book_id = 249;` | 12.2 왜 그럴까요 전사(`UPDATE 1`이 한 행인 근거) | 1 | ch12-26 |
| `SELECT quantity FROM order_items WHERE order_id = 4 AND book_id = 249;` | 12.2 왜 그럴까요("거기 담긴 249번 책 한 권") | 1 | ch12-26 |
| `SELECT title, stock FROM books WHERE book_id = 106;` | problem 3(「한 권으로 읽는 국수 사전」, 재고 2권을 되돌리면 4권) | 한 권으로 읽는 국수 사전 / 2 | ch12-27 / ch12-26 |
| `SELECT quantity FROM order_items WHERE order_id = 620 AND book_id = 106;` | problem 3("106번, 두 권") | 2 | ch12-26 |
| `SELECT count(*) FROM order_items WHERE order_id = 620;` | problem 3("620번 주문의 다른 항목") | 2 | ch12-26 |
| `SELECT name FROM customers WHERE customer_id = 51;` | problem 2("51번 손님 「신수아」 님") | 신수아 | ch12-27 |

### 12장에서 주장 케이스에서 뺀 수치

- **출력 블록 안에서 그대로 셀 수 있는 수치는 넣지 않았다** (D-033). 명령 태그의
  숫자 대부분이 여기 든다 — 12.2 따라 하기 2단계의 `UPDATE 44`(권수 44가
  `ch12-11`에 찍힌다), exercise 4의 `UPDATE 88`(`ch12-19`의 대상권수 88), 복습
  exercise 5의 `UPDATE 76`(`ch12-20`의 권수 76), problem 1의 `UPDATE 2`·`DELETE 2`
  (`ch12-22`가 두 줄·두 권씩을 보인다)·`DELETE 1`(주문 한 건), exercise 3의
  `DELETE 1`, 12.1 따라 하기 1단계의 `INSERT 0 1`(확인 표의 주문 수·항목 수가 각각
  하나씩 는다)이 그렇다. `books` 320권, `orders` 620건, `order_items` 1,243건,
  `reviews` 520건, 에세이 44권, 자기계발 45권 같은 본문의 수치도 모두 어느 출력
  블록에 그대로 찍혀 있어 넣지 않았다.
- **이미 바이트로 고정된 값들의 산술은 새 주장이 아니다** (D-032). 12.2 practice 2의
  `DELETE 23`("520건에서 497건")은 `ch12-13`(520)과 `ch12-14`(497)가 두 값을
  바이트로 고정하므로 따로 넣지 않았다. 같은 이유로 12.2 따라 하기
  1단계의 "1,000원씩 올랐다"(`ch12-08`의 8000·42000과 `ch12-10`의 9000·43000),
  exercise 3의 "620건에서 619건"(`ch12-01`의 620과 `ch12-18`의 619), problem 1의
  "각각 22권"(`ch12-22`의 20 + 수량 2, `ch12-23`의 22), problem 3의 "20권에서
  18권"(`ch12-26`의 20과 `ch12-25`의 18)도 넣지 않았다. exercise 1 채점 포인트의
  "621"(새 주문에 매겨질 번호)도 같다 — `ch12-26`이 `orders`의 가장 큰 주문번호
  620을 고정하므로 621 = 620 + 1이 그 값의 산술이다.

### 12장에서 케이스를 새로 만들지 않은 출력

- 12.1 «따라 하기» 앞머리의 쉘 블록(`cd ... && ./reset.sh` + `docker exec -it ...`)은
  psql 출력이 아니라 쉘 명령이고 출력을 싣지 않는다. `bash`로 펜스했으므로 케이스
  대조의 대상이 아니다.
- 12.1 «개념»의 `BEGIN;` / `변경 문장 1;` / … / `COMMIT;` 블록은 실제 문장이 아니라
  **트랜잭션 블록의 모양**을 보이는 뼈대이므로 실행할 수 없다. 언어를 밝히지 않은
  펜스로 실었고 출력도 싣지 않는다 (11장의 세 뼈대 블록과 같은 처리다).
- 12.1 «따라 하기» 3단계의 질의는 12.1 «문제 상황»과 **입력이 바이트 동일**하므로
  새 케이스를 만들지 않고 `ch12-01`이 두 자리를 뒷받침한다 (검증 케이스 규약 —
  입력이 같으면 같은 케이스다). 두 자리의 출력 블록도 같은데, 그것이 본문의 주장
  이다 — 실패한 트랜잭션이 아무것도 남기지 않아 「문제 상황」의 장부로 되돌아왔다.
- exercise 3의 지문은 `ch12-17`의 입력만 싣고 출력은 해설 토글 안에 싣는다 —
  같은 케이스가 두 자리를 뒷받침한다.

### 12장에서 의도적으로 거의 같은 출력을 내는 케이스 (부분 등가)

러너는 케이스 사이의 등가를 검사하지 않으므로(pipeline "러너가 검사하는 것과
검사하지 않는 것") 여기에 적어 둔다. **바이트 등가 주장이 아니라 값 주장이다.**

| 쌍 | 무엇이 같은가 |
|---|---|
| ch11-22-update-essay-price ↔ ch12-11-commit-essay-price | 12.2 «따라 하기» 2단계가 "11장 11.2절 «따라 하기» 5단계에서 확인했던 값과 같다"고 말하는 자리다. 두 기대 출력이 담은 에세이 44권의 권수·최저가·최고가 세 값이 `44`·`9000`·`40000`으로 같다. `ch12-11`은 확인 표와 확정 뒤 표 **두 개**를 담으므로 바이트로는 다르다 |

### 12장의 의도된 반례 (D-025)

- **없다.** 12장이 도입하는 서식 규칙 R45~R47은 모두 «개념»에서 선언되고, 그 뒤의
  코드는 규칙을 지킨다.
- 12.1 «따라 하기» 2단계의 `ch12-04`, exercise 3의 `ch12-17`처럼 오류를 기대하는
  케이스는 **내용**(도서번호를 잘못 적음, 지우는 차례가 거꾸로)이 대상인 반례이지
  서식 규칙을 어긴 코드가 아니다. 서식은 그대로 지킨다 (7~11장과 같은 처리다).

## ch13 — exit assessment «fundamentals 수료 판정»

exit assessment 문항의 기대 결과도 챕터와 같은 방식으로 케이스에 영속화한다
(D-012). 접두사는 그 파일의 번호를 따라 `ch13-`이다. 문항 14는 world를
변경하므로 그 두 케이스는 첫 줄에 `-- runner: reset`을 두어 러너가 실행 전후로
world를 초기화한다. 나머지 열다섯 개는 조회만 하므로 그 줄이 없다. 그중
`ch13-13`은 **오류를 기대하는 케이스**라 종료 코드가 `3`이다.

| 케이스 | 챕터에서의 위치 |
|---|---|
| ch13-01-q1c-row-counts | 문항 1 (다) — psql 프롬프트에서 실행하는 다섯 테이블 행 수 점검. 입력은 지문에, 출력은 해설 토글에 실린다 |
| ch13-02-q6-chuncheon-order-counts | 문항 6 — 표준 용어로 설명할 대상 질의. 입력은 지문에, 출력은 해설 토글에 실린다 |
| ch13-03-q7a-sale-shelf-picks | 문항 7 (가) 해설 — 균일가 매대에 올릴 여행·요리 책 여섯 권 |
| ch13-04-q7b-sale-shelf-union | 문항 7 (나) 해설 — 같은 여섯 권을 `UNION`으로 다시 구한다. 기대 출력이 `ch13-03`과 바이트 동일한 것이 이 문항의 요점이다 (아래 D-022 절) |
| ch13-05-q8-verify-count | 문항 8 해설 — 본 질의보다 먼저 내는 검증 질의 (S1.3) |
| ch13-06-q8-recent-no-birthdate | 문항 8 해설 — 생일을 적지 않은 2025년 이후 가입 고객 17명 |
| ch13-07-q9-shipping-orders | 문항 9 해설 — 두 테이블 내부 조인 (배송중 주문과 손님) |
| ch13-08-q10-five-star-reviews | 문항 10 해설 — 세 테이블 조인 (`LEFT JOIN`으로 구매 인증 없는 리뷰까지) |
| ch13-09-q11-city-sales | 문항 11 해설 — 도시별 매출 집계와 `HAVING`, 대상 행을 거르는 스칼라 서브쿼리 |
| ch13-10-q12-verify-review-counts | 문항 12 해설 — 묶기 전에 내는 검증 질의 (S1.3) |
| ch13-11-q12-rating-comment-counts | 문항 12 해설 — 별점별 리뷰 수와 내용 있는 리뷰 수 |
| ch13-12-q13a-price-tag-format | 문항 13 (가) 해설 — 문서에서 찾은 숫자 서식 패턴(`FM999,999`)을 적용한 가격표 |
| ch13-13-q13b-aggregate-in-where | 문항 13 (나) — 집계 함수를 `WHERE`에 써서 나는 오류. 입력은 지문에, 오류 메시지는 해설 토글에 실린다 (**오류 기대**, exit 3) |
| ch13-14-q14a-new-customer-order | 문항 14 (가) 해설 — 신규 손님 등록·주문·항목·재고 차감을 한 덩어리로 확정 |
| ch13-15-q14b-rollback-null-comments | 문항 14 (나) 해설 — 너무 많이 지운 것을 되돌린다 (세 확인 표를 한 케이스에) |
| ch13-16-world-claims-counts | **주장 케이스** — 본문이 인용하는 world 수치 주장 17건(대상 건수, 동명이인 수, 별점별 리뷰 수, 특정 책의 정가·재고, 가장 큰 번호, 부재). 본문에 출력 블록이 없다 |
| ch13-17-world-claims-text | **주장 케이스** — 본문이 이름으로 부르는 책 제목 2건. 실측값이 글자라 수치 주장과 케이스를 나눴다 (검증 케이스 규약 — 값의 타입이 섞이면 케이스를 나눈다). 본문에 출력 블록이 없다 |

### 러너로 재현할 수 없어 케이스로 만들지 않은 출력

| 챕터의 블록 | 제외 이유 |
|---|---|
| 「시작하기 전에」와 문항 1 (가)의 쉘 블록(`cd ... && ./reset.sh`, `docker exec -it ...`) | psql 출력이 아니라 쉘 명령이고 출력을 싣지 않는다. `bash`로 펜스했으므로 케이스 대조의 대상이 아니다 |
| 문항 1 (가)가 산문으로 언급하는 접속 프롬프트(`bookstore=#`·`bookstore-#`) | 대화형 세션에서만 나오는 표시라 비대화형 러너에는 나타나지 않는다(1장과 같은 처리). 블록으로 싣지 않고 산문 속 인라인 코드로만 쓴다. 직접 재현: `docker exec -it ll-sql-fundamentals psql -U postgres -d bookstore` |

### ch13이 케이스를 새로 만들지 않은 출력

- 문항 1 (나)의 `\d reviews`는 입력도 출력도 `ch01-07-d-reviews`와 **바이트
  동일**하므로 새 케이스를 만들지 않았다 (검증 케이스 규약 — 입력이 같으면 같은
  케이스다). 1장 절은 approved이므로 고치지 않고 여기에 적는다.
- 문항 6의 지문에 실린 질의는 그 해설의 출력 블록과 짝이 되는 입력이며
  `ch13-02`가 두 자리를 함께 뒷받침한다. 문항 1 (다)의 지문에 실린 질의도,
  문항 13 (나)의 지문에 실린 오류 나는 질의도 같은 관계로 `ch13-01`과
  `ch13-13`이 뒷받침한다.
- 문항 2 지문의 「`order_items`의 복합 기본키는 `(order_id, book_id)`」 주장은
  `ch01-08-d-order-items`의 기대 출력이 바이트로 고정하므로 새 케이스를 만들지
  않았다 (위 `\d reviews`와 같은 처리다). 1장 절은 approved이므로 고치지 않고
  여기에 적는다.

### ch13에서 출력 블록 없이 수치만 언급한 자리

본문이 결과를 싣지 않고 값만 인용하는 자리들이다. 인용한 값은 전부
`ch13-16-world-claims-counts`(정수)와 `ch13-17-world-claims-text`(글자)가 고정한다
(D-021).

| 질의 | 본문 위치 | 인용 값 | 고정하는 케이스 |
|---|---|---|---|
| `SELECT count(*) FROM books WHERE category IN ('여행', '요리') AND price BETWEEN 12000 AND 20000;` | 문항 7 (가) 해설("조건에 맞는 책은 모두 17권") | 17 | ch13-16 |
| `SELECT count(*) FROM customers WHERE birth_date IS NULL;` | 문항 8 채점 포인트("생일을 적지 않은 고객은 world 전체에 41명") | 41 | ch13-16 |
| `SELECT count(*) FROM customers WHERE name = '서도윤';` | 문항 9 해설("서도윤이라는 이름의 고객이 네 명") | 4 | ch13-16 |
| `SELECT count(*) FROM customers WHERE city = '춘천' AND name = '조도윤';` | 문항 6 해설("춘천에는 조도윤이라는 이름의 고객이 두 명") | 2 | ch13-16 |
| `SELECT count(DISTINCT city) FROM customers;` | 문항 11 해설("도시는 모두 열 곳") | 10 | ch13-16 |
| `SELECT count(*) FROM reviews WHERE rating = 5;` | 문항 10 채점 포인트("별점 5점 리뷰는 world 전체에 160건") | 160 | ch13-16 |
| `SELECT count(*) FROM reviews WHERE rating = 5 AND order_id IS NULL;` | 문항 10 채점 포인트("그중 68건이 구매 인증이 없습니다") | 68 | ch13-16 |
| `SELECT count(*) FROM reviews WHERE rating = 1;` | 문항 12 해설("별점 1점(23건)") | 23 | ch13-16 |
| `SELECT count(*) FROM reviews WHERE rating = 2;` | 문항 12 해설("2점(54건)") | 54 | ch13-16 |
| `SELECT count(*) FROM orders WHERE status = '배송완료';` | 문항 11 해설("배송완료 주문은 world 전체에 399건") | 399 | ch13-16 |
| `SELECT price, stock FROM books WHERE book_id = 97;` | 문항 14 (가) 지문(단가 16,000원)·해설("60권에서 59권") | 16000 / 60 | ch13-16 |
| `SELECT price, stock FROM books WHERE book_id = 108;` | 문항 14 (가) 지문(단가 12,000원)·해설("60권에서 58권") | 12000 / 60 | ch13-16 |
| `SELECT max(customer_id) FROM customers;` | 문항 14 (가) 채점 포인트(새 손님에게 매겨질 고객번호 151 = 150 + 1) | 150 | ch13-16 |
| `SELECT max(order_id) FROM orders;` | 문항 14 (가) 해설("초기 상태의 가장 큰 주문번호가 620") | 620 | ch13-16 |
| `SELECT count(*) FROM customers WHERE email = 'siyun.nam@bookmail.kr';` | 문항 14 (가) 지문(새 손님이므로 아직 없다는 전제) | 0 | ch13-16 |
| `SELECT title FROM books WHERE book_id = 97;` | 문항 14 (가) 지문(「우리가 몰랐던 도보 여행 안내서」) | 우리가 몰랐던 도보 여행 안내서 | ch13-17 |
| `SELECT title FROM books WHERE book_id = 108;` | 문항 14 (가) 지문(「우리가 몰랐던 커피 연습」) | 우리가 몰랐던 커피 연습 | ch13-17 |

### ch13에서 주장 케이스에서 뺀 수치

- **출력 블록 안에서 학습자가 직접 셀 수 있는 수치는 넣지 않았다** (D-033).
  문항 6 해설의 "주문수가 0인 네 줄"과 "여덟 줄만 남습니다"(12 − 4), 문항 10
  해설의 "주문일 자리가 빈 세 줄"과 "일곱 줄만 남습니다"(10 − 3), 문항 11
  해설의 "다섯 곳만 남았습니다"·"나머지 다섯 곳"(10 − 5), 각 문항의 결과 행
  수(6·6·17·11·10·5·3·11·2)가 그렇다. 모두 해당 출력 블록에 그대로 찍혀 있거나
  세면 나온다.
- **이미 바이트로 고정된 값들의 산술은 새 주장이 아니다** (D-032). 문항 12
  해설의 443·283·77(`ch13-11`의 112·171·160과 78·109·96, `ch13-10`의 520·331),
  문항 14 (가) 해설의 621(`ch13-14`의 기대 출력에 찍힌다)과 채점 포인트의
  151(`ch13-16`의 150 + 1), 문항 14 (나) 해설의 189(`ch13-15`의 520 − 331)가
  그렇다.
- 「시작하기 전에」와 문항 1 해설이 말하는 다섯 테이블의 행 수(320·150·1243·
  620·520)는 `ch13-01`의 기대 출력이 그대로 담는다.

### ch13의 의도된 반례 (D-025)

- **없다.** exit assessment는 새 구문도 새 서식 규칙도 도입하지 않으므로
  (`style.md`에 더한 규칙이 없다) 규칙 선언 이전의 위반 코드가 있을 자리가 없다.
  본문의 모든 질의는 1~12장이 세운 R1~R52를 그대로 지킨다. 문항 13 (나)의
  지문에 실린 **오류 나는 질의**는 서식 반례가 아니다 — 서식은 그대로 지키고
  **내용**(집계 함수를 `WHERE`에 쓴 것)이 오류의 대상이다. 11·12장의 오류 기대
  케이스와 같은 처리다.

### ch13에서 의도적으로 출력이 같은 케이스 쌍 (D-022)

| 쌍 | 뒷받침하는 본문 주장 |
|---|---|
| ch13-03 = ch13-04 | 문항 7 — 같은 여섯 권을 (가)는 `IN`으로, (나)는 `UNION`으로 구한다. 본문 (나) 해설이 "(가)의 표와 글자 하나 다르지 않습니다"라고 적는 자리이며, 그 등가가 곧 이 문항이 요구하는 확인이다. 입력이 다르므로 별개 케이스로 유지한다 (D-022) |
