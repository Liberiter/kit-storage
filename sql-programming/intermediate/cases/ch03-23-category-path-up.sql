-- 3장 3.2 «practice» 2: 요리 분류에서 최상위까지 거슬러 오른다
WITH RECURSIVE category_path AS (
    SELECT category_id, name, parent_id, 1 AS 단계
    FROM categories
    WHERE name = '요리'
    UNION ALL
    SELECT
        categories.category_id,
        categories.name,
        categories.parent_id,
        category_path.단계 + 1
    FROM categories
    INNER JOIN category_path
        ON categories.category_id = category_path.parent_id
)
SELECT 단계, name AS 분류
FROM category_path
ORDER BY 단계;
