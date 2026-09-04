-- 5.1 문제 상황 — orders 앞 10건. shipped_date 칸이 비어 있는 행을 보인다
SELECT order_id, order_date, status, shipped_date
FROM orders
ORDER BY order_id
LIMIT 10;
