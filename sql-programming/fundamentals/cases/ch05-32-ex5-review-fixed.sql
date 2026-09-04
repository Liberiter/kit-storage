-- 복습 exercise (b) — IS NOT NULL로 걸러 고친 질의
SELECT order_id, status, shipped_date
FROM orders
WHERE shipped_date IS NOT NULL
ORDER BY shipped_date DESC, order_id
LIMIT 5;
