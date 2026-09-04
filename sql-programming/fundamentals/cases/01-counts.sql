-- smoke: 테이블별 행 수 (world 규모 확인 겸 러너 동작 예시)
SELECT 'customers' AS table_name, count(*) AS rows FROM customers
UNION ALL SELECT 'books', count(*) FROM books
UNION ALL SELECT 'orders', count(*) FROM orders
UNION ALL SELECT 'order_items', count(*) FROM order_items
UNION ALL SELECT 'reviews', count(*) FROM reviews
ORDER BY table_name;
