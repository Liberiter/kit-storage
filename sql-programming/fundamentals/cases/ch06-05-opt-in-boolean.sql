-- 6.1 따라 하기 4단계: 불리언 타입은 그 자체가 검색 조건이 된다
SELECT customer_id, name, marketing_opt_in
FROM customers
WHERE marketing_opt_in
ORDER BY customer_id
LIMIT 5;
