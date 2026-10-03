-- 13장(exit assessment) 문항 4 지문 (다)·해설: 춘천 고객의 첫 주문 — row_number() 창
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
WHERE customers.city = '춘천' AND numbered.차례 = 1
ORDER BY 고객번호, 주문번호;
