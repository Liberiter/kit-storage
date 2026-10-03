-- 13장(exit assessment) 문항 6 (가) 해설: 고객마다 따로 센 뒤 잇는 도시별 8월 보고
WITH buyer_order AS (
    SELECT
        orders.customer_id,
        count(DISTINCT orders.order_id) AS 주문수,
        sum(order_items.quantity * order_items.unit_price) AS 매출
    FROM orders
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    WHERE orders.status <> '취소'
        AND orders.order_date BETWEEN '2026-08-01' AND '2026-08-31'
    GROUP BY orders.customer_id
),
buyer_view AS (
    SELECT customer_id, count(*) AS 조회수
    FROM page_views
    WHERE viewed_at >= '2026-08-01 00:00:00+09'
        AND viewed_at < '2026-09-01 00:00:00+09'
    GROUP BY customer_id
)
SELECT
    customers.city AS 도시,
    sum(buyer_order.주문수) AS 주문수,
    sum(buyer_order.매출) AS 매출,
    COALESCE(sum(buyer_view.조회수), 0) AS 조회수
FROM buyer_order
INNER JOIN customers ON buyer_order.customer_id = customers.customer_id
LEFT JOIN buyer_view ON buyer_order.customer_id = buyer_view.customer_id
GROUP BY customers.city
ORDER BY customers.city;
