-- 4장 4.1 «따라 하기» 5단계: 상관계수 두 가지 (한 블록에 질의 둘)
WITH customer_amount AS (
    SELECT
        orders.customer_id,
        count(DISTINCT orders.order_id) AS 주문수,
        sum(order_items.unit_price * order_items.quantity) AS 구매액
    FROM orders
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    WHERE orders.status <> '취소'
    GROUP BY orders.customer_id
)
SELECT
    count(*) AS 고객수,
    round(CAST(corr(주문수, 구매액) AS numeric), 3) AS 상관계수
FROM customer_amount;

SELECT round(CAST(corr(price, page_count) AS numeric), 3) AS 상관계수
FROM books;
