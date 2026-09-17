-- 1장 «연습하기» exercise 2: 도시별 주문 수를 상태별로 가른 교차 표
SELECT
    customers.city AS 도시,
    count(*) AS 주문수,
    count(*) FILTER (WHERE orders.status = '배송완료') AS 배송완료,
    count(*) FILTER (WHERE orders.status = '취소') AS 취소
FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.city
ORDER BY 주문수 DESC, 도시
LIMIT 5;
