-- 9.3 따라 하기 2단계: WHERE(행)와 HAVING(그룹)을 함께 쓴다
SELECT
    customers.customer_id AS 고객번호,
    customers.name AS 이름,
    count(*) AS 주문수
FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id
WHERE orders.order_date >= '2026-01-01'
GROUP BY customers.customer_id, customers.name
HAVING count(*) >= 6
ORDER BY 주문수 DESC, 고객번호;
