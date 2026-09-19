-- 3장 3.2 «practice» 1: 분류 트리를 단계와 함께 펼친다
WITH RECURSIVE category_tree AS (
    SELECT category_id, name, 1 AS 단계
    FROM categories
    WHERE parent_id IS NULL
    UNION ALL
    SELECT
        categories.category_id,
        categories.name,
        category_tree.단계 + 1
    FROM categories
    INNER JOIN category_tree
        ON categories.parent_id = category_tree.category_id
)
SELECT 단계, name AS 분류
FROM category_tree
ORDER BY 단계, category_id;
