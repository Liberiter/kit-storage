-- 13장(exit assessment) 문항 4 해설: (다)를 울산 고객으로 — 고객마다 한 줄
WITH numbered AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        row_number() OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS 차례
    FROM orders
)
SELECT
    customers.customer_id AS 고객번호,
    customers.name AS 고객,
    numbered.order_id AS 주문번호,
    numbered.order_date AS 첫주문일
FROM customers
INNER JOIN numbered ON customers.customer_id = numbered.customer_id
WHERE customers.city = '울산' AND numbered.차례 = 1
ORDER BY 고객번호, 주문번호;
