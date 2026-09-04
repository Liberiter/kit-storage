-- 10.2 따라 하기 4단계: 앞뒤를 바꾸면 EXCEPT의 답도 달라진다
SELECT customer_id AS 고객번호
FROM reviews
GROUP BY customer_id
HAVING count(*) >= 10
EXCEPT
SELECT customer_id
FROM orders
GROUP BY customer_id
HAVING count(*) >= 20
ORDER BY 고객번호;
