-- 13장(exit assessment) 주장 케이스 (정수) — 본문에 블록으로 등장하지 않는 world 의 수치·사실
--   2025년 첫 주문 고객 수 → 문항 1 채점 포인트 「2025년에 처음 주문한 고객을 따로 세어도 36명」
--   2025년 주문 고객 수 → 문항 1 채점 포인트 「2025년에 주문한 고객 수 80」, 문항 2 채점 포인트 「80명」
--   999번 책·999번 고객 행 수 → 문항 3 (나) 검증 ②의 문장 3·9 (없는 책·고객이 아닌 사람)
--   60번 책 행 수 → 문항 3 (나) 검증 ②가 거절 사유 하나만 남기려고 쓰는 정상 책
--   춘천 고객 수 → 문항 4 해설 「춘천의 고객은 열두 명」
--   6번 책 재고 → 문항 5 지문 「6번 책은 재고가 1권」
--   8월 대구 주문 고객 수 → 문항 6 (가) 해설 「8월에 주문한 고객이 한 명」
--   가장 큰 책 번호·420번 책 행 수 → 문항 7 해설 「책은 320번까지」, 「`420`은 `books`에 없는 번호」
--   UTC 8월 15일 조회 24회인 책 수 → 문항 8 모범 리포트 「다섯째와 같은 수가 없어」
SELECT '2025년 첫 주문 고객 수' AS 주장, count(*)::integer AS 실측값
FROM (
    SELECT customer_id, min(order_date) AS first_date
    FROM orders WHERE status <> '취소' GROUP BY customer_id
) AS f
WHERE first_date >= '2025-01-01' AND first_date < '2026-01-01'
UNION ALL
SELECT '2025년 주문 고객 수', count(DISTINCT customer_id)::integer
FROM orders
WHERE status <> '취소' AND order_date >= '2025-01-01' AND order_date < '2026-01-01'
UNION ALL
SELECT '999번 책 행 수', count(*)::integer FROM books WHERE book_id = 999
UNION ALL
SELECT '999번 고객 행 수', count(*)::integer FROM customers WHERE customer_id = 999
UNION ALL
SELECT '60번 책 행 수', count(*)::integer FROM books WHERE book_id = 60
UNION ALL
SELECT '춘천 고객 수', count(*)::integer FROM customers WHERE city = '춘천'
UNION ALL
SELECT '6번 책 재고', stock FROM books WHERE book_id = 6
UNION ALL
SELECT '8월 대구 주문 고객 수', count(DISTINCT orders.customer_id)::integer
FROM orders INNER JOIN customers ON orders.customer_id = customers.customer_id
WHERE customers.city = '대구' AND orders.status <> '취소'
    AND orders.order_date >= '2026-08-01' AND orders.order_date < '2026-09-01'
UNION ALL
SELECT '가장 큰 책 번호', max(book_id) FROM books
UNION ALL
SELECT '420번 책 행 수', count(*)::integer FROM books WHERE book_id = 420
UNION ALL
SELECT 'UTC 8월 15일 조회 24회인 책 수', count(*)::integer
FROM (
    SELECT book_id, count(*) AS n FROM page_views
    WHERE viewed_at::date = '2026-08-15' GROUP BY book_id
) AS d
WHERE n = 24;
