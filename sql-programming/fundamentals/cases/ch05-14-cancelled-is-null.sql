-- 5.1 흔한 실수 — 취소된 주문의 발송일도 NULL이다 (NULL은 이유를 말하지 않는다)
SELECT order_id, order_date, status, shipped_date
FROM orders
WHERE status = '취소'
ORDER BY order_id
LIMIT 5;
