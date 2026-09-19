-- 4장 «연습하기» exercise 2 해설: 구매액 상위 다섯 명과 전체 평균의 차이
WITH customer_amount AS (
    SELECT
        customers.name AS 이름,
        customers.city AS 도시,
        sum(order_items.unit_price * order_items.quantity) AS 구매액
    FROM customers
    INNER JOIN orders ON customers.customer_id = orders.customer_id
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    WHERE orders.status <> '취소'
    GROUP BY customers.customer_id, customers.name, customers.city
)
SELECT
    이름,
    도시,
    구매액,
    round(avg(구매액) OVER ()) AS "전체 평균",
    구매액 - round(avg(구매액) OVER ()) AS 차이
FROM customer_amount
ORDER BY 구매액 DESC, 이름
LIMIT 5;
