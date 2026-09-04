-- runner: reset
-- problem 1 해설 — 딸린 항목부터 지우고 주문을 지운다
DELETE FROM order_items
WHERE order_id IN (
    SELECT order_id
    FROM orders
    WHERE status = '취소'
        AND order_date BETWEEN '2024-01-01' AND '2024-12-31'
);

DELETE FROM orders
WHERE status = '취소' AND order_date BETWEEN '2024-01-01' AND '2024-12-31';

SELECT count(*) AS 남은취소주문 FROM orders WHERE status = '취소';
