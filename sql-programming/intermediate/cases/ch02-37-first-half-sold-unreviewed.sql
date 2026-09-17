-- 2장 «복습 exercise» 2 해설 (앞 코스 8장 — 다중 조인)
SELECT count(*) AS 권수
FROM books
WHERE NOT EXISTS (
    SELECT 1 FROM reviews WHERE reviews.book_id = books.book_id
)
    AND EXISTS (
        SELECT 1
        FROM order_items
        INNER JOIN orders ON order_items.order_id = orders.order_id
        WHERE order_items.book_id = books.book_id
            AND orders.order_date BETWEEN '2026-01-01' AND '2026-06-30'
    );
