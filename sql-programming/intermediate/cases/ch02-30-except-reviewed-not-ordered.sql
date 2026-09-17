-- 2장 2.3 «practice» 1 — 리뷰는 썼지만 주문은 없는 고객의 번호
SELECT customer_id AS 고객번호
FROM reviews
EXCEPT
SELECT customer_id
FROM orders
ORDER BY 고객번호;
