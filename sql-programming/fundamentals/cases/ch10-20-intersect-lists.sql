-- 10.2 따라 하기 3단계: INTERSECT는 양쪽에 모두 있는 행만 남긴다
SELECT customer_id AS 고객번호
FROM orders
GROUP BY customer_id
HAVING count(*) >= 20
INTERSECT
SELECT customer_id
FROM reviews
GROUP BY customer_id
HAVING count(*) >= 10
ORDER BY 고객번호;
