-- 2장 2.3 «따라 하기» 3단계 — 교집합으로 주문도 리뷰도 있는 고객을 뽑는다
SELECT customer_id AS 고객번호
FROM orders
INTERSECT
SELECT customer_id
FROM reviews
ORDER BY 고객번호
LIMIT 5;
