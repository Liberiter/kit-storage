-- 10.2 practice 2 풀이: 고객번호 10번까지 중 주문은 했지만 리뷰는 쓰지 않은 손님
SELECT customer_id AS 고객번호
FROM orders
WHERE customer_id <= 10
EXCEPT
SELECT customer_id
FROM reviews
WHERE customer_id <= 10
ORDER BY 고객번호;
