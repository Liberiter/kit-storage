-- runner: reset
-- 10장 10.2 «따라 하기» 1단계: 함수 price_band 를 만들고 1~5번 책에 불러 본다
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

SELECT book_id, price, price_band(price) AS 가격대
FROM books
WHERE book_id <= 5
ORDER BY book_id;
