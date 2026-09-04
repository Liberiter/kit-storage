-- 10.2 practice 1 풀이: 고객번호 10번까지 중 주문이나 리뷰를 남긴 손님
SELECT customer_id AS 고객번호
FROM orders
WHERE customer_id <= 10
UNION
SELECT customer_id
FROM reviews
WHERE customer_id <= 10
ORDER BY 고객번호;
