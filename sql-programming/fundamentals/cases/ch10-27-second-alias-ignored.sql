-- 10.2 흔한 실수: 결과의 열 이름은 첫 질의의 것이고 뒤 질의의 별칭은 쓰이지 않는다
SELECT customer_id AS 단골
FROM orders
GROUP BY customer_id
HAVING count(*) >= 20
UNION
SELECT customer_id AS 리뷰어
FROM reviews
GROUP BY customer_id
HAVING count(*) >= 10
ORDER BY 단골;
