-- runner: reset
-- 10장 10.2 «practice» 2: 쪽수 구간을 돌려주는 함수로 분량별 권수
CREATE FUNCTION page_band(pages integer)
RETURNS text
LANGUAGE sql
AS $$
SELECT
    CASE
        WHEN pages < 200 THEN '200쪽 미만'
        WHEN pages < 400 THEN '200~399쪽'
        ELSE '400쪽 이상'
    END AS 분량;
$$;

SELECT page_band(page_count) AS 분량, count(*) AS 권수
FROM books
GROUP BY page_band(page_count)
ORDER BY 권수 DESC;
