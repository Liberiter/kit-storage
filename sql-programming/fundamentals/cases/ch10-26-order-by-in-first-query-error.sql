-- 10.2 흔한 실수: 앞 질의에 ORDER BY를 붙이면 문법 오류 (exit 3)
SELECT customer_id AS 고객번호
FROM orders
GROUP BY customer_id
HAVING count(*) >= 20
ORDER BY 고객번호
UNION
SELECT customer_id
FROM reviews
GROUP BY customer_id
HAVING count(*) >= 10;
