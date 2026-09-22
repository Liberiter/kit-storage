-- 5장 «연습하기» exercise 1 해설: 도시마다 구매액 1위 고객
WITH customer_amount AS (
    SELECT
        customers.city AS 도시,
        customers.name AS 이름,
        sum(order_items.unit_price * order_items.quantity) AS 구매액
    FROM customers
    INNER JOIN orders ON customers.customer_id = orders.customer_id
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    WHERE orders.status <> '취소'
    GROUP BY customers.customer_id, customers.city, customers.name
),
ranked AS (
    SELECT
        도시,
        이름,
        구매액,
        rank() OVER (PARTITION BY 도시 ORDER BY 구매액 DESC) AS 순위
    FROM customer_amount
)
SELECT 도시, 이름, 구매액
FROM ranked
WHERE 순위 = 1
ORDER BY 도시;
