-- 13장(exit assessment) 문항 6 (가) 지문: 동료의 도시별 8월 보고 질의 (일대다 갈래 둘을 한 질의에 — 부풀려진 답)
SELECT
    customers.city AS 도시,
    count(DISTINCT orders.order_id) AS 주문수,
    sum(order_items.quantity * order_items.unit_price) AS 매출,
    count(page_views.view_id) AS 조회수
FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id
INNER JOIN order_items ON orders.order_id = order_items.order_id
INNER JOIN page_views ON customers.customer_id = page_views.customer_id
WHERE orders.status <> '취소'
    AND orders.order_date BETWEEN '2026-08-01' AND '2026-08-31'
    AND page_views.viewed_at >= '2026-08-01 00:00:00+09'
    AND page_views.viewed_at < '2026-09-01 00:00:00+09'
GROUP BY customers.city
ORDER BY customers.city;
