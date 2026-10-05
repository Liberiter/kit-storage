-- world 속성 검증 — 이 코스의 챕터들이 world에 요구하는 성질을 기계적으로 확인한다.
-- 실패 시 RAISE EXCEPTION (check_env.sh 가 실행 — 입장 점검의 첫 단계).
-- W2~W16 은 앞 코스(intermediate)의 같은 번호 검사를 그대로 가져온 것이고(주석의 장 번호는 앞 코스의
-- 것이다), W1·W12 는 이 코스의 world 에 맞게 고쳤다. W17 부터는 이 코스가 더한 대규모 테이블·이론 재료·
-- 관찰 도구를 본다.
-- 이 파일은 **읽기만 한다** — 행을 넣었다가 되돌리는 검사도 두지 않는다. 되돌려도 지운 행의 흔적
-- (죽은 튜플)이 페이지에 남아, 되돌린 직후의 물리 상태(가시성 맵·페이지 내용)를 바꾸기 때문이다.

DO $$
DECLARE n bigint; m bigint; x double precision; y double precision;
BEGIN
  -- W1. 테이블: public 20개(앞 코스의 12 + 이 코스의 8), 앞 코스의 핵심 다섯 테이블의 행 수는 그대로
  SELECT count(*) INTO n FROM information_schema.tables
   WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
  IF n <> 20 THEN RAISE EXCEPTION 'W1: public 테이블 수 % (기대 20)', n; END IF;
  SELECT count(*) INTO n FROM customers;    IF n <> 150  THEN RAISE EXCEPTION 'W1: customers % (기대 150)', n; END IF;
  SELECT count(*) INTO n FROM books;        IF n <> 320  THEN RAISE EXCEPTION 'W1: books % (기대 320)', n; END IF;
  SELECT count(*) INTO n FROM orders;       IF n <> 620  THEN RAISE EXCEPTION 'W1: orders % (기대 620)', n; END IF;
  SELECT count(*) INTO n FROM order_items;  IF n <> 1243 THEN RAISE EXCEPTION 'W1: order_items % (기대 1243)', n; END IF;
  SELECT count(*) INTO n FROM reviews;      IF n <> 520  THEN RAISE EXCEPTION 'W1: reviews % (기대 520)', n; END IF;

  -- W2. 분류 트리 (3장 재귀 CTE): 최상위 하나, 깊이 3, books.category 는 모두 말단
  SELECT count(*) INTO n FROM categories WHERE parent_id IS NULL;
  IF n <> 1 THEN RAISE EXCEPTION 'W2: 최상위 분류 %개 (기대 1)', n; END IF;
  WITH RECURSIVE t AS (
    SELECT category_id, 1 AS depth FROM categories WHERE parent_id IS NULL
    UNION ALL
    SELECT c.category_id, t.depth + 1 FROM categories c JOIN t ON c.parent_id = t.category_id)
  SELECT max(depth), count(*) INTO n, m FROM t;
  IF n <> 3 THEN RAISE EXCEPTION 'W2: 분류 트리 깊이 % (기대 3)', n; END IF;
  IF m <> (SELECT count(*) FROM categories) THEN RAISE EXCEPTION 'W2: 최상위에서 닿지 않는 분류 존재'; END IF;
  SELECT count(*) INTO n FROM books b
   WHERE EXISTS (SELECT 1 FROM categories p JOIN categories c ON c.parent_id = p.category_id WHERE p.name = b.category);
  IF n <> 0 THEN RAISE EXCEPTION 'W2: 말단이 아닌 분류를 가진 책 %권', n; END IF;
  SELECT count(DISTINCT category) INTO n FROM books;
  IF n <> 8 THEN RAISE EXCEPTION 'W2: books.category 종수 % (기대 8)', n; END IF;

  -- W3. 직원 자기 참조 (2장 self join·NOT IN 함정): 대표 1, 3단 이상, manager_id NULL 이 NOT IN 을 비운다
  SELECT count(*) INTO n FROM staff WHERE manager_id IS NULL;
  IF n <> 1 THEN RAISE EXCEPTION 'W3: manager_id 가 NULL 인 직원 % (기대 1 — 대표)', n; END IF;
  WITH RECURSIVE t AS (
    SELECT staff_id, 1 AS depth FROM staff WHERE manager_id IS NULL
    UNION ALL
    SELECT s.staff_id, t.depth + 1 FROM staff s JOIN t ON s.manager_id = t.staff_id)
  SELECT max(depth), count(*) INTO n, m FROM t;
  IF n < 3 THEN RAISE EXCEPTION 'W3: 직원 계층 깊이 % (기대 3+)', n; END IF;
  IF m <> (SELECT count(*) FROM staff) THEN RAISE EXCEPTION 'W3: 대표에게 닿지 않는 직원 존재'; END IF;
  SELECT count(*) INTO n FROM staff WHERE staff_id NOT IN (SELECT manager_id FROM staff);
  IF n <> 0 THEN RAISE EXCEPTION 'W3: NOT IN 함정이 재현되지 않음 (부하 없는 직원이 %명으로 나옴 — NULL 이 있으면 0이어야 함)', n; END IF;
  SELECT count(*) INTO n FROM staff s WHERE NOT EXISTS (SELECT 1 FROM staff x WHERE x.manager_id = s.staff_id);
  IF n < 10 THEN RAISE EXCEPTION 'W3: 부하 없는 직원(NOT EXISTS) % (기대 10+)', n; END IF;

  -- W4. page_views 규모·기간 (11장 EXPLAIN, 4·5장 시계열): 15만 행 이상, 92일, 매일 1,000건 이상
  SELECT count(*) INTO n FROM page_views;
  IF n < 150000 THEN RAISE EXCEPTION 'W4: page_views % (기대 150,000+)', n; END IF;
  SELECT count(DISTINCT d), min(cnt) INTO n, m
    FROM (SELECT (viewed_at AT TIME ZONE 'Asia/Seoul')::date AS d, count(*) AS cnt FROM page_views GROUP BY 1) t;
  IF n <> 92 THEN RAISE EXCEPTION 'W4: page_views 날짜 수 % (기대 92 — 2026-06-01~08-31)', n; END IF;
  IF m < 1000 THEN RAISE EXCEPTION 'W4: 하루 최소 조회 % (기대 1,000+)', m; END IF;
  SELECT count(*) INTO n FROM pg_indexes WHERE schemaname = 'public' AND tablename = 'page_views';
  IF n <> 1 THEN RAISE EXCEPTION 'W4: page_views 인덱스 %개 (기대 1 — 기본 키만; 인덱스 만들기는 11장 실습)', n; END IF;

  -- W5. 시계열 성질 (4·5장 lag/lead·이동 평균): 일별 조회 수에 편차가 있고 주말이 평일보다 많다
  SELECT avg(c) FILTER (WHERE dow IN (0, 6)), avg(c) FILTER (WHERE dow NOT IN (0, 6)) INTO x, y
    FROM (SELECT extract(dow FROM (viewed_at AT TIME ZONE 'Asia/Seoul')::date) dow, count(*) c
            FROM page_views GROUP BY (viewed_at AT TIME ZONE 'Asia/Seoul')::date) t;
  IF x <= y THEN RAISE EXCEPTION 'W5: 주말 평균 % ≤ 평일 평균 % (주말이 많아야 함)', x, y; END IF;

  -- W6. 재고 원장 (5장 누적 합·2장 이전 이벤트·12장 재고): 합계 = books.stock, 누적 잔량 음수 없음
  SELECT count(*) INTO n FROM books b
   WHERE b.stock <> coalesce((SELECT sum(quantity) FROM stock_movements m WHERE m.book_id = b.book_id), 0);
  IF n <> 0 THEN RAISE EXCEPTION 'W6: 원장 합계가 books.stock 과 다른 책 %권', n; END IF;
  SELECT count(*) INTO n FROM (
    SELECT sum(quantity) OVER (PARTITION BY book_id ORDER BY moved_at, movement_id) AS bal FROM stock_movements) t
   WHERE bal < 0;
  IF n <> 0 THEN RAISE EXCEPTION 'W6: 누적 잔량이 음수인 시점 %건', n; END IF;
  SELECT count(*) INTO n FROM stock_movements;
  IF n < 1000 THEN RAISE EXCEPTION 'W6: stock_movements % (기대 1,000+)', n; END IF;
  SELECT count(DISTINCT reason) INTO n FROM stock_movements;
  IF n < 2 THEN RAISE EXCEPTION 'W6: 입출고 사유 종수 % (기대 2+)', n; END IF;

  -- W7. 태그 배열·ISBN (9장 배열): 전 책에 메타, 태그 1개 이상, 3개 이상인 책도 있고, 종류가 10개 이상
  SELECT count(*) INTO n FROM book_meta;
  IF n <> 320 THEN RAISE EXCEPTION 'W7: book_meta % (기대 320)', n; END IF;
  SELECT count(*) INTO n FROM book_meta WHERE cardinality(tags) >= 3;
  IF n < 30 THEN RAISE EXCEPTION 'W7: 태그 3개 이상인 책 % (기대 30+)', n; END IF;
  SELECT count(DISTINCT t) INTO n FROM book_meta, unnest(tags) t;
  IF n < 10 THEN RAISE EXCEPTION 'W7: 태그 종수 % (기대 10+)', n; END IF;

  -- W8. JSONB (9장): 모든 로그에 device·referrer·dwell_ms·scroll_pct, utm 은 광고 유입에만
  SELECT count(*) INTO n FROM page_views
   WHERE NOT (context ? 'device' AND context ? 'referrer' AND context ? 'dwell_ms' AND context ? 'scroll_pct');
  IF n <> 0 THEN RAISE EXCEPTION 'W8: 필수 키가 빠진 context %건', n; END IF;
  SELECT count(*) INTO n FROM page_views WHERE (context ? 'utm') <> (context->>'referrer' = 'ad');
  IF n <> 0 THEN RAISE EXCEPTION 'W8: utm 키와 referrer=ad 가 어긋난 행 %건', n; END IF;
  SELECT stddev((context->>'dwell_ms')::int) INTO x FROM page_views;
  IF x IS NULL OR x < 500 THEN RAISE EXCEPTION 'W8: dwell_ms 표준편차 % (분포 통계 소재로 부족)', x; END IF;

  -- W9. 시간대 (9장 timestamptz): 한국 외 시간대 방문이 5% 이상, 시간대 4종 이상
  SELECT count(*) FILTER (WHERE client_tz <> 'Asia/Seoul'), count(*) INTO n, m FROM page_views;
  IF n * 20 < m THEN RAISE EXCEPTION 'W9: 한국 외 시간대 방문 %/% (기대 5%%+)', n, m; END IF;
  SELECT count(DISTINCT client_tz) INTO n FROM page_views;
  IF n < 4 THEN RAISE EXCEPTION 'W9: 시간대 종수 % (기대 4+)', n; END IF;

  -- W10. 공급 피드·UPSERT 재료 (7장): 반복 등장 책, 완전 중복 행, 없는 책, 음수 가격, 갱신·삽입 양쪽
  SELECT count(*) INTO n FROM (SELECT book_id FROM supplier_feed GROUP BY book_id HAVING count(DISTINCT feed_date) >= 2) t;
  IF n < 10 THEN RAISE EXCEPTION 'W10: 두 날짜에 모두 등장하는 책 % (기대 10+)', n; END IF;
  SELECT count(*) INTO n FROM (SELECT 1 FROM supplier_feed GROUP BY feed_date, book_id, supplier_price, supplier_stock, received_at HAVING count(*) > 1) t;
  IF n <> 1 THEN RAISE EXCEPTION 'W10: 완전 중복 행 그룹 % (기대 1)', n; END IF;
  SELECT count(*) INTO n FROM supplier_feed f WHERE NOT EXISTS (SELECT 1 FROM books b WHERE b.book_id = f.book_id);
  IF n <> 1 THEN RAISE EXCEPTION 'W10: 없는 책 번호 행 % (기대 1)', n; END IF;
  SELECT count(*) INTO n FROM supplier_feed WHERE supplier_price <= 0;
  IF n <> 1 THEN RAISE EXCEPTION 'W10: 음수 가격 행 % (기대 1)', n; END IF;
  SELECT count(*) FILTER (WHERE s.book_id IS NOT NULL), count(*) FILTER (WHERE s.book_id IS NULL) INTO n, m
    FROM (SELECT DISTINCT book_id FROM supplier_feed) f LEFT JOIN book_supply s USING (book_id);
  IF n < 10 OR m < 10 THEN RAISE EXCEPTION 'W10: 피드 책 가운데 공급 현황에 있는 것 %/없는 것 % (기대 각 10+)', n, m; END IF;
  SELECT count(*) INTO n FROM book_supply;
  IF n NOT BETWEEN 150 AND 250 THEN RAISE EXCEPTION 'W10: book_supply % (기대 150~250)', n; END IF;

  -- W11. 조건 집계·통계 재료 (1·4장): 주문 상태 4종, 월 24개 이상, 가격·쪽수 상관 계산 가능
  SELECT count(DISTINCT status) INTO n FROM orders;
  IF n <> 4 THEN RAISE EXCEPTION 'W11: 주문 상태 종수 % (기대 4)', n; END IF;
  SELECT count(DISTINCT date_trunc('month', order_date)) INTO n FROM orders;
  IF n < 24 THEN RAISE EXCEPTION 'W11: 주문 월 수 % (기대 24+)', n; END IF;
  SELECT corr(price, page_count), stddev(price) INTO x, y FROM books;
  IF x IS NULL OR y IS NULL OR y = 0 THEN RAISE EXCEPTION 'W11: 가격·쪽수 통계 계산 불가'; END IF;

  -- W12. 제약이 걸려 있는가 (앞 코스 7장 CHECK·UNIQUE·FK) — 카탈로그로 본다 (행을 넣어 보지 않는다)
  SELECT count(*) INTO n FROM pg_constraint
   WHERE conrelid = 'book_supply'::regclass AND contype = 'c' AND pg_get_constraintdef(oid) LIKE '%supplier_price > 0%';
  IF n <> 1 THEN RAISE EXCEPTION 'W12: book_supply 의 CHECK (supplier_price > 0) 가 없다'; END IF;
  SELECT count(*) INTO n FROM pg_constraint
   WHERE conrelid = 'book_meta'::regclass AND contype = 'u';
  IF n <> 1 THEN RAISE EXCEPTION 'W12: book_meta 의 UNIQUE(isbn13) 가 없다'; END IF;
  SELECT count(*) INTO n FROM pg_constraint
   WHERE conrelid = 'page_views'::regclass AND contype = 'f';
  IF n <> 2 THEN RAISE EXCEPTION 'W12: page_views 외래키 %개 (기대 2)', n; END IF;

  -- W13. NULL 허용 외래키 (2장 NOT IN 함정·반조인): reviews.order_id, page_views.customer_id
  SELECT count(*) FILTER (WHERE order_id IS NULL), count(*) FILTER (WHERE order_id IS NOT NULL) INTO n, m FROM reviews;
  IF n < 100 OR m < 100 THEN RAISE EXCEPTION 'W13: reviews.order_id NULL %/NOT NULL % (기대 각 100+)', n, m; END IF;
  SELECT count(*) FILTER (WHERE customer_id IS NULL), count(*) INTO n, m FROM page_views;
  IF n * 10 < m * 4 OR n * 10 > m * 8 THEN RAISE EXCEPTION 'W13: page_views.customer_id NULL 비율 %/% (기대 40~80%%)', n, m; END IF;

  -- W14. 동시성 실습 재료 (앞 코스 12장 — 이 코스의 두 세션 재현 scenarios/ 도 1·2번 책의 재고를 쓴다): 재고 2 이상
  SELECT stock INTO n FROM books WHERE book_id = 1;
  IF n IS NULL OR n < 2 THEN RAISE EXCEPTION 'W14: 1번 책 재고 % (기대 2+ — 동시성 실습 대상)', n; END IF;
  SELECT stock INTO n FROM books WHERE book_id = 2;
  IF n IS NULL OR n < 2 THEN RAISE EXCEPTION 'W14: 2번 책 재고 % (기대 2+ — 동시성 실습 대상)', n; END IF;

  -- W15. 6장 비정규 원장 (스키마 legacy): 150행 이상, 전 열 text, 책 2종 이상인 줄 존재
  SELECT count(*) INTO n FROM legacy.sales_ledger;
  IF n < 150 THEN RAISE EXCEPTION 'W15: legacy.sales_ledger % (기대 150+)', n; END IF;
  SELECT count(*) INTO n FROM information_schema.columns
   WHERE table_schema = 'legacy' AND table_name = 'sales_ledger' AND data_type <> 'text';
  IF n <> 0 THEN RAISE EXCEPTION 'W15: text 가 아닌 열 %개 (원장은 전 열 text 여야 함)', n; END IF;
  SELECT count(*) INTO n FROM legacy.sales_ledger WHERE "도서2" IS NOT NULL;
  IF n < 40 THEN RAISE EXCEPTION 'W15: 책 2종 이상인 줄 % (기대 40+)', n; END IF;

  -- W16. 8장 안티패턴 조각 (스키마 antipatterns): 테이블 4개, 쉼표 목록·상태 표기 혼재·code 중복
  SELECT count(*) INTO n FROM information_schema.tables WHERE table_schema = 'antipatterns';
  IF n <> 4 THEN RAISE EXCEPTION 'W16: antipatterns 테이블 수 % (기대 4)', n; END IF;
  SELECT count(*) INTO n FROM antipatterns.products WHERE tags LIKE '%,%';
  IF n < 10 THEN RAISE EXCEPTION 'W16: 쉼표 목록 태그 행 % (기대 10+)', n; END IF;
  SELECT count(DISTINCT status) INTO n FROM antipatterns.products WHERE lower(status) = 'active' OR status = '활성';
  IF n < 3 THEN RAISE EXCEPTION 'W16: 활성 상태 표기 종수 % (기대 3+ — 표기 혼재)', n; END IF;
  SELECT count(*) INTO n FROM (SELECT code FROM antipatterns.products GROUP BY code HAVING count(*) > 1) t;
  IF n <> 1 THEN RAISE EXCEPTION 'W16: 중복 code %개 (기대 1)', n; END IF;

  -- W17. 대규모 테이블의 행 수 (생성이 결정적이므로 정확한 값으로 본다)
  SELECT count(*) INTO n FROM stores;           IF n <> 12      THEN RAISE EXCEPTION 'W17: stores % (기대 12)', n; END IF;
  SELECT count(*) INTO n FROM accounts;         IF n <> 300000  THEN RAISE EXCEPTION 'W17: accounts % (기대 300000)', n; END IF;
  SELECT count(*) INTO n FROM sales;            IF n <> 1500000 THEN RAISE EXCEPTION 'W17: sales % (기대 1500000)', n; END IF;
  SELECT count(*) INTO n FROM book_contents;    IF n <> 320     THEN RAISE EXCEPTION 'W17: book_contents % (기대 320)', n; END IF;
  SELECT count(*) INTO n FROM discussion_posts; IF n <> 30000   THEN RAISE EXCEPTION 'W17: discussion_posts % (기대 30000)', n; END IF;
  SELECT count(*) INTO n FROM duty_roster;      IF n <> 7       THEN RAISE EXCEPTION 'W17: duty_roster % (기대 7)', n; END IF;
  SELECT count(*), sum(sale_id), sum(weight_g) INTO n, m, y FROM shipments_sorted;
  IF n < 500000 THEN RAISE EXCEPTION 'W17: shipments_sorted % (기대 500000+)', n; END IF;
  IF (SELECT count(*) FROM shipments_random) <> n
     OR (SELECT sum(sale_id) FROM shipments_random) <> m
     OR (SELECT sum(weight_g) FROM shipments_random) <> y
  THEN RAISE EXCEPTION 'W17: shipments_random 의 행이 shipments_sorted 와 다르다 (적재 차례만 달라야 한다)'; END IF;

  -- W18. 편중 분포: 가장 많이 팔린 책이 8% 이상, disputed 는 있되 0.5% 미만, 온라인몰이 65~80%,
  --      온라인이면 channel 이 web·app, 매장이면 store (두 열이 서로 독립이 아니다)
  SELECT max(c) INTO n FROM (SELECT count(*) c FROM sales GROUP BY book_id) t;
  IF n * 100 < 1500000 * 8 THEN RAISE EXCEPTION 'W18: 가장 많이 팔린 책 %건 (기대 전체의 8%%+)', n; END IF;
  SELECT count(*) INTO n FROM sales WHERE status = 'disputed';
  IF n = 0 OR n * 200 >= 1500000 THEN RAISE EXCEPTION 'W18: disputed %건 (기대 1건 이상, 0.5%% 미만)', n; END IF;
  SELECT count(*) INTO n FROM sales WHERE store_id = 1;
  IF n * 100 < 1500000 * 65 OR n * 100 > 1500000 * 80 THEN RAISE EXCEPTION 'W18: 온라인몰 판매 %건 (기대 65~80%%)', n; END IF;
  SELECT count(*) INTO n FROM sales WHERE (store_id = 1) = (channel = 'store');
  IF n <> 0 THEN RAISE EXCEPTION 'W18: 지점과 channel 이 어긋난 판매 %건 (온라인=web·app, 매장=store)', n; END IF;

  -- W19. 서로 독립이 아닌 열 쌍: district 가 정해지면 city 가 정해진다, 서울이 20% 이상
  SELECT count(*) INTO n FROM (SELECT district FROM accounts GROUP BY district HAVING count(DISTINCT city) > 1) t;
  IF n <> 0 THEN RAISE EXCEPTION 'W19: 도시가 둘 이상인 구 %개 (district → city 여야 한다)', n; END IF;
  SELECT count(*) FILTER (WHERE city = '서울'), count(*) INTO n, m FROM accounts;
  IF n * 5 < m THEN RAISE EXCEPTION 'W19: 서울 회원 %/% (기대 20%%+)', n, m; END IF;
  SELECT count(*) INTO n FROM accounts a JOIN customers c USING (customer_id) WHERE a.email = c.email AND a.name = c.name;
  IF n <> 150 THEN RAISE EXCEPTION 'W19: 앞 코스 고객과 이름·이메일이 같은 회원 % (기대 150)', n; END IF;
  SELECT count(*) INTO n FROM accounts a WHERE NOT EXISTS (SELECT 1 FROM sales s WHERE s.account_id = a.account_id);
  IF n < 10000 THEN RAISE EXCEPTION 'W19: 판매가 없는 회원 % (기대 10000+)', n; END IF;
  SELECT count(*) INTO n FROM accounts WHERE email <> lower(email);
  IF n < 10000 THEN RAISE EXCEPTION 'W19: 대문자가 섞인 이메일 % (기대 10000+ — 식 인덱스 재료)', n; END IF;

  -- W20. 물리 차례와의 상관 (통계): sales.sold_at·shipments_sorted.shipped_at 은 1에 가깝고 shipments_random 은 0에 가깝다
  SELECT correlation INTO x FROM pg_stats WHERE schemaname = 'public' AND tablename = 'sales' AND attname = 'sold_at';
  IF x IS NULL OR x < 0.99 THEN RAISE EXCEPTION 'W20: sales.sold_at 상관 % (기대 0.99+ — 통계가 없으면 NULL)', x; END IF;
  SELECT correlation INTO x FROM pg_stats WHERE schemaname = 'public' AND tablename = 'shipments_sorted' AND attname = 'shipped_at';
  IF x IS NULL OR x < 0.99 THEN RAISE EXCEPTION 'W20: shipments_sorted.shipped_at 상관 % (기대 0.99+)', x; END IF;
  SELECT correlation INTO x FROM pg_stats WHERE schemaname = 'public' AND tablename = 'shipments_random' AND attname = 'shipped_at';
  IF x IS NULL OR abs(x) > 0.05 THEN RAISE EXCEPTION 'W20: shipments_random.shipped_at 상관 % (기대 |x| ≤ 0.05)', x; END IF;

  -- W21. 큰 값(TOAST): 압축되어 저장된 발췌가 있고, 압축되지 않은 2KB 넘는 발췌도 있다
  SELECT count(*) INTO n FROM book_contents WHERE pg_column_compression(excerpt) IS NOT NULL;
  IF n < 50 THEN RAISE EXCEPTION 'W21: 압축 저장된 발췌 % (기대 50+)', n; END IF;
  SELECT count(*) INTO n FROM book_contents WHERE pg_column_compression(excerpt) IS NULL AND octet_length(excerpt) > 2048;
  IF n < 10 THEN RAISE EXCEPTION 'W21: 압축되지 않은 2KB 초과 발췌 % (기대 10+)', n; END IF;
  SELECT count(*) INTO n FROM book_contents WHERE octet_length(excerpt) < 1000;
  IF n < 20 THEN RAISE EXCEPTION 'W21: 1KB 미만 발췌 % (기대 20+ — 행 크기가 다양해야 한다)', n; END IF;

  -- W22. 깊은 계층: 토론 글의 깊이가 30 이상, 모든 글이 글타래의 첫 글에서 닿는다
  WITH RECURSIVE t AS (
    SELECT post_id, 1 AS depth FROM discussion_posts WHERE parent_id IS NULL
    UNION ALL
    SELECT p.post_id, t.depth + 1 FROM discussion_posts p JOIN t ON p.parent_id = t.post_id)
  SELECT max(depth), count(*) INTO n, m FROM t;
  IF n < 30 THEN RAISE EXCEPTION 'W22: 토론 글 깊이 % (기대 30+)', n; END IF;
  IF m <> 30000 THEN RAISE EXCEPTION 'W22: 첫 글에서 닿는 글 % (기대 30000)', m; END IF;

  -- W23. 관찰 도구 확장
  SELECT count(*) INTO n FROM pg_extension
   WHERE extname IN ('pg_stat_statements', 'pageinspect', 'pg_buffercache', 'pgstattuple', 'pg_visibility');
  IF n <> 5 THEN RAISE EXCEPTION 'W23: 관찰 도구 확장 %개 (기대 5 — pg_stat_statements·pageinspect·pg_buffercache·pgstattuple·pg_visibility)', n; END IF;

  -- W24. 처음 상태의 인덱스 — 인덱스를 언제 만들지가 실습 거리라 처음에는 정해진 것만 있다
  SELECT count(*) INTO n FROM pg_indexes WHERE schemaname = 'public' AND tablename = 'sales';
  IF n <> 1 THEN RAISE EXCEPTION 'W24: sales 인덱스 %개 (기대 1 — 기본 키만)', n; END IF;
  SELECT count(*) INTO n FROM pg_indexes WHERE schemaname = 'public' AND tablename = 'accounts';
  IF n <> 3 THEN RAISE EXCEPTION 'W24: accounts 인덱스 %개 (기대 3 — 기본 키·email·customer_id)', n; END IF;
  SELECT count(*) INTO n FROM pg_indexes WHERE schemaname = 'public' AND tablename IN ('shipments_sorted', 'shipments_random');
  IF n <> 4 THEN RAISE EXCEPTION 'W24: shipments 두 테이블의 인덱스 %개 (기대 4 — 기본 키와 shipped_at 각각)', n; END IF;
  SELECT count(*) INTO n FROM pg_indexes WHERE schemaname = 'public' AND tablename = 'discussion_posts';
  IF n <> 1 THEN RAISE EXCEPTION 'W24: discussion_posts 인덱스 %개 (기대 1 — 기본 키만)', n; END IF;

  -- W25. 설계 이론 재료 (스키마 theory): 표 셋, 처음에는 되풀이된 사실이 서로 어긋나지 않는다
  SELECT count(*) INTO n FROM information_schema.tables WHERE table_schema = 'theory';
  IF n <> 3 THEN RAISE EXCEPTION 'W25: theory 테이블 수 % (기대 3)', n; END IF;
  SELECT count(*) INTO n FROM (SELECT venue FROM theory.talk_signups GROUP BY venue HAVING count(DISTINCT venue_address) > 1) t;
  IF n <> 0 THEN RAISE EXCEPTION 'W25: 주소가 둘 이상인 장소 %곳 (처음 상태는 어긋남이 없어야 한다)', n; END IF;
  SELECT count(*) INTO n FROM (SELECT venue FROM theory.talk_signups GROUP BY venue HAVING count(DISTINCT talk_id) >= 2) t;
  IF n < 2 THEN RAISE EXCEPTION 'W25: 강연이 두 번 이상 열린 장소 %곳 (기대 2+ — 같은 주소가 되풀이되어야 한다)', n; END IF;
  SELECT count(*) INTO n FROM (SELECT mentor FROM theory.club_mentors GROUP BY mentor HAVING count(DISTINCT genre) > 1) t;
  IF n <> 0 THEN RAISE EXCEPTION 'W25: 장르가 둘 이상인 멘토 %명 (멘토 → 장르여야 한다)', n; END IF;
  SELECT count(*) INTO n FROM theory.order_book_lines;
  IF n <> 1243 THEN RAISE EXCEPTION 'W25: theory.order_book_lines % (기대 1243 — 주문 줄과 같다)', n; END IF;

  -- W26. 두 세션 실습 재료: 1번 지점의 당직이 정확히 둘
  SELECT count(*) INTO n FROM duty_roster WHERE store_id = 1 AND on_duty;
  IF n <> 2 THEN RAISE EXCEPTION 'W26: 1번 지점 당직 %명 (기대 2)', n; END IF;

  -- W27. 정착 상태: 큰 테이블의 모든 페이지가 가시성 맵에 «모두 보임»으로 표시되어 있다 (뒷정리가 끝난 상태)
  SELECT count(*) INTO n FROM pg_class
   WHERE relnamespace = 'public'::regnamespace AND relkind = 'r'
     AND relname IN ('sales', 'accounts', 'shipments_sorted', 'shipments_random', 'page_views', 'discussion_posts')
     AND relallvisible <> relpages;
  IF n <> 0 THEN RAISE EXCEPTION 'W27: 가시성 맵이 다 채워지지 않은 테이블 %개 (되돌린 직후에는 0 — ./reset.sh)', n; END IF;

  RAISE NOTICE 'WORLD CHECK: W1~W27 전 항목 통과';
END $$;
