-- 5장 «복습 exercise» 1 해설 (3장 — 재귀 CTE): 단계마다 이름 순으로 번호를 매긴다
WITH RECURSIVE tree AS (
    SELECT category_id, name, 1 AS 단계
    FROM categories
    WHERE parent_id IS NULL
    UNION ALL
    SELECT categories.category_id, categories.name, tree.단계 + 1
    FROM categories
    INNER JOIN tree ON categories.parent_id = tree.category_id
)
SELECT
    단계,
    row_number() OVER (PARTITION BY 단계 ORDER BY name) AS 번호,
    name AS 분류
FROM tree
ORDER BY 단계, 번호;
