-- 10.2 따라 하기 4단계: EXCEPT는 앞 질의에만 있는 행을 남긴다
SELECT customer_id AS 고객번호
FROM orders
GROUP BY customer_id
HAVING count(*) >= 20
EXCEPT
SELECT customer_id
FROM reviews
GROUP BY customer_id
HAVING count(*) >= 10
ORDER BY 고객번호;
