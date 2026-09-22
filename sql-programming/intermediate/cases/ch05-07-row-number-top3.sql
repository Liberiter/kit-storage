-- 5장 5.1 «왜 그럴까요»: row_number 로 자르면 분야마다 딱 세 권이 남는다
WITH ranked AS (
    SELECT
        category AS 분야,
        title AS 제목,
        price AS 가격,
        row_number() OVER (PARTITION BY category ORDER BY price DESC, book_id)
            AS 순위
    FROM books
)
SELECT 분야, 순위, 제목, 가격
FROM ranked
WHERE 순위 <= 3
ORDER BY 분야, 순위;
