-- 2장 «연습하기» exercise 4 해설 — 한쪽만 한 고객이 각각 몇 명인가
SELECT '리뷰만 씀' AS 구분, count(*) AS 인원
FROM customers
WHERE EXISTS (
    SELECT 1 FROM reviews WHERE reviews.customer_id = customers.customer_id
)
    AND NOT EXISTS (
        SELECT 1 FROM orders WHERE orders.customer_id = customers.customer_id
    )
UNION ALL
SELECT '주문만 함', count(*)
FROM customers
WHERE EXISTS (
    SELECT 1 FROM orders WHERE orders.customer_id = customers.customer_id
)
    AND NOT EXISTS (
        SELECT 1 FROM reviews WHERE reviews.customer_id = customers.customer_id
    )
ORDER BY 구분;
