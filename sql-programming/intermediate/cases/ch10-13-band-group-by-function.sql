-- runner: reset
-- 10장 10.2 «따라 하기» 2단계: 문제 상황의 질의를 함수로 다시 쓴다 (ch10-11 과 출력이 같다)
CREATE FUNCTION price_band(amount integer)
RETURNS text
LANGUAGE sql
AS $$
SELECT
    CASE
        WHEN amount < 10000 THEN '1만원 미만'
        WHEN amount < 20000 THEN '1만원대'
        ELSE '2만원 이상'
    END AS 가격대;
$$;

SELECT
    price_band(order_items.unit_price) AS 가격대,
    sum(order_items.quantity) AS 판매권수
FROM orders
INNER JOIN order_items ON orders.order_id = order_items.order_id
WHERE orders.status <> '취소' AND orders.order_date >= '2026-01-01'
GROUP BY price_band(order_items.unit_price)
ORDER BY 판매권수 DESC;
