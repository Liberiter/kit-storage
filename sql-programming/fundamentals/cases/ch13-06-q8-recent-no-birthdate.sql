-- 13장 exit assessment 문항 8 해설: 생일을 적지 않은 2025년 이후 가입 고객
SELECT
    customer_id AS 고객번호,
    name AS 이름,
    city AS 도시,
    signup_date AS 가입일
FROM customers
WHERE birth_date IS NULL AND signup_date >= '2025-01-01'
ORDER BY 가입일, 고객번호;
