-- 13장(exit assessment) 문항 4 지문 (나): 춘천 고객의 첫 주문 — 고객별 첫 주문일을 CTE로 구해 잇기
WITH first_date AS (
    SELECT customer_id, min(order_date) AS 첫주문일
    FROM orders
    GROUP BY customer_id
)
SELECT
    customers.customer_id AS 고객번호,
    customers.name AS 고객,
    orders.order_id AS 주문번호,
    first_date.첫주문일
FROM customers
INNER JOIN first_date ON customers.customer_id = first_date.customer_id
INNER JOIN orders
    ON first_date.customer_id = orders.customer_id
    AND first_date.첫주문일 = orders.order_date
WHERE customers.city = '춘천'
ORDER BY 고객번호, 주문번호;
