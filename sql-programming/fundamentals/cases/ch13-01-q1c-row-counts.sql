-- 13장 exit assessment 문항 1 (다): psql에서 실행하는 다섯 테이블 행 수 점검 질의
SELECT 'books' AS 테이블, count(*) AS 행수
FROM books
UNION ALL
SELECT 'customers', count(*)
FROM customers
UNION ALL
SELECT 'order_items', count(*)
FROM order_items
UNION ALL
SELECT 'orders', count(*)
FROM orders
UNION ALL
SELECT 'reviews', count(*)
FROM reviews
ORDER BY 테이블;
