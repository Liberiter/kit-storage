-- runner: reset
-- 10장 10.2 «왜 그럴까요»: numeric 값을 넘기면 맞는 함수를 찾지 못한다 (오류 기대)
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

SELECT category, price_band(round(avg(price))) AS 평균가격대
FROM books
GROUP BY category;
