-- 10.2 따라 하기 2단계: UNION ALL은 겹치는 행도 그대로 둔다
SELECT customer_id AS 고객번호
FROM orders
GROUP BY customer_id
HAVING count(*) >= 20
UNION ALL
SELECT customer_id
FROM reviews
GROUP BY customer_id
HAVING count(*) >= 10
ORDER BY 고객번호;
