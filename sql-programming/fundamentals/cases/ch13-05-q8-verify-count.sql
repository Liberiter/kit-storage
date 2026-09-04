-- 13장 exit assessment 문항 8 해설: 본 질의보다 먼저 내는 검증 질의 (행 수)
SELECT count(*) AS 대상고객수
FROM customers
WHERE birth_date IS NULL AND signup_date >= '2025-01-01';
