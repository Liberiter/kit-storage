-- 5.1 문제 상황 — `WHERE shipped_date = NULL` (오류 없이 0행)
SELECT order_id, order_date, status, shipped_date
FROM orders
WHERE shipped_date = NULL;
