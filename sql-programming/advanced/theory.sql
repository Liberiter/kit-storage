-- theory.sql — 설계 이론(함수 종속·정규형)을 따져 볼 표 세 개. 스키마 theory 에 따로 둔다.
-- seed_scale.sql 다음에 적재한다 (accounts·orders·order_items·books 에서 값을 가져온다).
--
-- 세 표 모두 일부러 한 테이블에 여러 사실을 함께 적었다. 그래서 같은 사실이 여러 줄에 되풀이되고,
-- 한 줄만 고치면 줄끼리 어긋나는 일(갱신 이상)을 실제로 만들어 볼 수 있다. 데이터는 처음에는
-- 서로 어긋나지 않는다 — 어긋나게 만드는 것은 실습이다.
--
--   theory.order_book_lines  주문 줄마다 주문 날짜·고객 이름·책 제목을 함께 적은 표 (기본키 두 열)
--   theory.talk_signups      저자 강연 신청 원장 — 강연·장소·회원을 한 줄에 (행을 가려내는 열 조합이 여럿)
--   theory.club_mentors      독서 모임의 회원·장르·멘토 배정 (멘토마다 맡는 장르가 하나)
--
-- 모든 열이 값이 여러 가지다 — 모든 행이 같은 값을 갖는 열은 두지 않았다.

SET client_min_messages = warning;
CREATE SCHEMA theory;

CREATE TABLE theory.order_book_lines (
    order_id      integer NOT NULL,
    book_id       integer NOT NULL,
    order_date    date    NOT NULL,
    customer_name text    NOT NULL,
    book_title    text    NOT NULL,
    quantity      integer NOT NULL,
    PRIMARY KEY (order_id, book_id)
);

INSERT INTO theory.order_book_lines
SELECT oi.order_id, oi.book_id, o.order_date, c.name, b.title, oi.quantity
  FROM order_items oi
  JOIN orders o    USING (order_id)
  JOIN customers c USING (customer_id)
  JOIN books b     USING (book_id)
 ORDER BY oi.order_id, oi.book_id;

CREATE TABLE theory.talk_signups (
    talk_id       integer NOT NULL,
    talk_title    text    NOT NULL,
    talk_date     date    NOT NULL,
    fee           integer NOT NULL,
    venue         text    NOT NULL,
    venue_address text    NOT NULL,
    account_id    integer NOT NULL,
    account_name  text    NOT NULL,
    account_email text    NOT NULL,
    seat_no       integer NOT NULL,
    PRIMARY KEY (talk_id, account_id)
);

-- 강연 여덟 번, 장소 네 곳. 한 장소에서 강연이 여러 번 열리고, 한 회원이 여러 강연을 신청한다.
WITH talks (talk_id, talk_title, talk_date, fee, venue) AS (VALUES
    (1, '소설은 어디서 오는가',     date '2026-03-07', 15000, '강남 북라운지'),
    (2, '여행기를 쓰는 법',         date '2026-03-21', 12000, '홍대 작은극장'),
    (3, '과학책 읽기 모임 특강',    date '2026-04-04', 10000, '강남 북라운지'),
    (4, '어린이책의 그림',          date '2026-04-18',  8000, '해운대 문화홀'),
    (5, '요리책 한 권 만들기',      date '2026-05-02', 20000, '홍대 작은극장'),
    (6, '역사 속 책방들',           date '2026-05-16', 12000, '수원 시민서재'),
    (7, '에세이, 나를 쓰는 연습',   date '2026-05-30', 15000, '강남 북라운지'),
    (8, '자기계발서를 의심하기',    date '2026-06-13', 10000, '해운대 문화홀')),
venues (venue, venue_address) AS (VALUES
    ('강남 북라운지', '서울 강남구 테헤란로 101'),
    ('홍대 작은극장', '서울 마포구 와우산로 21'),
    ('해운대 문화홀', '부산 해운대구 해운대로 570'),
    ('수원 시민서재', '수원 팔달구 정조로 825')),
signups AS (
    -- 강연마다 5~9명. 회원은 먼저 가입한 회원 60명 가운데서 해시로 고른다 (한 회원이 여러 강연에 나온다).
    SELECT t.talk_id, k.seat_no,
           (SELECT a.account_id FROM accounts a
             WHERE a.account_id <= 60
             ORDER BY hashint8extended(a.account_id * 10 + t.talk_id, 81), a.account_id
             OFFSET k.seat_no - 1 LIMIT 1) AS account_id
      FROM talks t
      CROSS JOIN LATERAL generate_series(1, 5 + (t.talk_id * 3) % 5) AS k(seat_no))
INSERT INTO theory.talk_signups
SELECT t.talk_id, t.talk_title, t.talk_date, t.fee, t.venue, v.venue_address,
       a.account_id, a.name, a.email, s.seat_no
  FROM signups s
  JOIN talks t    USING (talk_id)
  JOIN venues v   USING (venue)
  JOIN accounts a USING (account_id)
 ORDER BY s.talk_id, s.seat_no;

CREATE TABLE theory.club_mentors (
    account_id integer NOT NULL,
    genre      text    NOT NULL,
    mentor     text    NOT NULL,
    PRIMARY KEY (account_id, genre)
);

-- 멘토 여섯 명이 장르 셋을 둘씩 맡는다 (멘토 → 장르). 회원은 장르마다 멘토 한 명에게 배정된다.
WITH mentors (mentor, genre) AS (VALUES
    ('한서진', '소설'), ('문지호', '소설'),
    ('백하늘', '과학'), ('남궁별', '과학'),
    ('차유나', '역사'), ('편도윤', '역사'))
INSERT INTO theory.club_mentors
SELECT a.account_id, g.genre,
       (SELECT m.mentor FROM mentors m WHERE m.genre = g.genre
         ORDER BY hashint8extended(a.account_id * 7 + g.gi, 82), m.mentor LIMIT 1)
  FROM accounts a
  CROSS JOIN (VALUES (1, '소설'), (2, '과학'), (3, '역사')) AS g(gi, genre)
 WHERE a.account_id BETWEEN 1 AND 12
   AND (hashint8extended(a.account_id * 13 + g.gi, 83) & 3) <> 0
 ORDER BY a.account_id, g.genre;
