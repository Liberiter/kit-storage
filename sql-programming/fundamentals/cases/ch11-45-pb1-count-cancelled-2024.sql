-- problem 1 해설 — 지울 주문과 딸린 항목이 몇 건인지 먼저 센다
SELECT count(*) AS 지울주문
FROM orders
WHERE status = '취소' AND order_date BETWEEN '2024-01-01' AND '2024-12-31';

SELECT count(*) AS 지울항목
FROM order_items
WHERE order_id IN (
    SELECT order_id
    FROM orders
    WHERE status = '취소'
        AND order_date BETWEEN '2024-01-01' AND '2024-12-31'
);
