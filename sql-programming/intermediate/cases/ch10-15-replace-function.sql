-- runner: reset
-- 10장 10.2 «따라 하기» 4단계: CREATE OR REPLACE FUNCTION 으로 구간을 바꾸면 부르는 질의의 결과가 따라 바뀐다
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

CREATE OR REPLACE FUNCTION price_band(amount integer)
RETURNS text
LANGUAGE sql
AS $$
SELECT
    CASE
        WHEN amount < 10000 THEN '1만원 미만'
        WHEN amount < 20000 THEN '1만원대'
        WHEN amount < 30000 THEN '2만원대'
        ELSE '3만원 이상'
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
