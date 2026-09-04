-- 복습 exercise (a) — 내림차순 정렬에서 NULL이 앞을 차지해 버린 결과
SELECT order_id, status, shipped_date
FROM orders
ORDER BY shipped_date DESC, order_id
LIMIT 5;
