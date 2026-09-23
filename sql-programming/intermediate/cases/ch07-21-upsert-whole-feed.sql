-- runner: reset
-- 7장 7.2 «따라 하기» 5단계: 피드 전체를 걸러 책마다 최신 한 줄만 반영한다
WITH clean AS (
    SELECT
        book_id,
        supplier_price,
        supplier_stock,
        received_at,
        row_number() OVER (
            PARTITION BY book_id
            ORDER BY feed_date DESC, feed_id DESC
        ) AS 최신순
    FROM supplier_feed
    WHERE supplier_price > 0
        AND EXISTS (
            SELECT 1 FROM books WHERE books.book_id = supplier_feed.book_id
        )
)
INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
SELECT book_id, supplier_price, supplier_stock, received_at
FROM clean
WHERE 최신순 = 1
ON CONFLICT (book_id) DO UPDATE
SET supplier_price = EXCLUDED.supplier_price,
    supplier_stock = EXCLUDED.supplier_stock,
    updated_at = EXCLUDED.updated_at;

SELECT count(*) AS 공급현황줄수 FROM book_supply;

SELECT book_id, supplier_price, supplier_stock, updated_at
FROM book_supply
WHERE book_id IN (2, 19)
ORDER BY book_id;
