-- runner: reset
-- 7장 «연습하기» exercise 3 해설: 09-01 피드에서 쓸 수 있는 줄만 골라 UPSERT
WITH usable AS (
    SELECT
        book_id,
        supplier_price,
        supplier_stock,
        received_at,
        row_number() OVER (PARTITION BY book_id ORDER BY feed_id DESC) AS 줄번호
    FROM supplier_feed
    WHERE feed_date = '2026-09-01'
        AND supplier_price > 0
        AND EXISTS (
            SELECT 1 FROM books WHERE books.book_id = supplier_feed.book_id
        )
),
upserted AS (
    INSERT INTO book_supply (
        book_id, supplier_price, supplier_stock, updated_at
    )
    SELECT book_id, supplier_price, supplier_stock, received_at
    FROM usable
    WHERE 줄번호 = 1
    ON CONFLICT (book_id) DO UPDATE
    SET supplier_price = EXCLUDED.supplier_price,
        supplier_stock = EXCLUDED.supplier_stock,
        updated_at = EXCLUDED.updated_at
    RETURNING OLD.book_id AS 예전
)
SELECT
    count(*) AS 처리한책,
    count(*) FILTER (WHERE 예전 IS NULL) AS 새로넣은책,
    count(*) FILTER (WHERE 예전 IS NOT NULL) AS 고친책
FROM upserted;
