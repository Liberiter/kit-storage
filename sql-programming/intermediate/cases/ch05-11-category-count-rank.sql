-- 5장 5.1 «practice» 1: 분야별 권수에 등수를 붙인다 (동점은 같은 등수)
WITH category_count AS (
    SELECT category AS 분야, count(*) AS 권수
    FROM books
    GROUP BY category
)
SELECT
    rank() OVER (ORDER BY 권수 DESC) AS 순위,
    분야,
    권수
FROM category_count
ORDER BY 권수 DESC, 분야;
