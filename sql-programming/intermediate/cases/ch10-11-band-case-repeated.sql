-- 10장 10.2 «문제 상황»: 가격대를 가르는 CASE 를 선택 목록과 GROUP BY 에 두 번 적는다
SELECT
    CASE
        WHEN order_items.unit_price < 10000 THEN '1만원 미만'
        WHEN order_items.unit_price < 20000 THEN '1만원대'
        ELSE '2만원 이상'
    END AS 가격대,
    sum(order_items.quantity) AS 판매권수
FROM orders
INNER JOIN order_items ON orders.order_id = order_items.order_id
WHERE orders.status <> '취소' AND orders.order_date >= '2026-01-01'
GROUP BY
    CASE
        WHEN order_items.unit_price < 10000 THEN '1만원 미만'
        WHEN order_items.unit_price < 20000 THEN '1만원대'
        ELSE '2만원 이상'
    END
ORDER BY 판매권수 DESC;
