-- 5.2 흔한 실수 — 날짜 열을 글자로 채우려 하면 오류 (exit 3)
SELECT order_id, COALESCE(shipped_date, '준비 중') AS 발송일
FROM orders
ORDER BY order_id
LIMIT 3;
