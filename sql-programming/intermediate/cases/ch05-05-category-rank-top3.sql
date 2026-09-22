-- 5장 5.1 «따라 하기» 4단계: PARTITION BY 로 분야마다 순위를 매기고 상위 세 등만
WITH ranked AS (
    SELECT
        category AS 분야,
        title AS 제목,
        price AS 가격,
        rank() OVER (PARTITION BY category ORDER BY price DESC) AS 순위
    FROM books
    WHERE category IN ('에세이', '요리')
)
SELECT 분야, 순위, 제목, 가격
FROM ranked
WHERE 순위 <= 3
ORDER BY 분야, 순위, 제목;
