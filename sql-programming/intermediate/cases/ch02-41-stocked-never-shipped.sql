-- 2장 «도전하기» problem 3 해설 — 원장 기록은 있는데 출고가 없는 책
SELECT count(*) AS 권수
FROM books
WHERE EXISTS (
    SELECT 1
    FROM stock_movements
    WHERE stock_movements.book_id = books.book_id
)
    AND NOT EXISTS (
        SELECT 1
        FROM stock_movements
        WHERE stock_movements.book_id = books.book_id
            AND stock_movements.reason = '출고'
    );

SELECT books.book_id AS 도서번호, books.title AS 제목, books.stock AS 재고
FROM books
WHERE EXISTS (
    SELECT 1
    FROM stock_movements
    WHERE stock_movements.book_id = books.book_id
)
    AND NOT EXISTS (
        SELECT 1
        FROM stock_movements
        WHERE stock_movements.book_id = books.book_id
            AND stock_movements.reason = '출고'
    )
ORDER BY books.book_id
LIMIT 5;
