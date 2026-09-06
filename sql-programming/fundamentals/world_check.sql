-- world 속성 검증 — 이 코스의 챕터들이 world에 요구하는 성질을 기계적으로 확인한다.
-- 실패 시 RAISE EXCEPTION (러너·검증의 기계 검사 대상).
-- 각 검사 번호는 HARNESS.md의 요구 매트릭스 "검증" 열과 대응한다.

DO $$
DECLARE n bigint; m bigint;
BEGIN
  -- W1. 테이블 5개, FK 관계, 3테이블 조인 경로
  SELECT count(*) INTO n FROM information_schema.tables
   WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
  IF n <> 5 THEN RAISE EXCEPTION 'W1: 테이블 수 % (기대 5)', n; END IF;
  SELECT count(*) INTO n FROM information_schema.table_constraints
   WHERE table_schema = 'public' AND constraint_type = 'FOREIGN KEY';
  IF n < 5 THEN RAISE EXCEPTION 'W1: FK 제약 % (기대 5+)', n; END IF;
  SELECT count(*) INTO n
    FROM customers c JOIN orders o USING (customer_id)
         JOIN order_items oi USING (order_id);
  IF n < 500 THEN RAISE EXCEPTION 'W1: 3테이블 조인 결과 % (기대 500+)', n; END IF;

  -- W2. 규모 (주 테이블 수백 행)
  SELECT count(*) INTO n FROM books;
  IF n < 300 THEN RAISE EXCEPTION 'W2: books % (기대 300+)', n; END IF;
  SELECT count(*) INTO n FROM customers;
  IF n < 140 THEN RAISE EXCEPTION 'W2: customers % (기대 140+)', n; END IF;
  SELECT count(*) INTO n FROM orders;
  IF n < 500 THEN RAISE EXCEPTION 'W2: orders % (기대 500+)', n; END IF;
  SELECT count(*) INTO n FROM order_items;
  IF n < 900 THEN RAISE EXCEPTION 'W2: order_items % (기대 900+)', n; END IF;
  SELECT count(*) INTO n FROM reviews;
  IF n < 400 THEN RAISE EXCEPTION 'W2: reviews % (기대 400+)', n; END IF;

  -- W3. books는 전 열 NOT NULL (2~4장 NULL-free 예제 전제)
  SELECT count(*) INTO n FROM information_schema.columns
   WHERE table_schema = 'public' AND table_name = 'books' AND is_nullable = 'YES';
  IF n <> 0 THEN RAISE EXCEPTION 'W3: books에 NULL 허용 열 %개', n; END IF;

  -- W4. NULL이 자연스러운 열 2개 이상 (양쪽 값 모두 존재)
  SELECT count(*) FILTER (WHERE shipped_date IS NULL),
         count(*) FILTER (WHERE shipped_date IS NOT NULL) INTO n, m FROM orders;
  IF n < 50 OR m < 100 THEN RAISE EXCEPTION 'W4: shipped_date NULL %/NOT NULL % (기대 50+/100+)', n, m; END IF;
  SELECT count(*) FILTER (WHERE birth_date IS NULL) INTO n FROM customers;
  IF n < 20 THEN RAISE EXCEPTION 'W4: birth_date NULL % (기대 20+)', n; END IF;
  SELECT count(*) FILTER (WHERE comment IS NULL),
         count(*) FILTER (WHERE comment IS NOT NULL) INTO n, m FROM reviews;
  IF n < 50 OR m < 100 THEN RAISE EXCEPTION 'W4: comment NULL %/NOT NULL % (기대 50+/100+ — COUNT 대비용)', n, m; END IF;

  -- W5. 자식 없는 부모
  SELECT count(*) INTO n FROM customers c
   WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);
  IF n < 10 THEN RAISE EXCEPTION 'W5: 주문 없는 고객 % (기대 10+)', n; END IF;
  SELECT count(*) INTO n FROM books b
   WHERE NOT EXISTS (SELECT 1 FROM order_items oi WHERE oi.book_id = b.book_id);
  IF n < 5 THEN RAISE EXCEPTION 'W5: 주문된 적 없는 책 % (기대 5+)', n; END IF;
  SELECT count(*) INTO n FROM books b
   WHERE NOT EXISTS (SELECT 1 FROM reviews r WHERE r.book_id = b.book_id);
  IF n < 5 THEN RAISE EXCEPTION 'W5: 리뷰 없는 책 % (기대 5+)', n; END IF;

  -- W6. 중복 값 열(DISTINCT 유의미)·동점 정렬 값·그룹 크기 편차
  SELECT count(DISTINCT category) INTO n FROM books;
  IF n NOT BETWEEN 5 AND 12 THEN RAISE EXCEPTION 'W6: 카테고리 수 % (기대 5~12)', n; END IF;
  SELECT count(*) INTO n FROM (SELECT price FROM books GROUP BY price HAVING count(*) >= 2) t;
  IF n < 10 THEN RAISE EXCEPTION 'W6: 동점 가격 값 % (기대 10+)', n; END IF;
  SELECT max(cnt), min(cnt) INTO n, m
    FROM (SELECT count(*) cnt FROM orders GROUP BY customer_id) t;
  IF n < 8 OR m > 2 THEN RAISE EXCEPTION 'W6: 고객별 주문 수 편차 max=% min=% (기대 max 8+, min 2 이하)', n, m; END IF;

  -- W7. LIKE·BETWEEN·IN 유의미 대상
  SELECT count(*) INTO n FROM books WHERE title LIKE '%여행%';
  IF n < 3 THEN RAISE EXCEPTION 'W7: ''여행'' 포함 제목 % (기대 3+)', n; END IF;
  SELECT count(*) INTO n FROM books WHERE price BETWEEN 10000 AND 20000;
  IF n < 30 THEN RAISE EXCEPTION 'W7: 1~2만원대 책 % (기대 30+)', n; END IF;

  -- W8. 계산 쌍(단가×수량)·날짜 연산 대상
  SELECT count(*) INTO n FROM order_items WHERE quantity >= 2;
  IF n < 100 THEN RAISE EXCEPTION 'W8: 수량 2+ 항목 % (기대 100+)', n; END IF;
  SELECT count(*) INTO n FROM orders WHERE shipped_date > order_date;
  IF n < 100 THEN RAISE EXCEPTION 'W8: 발송 소요일 1일+ 주문 % (기대 100+)', n; END IF;

  -- W9. 서브쿼리 유의미(평균 이상 — 진부분집합)
  SELECT count(*) INTO n FROM books WHERE price > (SELECT avg(price) FROM books);
  SELECT count(*) INTO m FROM books;
  IF n = 0 OR n = m THEN RAISE EXCEPTION 'W9: 평균 초과 % / 전체 % — 진부분집합 아님', n, m; END IF;

  -- W10. world 정합성 (설정 모순 없음)
  SELECT count(*) INTO n FROM orders
   WHERE (status IN ('배송중', '배송완료')) <> (shipped_date IS NOT NULL);
  IF n <> 0 THEN RAISE EXCEPTION 'W10: 상태-발송일 모순 %건', n; END IF;
  SELECT count(*) INTO n FROM orders o JOIN customers c USING (customer_id)
   WHERE o.order_date < c.signup_date;
  IF n <> 0 THEN RAISE EXCEPTION 'W10: 가입 전 주문 %건', n; END IF;
  SELECT count(*) INTO n FROM reviews r JOIN customers c USING (customer_id)
   WHERE r.review_date < c.signup_date;
  IF n <> 0 THEN RAISE EXCEPTION 'W10: 가입 전 리뷰 %건', n; END IF;
  SELECT count(*) INTO n FROM order_items oi
    JOIN orders o USING (order_id) JOIN books b USING (book_id)
   WHERE o.order_date < b.published_date;
  IF n <> 0 THEN RAISE EXCEPTION 'W10: 출간 전 주문 %건', n; END IF;
  SELECT count(*) INTO n FROM reviews r JOIN books b USING (book_id)
   WHERE r.review_date < b.published_date;
  IF n <> 0 THEN RAISE EXCEPTION 'W10: 출간 전 리뷰 %건', n; END IF;

  -- W11. 제약이 실제로 위반을 막는가 (PK·FK·CHECK — 11장 경험 전제)
  BEGIN
    INSERT INTO orders (order_id, customer_id, order_date, status)
    VALUES (1, 1, '2026-01-01', '배송준비');
    RAISE EXCEPTION 'W11: PK 중복이 허용됨';
  EXCEPTION WHEN unique_violation THEN NULL;
  END;
  BEGIN
    INSERT INTO orders (customer_id, order_date, status)
    VALUES (999999, '2026-01-01', '배송준비');
    RAISE EXCEPTION 'W11: FK 위반이 허용됨';
  EXCEPTION WHEN foreign_key_violation THEN NULL;
  END;
  BEGIN
    UPDATE books SET stock = -1 WHERE book_id = 1;
    RAISE EXCEPTION 'W11: CHECK(stock>=0) 위반이 허용됨';
  EXCEPTION WHEN check_violation THEN NULL;
  END;

  -- W13. NULL 허용 FK (reviews.order_id — 7장 요구) 분포와 정합
  SELECT count(*) FILTER (WHERE order_id IS NULL),
         count(*) FILTER (WHERE order_id IS NOT NULL) INTO n, m FROM reviews;
  IF n < 100 OR m < 100 THEN RAISE EXCEPTION 'W13: order_id NULL %/NOT NULL % (기대 각 100+)', n, m; END IF;
  SELECT count(*) INTO n
    FROM reviews r JOIN orders o USING (order_id)
   WHERE r.customer_id <> o.customer_id
      OR o.status <> '배송완료'
      OR r.review_date < o.shipped_date
      OR NOT EXISTS (SELECT 1 FROM order_items oi
                      WHERE oi.order_id = r.order_id AND oi.book_id = r.book_id);
  IF n <> 0 THEN RAISE EXCEPTION 'W13: 구매 인증 리뷰 정합성 위반 %건 (배송완료·발송일 이후·주문 포함 책이어야 함)', n; END IF;

  -- W12. 이체형 시나리오 재료 (재고 있는 책 — 12장 차감+기록)
  SELECT count(*) INTO n FROM books WHERE stock > 0;
  IF n < 100 THEN RAISE EXCEPTION 'W12: 재고 보유 책 % (기대 100+)', n; END IF;

  RAISE NOTICE 'WORLD CHECK: W1~W13 전 항목 통과';
END $$;
