-- smoke: 재귀 CTE — 분류 트리를 깊이·경로와 함께 펼치고 말단별 책 수를 붙인다 (3장 요구 예시)
WITH RECURSIVE tree AS (
    SELECT category_id, name, parent_id, 1 AS depth, name AS path
    FROM categories
    WHERE parent_id IS NULL
    UNION ALL
    SELECT c.category_id, c.name, c.parent_id, t.depth + 1, t.path || ' > ' || c.name
    FROM categories c
    JOIN tree t ON c.parent_id = t.category_id
)
SELECT t.depth, t.path, count(b.book_id) AS books
FROM tree t
LEFT JOIN books b ON b.category = t.name
GROUP BY t.depth, t.path
ORDER BY t.path;
