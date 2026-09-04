-- 5.1 따라 하기 2단계 — `IS NOT NULL`로 발송된 주문을 고른다
SELECT order_id, order_date, status, shipped_date
FROM orders
WHERE shipped_date IS NOT NULL
ORDER BY order_id
LIMIT 5;
