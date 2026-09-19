-- 4장 4.1 «practice» 2: 주문 한 건의 결제 금액 분포 (2026년 상반기)
WITH order_amount AS (
    SELECT
        orders.order_id,
        sum(order_items.unit_price * order_items.quantity) AS 금액
    FROM orders
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    WHERE orders.order_date BETWEEN '2026-01-01' AND '2026-06-30'
        AND orders.status <> '취소'
    GROUP BY orders.order_id
)
SELECT
    count(*) AS 주문수,
    round(avg(금액)) AS 평균금액,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY 금액) AS 중앙값,
    round(stddev(금액)) AS 표준편차
FROM order_amount;
