-- 4장 4.2 «practice» 2: 분야별 권수와 전체 대비 비중
WITH category_count AS (
    SELECT category AS 분야, count(*) AS 권수
    FROM books
    GROUP BY category
)
SELECT 분야, 권수, round(100.0 * 권수 / sum(권수) OVER (), 1) AS "비중(%)"
FROM category_count
ORDER BY 권수 DESC, 분야;
