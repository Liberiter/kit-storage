-- 13장(exit assessment) 문항 2 해설: 2025년 도시별 고객 구매액 분포(중앙값·표준편차)·큰손 수·매출 비중
WITH customer_amount AS (
    SELECT
        customers.city AS 도시,
        customers.customer_id,
        sum(order_items.quantity * order_items.unit_price) AS 구매액
    FROM customers
    INNER JOIN orders ON customers.customer_id = orders.customer_id
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    WHERE orders.status <> '취소'
        AND orders.order_date BETWEEN '2025-01-01' AND '2025-12-31'
    GROUP BY customers.city, customers.customer_id
),
city_stat AS (
    SELECT
        도시,
        count(*) AS 구매고객,
        percentile_cont(0.5) WITHIN GROUP (ORDER BY 구매액) AS 중앙값,
        round(stddev(구매액)) AS 표준편차,
        count(*) FILTER (WHERE 구매액 >= 300000) AS 큰손,
        sum(구매액) AS 매출
    FROM customer_amount
    GROUP BY 도시
)
SELECT
    도시,
    구매고객,
    중앙값,
    표준편차,
    큰손,
    round(100.0 * 매출 / sum(매출) OVER (), 1) AS "매출 비중(%)"
FROM city_stat
ORDER BY 중앙값 DESC, 도시;
