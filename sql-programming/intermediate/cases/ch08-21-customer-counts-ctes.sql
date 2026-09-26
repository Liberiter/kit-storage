-- 8장 8.2 «practice» 1: 고객마다 주문 수와 리뷰 수 — 질문마다 따로 센 뒤 잇는다
WITH ordered AS (
    SELECT customer_id, count(*) AS 주문수
    FROM orders
    GROUP BY customer_id
),
reviewed AS (
    SELECT customer_id, count(*) AS 리뷰수
    FROM reviews
    GROUP BY customer_id
)
SELECT
    customers.customer_id AS 고객번호,
    COALESCE(ordered.주문수, 0) AS 주문수,
    COALESCE(reviewed.리뷰수, 0) AS 리뷰수
FROM customers
LEFT JOIN ordered ON customers.customer_id = ordered.customer_id
LEFT JOIN reviewed ON customers.customer_id = reviewed.customer_id
WHERE customers.customer_id <= 5
ORDER BY customers.customer_id;
