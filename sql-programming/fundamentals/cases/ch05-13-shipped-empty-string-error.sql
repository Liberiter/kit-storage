-- 5.1 흔한 실수 — 날짜 열에 빈 문자열을 견주면 오류 (exit 3)
SELECT order_id, shipped_date FROM orders WHERE shipped_date = '';
