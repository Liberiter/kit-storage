-- seed_ops.sql — 운영 테이블의 데이터를 **적재 시점에 결정적으로 생성**한다.
-- seed_ref.sql·seed.sql 다음에 적재한다 (books·orders·staff 가 있어야 한다).
--
-- 왜 데이터를 파일에 적어 두지 않고 만드는가: page_views 는 약 20만 행(문장으로 쓰면 수십 MB)이다.
-- 대신 행마다 결정적인 난수를 계산해 만든다 — 실행할 때마다 같은 데이터가 나온다.
--
-- 결정성의 근거: 난수는 random() 이 아니라 **해시 함수**(hashint8extended)로 만든다.
--   u(k, salt) = hashint8extended(k, salt) 의 하위 31비트 / 2^31  ∈ [0, 1)
-- 같은 (k, salt) 에는 언제나 같은 값이 나오고, 실행 계획·병렬 실행·평가 순서에 영향을
-- 받지 않는다. hashint8extended 는 해시 파티션 배치에 쓰이는 함수라 PostgreSQL 메이저가
-- 바뀌어도 값이 유지된다. 정규 분포가 필요한 자리는 두 균등 난수로 Box-Muller 변환을 쓴다.
-- 그래서 두 번 구축하면 바이트 단위로 같은 데이터가 나온다 (검증은 HARNESS.md).
--
-- 보조 함수는 pg_temp 스키마에 만들어 세션이 끝나면 사라진다 — world 에 남지 않는다.

SET client_min_messages = warning;

CREATE FUNCTION pg_temp.u(k bigint, salt integer) RETURNS double precision
LANGUAGE sql IMMUTABLE AS $$
  SELECT (hashint8extended(k, salt) & 2147483647)::double precision / 2147483648.0
$$;

-- 표준 정규 난수 (Box-Muller). 1 - u 로 ln(0) 을 피한다.
CREATE FUNCTION pg_temp.z(k bigint, salt integer) RETURNS double precision
LANGUAGE sql IMMUTABLE AS $$
  SELECT sqrt(-2 * ln(1 - pg_temp.u(k, salt))) * cos(2 * pi() * pg_temp.u(k, salt + 1000))
$$;

BEGIN;

-- ---------- book_meta: ISBN·태그 배열 (320행) ----------
INSERT INTO book_meta (book_id, isbn13, tags)
SELECT b.book_id,
       format('979-11-%s-%s-%s',
              lpad(((b.book_id * 7919) % 100000)::text, 5, '0'),
              lpad(((b.book_id * 104729) % 1000)::text, 3, '0'),
              (b.book_id * 31) % 10),
       -- 분류별 후보 6개 가운데 첫 태그는 항상, 나머지는 각각 확률 0.4로 고른다
       (SELECT array_agg(t ORDER BY ord)
          FROM unnest(pool.tags) WITH ORDINALITY AS x(t, ord)
         WHERE ord = 1 OR pg_temp.u(b.book_id * 10 + ord, 11) < 0.4)
  FROM books b
  JOIN (VALUES
         ('소설',     ARRAY['한국소설', '장편', '베스트셀러', '영화화', '청소년추천', '스테디셀러']),
         ('에세이',   ARRAY['에세이', '위로', '일상', '그림에세이', '베스트셀러', '선물추천']),
         ('과학',     ARRAY['교양과학', '우주', '생명', '수학', '청소년추천', '스테디셀러']),
         ('역사',     ARRAY['한국사', '세계사', '교양', '인물', '청소년추천', '베스트셀러']),
         ('자기계발', ARRAY['자기계발', '습관', '일잘러', '소통', '베스트셀러', '오디오북']),
         ('요리',     ARRAY['요리', '홈쿡', '베이킹', '비건', '선물추천', '사진많음']),
         ('여행',     ARRAY['여행', '국내여행', '해외여행', '도보', '사진많음', '에세이']),
         ('어린이',   ARRAY['어린이', '그림책', '초등', '학습', '선물추천', '스테디셀러'])
       ) AS pool(category, tags) ON pool.category = b.category
 ORDER BY b.book_id;

-- ---------- stock_movements: 주문 데이터에서 유도 (난수 없음) ----------
-- 출고: 발송된 주문(배송중·배송완료)의 항목마다 발송일에 −수량.
-- 입고: 책마다 2024-01-02 에 「재고 + 2025-06-02 이전 출고 합」, 2025-06-02 에 「그 이후 출고 합」.
--       그래서 누적 합은 음수가 되지 않고, 마지막 잔량은 books.stock 과 같다.
-- 담당 직원은 물류팀(3·10·11·12·13·23) 가운데 결정적으로 돌려 배정한다.
WITH outbound AS (
  SELECT oi.book_id, oi.order_id, oi.quantity,
         (o.shipped_date::timestamp + time '10:00' + ((o.order_id * 7) % 480) * interval '1 minute')
           AT TIME ZONE 'Asia/Seoul' AS moved_at,
         o.shipped_date
    FROM order_items oi JOIN orders o USING (order_id)
   WHERE o.shipped_date IS NOT NULL
),
inbound AS (
  SELECT b.book_id,
         timestamptz '2024-01-02 09:00+09' AS moved_at,
         b.stock + coalesce((SELECT sum(quantity) FROM outbound x
                              WHERE x.book_id = b.book_id AND x.shipped_date < '2025-06-02'), 0) AS quantity
    FROM books b
  UNION ALL
  SELECT b.book_id,
         timestamptz '2025-06-02 09:00+09',
         (SELECT sum(quantity) FROM outbound x
           WHERE x.book_id = b.book_id AND x.shipped_date >= '2025-06-02')
    FROM books b
   WHERE EXISTS (SELECT 1 FROM outbound x
                  WHERE x.book_id = b.book_id AND x.shipped_date >= '2025-06-02')
),
all_moves AS (
  SELECT book_id, moved_at, quantity, '입고' AS reason, NULL::integer AS order_id FROM inbound WHERE quantity > 0
  UNION ALL
  SELECT book_id, moved_at, -quantity, '출고', order_id FROM outbound
)
INSERT INTO stock_movements (book_id, moved_at, quantity, reason, order_id, staff_id)
SELECT book_id, moved_at, quantity, reason, order_id,
       (ARRAY[3, 10, 11, 12, 13, 23])[1 + (book_id + coalesce(order_id, 0)) % 6]
  FROM all_moves
 ORDER BY moved_at, book_id, order_id;

-- ---------- book_supply: 책 약 200권의 공급 현황 ----------
INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
SELECT b.book_id,
       greatest(100, round(b.price * 0.6 / 100) * 100)::integer,
       floor(pg_temp.u(b.book_id, 21) * 200)::integer,
       timestamptz '2026-08-01 09:00+09' + floor(pg_temp.u(b.book_id, 22) * 20) * interval '1 day'
  FROM books b
 WHERE pg_temp.u(b.book_id, 20) < 0.62
 ORDER BY b.book_id;

-- ---------- supplier_feed: 피드 두 차례 + 오류 행 ----------
-- 첫 피드(2026-08-25): 약 40권. 두 번째 피드(2026-09-01): 첫 피드의 절반쯤이 다시 오고(같은 책,
-- 다른 날짜) 새 책 약 20권이 더해진다. 끝에 오류 행 셋 — 첫 피드 행의 완전 중복, 없는 책 번호, 음수 가격.
WITH day1 AS (
  SELECT b.book_id FROM books b WHERE pg_temp.u(b.book_id, 30) < 0.125
),
day2 AS (
  SELECT book_id FROM day1 WHERE pg_temp.u(book_id, 31) < 0.5
  UNION
  SELECT b.book_id FROM books b
   WHERE pg_temp.u(b.book_id, 32) < 0.07 AND b.book_id NOT IN (SELECT book_id FROM day1)
),
rows_ AS (
  SELECT 1 AS feed_no, date '2026-08-25' AS feed_date, book_id FROM day1
  UNION ALL
  SELECT 2, date '2026-09-01', book_id FROM day2
)
INSERT INTO supplier_feed (feed_date, book_id, supplier_price, supplier_stock, received_at)
SELECT r.feed_date, r.book_id,
       greatest(100, round(b.price * (0.55 + pg_temp.u(r.book_id * 10 + r.feed_no, 33) * 0.1) / 100) * 100)::integer,
       floor(pg_temp.u(r.book_id * 10 + r.feed_no, 34) * 150)::integer,
       (r.feed_date::timestamp + time '06:30') AT TIME ZONE 'UTC' + r.book_id * interval '1 second'
  FROM rows_ r JOIN books b USING (book_id)
 ORDER BY r.feed_no, r.book_id;

-- 오류 행: (1) 첫 피드의 첫 행과 완전히 같은 행 (2) 없는 책 번호 (3) 음수 가격
INSERT INTO supplier_feed (feed_date, book_id, supplier_price, supplier_stock, received_at)
SELECT feed_date, book_id, supplier_price, supplier_stock, received_at
  FROM supplier_feed WHERE feed_date = '2026-08-25' ORDER BY feed_id LIMIT 1;
INSERT INTO supplier_feed (feed_date, book_id, supplier_price, supplier_stock, received_at) VALUES
  ('2026-09-01', 9999, 12000, 30, timestamptz '2026-09-01 06:30:00+00'),
  ('2026-09-01', (SELECT min(book_id) FROM supplier_feed WHERE feed_date = '2026-09-01'),
                 -1500, 12, timestamptz '2026-09-01 06:31:00+00');

-- ---------- page_views: 2026-06-01 ~ 2026-08-31, 약 20만 행 ----------
-- 하루 조회 수 = 1600 + 6×(경과일) + (주말이면 500) + 난수(0~299). 책 인기는 거듭제곱(1.5)으로
-- 치우치고 37배 순환(+11)으로 번호 전체에 흩뿌린다. 시각은 하루 안에서 정오 중심(삼각형
-- 세 균등 난수 평균). dwell_ms 는 로그 정규(중앙값 약 1.5초), scroll_pct 는 dwell 에 따른다.
INSERT INTO page_views (viewed_at, book_id, customer_id, client_tz, context)
SELECT timestamptz '2026-06-01 00:00+09' + d * interval '1 day'
         + floor((pg_temp.u(k, 6) + pg_temp.u(k, 7) + pg_temp.u(k, 8)) / 3 * 86400) * interval '1 second',
       1 + ((floor(power(pg_temp.u(k, 2), 1.5) * 320)::integer * 37 + 11) % 320),
       CASE WHEN pg_temp.u(k, 3) < 0.6 THEN NULL
            ELSE 1 + ((floor(power(pg_temp.u(k, 4), 1.5) * 150)::integer * 7) % 150) END,
       CASE WHEN pg_temp.u(k, 5) < 0.85 THEN 'Asia/Seoul'
            WHEN pg_temp.u(k, 5) < 0.90 THEN 'America/Los_Angeles'
            WHEN pg_temp.u(k, 5) < 0.94 THEN 'Europe/London'
            WHEN pg_temp.u(k, 5) < 0.97 THEN 'Asia/Tokyo'
            ELSE 'Australia/Sydney' END,
       jsonb_build_object(
         'device',   CASE WHEN pg_temp.u(k, 9) < 0.58 THEN 'mobile'
                          WHEN pg_temp.u(k, 9) < 0.93 THEN 'desktop' ELSE 'tablet' END,
         'referrer', ref,
         'dwell_ms', dwell,
         'scroll_pct', least(100, greatest(0, round(dwell / 60.0 + 12 * pg_temp.z(k, 13))))::integer)
       || CASE WHEN ref = 'ad'
               THEN jsonb_build_object('utm', (ARRAY['summer-sale', 'back-to-school', 'newsletter-0826'])[1 + floor(pg_temp.u(k, 15) * 3)::integer])
               ELSE '{}'::jsonb END
  FROM generate_series(0, 91) AS d
 CROSS JOIN LATERAL generate_series(1,
         1600 + d * 6
         + CASE WHEN extract(dow FROM date '2026-06-01' + d) IN (0, 6) THEN 500 ELSE 0 END
         + floor(pg_temp.u(d, 1) * 300)::integer) AS n
 CROSS JOIN LATERAL (SELECT d::bigint * 10000 + n) AS key(k)
 CROSS JOIN LATERAL (SELECT CASE WHEN pg_temp.u(k, 10) < 0.45 THEN 'search'
                                 WHEN pg_temp.u(k, 10) < 0.70 THEN 'direct'
                                 WHEN pg_temp.u(k, 10) < 0.85 THEN 'sns'
                                 WHEN pg_temp.u(k, 10) < 0.95 THEN 'ad' ELSE 'email' END,
                            greatest(200, round(exp(7.3 + 0.8 * pg_temp.z(k, 11))))::integer) AS attrs(ref, dwell)
 ORDER BY d, n;

COMMIT;

DROP FUNCTION pg_temp.z(bigint, integer);
DROP FUNCTION pg_temp.u(bigint, integer);
