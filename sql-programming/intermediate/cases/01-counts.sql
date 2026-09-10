-- smoke: 테이블별 행 수 (world 규모 확인 겸 러너 동작 예시 — 조회형)
SELECT 'categories' AS table_name, count(*) AS rows FROM categories
UNION ALL SELECT 'customers', count(*) FROM customers
UNION ALL SELECT 'books', count(*) FROM books
UNION ALL SELECT 'orders', count(*) FROM orders
UNION ALL SELECT 'order_items', count(*) FROM order_items
UNION ALL SELECT 'reviews', count(*) FROM reviews
UNION ALL SELECT 'staff', count(*) FROM staff
UNION ALL SELECT 'book_meta', count(*) FROM book_meta
UNION ALL SELECT 'book_supply', count(*) FROM book_supply
UNION ALL SELECT 'supplier_feed', count(*) FROM supplier_feed
UNION ALL SELECT 'stock_movements', count(*) FROM stock_movements
UNION ALL SELECT 'page_views', count(*) FROM page_views
UNION ALL SELECT 'legacy.sales_ledger', count(*) FROM legacy.sales_ledger
UNION ALL SELECT 'antipatterns.products', count(*) FROM antipatterns.products
ORDER BY table_name;
