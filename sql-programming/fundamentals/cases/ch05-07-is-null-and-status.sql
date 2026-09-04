-- 5.1 따라 하기 5단계 — IS NULL과 3장의 `AND`·`<>`를 함께 쓴다
SELECT order_id, order_date, status, shipped_date
FROM orders
WHERE shipped_date IS NULL AND status <> '취소'
ORDER BY order_id
LIMIT 5;
