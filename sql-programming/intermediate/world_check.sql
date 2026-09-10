-- world 속성 검증 — 이 코스의 챕터들이 world에 요구하는 성질을 기계적으로 확인한다.
-- 실패 시 RAISE EXCEPTION (check_env.sh 가 실행 — 입장 점검의 첫 단계).
-- 각 검사 번호는 HARNESS.md 요구 매트릭스의 "검증" 열과 대응한다.
-- 이 파일은 읽기만 한다 — W12의 제약 검사는 예외 블록 안에서 굴려 되돌린다.

DO $$
DECLARE n bigint; m bigint; x double precision; y double precision;
BEGIN
  -- W1. 테이블: public 12개(핵심 5 + 운영 7), 핵심 다섯 테이블의 행 수는 앞 코스와 같다
  SELECT count(*) INTO n FROM information_schema.tables
   WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
  IF n <> 12 THEN RAISE EXCEPTION 'W1: public 테이블 수 % (기대 12)', n; END IF;
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

  -- W12. 제약이 실제로 위반을 막는가 (7장 CHECK·UNIQUE·FK 경험)
  BEGIN
    INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
    VALUES ((SELECT min(book_id) FROM books WHERE book_id NOT IN (SELECT book_id FROM book_supply)), -1, 0, now());
    RAISE EXCEPTION 'W12: CHECK(supplier_price > 0) 위반이 허용됨';
  EXCEPTION WHEN check_violation THEN NULL;
  END;
  BEGIN
    INSERT INTO book_meta (book_id, isbn13, tags)
    VALUES (1, (SELECT isbn13 FROM book_meta WHERE book_id = 2), ARRAY['x']);
    RAISE EXCEPTION 'W12: UNIQUE(isbn13) 또는 PK 위반이 허용됨';
  EXCEPTION WHEN unique_violation THEN NULL;
  END;
  BEGIN
    INSERT INTO page_views (viewed_at, book_id, client_tz, context)
    VALUES (now(), 999999, 'Asia/Seoul', '{}');
    RAISE EXCEPTION 'W12: FK(page_views.book_id) 위반이 허용됨';
  EXCEPTION WHEN foreign_key_violation THEN NULL;
  END;

  -- W13. NULL 허용 외래키 (2장 NOT IN 함정·반조인): reviews.order_id, page_views.customer_id
  SELECT count(*) FILTER (WHERE order_id IS NULL), count(*) FILTER (WHERE order_id IS NOT NULL) INTO n, m FROM reviews;
  IF n < 100 OR m < 100 THEN RAISE EXCEPTION 'W13: reviews.order_id NULL %/NOT NULL % (기대 각 100+)', n, m; END IF;
  SELECT count(*) FILTER (WHERE customer_id IS NULL), count(*) INTO n, m FROM page_views;
  IF n * 10 < m * 4 OR n * 10 > m * 8 THEN RAISE EXCEPTION 'W13: page_views.customer_id NULL 비율 %/% (기대 40~80%%)', n, m; END IF;

  -- W14. 동시성 실습 재료 (12장): concurrency/ 스크립트가 쓰는 1번 책의 재고가 2 이상
  SELECT stock INTO n FROM books WHERE book_id = 1;
  IF n IS NULL OR n < 2 THEN RAISE EXCEPTION 'W14: 1번 책 재고 % (기대 2+ — 동시성 실습 대상)', n; END IF;

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

  RAISE NOTICE 'WORLD CHECK: W1~W16 전 항목 통과';
END $$;
