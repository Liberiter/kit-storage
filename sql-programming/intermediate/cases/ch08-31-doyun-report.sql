-- 8장 «도전하기» problem 2 해설: 동명이인 네 사람을 가려 각자의 주문 수·구매액·리뷰 수를 낸다
WITH ordered AS (
    SELECT
        orders.customer_id,
        count(DISTINCT orders.order_id) AS 주문수,
        sum(order_items.quantity * order_items.unit_price) AS 구매액
    FROM orders
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    WHERE orders.status <> '취소'
    GROUP BY orders.customer_id
),
reviewed AS (
    SELECT customer_id, count(*) AS 리뷰수
    FROM reviews
    GROUP BY customer_id
)
SELECT
    customers.customer_id AS 고객번호,
    customers.email AS 이메일,
    COALESCE(ordered.주문수, 0) AS 주문수,
    COALESCE(ordered.구매액, 0) AS 구매액,
    COALESCE(reviewed.리뷰수, 0) AS 리뷰수
FROM customers
LEFT JOIN ordered ON customers.customer_id = ordered.customer_id
LEFT JOIN reviewed ON customers.customer_id = reviewed.customer_id
WHERE customers.name = '서도윤'
ORDER BY customers.customer_id;
