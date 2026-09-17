-- 2장 «도전하기» problem 2 해설 — 주문은 했지만 리뷰를 쓰지 않은 고객
SELECT
    customers.customer_id AS 고객번호,
    customers.name AS 이름,
    customers.city AS 도시,
    count(*) AS 주문수,
    max(orders.order_date) AS "마지막 주문일"
FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id
WHERE NOT EXISTS (
    SELECT 1 FROM reviews WHERE reviews.customer_id = customers.customer_id
)
GROUP BY customers.customer_id, customers.name, customers.city
ORDER BY 주문수 DESC, 고객번호;
