-- 5장 5.1 «practice» 2: 분야마다 쪽수가 많은 상위 두 등
WITH ranked AS (
    SELECT
        category AS 분야,
        title AS 제목,
        page_count AS 쪽수,
        rank() OVER (PARTITION BY category ORDER BY page_count DESC) AS 순위
    FROM books
)
SELECT 분야, 순위, 제목, 쪽수
FROM ranked
WHERE 순위 <= 2
ORDER BY 분야, 순위, 제목;
