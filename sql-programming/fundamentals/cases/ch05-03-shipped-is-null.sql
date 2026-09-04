-- 5.1 따라 하기 1단계 — `IS NULL`로 발송일이 없는 주문을 고른다
SELECT order_id, order_date, status, shipped_date
FROM orders
WHERE shipped_date IS NULL
ORDER BY order_id
LIMIT 5;
