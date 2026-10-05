-- seed_scale.sql — scale_schema.sql 의 테이블에 데이터를 **적재 시점에 결정적으로 생성**한다.
-- schema.sql·seed_ref.sql·seed.sql·seed_ops.sql 다음에 적재한다 (books·customers·staff 가 있어야 한다).
--
-- 난수는 random() 이 아니라 해시 함수로 만든다 — seed_ops.sql 과 같은 방법이다.
--   u(k, salt) = hashint8extended(k, salt) 의 하위 31비트 / 2^31  ∈ [0, 1)
-- 같은 (k, salt) 에는 언제나 같은 값이 나오고 실행 계획·병렬 실행·평가 순서와 무관하다. 그래서
-- 누가 언제 구축해도 같은 데이터가 같은 차례로 들어간다 — 행이 디스크의 어느 페이지 몇 번째 자리에
-- 놓이는지까지 같다. 보조 함수는 pg_temp 에 만들어 세션이 끝나면 사라진다.
--
-- 분포 (이 코스의 장들이 기대는 성질):
--   sales.book_id      소수의 책에 판매가 몰린다 (가장 많이 팔린 책이 약 10%)
--   sales.account_id    오래된 회원일수록 많이 산다. 한 번도 사지 않은 회원도 있다
--   sales.status       completed 가 거의 전부이고 disputed 는 0.12% 안팎
--   sales.store_id     온라인몰(1번)이 약 72% — 온라인이면 channel 은 web·app, 매장이면 store
--   accounts.city·district  district 가 정해지면 city 가 정해진다 (두 열이 서로 독립이 아니다)
--   sales.sale_id·sold_at  둘 다 적재 차례와 같은 차례다 — 물리 차례와의 상관이 1에 가깝다
--   shipments_random   shipments_sorted 와 행은 같고 적재 차례만 해시로 섞었다

SET client_min_messages = warning;
SET default_toast_compression = 'pglz';   -- 큰 값의 압축 방식을 서버 설정과 무관하게 고정한다
SET timezone = 'UTC';

CREATE FUNCTION pg_temp.u(k bigint, salt integer) RETURNS double precision
LANGUAGE sql IMMUTABLE AS $$
  SELECT (hashint8extended(k, salt) & 2147483647)::double precision / 2147483648.0
$$;

CREATE FUNCTION pg_temp.z(k bigint, salt integer) RETURNS double precision
LANGUAGE sql IMMUTABLE AS $$
  SELECT sqrt(-2 * ln(1 - pg_temp.u(k, salt))) * cos(2 * pi() * pg_temp.u(k, salt + 1000))
$$;

-- 가중치가 있는 목록에서 하나 고르기: 누적 가중치 배열과 균등 난수 x 로 위치(1부터)를 찾는다.
CREATE FUNCTION pg_temp.pick(cum double precision[], x double precision) RETURNS integer
LANGUAGE sql IMMUTABLE AS $$
  SELECT coalesce(min(i), array_length(cum, 1)) FROM generate_subscripts(cum, 1) i WHERE x < cum[i]
$$;

BEGIN;

-- ---------- stores: 지점 12곳 ----------
INSERT INTO stores (store_id, name, kind, city, opened_on) VALUES
  ( 1, '책숲 온라인몰', 'online',  NULL,   '2015-03-02'),
  ( 2, '책숲 강남점',   'offline', '서울', '2016-04-01'),
  ( 3, '책숲 홍대점',   'offline', '서울', '2017-09-15'),
  ( 4, '책숲 해운대점', 'offline', '부산', '2018-05-10'),
  ( 5, '책숲 수원점',   'offline', '수원', '2019-03-22'),
  ( 6, '책숲 대전점',   'offline', '대전', '2019-11-01'),
  ( 7, '책숲 광주점',   'offline', '광주', '2020-06-05'),
  ( 8, '책숲 대구점',   'offline', '대구', '2021-02-19'),
  ( 9, '책숲 인천점',   'offline', '인천', '2021-08-30'),
  (10, '책숲 제주점',   'offline', '제주', '2022-04-08'),
  (11, '책숲 울산점',   'offline', '울산', '2023-01-13'),
  (12, '책숲 춘천점',   'offline', '춘천', '2023-07-07');

-- ---------- accounts: 회원 30만 명 ----------
-- 회원 번호는 가입 차례다: joined_at 은 2016-01-01 ~ 2026-08-31 에 번호 차례로 놓인다.
-- 앞 코스의 고객 150명은 가입일에 해당하는 자리의 회원 번호를 얻고 이름·이메일·도시를 그대로 가져온다.
CREATE TEMP TABLE name_parts (kind text, idx int, ko text, en text);
INSERT INTO name_parts
SELECT 'family', ord, ko, en FROM unnest(
  ARRAY['김','이','박','최','정','강','조','윤','장','임','한','오','서','신','권','황','안','송','류','홍'],
  ARRAY['Kim','Lee','Park','Choi','Jung','Kang','Cho','Yoon','Jang','Lim','Han','Oh','Seo','Shin','Kwon','Hwang','Ahn','Song','Ryu','Hong'])
  WITH ORDINALITY AS t(ko, en, ord)
UNION ALL
SELECT 'given', ord, ko, en FROM unnest(
  ARRAY['민준','서연','도윤','서윤','하준','지우','시우','하은','주원','지유','예준','수아','지호','채원','건우','지안',
        '우진','다은','선우','예린','현우','소율','유준','아린','연우','윤서','정우','민서','승현','하린',
        '태윤','가은','재원','수빈','준서','예은','은우','나윤','시윤','다인'],
  ARRAY['Minjun','Seoyeon','Doyun','Seoyun','Hajun','Jiwoo','Siwoo','Haeun','Juwon','Jiyu','Yejun','Sua','Jiho','Chaewon','Gunwoo','Jian',
        'Woojin','Daeun','Sunwoo','Yerin','Hyunwoo','Soyul','Yujun','Arin','Yeonwoo','Yunseo','Jungwoo','Minseo','Seunghyun','Harin',
        'Taeyun','Gaeun','Jaewon','Subin','Junseo','Yeeun','Eunwoo','Nayun','Siyun','Dain'])
  WITH ORDINALITY AS t(ko, en, ord);

-- 도시·구: 구 이름은 이 world 안에서 겹치지 않는다 (district → city).
CREATE TEMP TABLE geo (city text, city_w double precision, districts text[], district_w double precision[]);
INSERT INTO geo VALUES
  ('서울', 0.28, ARRAY['강남구','마포구','송파구','종로구','노원구'], ARRAY[0.30,0.22,0.22,0.10,0.16]),
  ('부산', 0.12, ARRAY['해운대구','부산진구','수영구'],             ARRAY[0.45,0.35,0.20]),
  ('수원', 0.11, ARRAY['영통구','팔달구','장안구'],                 ARRAY[0.50,0.25,0.25]),
  ('인천', 0.10, ARRAY['연수구','남동구','부평구'],                 ARRAY[0.40,0.30,0.30]),
  ('대구', 0.08, ARRAY['수성구','달서구'],                          ARRAY[0.55,0.45]),
  ('대전', 0.07, ARRAY['유성구','대덕구'],                          ARRAY[0.70,0.30]),
  ('광주', 0.07, ARRAY['광산구','북구'],                            ARRAY[0.60,0.40]),
  ('제주', 0.07, ARRAY['제주시','서귀포시'],                        ARRAY[0.75,0.25]),
  ('울산', 0.05, ARRAY['울주군','남구'],                            ARRAY[0.35,0.65]),
  ('춘천', 0.05, ARRAY['석사동','퇴계동'],                          ARRAY[0.50,0.50]);
CREATE TEMP TABLE geo_cum AS
SELECT city, districts,
       (SELECT array_agg(s ORDER BY i) FROM (
          SELECT i, sum(district_w[i]) OVER (ORDER BY i) AS s FROM generate_subscripts(district_w, 1) i) w) AS district_cum,
       sum(city_w) OVER (ORDER BY city_w DESC, city ROWS UNBOUNDED PRECEDING) AS cum
  FROM geo;

-- 앞 코스 고객 → 회원 번호: 가입일이 timeline 의 어디인지로 정하고, 같은 날짜끼리는 이어 붙인다.
CREATE TEMP TABLE customer_account AS
SELECT customer_id,
       floor(extract(epoch FROM (signup_date::timestamp - timestamp '2016-01-01'))
             / extract(epoch FROM (timestamp '2026-09-01' - timestamp '2016-01-01')) * 300000)::int
         + row_number() OVER (PARTITION BY signup_date ORDER BY customer_id)::int AS account_id
  FROM customers;

INSERT INTO accounts (account_id, email, name, city, district, birth_year, grade, joined_at, marketing_opt_in, customer_id)
SELECT m,
       CASE WHEN c.customer_id IS NOT NULL THEN c.email
            WHEN pg_temp.u(m, 11) < 0.25
              THEN g.en || '.' || f.en || m || '@' || (ARRAY['BookMail.kr','ReadMail.kr','SoopMail.kr'])[1 + (m % 3)]
            ELSE lower(g.en) || '.' || lower(f.en) || m || '@' || (ARRAY['bookmail.kr','readmail.kr','soopmail.kr'])[1 + (m % 3)]
       END,
       coalesce(c.name, f.ko || g.ko),
       coalesce(c.city, gc.city),
       CASE WHEN c.customer_id IS NOT NULL
            THEN (SELECT districts[1 + (c.customer_id % array_length(districts, 1))] FROM geo WHERE geo.city = c.city)
            ELSE gc.districts[pg_temp.pick(gc.district_cum, pg_temp.u(m, 13))]
       END,
       least(2008, greatest(1950, round(1986 + 11 * pg_temp.z(m, 14))))::smallint,
       CASE WHEN pg_temp.u(m, 15) < 0.010 THEN 'VIP'
            WHEN pg_temp.u(m, 15) < 0.050 THEN '골드'
            WHEN pg_temp.u(m, 15) < 0.150 THEN '실버'
            ELSE '일반' END,
       CASE WHEN c.customer_id IS NOT NULL
            THEN (c.signup_date::timestamp + interval '10 hours') AT TIME ZONE 'Asia/Seoul'
            ELSE date_trunc('second', timestamptz '2016-01-01 00:00:00+09'
                 + (m - 1) * (timestamptz '2026-09-01 00:00:00+09' - timestamptz '2016-01-01 00:00:00+09') / 300000
                 + (pg_temp.u(m, 16) * 900) * interval '1 second')
       END,
       coalesce(c.marketing_opt_in, pg_temp.u(m, 17) < 0.42),
       c.customer_id
  FROM generate_series(1, 300000) AS m
  JOIN name_parts f ON f.kind = 'family'
                   AND f.idx = 1 + floor(20 * pg_temp.u(m, 18) ^ 1.6)::int
  JOIN name_parts g ON g.kind = 'given' AND g.idx = 1 + (hashint8extended(m, 19) & 2147483647) % 40
  JOIN geo_cum gc ON gc.city = (SELECT city FROM geo_cum WHERE pg_temp.u(m, 12) < cum ORDER BY cum LIMIT 1)
  LEFT JOIN customer_account cm ON cm.account_id = m
  LEFT JOIN customers c ON c.customer_id = cm.customer_id
 ORDER BY m;

-- ---------- sales: 판매 150만 건 ----------
-- sale_id 차례 = 시각 차례 = 적재 차례. 2024-01-01 ~ 2026-08-31 (한국 시각) 에 놓되 뒤로 갈수록
-- 촘촘하다 (플랫폼이 자랐다). 한 판매의 회원은 그 시각까지 가입한 회원 가운데서 고른다.
CREATE TEMP TABLE book_rank AS
SELECT book_id, published_date,
       row_number() OVER (ORDER BY hashint8extended(book_id, 21), book_id) - 1 AS r_all
  FROM books;
CREATE TEMP TABLE old_rank AS
SELECT book_id, row_number() OVER (ORDER BY r_all) - 1 AS r_old
  FROM book_rank WHERE published_date < date '2024-01-01';
CREATE TEMP TABLE coupon_codes (yr int, codes text[]);
INSERT INTO coupon_codes VALUES
  (2024, ARRAY['WELCOME24','SPRING24','BOOKDAY24','WINTER24']),
  (2025, ARRAY['WELCOME25','SPRING25','BOOKDAY25','WINTER25']),
  (2026, ARRAY['WELCOME26','SPRING26','BOOKDAY26']);

CREATE TEMP TABLE sale_draft AS
SELECT g AS sale_id,
       date_trunc('second',
         timestamptz '2024-01-01 00:00:00+09'
         + ((((g - 1)::double precision / 1500000) ^ 0.85)
            * extract(epoch FROM (timestamptz '2026-09-01 00:00:00+09' - timestamptz '2024-01-01 00:00:00+09'))
            + pg_temp.u(g, 31) * 40) * interval '1 second') AS sold_at
  FROM generate_series(1, 1500000) AS g;

INSERT INTO sales (sale_id, sold_at, account_id, book_id, store_id, channel, quantity, unit_price,
                   status, coupon_code, receipt_no)
SELECT d.sale_id, d.sold_at,
       1 + floor(mt.joined_cnt * pg_temp.u(d.sale_id, 32) ^ 2.2)::int,
       b.book_id, st.store_id,
       CASE WHEN st.store_id <> 1 THEN 'store'
            WHEN pg_temp.u(d.sale_id, 36) < 0.58 THEN 'app' ELSE 'web' END,
       (CASE WHEN pg_temp.u(d.sale_id, 37) < 0.86 THEN 1
             WHEN pg_temp.u(d.sale_id, 37) < 0.96 THEN 2
             WHEN pg_temp.u(d.sale_id, 37) < 0.99 THEN 3
             ELSE 4 + (d.sale_id % 2) END)::smallint,
       CASE WHEN pg_temp.u(d.sale_id, 38) < 0.60 THEN round(bk.price * 0.9 / 10)::int * 10 ELSE bk.price END,
       CASE WHEN pg_temp.u(d.sale_id, 39) < 0.0012 THEN 'disputed'
            WHEN pg_temp.u(d.sale_id, 39) < 0.0110 THEN 'refunded'
            ELSE 'completed' END,
       CASE WHEN pg_temp.u(d.sale_id, 40) < 0.06
            THEN (SELECT codes[1 + floor(pg_temp.u(d.sale_id, 41) * array_length(codes, 1))::int]
                    FROM coupon_codes WHERE yr = extract(year FROM d.sold_at AT TIME ZONE 'Asia/Seoul')::int)
       END,
       'R' || to_char(d.sold_at AT TIME ZONE 'Asia/Seoul', 'YYMMDD') || '-' || lpad(d.sale_id::text, 7, '0')
  FROM sale_draft d
  CROSS JOIN LATERAL (
    SELECT greatest(1000, least(300000, floor(
             extract(epoch FROM (d.sold_at - timestamptz '2016-01-01 00:00:00+09'))
             / extract(epoch FROM (timestamptz '2026-09-01 00:00:00+09' - timestamptz '2016-01-01 00:00:00+09'))
             * 300000)::int)) AS joined_cnt) mt
  CROSS JOIN LATERAL (
    SELECT floor(320 * pg_temp.u(d.sale_id, 33) ^ 2.6)::int AS r) rr
  JOIN book_rank ba ON ba.r_all = rr.r
  JOIN old_rank bo ON bo.r_old = rr.r % (SELECT count(*) FROM old_rank)
  CROSS JOIN LATERAL (
    SELECT CASE WHEN ba.published_date <= (d.sold_at AT TIME ZONE 'Asia/Seoul')::date
                THEN ba.book_id ELSE bo.book_id END AS book_id) b
  JOIN books bk ON bk.book_id = b.book_id
  CROSS JOIN LATERAL (
    SELECT CASE WHEN pg_temp.u(d.sale_id, 34) < 0.72 THEN 1::smallint
                ELSE (2 + pg_temp.pick(ARRAY[0.20,0.33,0.43,0.53,0.62,0.70,0.78,0.85,0.91,0.96,1.0],
                                       pg_temp.u(d.sale_id, 35)) - 1)::smallint END AS store_id) st
 ORDER BY d.sale_id;

DROP TABLE sale_draft;

-- ---------- shipments: 온라인 판매(1번 지점) 가운데 짝수 번호의 배송 기록 ----------
CREATE TEMP TABLE ship_draft AS
SELECT row_number() OVER (ORDER BY shipped_at, sale_id)::int AS shipment_id, *
  FROM (
    SELECT s.sale_id,
           s.sold_at + (6 + floor(pg_temp.u(s.sale_id, 51) * 66)) * interval '1 hour'
                     + floor(pg_temp.u(s.sale_id, 52) * 3600) * interval '1 second' AS shipped_at,
           (ARRAY['한빛택배','숲길로지스','바로배송','새벽특송','우리우편'])[
             pg_temp.pick(ARRAY[0.38,0.64,0.82,0.94,1.0], pg_temp.u(s.sale_id, 53))] AS carrier,
           m.city AS region,
           (180 + floor(pg_temp.u(s.sale_id, 54) * 520))::int * s.quantity AS weight_g
      FROM sales s JOIN accounts m USING (account_id)
     WHERE s.store_id = 1 AND s.sale_id % 2 = 0) x;

INSERT INTO shipments_sorted SELECT * FROM ship_draft ORDER BY shipment_id;
INSERT INTO shipments_random SELECT * FROM ship_draft ORDER BY hashint8extended(shipment_id, 55), shipment_id;
DROP TABLE ship_draft;

-- ---------- book_contents: 책마다 소개·발췌·목차 ----------
-- 발췌(excerpt)의 길이를 책마다 크게 갈랐다. 문장을 되풀이해 만든 발췌는 압축이 잘 되고,
-- 해시 문자열을 이어 만든 발췌(스캔 원문 표시 — 책 번호가 7로 나누어떨어지는 책)는 거의 압축되지 않는다.
INSERT INTO book_contents (book_id, summary, excerpt, toc)
SELECT b.book_id,
       b.title || ' — ' || b.author || '의 ' || b.category || ' 책. '
         || repeat('책숲 편집부가 고른 이 달의 책입니다. ', 1 + (b.book_id % 6)),
       CASE WHEN b.book_id % 7 = 0
            THEN (SELECT string_agg(md5(b.book_id || ':' || i), '' ORDER BY i)
                    FROM generate_series(1, 40 + floor(pg_temp.u(b.book_id, 61) * 260)::int) i)
            ELSE repeat('「' || b.title || '」의 한 장면입니다. 이야기는 천천히 흐르고, 독자는 그 흐름을 따라 걷습니다. ',
                        2 + floor(pg_temp.u(b.book_id, 62) ^ 3 * 400)::int)
       END,
       (SELECT jsonb_build_object('title', b.title,
                                  'chapters', jsonb_agg(jsonb_build_object('no', i, 'title', i || '장 — ' || b.category || ' 이야기 ' || i,
                                                                           'pages', 8 + (hashint8extended(b.book_id * 100 + i, 63) & 15)) ORDER BY i))
          FROM generate_series(1, 3 + floor(pg_temp.u(b.book_id, 64) ^ 2 * 120)::int) i)
  FROM books b
 ORDER BY b.book_id;

-- ---------- discussion_posts: 독서 토론 게시판 ----------
-- 글타래 2,000개에 글 3만 개. 큰 글타래일수록 댓글이 바로 앞 글에 이어 달려 깊어진다.
CREATE TEMP TABLE post_draft AS
SELECT p AS post_id,
       CASE WHEN p <= 2000 THEN p ELSE 1 + floor(2000 * pg_temp.u(p, 71) ^ 2.4)::int END AS thread_id
  FROM generate_series(1, 30000) AS p;
CREATE TEMP TABLE post_ranked AS
SELECT post_id, thread_id,
       row_number() OVER (PARTITION BY thread_id ORDER BY post_id) AS rn,
       lag(post_id) OVER (PARTITION BY thread_id ORDER BY post_id) AS prev_id
  FROM post_draft;
CREATE INDEX ON post_ranked (thread_id, rn);
INSERT INTO discussion_posts (post_id, parent_id, book_id, account_id, posted_at, body)
SELECT r.post_id,
       CASE WHEN r.rn = 1 THEN NULL
            WHEN pg_temp.u(r.post_id, 72) < 0.55 THEN r.prev_id
            ELSE (SELECT x.post_id FROM post_ranked x
                   WHERE x.thread_id = r.thread_id
                     AND x.rn = 1 + floor(pg_temp.u(r.post_id, 73) * (r.rn - 1))::int)
       END,
       1 + (hashint8extended(r.thread_id, 74) & 2147483647) % 320,
       1 + floor(300000 * pg_temp.u(r.post_id, 75) ^ 1.5)::int,
       timestamptz '2025-01-01 09:00:00+09' + (r.post_id - 1) * interval '17 minutes'
         + floor(pg_temp.u(r.post_id, 76) * 900) * interval '1 second',
       CASE WHEN r.rn = 1 THEN '이 책 이야기를 나눠요 — 글타래 ' || r.thread_id
            ELSE (ARRAY['저도 같은 생각이에요.','그 장면이 오래 남았습니다.','반대 의견도 있어요.',
                        '다음 장이 더 좋았어요.','번역이 아쉬웠습니다.','추천해 주셔서 읽었어요.'])[1 + r.post_id % 6]
       END
  FROM post_ranked r
 ORDER BY r.post_id;
DROP TABLE post_draft;
DROP TABLE post_ranked;

-- ---------- duty_roster: 지점별 당직표 ----------
-- 1번 지점(온라인몰 고객센터)은 당직 둘 — 「적어도 한 명은 당직」 규칙을 두 세션이 함께 어기는 실습 재료.
INSERT INTO duty_roster (store_id, staff_id, on_duty) VALUES
  (1, 14, true), (1, 15, true), (1, 16, false),
  (2,  8, true), (2,  9, false),
  (3, 22, true), (3, 24, false);

COMMIT;

-- ---------- 적재 뒤: 외래키와 인덱스 ----------
ALTER TABLE accounts          ADD FOREIGN KEY (customer_id) REFERENCES customers (customer_id);
ALTER TABLE sales            ADD FOREIGN KEY (account_id)   REFERENCES accounts (account_id);
ALTER TABLE sales            ADD FOREIGN KEY (book_id)     REFERENCES books (book_id);
ALTER TABLE sales            ADD FOREIGN KEY (store_id)    REFERENCES stores (store_id);
ALTER TABLE shipments_sorted ADD FOREIGN KEY (sale_id)     REFERENCES sales (sale_id);
ALTER TABLE shipments_random ADD FOREIGN KEY (sale_id)     REFERENCES sales (sale_id);
ALTER TABLE book_contents    ADD FOREIGN KEY (book_id)     REFERENCES books (book_id);
ALTER TABLE discussion_posts ADD FOREIGN KEY (parent_id)   REFERENCES discussion_posts (post_id);
ALTER TABLE discussion_posts ADD FOREIGN KEY (book_id)     REFERENCES books (book_id);
ALTER TABLE discussion_posts ADD FOREIGN KEY (account_id)   REFERENCES accounts (account_id);
ALTER TABLE duty_roster      ADD FOREIGN KEY (store_id)    REFERENCES stores (store_id);
ALTER TABLE duty_roster      ADD FOREIGN KEY (staff_id)    REFERENCES staff (staff_id);

-- 배송 기록의 발송 시각 인덱스 — 두 테이블에 같은 정의로 둔다. 행도 정의도 같고 적재 차례만 다르다.
CREATE INDEX shipments_sorted_shipped_at_idx ON shipments_sorted (shipped_at);
CREATE INDEX shipments_random_shipped_at_idx ON shipments_random (shipped_at);

-- 통계 표본을 전체 행으로 고정한다 — ANALYZE 의 기본 표본(3만 행)은 무작위라 실행 계획의 추정
-- 행 수가 구축마다 달라진다. 테이블마다 한 열의 통계 목표를 10000 으로 올리면 표본 크기(300×10000)가
-- 전체 행 수를 넘어 ANALYZE 가 테이블을 통째로 읽는다. 다른 열의 통계 크기(가장 흔한 값 목록·
-- 히스토그램의 칸 수)는 기본값 그대로다 — 표본만 전체 행이 된다.
ALTER TABLE sales            ALTER COLUMN sale_id     SET STATISTICS 10000;
ALTER TABLE accounts          ALTER COLUMN account_id   SET STATISTICS 10000;
ALTER TABLE shipments_sorted ALTER COLUMN shipment_id SET STATISTICS 10000;
ALTER TABLE shipments_random ALTER COLUMN shipment_id SET STATISTICS 10000;
ALTER TABLE discussion_posts ALTER COLUMN post_id     SET STATISTICS 10000;
