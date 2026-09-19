-- 4장 «도전하기» problem 2 해설: 자기 도시 평균의 두 배 이상을 산 고객
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
city_share AS (
    SELECT
        도시,
        이름,
        구매액,
        round(avg(구매액) OVER (PARTITION BY 도시)) AS 도시평균,
        round(100.0 * 구매액 / sum(구매액) OVER (PARTITION BY 도시), 1)
            AS "도시 안 비중(%)"
    FROM customer_amount
)
SELECT 도시, 이름, 구매액, 도시평균, "도시 안 비중(%)"
FROM city_share
WHERE 구매액 >= 2 * 도시평균
ORDER BY 도시, 구매액 DESC, 이름;
