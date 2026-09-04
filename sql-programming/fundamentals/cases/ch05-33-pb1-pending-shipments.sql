-- problem 1 해설 — 발송 대기 현황판 (취소 제외, 주문일이 오래된 순)
SELECT order_id AS 주문번호, order_date AS 주문일, status AS 상태
FROM orders
WHERE shipped_date IS NULL AND status <> '취소'
ORDER BY order_date, order_id
LIMIT 5;
